function datafit()
% load data from the .mat file extracted by function dataExtract
% run algrithm to fit the data
root='D:\firefoxDownload\matlab\dataset2012\dataset';
% layernum=3;
pathlist1=dir(root);
filenum1=length(pathlist1);
filenamelist1={pathlist1.name};

layers={};
layers(8,8)={10};
hits=zeros(8,8,1000);
for i=3:filenum1
%    if(i<6)
%        continue;
%    end
   pathlist2=dir([root,'\',filenamelist1{i}]);
   filenum2=length(pathlist2);
   filenamelist2={pathlist2.name};
   for j=3:filenum2
%        if(i==6&&j<4)
%           continue;
%        end
       path=[root,'\',filenamelist1{i},'\',filenamelist2{j}];
       filename=path2filename(path);
%        fullname=['mat\',filename];
       data=load(filename);
%      save(path2filename(path),'roipoint','rgb','class','path');
        [layer,hit]=fit(data.rgb,data.class,filename,i,j);
        len=length(hit);
        len=min(size(hits),len);
        hits(i-2,j-2,1:len)=hit(1:len);
        layers(i-2,j-2)={layer};
       break;
   end
   break;
end
save('datafit.mat','layers','hits');

% path2filename
function filename=path2filename(path)
root='D:\firefoxDownload\matlab\dataset201*\dataset\';
start=length(root);
shortpath=path(start+1:end);
filename=strrep(shortpath,'\','-');
filename=[filename,'.mat'];

function [layer,hit]=fit(rgb,class,filename,ii,jj)
% fit the rgb.

foregroundRadio=0.3;
% c: channel, d: frameNum
[a,b,c,d]=size(rgb);

layer=struct(...
'max',zeros(a,b,1,'uint8'),...
'min',zeros(a,b,1,'uint8'),...
'fc',zeros(a,b,'uint8'),...
'bc',zeros(a,b,'uint8'),...
'pmin',zeros(a,b,c,'double'),...
'pmax',zeros(a,b,c,'double'),...
'pminnum',zeros(a,b),...
'pmaxnum',zeros(a,b),...
'frameNum',0);

hit=zeros(1,d);
%gray pic
if(c==1)

%rgb pic
else  
    for i=2:d
        if(i==2)%init layer
            layer.max=max(rgb(:,:,1,1:2),[],4);
            layer.min=min(rgb(:,:,1,1:2),[],4);
            dif=rgb(:,:,:,2)-rgb(:,:,:,1);
            dif=sum(dif.^2,3);
            dif=dif(:);
%             foregroundRadio,第一帧中前景的比例。
            threshold=prctile(dif,1-foregroundRadio);
            idx=dif>threshold;
            mask=idx;
            
            layer.fc(idx)=1;
            rmax=max(rgb(:,:,1,1:2),[],4);
            rmaxidx1=(rgb(:,:,1,1)==rmax);
%             rmaxidx2=(rgb(:,:,1,2)==rmax);
            y=zeros(a,b,1,1);
            
            for j=1:3
                rgb1=rgb(:,:,j,1);
                rgb2=rgb(:,:,j,2);
                y(rmaxidx1)=rgb1(rmaxidx1);
                y(~rmaxidx1)=rgb2(~rmaxidx1);
                layer.pmax(:,:,j)=y;
                
                layer.pmin(:,:,j)=rgb1+rgb2-y;
            end
            layer.pmaxnum(:)=1;
            layer.pminnum(:)=1;
            layer.frameNum=2;
        else
            [fmask,bmask,mask]=predict(layer,rgb(:,:,:,i));
            layer=update(layer,fmask,bmask,mask,rgb(:,:,:,i));
        end
        
%         if(ii==3&&jj==3)
%             display(i);
%             
%             load record.mat;
%             if(sum(layer.pmax(3,3,:))~=sum(recordmax(:,i)))
%                 display(layer.pmax(3,3,:));
%             end
%             
%             if(layer.pmaxnum(3,3)~=recordmaxnum(i))
%                display(layer.pmaxnum(3,3)); 
%             end
%             
%             if(sum(layer.pmin(3,3,:))~=sum(recordmin(:,i)))
%                display(layer.pmin(3,3,:)); 
%             end
%             
%             if(layer.pminnum(3,3)~=recordminnum(i))
%                display(layer.pminnum(3,3)); 
%             end
%         else
%             break;
%         end
        
        a=mask(:);
        b=class(:,:,1,i);
        b=b(:);
        hit(i)=sum(~xor(a,b));
    end
end

function [fmask,bmask,mask]=predict(layer,rgb)
% predict forground mask

p=(layer.pmax+layer.pmin)/2;
v=layer.pmax-layer.pmin;
for i=3:-1:1
    p(:,:,i)=p(:,:,i)-p(:,:,1);
    v(:,:,i)=v(:,:,i)./v(:,:,1);
end

r=rgb(:,:,1,1);
[a,b,~,~]=size(rgb);
% pre=zeros(a,b,c,1);
% pre(:,:,1,1)=r;
% pre(:,:,2,1)=r*v(2)+p(2);
% pre(:,:,3,1)=r*v(3)+p(3);
% 
% dif=rgb-pre;
% dif=sum(dif.^2,3);
upidx=r>layer.max;
downidx=r<layer.min;
% mididx=(~upidx)&(~downidx);

midpoint(:,:,1)=r;
midpoint(:,:,2)=r*v(2)+p(2);
midpoint(:,:,3)=r*v(3)+p(3);

uppoint(:,:,1)=layer.max;
uppoint(:,:,2)=layer.max*v(2)+p(2);
uppoint(:,:,3)=layer.max*v(3)+p(3);

downpoint(:,:,1)=layer.min;
downpoint(:,:,2)=layer.min*v(2)+p(2);
downpoint(:,:,3)=layer.min*v(3)+p(3);

prepoint=midpoint;
prepoint(upidx)=uppoint(upidx);
prepoint(upidx+a*b)=uppoint(upidx+a*b);
prepoint(upidx+2*a*b)=uppoint(upidx+2*a*b);
prepoint(downidx)=downpoint(downidx);
prepoint(downidx+a*b)=downpoint(downidx+a*b);
prepoint(downidx+2*a*b)=downpoint(downidx+2*a*b);

dif=rgb-prepoint;
dif=sum(dif.^2,3);

mask=dif>25;
fcmask=layer.fc>2;
bcmask=layer.bc>2;
fmask=mask&fcmask&(~bcmask);
fmask=bwareaopen(fmask,5);
bmask=mask&(~fcmask)&bcmask;
bmask=bwareaopen(bmask,5);

function layer=update(layer,fmask,bmask,mask,rgbi)
[a,b,~]=size(rgbi);

layer.max=max(layer.max,rgbi(:,:,1));
layer.min=min(layer.min,rgbi(:,:,1));

layer.fc(mask)=layer.fc(mask)+1;
layer.fc(~mask)=0;
layer.bc(~mask)=layer.bc(~mask)+1;
layer.bc(mask)=0;

pmaxidx=rgbi(:,:,1)>layer.pmax(:,:,1);
pminidx=rgbi(:,:,1)<layer.pmin(:,:,1);

idx=layer.pminnum<layer.pmaxnum;
midminidx=idx&(~pmaxidx)&(~pminidx);
midmaxidx=(~idx)&(~pmaxidx)&(~pminidx);

pmaxidx=pmaxidx|midmaxidx;
pminidx=pminidx|midminidx;

andsum=sum(sum(pmaxidx&pminidx));
orsum=sum(sum(pmaxidx|pminidx));
if(andsum~=0||orsum~=a*b)
   disp('error andsum,orsum in datafit'); 
end

% 用概率更新未知区域umask（即不是强前景fmask，也不是强背景bmask）
% 可能是动态背景，或者运动前景
umask=(~fmask)&(~bmask);
ran=rand(size(umask));
ran=ran>0.5;
% 随机地假设背景
ran=ran&umask;  

pmaxidx=(pmaxidx&bmask)|ran;
pminidx=(pminidx&bmask)|ran;


layer.pmaxnum(pmaxidx)=layer.pmaxnum(pmaxidx)+1;
layer.pmax=updatepmaxmin(layer.pmax,pmaxidx,rgbi);

layer.pminnum(pminidx)=layer.pminnum(pminidx)+1;
layer.pmin=updatepmaxmin(layer.pmin,pminidx,rgbi);

layer.frameNum=layer.frameNum+1;
% if(sum(sum(layer.pminnum+layer.pmaxnum-layer.frameNum))~=0)
%     disp('error pminnum,pmaxnum in datafit');
% end

function pmaxmin=updatepmaxmin(pmaxmin,idx,rgbi)
[a,b,c]=size(rgbi);
idx=find(idx);
for i=0:c-1
    pmaxmin(idx+a*b*i)=pmaxmin(idx+a*b*i)*0.95+rgbi(idx+a*b*i)*0.05;
end
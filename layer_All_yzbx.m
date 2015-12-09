function layer_All_yzbx()
% layerUpdate_yzbx()
% tmp3()-->getVecgapMask()
% ...... find in lyaerUpdate_yzbx()

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
h=figure;
set(h,'numberTitle','off');
set(h,'HandleVisibility','on');
v=ones(0,4);
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
       
       pathlist3=dir([path,'\input']);
       filenum3=length(pathlist3);
       filenamelist3={pathlist3.name};
       
       pathlist4=dir([path,'\groundtruth']);
       filenamelist4={pathlist4.name};
       filename=path2filename(path);
       
       filename=path2filename(path);
       data=load(filename);
       roipoint=data.roipoint;
       
       roiframeNum=load([path,'\temporalROI.txt']);
       frameNum=0;
       for k=roiframeNum(1)+2:roiframeNum(2)+2
          frameNum=frameNum+1;
          frame=imread([path,'\input\',filenamelist3{k}]); 
          class=imread([path,'\groundtruth\',filenamelist4{k}]);
          
          if(frameNum<=2)
              if(frameNum==1)
                 oldframe=frame; 
              else
                  layer=initlayer(oldframe,frame);
              end
          else
              [fmask,bmask,mask]=predict(layer,frame);
              layer=update(layer,frame);
              
              set(h,'Name',[num2str(k),'/',num2str(roiframeNum(2)+2)]);
              subplot(2,4,1,'replace'),imshow(frame),title('input');
              subplot(2,4,2,'replace'),imshow(class),title('groundtruth');
              subplot(2,4,3,'replace'),imshow(mask),title('mask');
              subplot(2,4,4,'replace'),imshow(fmask),title('fmask');
              subplot(2,4,5,'replace'),imshow(bmask),title('bmask');
              
              adaptimg=adapt_yzbx(abs(uint8(layer.mean)-frame));
              adaptmask=true(size(mask));
              for xi=1:3
                 adaptmask=adaptmask&(adaptimg(:,:,xi)>100); 
              end
              subplot(2,4,6,'replace'),imshow(uint8(layer.max)),title('layer.max');
              for xi=1:3
                 adaptmask=adaptmask&(adaptimg(:,:,xi)>200); 
              end
              subplot(2,4,7,'replace'),imshow(uint8(layer.min)),title('layer.min');
              subplot(2,4,8,'replace'),imshow(adaptimg),title('adaptimg');
              pause(0.1);
              
              vec=layer.pmaxSetMean-layer.pminSetMean;
              for xi=3:-1:1
                 vec(:,:,xi)=vec(:,:,xi)./vec(:,:,1); 
              end
            
              v(end+1,1)=max(max(vec(:,:,2),[],2),[],1);
              v(end,2)=min(min(vec(:,:,2),[],2),[],1);
              v(end,3)=max(max(vec(:,:,3),[],2),[],1);
              v(end,4)=min(min(vec(:,:,3),[],2),[],1);
          end
            
%           [layer,hit]=fit(frame,class,filename,i,j);
%           len=length(hit);
%           len=min(size(hits),len);
%           hits(i-2,j-2,1:len)=hit(1:len);
%           layers(i-2,j-2)={layer};
       end
       
%        fullname=['mat\',filename];
%        
%      save(path2filename(path),'roipoint','rgb','class','path');
        
       break;
   end
   break;
end
save('datafit.mat','layers','hits');
save('tmp.mat','v');

% path2filename
function filename=path2filename(path)
root='D:\firefoxDownload\matlab\dataset201*\dataset\';
start=length(root);
shortpath=path(start+1:end);
filename=strrep(shortpath,'\','-');
filename=[filename,'.mat'];


function [layer]=initlayer(oldrgb,rgb)
[a,b,c]=size(rgb);

% max, the max value in pixel history.
% min, the min value in pixel history.
% mask1=(frame<max+gap))&(frame>(min-gap))
% gap, the gap between layer.mean and pixel.
% mean, the mean value in pixel history.
% rangeratio, the ratio for range=(max-min+2*gap)
% mask2=(frame-mean)>(max-min+2*gap).*rangeratio
% fc, foreground counter, update by formula fc=fc+mask;
% fmask=fc>3 
% bc, background counter. update by formula bc=bc+(~mask);
% bmask=bc>3, mask mean foregroundmask, bmask mean background mask;
% pminSetMean, smaller pixel set's mean. (pixel-mean)>(10,10,10)
% pmaxSetMean, bigger pixel set's mean.  (mean-pixel)>(10,10,10)
% pminSetMean and pmaxSetMean wanted to save the pixel history, then
% count a better vector for 'fitting line' than mean.
% pminnum, the number of smaller pixel set.
% pmaxnum, the number of bigger pixel set.
% to use pmaxSetMean and pminSetMean, we need pminnum>0 and pmaxnum>0
% vecgap, the vector gap for (pmaxSetMean,pminSetMean) and mean 
% mask3=cross(frame,vector)>vecgap
% minvecgap, the minimal vecgap.
% mmgnoise, maxmingap noise for mask1
% mmrnoise, maxminratio noise for mask2
% vecnoise, vector noise for mask3
% gapinc, the increase step for gap update. gap=gap+dif+gapinc;
% bw1, bw1 is the mask history, update by bw1=mask

layer=struct(...
'max',zeros(a,b,c,'double'),...
'min',zeros(a,b,c,'double'),...
'gap',ones(a,b,c,'double')*5,...
'mean',zeros(a,b,c,'double'),...
'rangeratio',zeros(a,b,c,'double'),...
'fc',zeros(a,b,'uint32'),...
'bc',ones(a,b,'uint32'),...
'pminSetMean',zeros(a,b,c,'double'),...
'pmaxSetMean',zeros(a,b,c,'double'),...
'pminnum',zeros(a,b,'uint32'),...
'pmaxnum',zeros(a,b,'uint32'),...
'vecgap',ones(a,b,'double')*0.1,...
'minvecgap',0.1,...
'mmgnoise',zeros(1,2,'double'),...
'mmrnoise',zeros(1,2,'double'),...
'vecnoise',zeros(1,2,'double'),...
'gapinc',5,...
'bw1',false(a,b),...
'frameNum',2);

if(c==1)
    disp('expect rgb pic');
else
%     layer.max=max(rgb(:,:,1),oldrgb(:,:,1))+gap;
%     layer.min=min(rgb(:,:,1),oldrgb(:,:,1))-gap;
%     layer.max=max(rgb,oldrgb);
%     layer.min=min(rgb,oldrgb);
%     layer.mean=double(rgb+oldrgb)/2;
    layer.max=double(oldrgb);
    layer.min=double(oldrgb);
    layer.mean=double(oldrgb);
    layer=layerUpdate_yzbx(layer,rgb);
%     layer.gap=1.3*max(abs(double(rgb)-layer.mean),...
%         abs(double(oldrgb)-layer.mean));
    
%     init fail will happend forever!!!
%     rmax=max(rgb(:,:,1),oldrgb(:,:,1));
%     rmaxidx1=(oldrgb(:,:,1)==rmax);
%     y=zeros(a,b,1);
%     for j=1:3
%         rgb1=double(oldrgb(:,:,j));
%         rgb2=double(rgb(:,:,j));
%         y(rmaxidx1)=rgb1(rmaxidx1);
%         y(~rmaxidx1)=rgb2(~rmaxidx1);
%         layer.pmaxSetMean(:,:,j)=y;
% 
%         layer.pminSetMean(:,:,j)=rgb1+rgb2-y;
%     end

%     layer.pmaxSetMean=double(max(oldrgb,rgb));
%     layer.pminSetMean=double(min(oldrgb,rgb));
end


function [layer,hit]=fit(rgb,class,filename,ii,jj)
% fit the rgb.

foregroundratio=0.3;
% c: channel, d: frameNum
[a,b,c,d]=size(rgb);

% pmaxnum: the number of pmaxSet(big 'r value' set).
% pminnum: the number of pminSet(small 'r value' set).
layer=struct(...
'max',zeros(a,b,1,'uint8'),...
'min',zeros(a,b,1,'uint8'),...
'fc',zeros(a,b,'uint8'),...
'bc',zeros(a,b,'uint8'),...
'pminSetMean',zeros(a,b,c,'double'),...
'pmaxSetMean',zeros(a,b,c,'double'),...
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
%             foregroundratio,第一帧中前景的比例。
            threshold=prctile(dif,1-foregroundratio);
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
                layer.pmaxSetMean(:,:,j)=y;
                
                layer.pminSetMean(:,:,j)=rgb1+rgb2-y;
            end
            layer.pmaxnum(:)=1;
            layer.pminnum(:)=1;
            layer.frameNum=2;
        else
            [fmask,bmask,mask]=predict(layer,rgb(:,:,:,i));
            layer=update(layer,fmask,bmask,mask,rgb(:,:,:,i));
        end
       
        a=mask(:);
        b=class(:,:,1,i);
        b=b(:);
        hit(i)=sum(~xor(a,b));
       
    end
end


function [fmask,bmask,mask]=predict(layer,frame)
% predict forground mask
mmgmask=maxminGapLayerFilter_yzbx(frame,layer.max,layer.min,layer.gap);
rrmmask=ratioLayerFilter_yzbx(frame,layer.max,layer.min,layer.gap,layer.rangeratio,layer.mean);
vecMask=getVectorMask_yzbx(frame,layer.mean,layer.pmaxnum,layer.pminnum);
vmask=vectorLayerMask_yzbx(frame,vecMask,layer.pminSetMean,layer.pmaxSetMean,layer.mean,layer.vecgap);

fmask=mmgmask;
[bmask,dif]=tmp3(layer,frame);
mask=dif>layer.vecgap;
% fmask=(layer.fc>2);
% bmask=(layer.bc>2);
% fmask=bwareaopen(fmask,5);
% bmask=bwareaopen(bmask,5);

function layer=update(layer,frame)
    layer=layerUpdate_yzbx(layer,frame);
% % pmaxidx 大于背景像素上界的索引
% % pminidx 小于背景像素下界的索引
% pmaxidx=rgbi(:,:,1)>layer.pmaxSetMean(:,:,1);
% pminidx=rgbi(:,:,1)<layer.pminSetMean(:,:,1);
% 
% % midminidx 背景像素范围中，应分配到‘下界集合’的索引
% % midmaxidx 背景像素范围中，应分配到‘上界集合’的索引
% idx=layer.pminnum<layer.pmaxnum;
% midminidx=idx&(~pmaxidx)&(~pminidx);
% midmaxidx=(~idx)&(~pmaxidx)&(~pminidx);
% 
% % pmaxidx 0-255的像素范围内，应分配到‘上界集合’的索引
% % pminidx 0-255的像素范围内，应分配到‘下界集合’的索引
% pmaxidx=pmaxidx|midmaxidx;
% pminidx=pminidx|midminidx;

% 一个像素，要么分配到‘上界集合’，要么分配到‘下界集合’。
% andsum=sum(sum(pmaxidx&pminidx));
% orsum=sum(sum(pmaxidx|pminidx));
% if(andsum~=0||orsum~=a*b)
%    disp('error andsum,orsum in datafit'); 
% end

% 用概率更新未知区域umask（即不是强前景fmask，也不是强背景bmask）
% 可能是动态背景，或者运动前景
% umask=(~fmask)&(~bmask);
% ran=rand(size(umask));
% ran=ran>0.7;
% 随机地假设部分’弱前景‘为’随机背景‘。
% ran=ran&umask&mask;  

% 对强背景bmask进行alpha=0.05的背景更新，极少有前景
% 对弱背景~mask进行alpha=0.03的背景更新,可能有前景
% 对随机背景ran进行alpha=0.01的背景更新，可能有背景
% ran&(~mask)=ran&bmask=0, but bmask=(~mask)&(~fcmask)&bcmask;


function pmaxmin=updatepmaxmin(pmaxmin,idx,rgbi,alpha)
[a,b,c]=size(rgbi);
idx=find(idx);
for i=0:c-1
    pmaxmin(idx+a*b*i)=double(pmaxmin(idx+a*b*i))*(1-alpha)+double(rgbi(idx+a*b*i))*alpha;
end
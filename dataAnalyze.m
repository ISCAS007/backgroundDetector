%拟合分析根目录dataset2014,dataset2012下的所有数据
% dataset2014 包含dataset2012, 但新加的视频类groundtruth只提供前面一半
% groundtruth 有5类
% outside roi=85,unknown=170,motion=255,hard shadow=50,static=0
% 突然停止的目标将逐渐融入背景
function dataAnalyze()
root='D:\firefoxDownload\matlab\dataset2012\dataset';
% layernum=3;
pathlist1=dir(root);
filenum1=length(pathlist1);
filenamelist1={pathlist1.name};
polys=zeros(6,10,10);
results=zeros(8,10,10);
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
        [poly,result]=analyze(data.rgb,data.class,filename,i,j);
        polys(:,i,j)=poly(:);
        results(:,i,j)=result;
%        break;
   end
end
save('analyze.mat','polys','results');
showAnalyze(polys,results,filenamelist1);

function [poly,result]=analyze(rgb,class,filename,i,j)
% analyze rgb and class
% the first data is error classied.
[~,~,c,d]=size(rgb);
%     outroi=find(class(3,3,1,:)==85);
unknown=find(class(3,3,1,:)==170);
motion=find(class(3,3,1,:)==255);
shadow=find(class(3,3,1,:)==50);
static=find(class(3,3,1,:)==0);

if(isempty(unknown))
   unknown=1; 
end
if(isempty(motion))
    disp([i,j]);
    disp(filename);
    motion=1;
end
if(isempty(shadow))
    shadow=1;
end
if(isempty(static))
    shadow=1;
end

if(c==1)
   r=zeros(1,d);
   r(:)=rgb(3,3,1,:);
    
   h=figure('Name',[filename,'-gray']);
   scatter(1:d,r(static),3);
   hold on,scatter(1:d,r(unknown),3);
   scatter(1:d,r(motion),3);
   scatter(1:d,r(shadow),3);
   legend('static','unknown','motion','shadow'),title([filename,'-gray']);
   saveas(h,filename(1:end-4),'jpg');
   
   poly=[0,mean(r(static)),0,1,0,0];
   result=zeros(1,8);
else
    r=zeros(1,d);
    g=zeros(1,d);
    b=zeros(1,d);
    r(:)=rgb(3,3,1,:);
    g(:)=rgb(3,3,2,:);
    b(:)=rgb(3,3,3,:);

%     h=figure,scatter(r(static),g(static),3),title([filename,'-r,g']);
%     hold on,scatter(r(unknown),g(unknown),3);
%     scatter(r(motion),g(motion),3);
%     scatter(r(shadow),g(shadow),3);
%     legend('static','unknown','motion','shadow');
%     saveas(h,[filename(1:end-4),'-rg'],'jpg');
%     
%     rr=r;gg=g;bb=b;
%     r=gg;g=bb;
%     h=figure,scatter(r(static),g(static),3),title([filename,'-g,b']);
%     hold on,scatter(r(unknown),g(unknown),3);
%     scatter(r(motion),g(motion),3);
%     scatter(r(shadow),g(shadow),3);
%     legend('static','unknown','motion','shadow');
%      saveas(h,[filename(1:end-4),'-gb'],'jpg');
%     
%     r=bb;g=rr;
%     h=figure,scatter(r(static),g(static),3),title([filename,'-b,r']);
%     hold on,scatter(r(unknown),g(unknown),3);
%     scatter(r(motion),g(motion),3);
%     scatter(r(shadow),g(shadow),3);
%     legend('static','unknown','motion','shadow');
%     saveas(h,[filename(1:end-4),'-br'],'jpg');
    
    h=figure('Name',[filename,'-r,g,b']);
    scatter3(r(static),g(static),b(static),3);title([filename,'-r,g,b']);
    hold on,scatter3(r(unknown),g(unknown),b(unknown),3);
    scatter3(r(motion),g(motion),b(motion),3);
    scatter3(r(shadow),g(shadow),b(shadow),3);
    
    
    
    p=linefit3d(r(static),g(static),b(static));
    pre=p(4:6)'*r+p(1:3)'*ones(size(r));
    dif=sum(abs(pre-[r;g;b]),1);

%     计算光照强度带来的差别,difab为超出背景像素范围后的差别计算    
    minsr=min(r(static));
    a=p(4:6)*minsr+p(1:3);
    pre=a'*ones(size(r));
    difa=sum(abs(pre-[r;g;b]),1);
    
    maxsr=max(r(static));
    a=p(4:6)*maxsr+p(1:3);
    pre=a'*ones(size(r));
    difb=sum(abs(pre-[r;g;b]),1);
    
    difab=min(difa,difb);
    idx1=find(r<maxsr);
    idx2=r(idx1)>minsr;
    idx=idx1(idx2);
    
    difab(idx)=dif(idx);
%     考虑光照强度信息 consider lighting information
    dif=difab;
%   注释可忽略光照强度信息
    
    maxstatic=max(dif(static));
    lengthstatic=length(static);
    minmotion=min(dif(motion));
    lengthmotion=length(motion);
    result=[mean(dif(static)),max(dif(static)),lengthstatic,...
        mean(dif(motion)),min(dif(motion)),lengthmotion,...
        sum(dif(static)>=minmotion)/lengthstatic,...
        sum(dif(motion)<=maxstatic)/lengthmotion];
    
    
    x=min(50,min(r(static))):max(200,max(r(static)));
    y=p(2)+x*p(5);
    z=p(3)+x*p(6);
    plot3(x,y,z,'red');
    legend('static','unknown','motion','shadow','fit line');
    
    saveas(h,[filename(1:end-4),'-rgb'],'jpg');
%     r=rr;
%     h=figure,scatter(static,r(static),5,'red'),title([filename,'-r_static']);
%     hold on,plot(1:d,r);
%     legend('static','r');
%     saveas(h,[filename,'-r_static'],'jpg');
%     
%     h=figure,scatter(motion,r(motion),5,'red'),title([filename,'-r_motion']);
%     hold on,plot(1:d,r);
%     legend('motion','r');
%     saveas(h,[filename,'-r_motion'],'jpg');
    
    poly=p;
end

% path2filename
function filename=path2filename(path)
root='D:\firefoxDownload\matlab\dataset201*\dataset\';
start=length(root);
shortpath=path(start+1:end);
filename=strrep(shortpath,'\','-');
filename=[filename,'.mat'];

function showAnalyze(polys,results,dataset2012)
% load analyze.mat;
% load dataset2012.mat;

% polys=zeros(6,10,10);
% results=zeros(8,10,10);
% result=[mean(dif(static)),max(dif(static)),size(static),...
%         mean(dif(motion)),min(dif(motion)),size(motion),...
%         sum(dif(static)>minmotion)/lengthstatic,...
%         sum(dif(motion)<maxstatic)/lengthmotion];
% poly=[0,p1(2),p2(2),1,p1(1),p2(1)];
polys=polys(:,3:end,3:end);
results=results(:,3:end,3:end);


col=zeros(1,8);
wid=60;
cfor{8}='bank';
for j=1:8
   cfor{j}='bank'; 
end
pcname={'x0','y0','z0','v1','v2','v3'};
for i=1:8
    data=polys(:,i,:);
    data=data(:);
    if(sum(data)~=0)
        data=reshape(data,6,8);
        data=data';
        col(i)=sum(data(:,4));
        figure('Name',[dataset2012{i+2},' polys']);
        t=uitable('data',data(1:col(i),:));
        set(t,'columnWidth',{wid});
        set(t,'columnFormat',cfor);
        set(t,'columnName',pcname);
        set(t,'Position',[30,30,50+6*wid,200]);
    end
end

rcname={'mean(s)','max(s)','num(s)','mean(m)','min(m)','num(m)','NN','NP'};
for i=1:8
    data=results(:,i,:);
    data=data(:);
    poly=polys(:,i,:);
    poly=poly(:);
%     对于灰度图像，results全为0
    if(sum(poly)~=0)
        data=reshape(data,8,8);
        data=data';
        data(:,7:8)=data(:,7:8)*100;
%         uitable('data',data);
        figure('Name',[dataset2012{i+2},' results']);
        t=uitable('data',data(1:col(i),:));
        set(t,'columnWidth',{wid});
        set(t,'columnFormat',cfor);
        set(t,'columnName',rcname);
        set(t,'Position',[30,30,50+8*wid,200]);
    end
end
%拟合分析根目录dataset2014,dataset2012下的所有数据
% dataset2014 包含dataset2012, 但新加的视频类groundtruth只提供前面一半
% groundtruth 有5类
% outside roi=85,unknown=170,motion=255,hard shadow=50,static=0
% 突然停止的目标将逐渐融入背景

% % % 严重有问题，各种问题，rgb的值不对。。。！
function dataAnalyze_run()
% root='D:\firefoxDownload\matlab\dataset2012\dataset';
root='D:\Program\matlab\dataset2012\dataset';
% layernum=3;
pathlist1=dir(root);
filenum1=length(pathlist1);
filenamelist1={pathlist1.name};
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
       display(filename);
%        fullname=['mat\',filename];
       data=load(filename);
	   
	   light=sum(data.rgb.^2,3);
	   light=max(light,1);
	   light=repmat(light,[1,1,3,1]);
	   data.rgb=data.rgb./light;
	   
       analyze(data.rgb,data.class,filename,i,j);
  
%        break;
   end
   break;
end

function [poly,result]=analyze(rgb,rgbclass,filename,i,j)
% analyze rgb and class
% the first data is error classied.
[~,~,c,d]=size(rgb);
%     outroi=find(class(3,3,1,:)==85);
unknown=find(rgbclass(3,3,1,:)==170);
motion=find(rgbclass(3,3,1,:)==255);
shadow=find(rgbclass(3,3,1,:)==50);
static=find(rgbclass(3,3,1,:)==0);

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
%     scatter3(r(static),g(static),b(static),3);
    scatter(static,r(static));
    title([filename,'-r,g,b']);
    hold on;
%     scatter3(r(unknown),g(unknown),b(unknown),3);
%     scatter3(r(motion),g(motion),b(motion),3);
    scatter(motion,r(motion));
%     scatter3(r(shadow),g(shadow),b(shadow),3);
    
   
    legend('static','motion');
    
%     saveas(h,[filename(1:end-4),'-rgb'],'jpg');
% 	close(h);
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
end

% path2filename
function filename=path2filename(path)
% root='D:\firefoxDownload\matlab\dataset201*\dataset\';
root='D:\Program\matlab\dataset2012\dataset\';
start=length(root);
shortpath=path(start+1:end);
filename=strrep(shortpath,'\','-');
filename=[filename,'.mat'];
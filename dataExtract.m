%拟合分析根目录dataset2014,dataset2012下的所有数据
% dataset2014 包含dataset2012, 但新加的视频类groundtruth只提供前面一半
% groundtruth 有5类
% outside roi=85,unknown=170,motion=255,hard shadow=50,static=0
% 突然停止的目标将逐渐融入背景
function dataExtract()
root='D:\firefoxDownload\matlab\dataset2012\dataset';
% layernum=3;
init();

pathlist1=dir(root);
filenum1=length(pathlist1);
filenamelist1={pathlist1.name};
for i=3:filenum1
    if(i~=6)
       continue; 
    end
   pathlist2=dir([root,'\',filenamelist1{i}]);
   filenum2=length(pathlist2);
   filenamelist2={pathlist2.name};
   for j=3:filenum2
       if(j~=4)
           continue;
       end
       disp([i,j]);
       path=[root,'\',filenamelist1{i},'\',filenamelist2{j}];
       [rgb,class]=getPointInfo(path,i,j);
   end
end

function init()
global blacklist;
global goodroimap;
    
blacklist=false(10,10);
i=[3,4,5,5,5,6,6,6,6,6];
j=[3,3,5,6,7,3,4,6,7,8];
idx=i+(j-1)*10;
blacklist(idx)=true;
goodroimap=zeros(2,10,10);

goodroimap(:,3,3)=[282,164]';%baseline-PETS2006.mat
goodroimap(:,4,3)=[109,201]';%cameraJitter-badminton.mat
goodroimap(:,5,5)=[433,354]';%dynamicBackground-fall.mat
goodroimap(:,5,6)=[213,103]';%dynamicBackground-fountain01.mat
goodroimap(:,5,7)=[187,97]';%dynamicBackground-fountain02.mat
goodroimap(:,6,3)=[233,82]';%intermittentObjectMotion-abandonedBox.mat
goodroimap(:,6,4)=[187,139]';%intermittentObjectMotion-parking.mat
goodroimap(:,6,6)=[292,60]';%intermittentObjectMotion-streetLight.mat
goodroimap(:,6,7)=[19,182]';%intermittentObjectMotion-tramstop.mat
goodroimap(:,6,8)=[44,124]';%intermittentObjectMotion-winterDriveway.mat


% 获得像素rgb以及分类信息
function [rgb,class]=getPointInfo(path,i,j)
inputpath=[path,'\input'];
inputlist=dir([path,'\input']);
groundtruthpath=[path,'\groundtruth'];
groundtruthlist=dir([path,'\groundtruth']);
roiFrameNum=load([path,'\temporalROI.txt']);

frame=imread([inputpath,'\',inputlist(3).name]);
[width,height,channel]=size(frame);
x=round(width/2);
y=round(height/2);
roiArea=imread([path,'\ROI.bmp']); 

global blacklist;
global goodroimap;

if(blacklist(i,j))
    y=goodroimap(1,i,j);
    x=goodroimap(2,i,j);
else
    if(roiArea(x,y)==0)
        a=unique(roiArea);
        if(length(a)>1)
            disp(path);
        %     roi is marked as 1 or 255
            idx=find(roiArea~=0);
        %     idx=(y-1)*height+x
            middle=idx(round(length(idx)/2));
            y=floor(middle/height)+1;
            x=middle-(y-1)*height;
            x=max(3,x);
            x=min(width-2,x);
            y=max(3,y);
            y=min(height-2,y);
        end
    end
end

rgb=zeros(5,5,channel,roiFrameNum(2)-roiFrameNum(1)+1);
class=zeros(5,5,1,roiFrameNum(2)-roiFrameNum(1)+1);
for i=roiFrameNum(1):roiFrameNum(2)
    inputframe=imread([inputpath,'\',inputlist(i).name]);
    groundtruthframe=imread([groundtruthpath,'\',groundtruthlist(i).name]);
    num=i-roiFrameNum(1)+1;
    rgb(:,:,:,num)=inputframe(x-2:x+2,y-2:y+2,:);
    class(:,:,1,num)=groundtruthframe(x-2:x+2,y-2:y+2);
end
roipoint=[x,y];
save(path2filename(path),'roipoint','rgb','class','path','i','j');


% path2filename
function filename=path2filename(path)
root='D:\firefoxDownload\matlab\dataset201*\dataset\';
start=length(root);
shortpath=path(start+1:end);
filename=strrep(shortpath,'\','-');
filename=[filename,'.mat'];
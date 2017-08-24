function ShowDynamicBackground_pic7()
root='/media/yzbx/Windows7_OS/ComputerVision/Dataset/dataset';
% datatype={'dynamicBackground'};
% subtype={'boats','canoe','fall','overpass','fountain01','fountain02'};

datatype={'shadow'};
subtype={'bungalows'};
% subtype={'backdoor','bungalows','busStation','copyMachine','cubicle','peopleInShade'};

len=length(subtype);
close all;
for i=1:len
    
    %use bungalows (x=219,y=188);
%     break;
%     path=fullfile(root,datatype{1},subtype{i});
%     roi=load(fullfile(path,'temporalROI.txt'));
%     [shadowK,frameNumK]=getshadowK(path,roi);
%     figure(i);
%     imshow(shadowK);
%     
%     imgname=[datatype{1},'-',subtype{i},'-shadow.jpg'];
%     imwrite(shadowK,imgname);

    matname=[datatype{1},'-',subtype{i},'.mat']
    data=load(matname);
    class=data.class;
    shadow=find(class(3,3,1,:)==50);
    
    if(length(shadow)<10)
       continue; 
    end
    
    showmat(data,matname,i);
    h=figure(i);
    saveas(h,[datatype{1},'-',subtype{i},'-dynamicBackground'],'jpg');
end

function showmat(data,matname,i)

rgb=data.rgb;
class=data.class;

[~,~,c,d]=size(rgb);
% outroi=find(class(3,3,1,:)==85);
unknown=find(class(3,3,1,:)==170);
motion=find(class(3,3,1,:)==255);
shadow=find(class(3,3,1,:)==50);
static=find(class(3,3,1,:)==0);

if(length(shadow)<10)
    return;
end

if(isempty(unknown))
   unknown=1; 
end
if(isempty(motion))
    disp('warning: empty motion !!!');
    disp(data.path);
    disp(data.roipoint);
    motion=2;
end
if(isempty(shadow))
    shadow=3;
end
if(isempty(static))
    static=4;
end

basename=matname(1:end-4);
figure(i)
title([basename,'-dynamicBackground'])

marktype={'>','s','o','+'};
sizetype={36,36,36,3};
colortype={'r','g','b','k'};
% plotdatas={static,motion,shadow};
plotdatas={static,shadow};
len=length(plotdatas);

for i=1:len
    pd=plotdatas{i};
    r=rgb(3,3,1,pd);
    scatter(pd,r,sizetype{i},colortype{i},marktype{i});
    hold on;
end

xlabel('times');
ylabel('G');
% legend('static','motion','shadow');
legend('static','shadow');

end

function [shadowK,frameNumK]=getshadowK(root,roi)
%        get the postion of shadow which is shadow for K times or more.
%         groundTruthPath=[root,'\groundtruth'];
    groundTruthPath=fullfile(root,'groundtruth');
    infolist=dir(groundTruthPath);
    filelist={infolist.name};
    frameNum=roi(1);
    groundTruth=getFrame(groundTruthPath,filelist,frameNum);
    [a,b]=size(groundTruth);
    shadowCount=zeros(a,b,'uint8');
    K=50;
    while frameNum<=roi(2)
       groundTruth=getFrame(groundTruthPath,filelist,frameNum);
       if(isa(groundTruth,'uint8'))
           shadow=(groundTruth==50);
           shadowCount=shadowCount+uint8(shadow);
       else
          error('error: file type isnot uint8');
       end
       shadowK=shadowCount>=K;
%            if(sum(sum(shadowK))>100)
%                break;
%            end

       frameNum=frameNum+1;
    end

    frameNumK=frameNum-roi(1);
end

function frame=getFrame(filepath,filelist,frameNum)
    frame=imread(fullfile(filepath,filelist{frameNum+2}));
end

end
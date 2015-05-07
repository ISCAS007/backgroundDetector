%use layer to detect backgroud
%write by yzbx
%the detection function change to point-wise, not region-wise;
function layerAlgrithm(inputpath,outputfilename)

%init

% filepath='E:\yzbx_programe\Matlab\Data\boats\input';
filepath=[inputpath,'\','input'];
% ROIbmp=imread([inputpath,'\ROI.bmp']);
ROIframeNum=load([inputpath,'\temporalROI.txt']);

frameNum=0;
filelist=dir(filepath);
filenum=length(filelist)-2;
filename={filelist.name};
frame=getNextFrame();
[width,height,channel]=size(frame);


trainningFrameNum=min(ROIframeNum(1),100);
startFrameNum=ROIframeNum(1)-trainningFrameNum;
frameNum=frameNum+startFrameNum;
endFrameNum=min(ROIframeNum(1)+300,ROIframeNum(2));;

layer=struct(...
'layermax',zeros(size(frame),'uint8'),...
'layermin',zeros(size(frame),'uint8'),...
'layergap',zeros(size(frame),'uint8'),...
'layerbase',double(frame),...
'rangeradio',zeros(size(frame),'double'),...
'frameNum',0);


videoPlayer = vision.VideoPlayer('Position', [840, 50, 350, 200],'Name','origin frame');
layerPlayer = vision.VideoPlayer('Position', [840, 350, 350, 200],'Name','layer frame');
ColorAmendPlayer=vision.VideoPlayer('Position',[440,350,350,200],'Name','ColorAmend frame');

layermask=zeros(width,height);
CAmask=zeros(width,height);

%check
if(filenum<2||~isa(frame,'uint8')||channel~=3)
    disp('filenum < 2 or class(frame)~=uint8 or channel~=3');
    return
end
% loop

while frameNum<min(filenum,endFrameNum)
    frame=getNextFrame();
    if(frameNum<=ROIframeNum(1))
        
        layermask=layerFilter(frame,layer);
        layer=layerUpdate(layermask,frame,layer);
        CAmask=ColorAmend(layermask,frame,layer);
        if(frameNum==ROIframeNum(1))
            save(outputfilename,'inputpath','trainningFrameNum','layer');
        end
    else
        layermask=layerFilter(frame,layer);
        CAmask=ColorAmend(layermask,frame,layer);
    end
    
    display();
end

%function define
    
    function frame=getNextFrame()
        frameNum=frameNum+1;
        frame=imread([filepath,'\',filename{frameNum+2}]);
    end
   
    function display()
        videoPlayer.step(frame);
        layerPlayer.step(mask_yzbx(frame,layermask));
        ColorAmendPlayer.step(mask_yzbx(frame,CAmask));
        imshow(layerFilter2(frame,layer));
        title('layerFilter2');
    end
end


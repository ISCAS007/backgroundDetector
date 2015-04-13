%use layer to detect backgroud
%write by yzbx
%the detection function change to point-wise, not region-wise;
function baseFunction_evaluation_yzbx()

%init
frameNum=0;
filepath='E:\yzbx_programe\Matlab\Data\boats\input';
otherpath='E:\yzbx_programe\Matlab\Data\boats\groundtruth';
filelist=dir(filepath);
otherlist=dir(otherpath);
filenum=length(filelist)-2;
filename={filelist.name};
othername={otherlist.name};
colorTransform = makecform('srgb2lab');
otherframe=[];
frame=getNextFrame();
[width,height,channel]=size(frame);

layer=struct(...
'layermax',zeros(size(frame),'uint8'),...
'layermin',zeros(size(frame),'uint8'),...
'layergap',zeros(size(frame),'uint8'),...
'layerbase',zeros(size(frame),'double'),...
'rangeradio',zeros(size(frame),'double'),...
'frameNum',0);


videoPlayer = vision.VideoPlayer('Position', [840, 50, 350, 200],'Name','origin frame');
layerPlayer = vision.VideoPlayer('Position', [840, 350, 350, 200],'Name','layer frame');
groundTruthPlayer = vision.VideoPlayer('Position', [440, 50, 350, 200],'Name','groundTruth frame');
ColorAmendPlayer=vision.VideoPlayer('Position',[440,350,350,200],'Name','ColorAmend frame');

layermask=zeros(width,height);
CAmask=zeros(width,height);

%check
if(filenum<2||~isa(frame,'uint8')||channel~=3)
    disp('filenum < 2 or class(frame)~=uint8 or channel~=3');
    return
end
% loop
trainningFrameNum=300;
startFrameNum=1900-trainningFrameNum;
frameNum=frameNum+startFrameNum;
trainningFrameNum=startFrameNum+trainningFrameNum;
endFrameNum=2100;
while frameNum<min(filenum,endFrameNum)
    frame=getNextFrame();
    if(frameNum<trainningFrameNum)
        
        layermask=layerFilter(frame,layer);
        layer=layerUpdate(layermask,frame,layer);
        
        CAmask=ColorAmend(layermask,frame,layer);
    else
        layermask=layerFilter(frame,layer);
        CAmask=ColorAmend(layermask,frame,layer);
        imshow(layerFilter2(frame,layer));
        title('layerFilter2');
    end
    
    display();
end

figure,imshow(adapt_yzbx(layer.layermax-layer.layermin));
title('range (layer.layermax-layer.layermin)');
figure,imshow(adapt_yzbx(layer.layergap));
title('layer.layergap');
%function define
    
    function frame=getNextFrame()
        frameNum=frameNum+1;
        frame=imread([filepath,'\',filename{frameNum+2}]);
        otherframe=imread([otherpath,'\',othername{frameNum+2}]);
%         frame =applycform(frame, colorTransform);
    end
   
    function display()
        videoPlayer.step(frame);
        layerPlayer.step(mask_yzbx(frame,layermask));
        ColorAmendPlayer.step(mask_yzbx(frame,CAmask));
        groundTruthPlayer.step(otherframe);
    end
end


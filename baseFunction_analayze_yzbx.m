%use framedif to detect backgroud
%write by yzbx
function baseFunction_analayze_yzbx()

%init
frameNum=0;
filepath='D:\firefoxDownload\matlab\dataset2014\dataset\dynamicBackground\boats\input';
filelist=dir(filepath);
filenum=length(filelist)-2;
filename={filelist.name};
colorTransform = makecform('srgb2lab');
frame=getNextFrame();
[width,height,channel]=size(frame);
videoPlayer = vision.VideoPlayer('Position', [840, 50, 350, 200],'Name','origin frame');

%loop
if(filenum<2||~isa(frame,'uint8')||channel~=3)
    disp('filenum < 2 or class(frame)~=uint8 ');
    return
end
wanted=[5,5;127,150;134,133;150,35;73,70;223,201]';
record=zeros(3,size(wanted,2),300);
while frameNum<300
    frame=getNextFrame();
    for i=1:size(wanted,2)
        record(:,i,frameNum)=frame(wanted(1,i),wanted(2,i),:);
    end
    
    display();
end
y=zeros(300,3);
for i=1:size(wanted,2)
    y(:,1)=record(1,i,:);
    y(:,2)=record(2,i,:);
    y(:,3)=record(3,i,:);
    title(num2str(i));
    figure,plot([1:300],y);
end
%function define
    
    function frame=getNextFrame()
        frameNum=frameNum+1;
        frame=imread([filepath,'\',filename{frameNum+2+1800}]);
        frame =applycform(frame, colorTransform);
    end
    
    function display()
        videoPlayer.step(frame);
    end
end


%use framedif to detect backgroud
%write by yzbx
function record=get_point_info(pos,pathname,maxfilenum)

%init
frameNum=0;
filelist=dir(pathname);
filenum=length(filelist)-2;
filenum=min(filenum,maxfilenum);
filename={filelist.name};
% colorTransform = makecform('srgb2lab');
frame=getNextFrame();
[width,height,~]=size(frame);
frame=frame-1;
idx=find(pos(1,:)<3);
pos(1,idx)=3;
idx=find(pos(2,:)<3);
pos(2,idx)=3;
idx=find(pos(1,:)>width-2);
pos(1,idx)=width-2;
idx=find(pos(2,:)>height-2);
pos(2,idx)=height-2;

% wanted=[5,5;127,150;134,133;150,35;73,70;223,201]';
wanted=pos;
% for i=-2:1:2
%     for j=-2:1:2
%        pos(:,end+1)=p+[i,j];
%     end
% end
record=zeros(5,5,3,size(wanted,2),filenum);
% colorTransform = makecform('srgb2lab');
    
while frameNum<filenum
    frameNum=frameNum+1;
    frame=imread([pathname,'\',filename{frameNum+2}]);
%     frame = applycform(frame, colorTransform);
    for i=1:size(wanted,2)
        record(:,:,:,i,frameNum)=frame(wanted(1,i)-2:wanted(1,i)+2,...
            wanted(2,i)-2:wanted(2,i)+2,:);
    end
end

%function define
    
    function frame=getNextFrame()
        frameNum=frameNum+1;
        frame=imread([pathname,'\',filename{frameNum+2}]);
%         frame =applycform(frame, colorTransform);
    end
end


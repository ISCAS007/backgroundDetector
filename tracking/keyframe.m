clear,clc
csvpath='D:\Program\matlab\bgslibrary_mfc\dataset\data.csv';
avipath='D:\Program\matlab\bgslibrary_mfc\dataset\video.avi';
keyframepath='D:\Program\matlab\bgslibrary_mfc\dataset\keyFrame\';

sql=csvread(csvpath,1,0);
[a,b]=size(sql);
center=zeros(a,2);
center(:,1)=sql(:,3)+sql(:,5);
center(:,2)=sql(:,4)+sql(:,6);
center=center./2;

%avi read
videoFReader = vision.VideoFileReader(avipath);
videoPlayer = vision.VideoPlayer;
frameNum=1;
% while ~isDone(videoFReader)
%     videoFrame = step(videoFReader);
%     step(videoPlayer, videoFrame);
% end

minid=min(sql(:,1));
maxid=max(sql(:,1));
id=sql(:,1);
for i=minid:maxid
    idx=(id==i);
    trajectory=center(idx,:);
    frameid=sql(idx,2);
    minframeid=min(frameid);
    maxframeid=max(frameid);
    line=zeros(1,size(trajectory,1)*2);
    line(1:2:end)=trajectory(:,1);
    line(2:2:end)=trajectory(:,2);
    
    num=find(sql(:,1)==i,1,'first');
    rect=sql(num,3:6);
    rect(3:4)=rect(3:4)-rect(1:2);
    frameid=sql(num,2);
    while(frameNum<=frameid)
        img=step(videoFReader);
        if(frameNum<frameid)
            step(videoPlayer,img);
        end
        frameNum=frameNum+1;
    end
    
    img=insertMarker(img,trajectory);
    img=insertShape(img,'Line',line);
    img=insertObjectAnnotation(img,'rectangle',rect,num2str(i));
    step(videoPlayer,img);
    
    imwrite(img,[keyframepath,num2str(i),'.png'],'png');
%     figure,plot(trajectory(:,1),trajectory(:,2)),title([num2str(i),'-',num2str(minframeid),'-',num2str(maxframeid)]);
end

release(videoPlayer);
release(videoFReader);
clear,clc

csvpath='D:\Program\matlab\bgslibrary_mfc\dataset\data.csv';
avipath='D:\Program\matlab\bgslibrary_mfc\dataset\video.avi';
keyframepath='D:\Program\matlab\bgslibrary_mfc\dataset\keyFrame\';
maskpath='D:\Program\matlab\bgslibrary_mfc\outputs\foreground\00000001.png';
sql=csvread(csvpath,1,0);
sql(:,3)=sql(:,3)+1;
% the error from matlab!!!
% sql(:,2)=sql(:,2)+14178-8507;
% newsql=floor(sql);
% newsql(:,4)=sql(:,3)+1;
% newsql(:,3)=sql(:,4);
% newsql(:,5)=sql(:,6);
% newsql(:,6)=sql(:,5);
% sql=newsql;

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

% minid=0
minid=min(sql(:,1));
maxid=max(sql(:,1));
id=sql(:,1);

[height,width]=size(imread(maskpath));
% height=1080;
% width=1920;

mask={};
keyframe={};
mask{maxid+1}=false(height,width);
keyframe{maxid+1}=zeros(height,width,3);
for i=minid:maxid
   mask{i+1}=false(height,width); 
end

minf=min(sql(:,2));
maxf=max(sql(:,2));
% if(minf~=1)
%    error('must start from 1 to fit the avi read'); 
% end
for f=minf:maxf
    idx=find(sql(:,2)==f);
%     while(frameNum<=f)
%         img=step(videoFReader);
%         if(frameNum<f)
%             step(videoPlayer,img);
%         end
%         frameNum=frameNum+1;
%     end
    system(['run.sh ',num2str(f+13)]);
    img=imread('readVideo.png');
    step(videoPlayer,img);
    
    objs=sql(idx,1);
    for j=1:length(objs)
       obj=objs(j);
       sqlidx=idx(j);
       objmask=false(height,width);
%        j,sqlidx,sql(sqlidx,:)
       objmask(sql(sqlidx,4):sql(sqlidx,6),sql(sqlidx,3):sql(sqlidx,5))=true;
       
       masks=mask{obj+1};
       if(sum(objmask&masks)==0)
          mask{obj+1}=objmask|masks;
          
          
          if(sum(mask{obj+1}-objmask)==0)
              keyframe{obj+1}=img;
          else
              frame=keyframe{obj+1};
              frame(objmask)=img(objmask);
              keyframe{obj+1}=frame;    
          end
          
       end
    end
end

for i=minid:maxid
    idx=(id==i);
    trajectory=center(idx,:);
%     frameid=sql(idx,2);
%     minframeid=min(frameid);
%     maxframeid=max(frameid);
    line=zeros(1,size(trajectory,1)*2);
    line(1:2:end)=trajectory(:,1);
    line(2:2:end)=trajectory(:,2);
    
    num=find(sql(:,1)==i,1,'first');
    rect=sql(num,3:6);
    rect(3:4)=rect(3:4)-rect(1:2);
    
    img=keyframe{i+1};
    img=insertMarker(img,trajectory);
    img=insertShape(img,'Line',line);
    img=insertObjectAnnotation(img,'rectangle',rect,num2str(i));
    step(videoPlayer,img);
    
    imwrite(img,[keyframepath,num2str(i),'.png'],'png');
%     figure,plot(trajectory(:,1),trajectory(:,2)),title([num2str(i),'-',num2str(minframeid),'-',num2str(maxframeid)]);
end

release(videoPlayer);
release(videoFReader);
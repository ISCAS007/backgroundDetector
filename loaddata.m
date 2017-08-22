filepath='D:\firefoxDownload\matlab\dataset2014\dataset\dynamicBackground\boats\input';
otherpath='D:\firefoxDownload\matlab\dataset2014\dataset\dynamicBackground\boats\groundtruth';
filelist=dir(filepath);
otherlist=dir(otherpath);
filenum=length(filelist)-2;
maxfilenum=1000;
filenum=min(filenum,maxfilenum);
filename={filelist.name};
othername={otherlist.name};
frameNum=6900;
% DynamicBackground -> boat 900-1200,6900-7900
% Dynamicbackground -> cannoe 800-1100
% Dynamicbackground -> fall
% 1450-1550,1800-1920,1970-2080,2260-2320,2390-2460,2500-4000;
% Dynamicbackground -> fountain1 1000-1180;
% Dynamicbackground -> fountain2 650-1300
% DynamicBackground -> overpass 2300-3000;

frame=getNextFrame(frameNum+100,filepath,filename);
otherframe=getNextFrame(frameNum+100,otherpath,othername);
figure,imshow(frame);
figure,imshow(otherframe);

wanted=[128,153]';
record=zeros(5,5,3,size(wanted,2),filenum);
mark=zeros(5,5,size(wanted,2),filenum);
% colorTransform = makecform('srgb2lab');
    
for j=1:filenum
    frameNum=frameNum+1;
    frame=imread([filepath,'\',filename{frameNum+2}]);
    otherframe=imread([otherpath,'\',othername{frameNum+2}]);
%     frame = applycform(frame, colorTransform);
    for i=1:size(wanted,2)
        record(:,:,:,i,j)=frame(wanted(1,i)-2:wanted(1,i)+2,...
            wanted(2,i)-2:wanted(2,i)+2,:);
        mark(:,:,i,j)=otherframe(wanted(1,i)-2:wanted(1,i)+2,...
            wanted(2,i)-2:wanted(2,i)+2);
    end
end

disp('get pos info');

[a,b,c,d,e]=size(record);

% normalize
% sum_point_info=sum(point_info,3);
% for i=1:c
%     point_info(:,:,i,:,:)=point_info(:,:,i,:,:)./sum_point_info;
% end

r=ones(1,e);
g=ones(1,e);
b=ones(1,e);
pos=1;
r(:)=record(1,1,1,pos,:);
g(:)=record(1,1,2,pos,:);
b(:)=record(1,1,3,pos,:);

figure,scatter(r(2:end),b(2:end));
for i=2:90
   text(r(i),b(i),num2str(i)); 
end

idx255=find(mark(3,3,1,:)==255);
idx170=find(mark(3,3,1,:)==170);
idx000=find(mark(3,3,1,:)==0);
scatter_size=3;
figure,scatter(r(idx000),g(idx000),scatter_size);
hold on,scatter(r(idx170),g(idx170),scatter_size),scatter(r(idx255),g(idx255),scatter_size);
legend('000背景','170阴影','255前景');
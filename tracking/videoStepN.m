% avipath='D:\Program\matlab\bgslibrary_mfc\dataset\video.avi';
% videoFReader = vision.VideoFileReader(avipath);
% videoPlayer = vision.VideoPlayer;
% for i=1:7200
%     frame=videoFReader.step();
%     videoPlayer.step(frame);
% end

while(~videoFReader.isDone())
    frame=videoFReader.step();
    videoPlayer.step(frame);
end

% obj=VideoReader(avipath);
% width=obj.Width;
% height=obj.Height;
% frame=read(obj,1);
% imshow(frame);
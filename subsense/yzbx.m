function yzbx()
frameNum=6900;
% model is background 
% 0,50=background, 170,255=foreground, 85=out roi
input1=getInput(frameNum-1);
[height,width,channel]=size(input1);
model=subsensePlusOpticalFlow();
for i=1:300
    tic;
	disp(['frameNum=',num2str(frameNum)]);
	input=getInput(frameNum);
	foreground=getForeground(frameNum);
	
	frameNum=frameNum+1;
% 	dist=lbsp(input,input1);
    subplot(2,3,1),imshow(input),title('input');
	subplot(2,3,2),imshow(foreground);
    title(num2str(frameNum,'%06d'));
    
    model=process(model,input1,input);
    subplot(2,3,3),imshow(model.foreground),title('foreground');
    subplot(2,3,4),imshow(model.Dmin ./ max(model.Dmin(:))),title('Dmin');
    subplot(2,3,5),imshow(model.V ./ max(model.V(:))),title('V');
    subplot(2,3,6),imshow(model.R ./ max(model.R(:))),title('R');
    
    input1=input;
    pause(0.1);
    
    savefilename=['fg',num2str(frameNum),'.jpg'];
    imwrite(model.foreground,savefilename);
    toc;
end

end

function input=getInput(frameNum)
% 	root='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\boats\input';
    root='/media/yzbx/软件/firefoxDownload/matlab/dataset2012/dataset/dynamicBackground/boats/input';
	strnum=num2str(frameNum,'%06d');
	input=imread([root,'/in',strnum,'.jpg']);
end

function foreground=getForeground(frameNum)
% 	root='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\boats\groundtruth';
    root='/media/yzbx/软件/firefoxDownload/matlab/dataset2012/dataset/dynamicBackground/boats/groundtruth';
	strnum=num2str(frameNum,'%06d');
	foreground=imread([root,'/gt',strnum,'.png']);
end

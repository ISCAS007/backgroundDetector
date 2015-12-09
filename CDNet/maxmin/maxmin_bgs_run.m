%% base on subsenseErrorShow
function maxmin_bgs_run()
root='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\boats';
resultPath='E:\matlab\subsense\results\dynamicBackground\boats\';

roiImg=imread([root,'\ROI.bmp']);
roiMask=(roiImg~=0);
[height,width]=size(roiMask);

fp=zeros(height,width);
fn=zeros(height,width);

groundTruthPath=[root,'\groundtruth\'];
inputPath=[root,'\input\'];

temporalROI=load([root,'\temporalROI.txt']);
temporalROI(1)=6940;
temporalROI(2)=7200;
model=[];
for frameNum=temporalROI(1):temporalROI(2)
   gt=getImg(groundTruthPath,'gt',frameNum,'.png');
   in=getImg(inputPath,'in',frameNum,'.jpg');
%    out=getImg(resultPath,'bin',frameNum,'.png');
    [model,out]=maxmin_bgs(model,in);
   
   sigma=single(rgb2gray(in));
   sigma=sigma-medfilt2(sigma,[9,9]);
   sigma=sigma.^2;
   sigma=sigma/mean(sigma(:));
   sigma=imadjust(sigma);
   
   out=(out~=0);
   out=imfill(out,'holes');
   
   fp=fp+double(gt<=50&out~=0);
   fn=fn+double(gt>=170&out==0);
   
   figure(1);
   show();
   title(num2str(frameNum));
   pause(0.5);
end

    function show()
        subplot(231);
        imshow(model.Max);
        title('model.Max');
        subplot(232);
        imshow(model.Min);
        title('model.Min');
        
        errorMask=(gt>=170)&(out==0);
        labelMask=imdilate(errorMask,strel('disk',1));
        inputSample=in;
        r=inputSample(:,:,1);
        g=inputSample(:,:,2);
        b=inputSample(:,:,3);

        r(labelMask)=255;
        g(labelMask)=0;
        b(labelMask)=0;

        inputSample(:,:,1)=r;
        inputSample(:,:,2)=g;
        inputSample(:,:,3)=b;

        subplot(233);
        imshow(inputSample);
        title('error');

        subplot(234);
        imshow(out);
        title('output result');
        
        subplot(235);
        imshow(model.MaxHitCount>=2);
        title('model.MaxHitCount>=2');
        
        subplot(236);
        imshow(gt);
        title('groundtruth');
    end
end

function img=getImg(baseDir,prefix,frameNum,suffix)
str=num2str(frameNum,'%.6d');
img=imread([baseDir,prefix,str,suffix]);
end
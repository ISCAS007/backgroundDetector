function PBASErrorShow()
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
for frameNum=temporalROI(1):temporalROI(2)
   gt=getImg(groundTruthPath,'gt',frameNum,'.png');
   in=getImg(inputPath,'in',frameNum,'.jpg');
   out=getImg(resultPath,'bin',frameNum,'.png');
   
   out=(out~=0);
   out=imfill(out,'holes');
   
   fp=fp+double(gt<=50&out~=0);
   fn=fn+double(gt>=170&out==0);
   
   show();
   title(num2str(frameNum));
   pause(0.5);
end

    function show()
        subplot(231);
        imshow(fp./max(fp(:)));
        subplot(232);
        imshow(fn./max(fn(:)));
        
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

        subplot(234);
        imshow(out);
        
        subplot(235);
        imshow(in);
        subplot(236);
        imshow(gt);
    end
end

function img=getImg(baseDir,prefix,frameNum,suffix)
str=num2str(frameNum,'%.6d');
img=imread([baseDir,prefix,str,suffix]);
end

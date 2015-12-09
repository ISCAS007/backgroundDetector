%% base on subsenseErrorShow
function subsense_improve_test()
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
for frameNum=temporalROI(1):temporalROI(2)
   gt=getImg(groundTruthPath,'gt',frameNum,'.png');
   in=getImg(inputPath,'in',frameNum,'.jpg');
   out=getImg(resultPath,'bin',frameNum,'.png');
   
   
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
   
   figure(2);
   colorNum=3;
   inputIn=repmat(gt,[1,1,3]);
   [color]=getMainKColor(in,out,colorNum);
   color=uint8(color);
   mainColorImg=zeros([100*colorNum,100*colorNum,3],'uint8');
   for i=1:colorNum
       for j=1:3
            mainColorImg(1+100*(i-1):100*i,:,j)=color(i,j);   
       end
   end
   subplot(2,2,1),imshow(mainColorImg);
   title('main color image');
end

    function show()
        subplot(231);
        imshow(fp./max(fp(:)));
        title('fp');
        subplot(232);
        imshow(fn./max(fn(:)));
        title('fn');
        
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
        imshow(sigma);
        title('space variance');
        
        subplot(236);
        imshow(gt);
        title('groundtruth');
    end
end

function img=getImg(baseDir,prefix,frameNum,suffix)
str=num2str(frameNum,'%.6d');
img=imread([baseDir,prefix,str,suffix]);
end

function [color]=getMainKColor(in,out,k)
    binWidth=5;
    num=ceil(256/binWidth);
    [height,width,c]=size(in);
    in=reshape(in,height*width,c);
    in=in(out(:)~=0,:);
    
    in=floor(in/binWidth);
    in(:,2)=in(:,2);
    in(:,3)=in(:,3);
    idx_y=[1;num+1;(num+1)^2];
    count=double(in)*idx_y;
    
    color=zeros(k,3);
    for i=1:k
        [M,F]=mode(count);
        z=floor(M/idx_y(3));
        y=floor((M-z*idx_y(3))/idx_y(2));
        x=M-z*idx_y(3)-y*idx_y(2);
        
        color(i,:)=[x,y,z];
        count=count(count~=M);
    end
    
    color=2+color*binWidth
end
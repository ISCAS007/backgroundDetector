% PBASErrorAnalyse([1500,1600]);
load('PBASErrorAnalyse.mat');
figure;
subplot(221);
imshow(fp./max(fp(:)));
subplot(222);
imshow(fn./max(fn(:)));


errorMask=errorPointImg~=0;
labelMask=imdilate(errorMask,strel('disk',1));
r=inputSample(:,:,1);
g=inputSample(:,:,2);
b=inputSample(:,:,3);

r(labelMask)=255;
g(labelMask)=0;
b(labelMask)=0;

inputSample(:,:,1)=r;
inputSample(:,:,2)=g;
inputSample(:,:,3)=b;

subplot(223);
imshow(inputSample);

subplot(224);
imshow(errorPointImg./max(errorPointImg(:)));
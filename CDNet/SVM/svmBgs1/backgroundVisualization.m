CDNetDir='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\fall';

inputDir=[CDNetDir,'\input\'];
labelDir=[CDNetDir,'\groundtruth\'];

roiFilename=[CDNetDir,'\ROI.bmp'];
roiImg=imread(roiFilename);

temporalROIFilename=[CDNetDir,'\temporalROI.txt'];
temporalROI=load(temporalROIFilename);

position=[76,139];    %±³¾°Ê÷Ò¶  std=49 scope=[-20,20]
% position=[391,91];    %±³¾°³µµÄ±íÃæ std=1 scope=[-3,3]
% position=[416,188];   %±³¾°²ÝµØ std=5 scope=[-10,10]
% position=[422,205];   %±³¾°°×ÂíÂ· std=3.6 scope=[-10,10]
% position=[459,171];   %±³¾°ºÚÂíÂ· std=3.5 scope=[-10,10]


N=100;
scope=[1000,1000+N];

data=zeros(N,4);

cform=makecform('srgb2lab');

img=getImg(inputDir,'in',1000,'.jpg');
for i=temporalROI(1):temporalROI(2)
    if(i>=scope(1)&&i<=scope(2))
        gtImg=getImg(labelDir,'gt',i,'.png');
        input=getImg(inputDir,'in',i,'.jpg');
        input=applycform(input,cform);
        data(i-scope(1)+1,1:3)=input(position(1),position(2),:);
        data(i-scope(1)+1,4)=gtImg(position(1),position(2));
    end
end
        
%         subplot(1,2,1);
%         imshow(input);
%         subplot(1,2,2);
r=data(:,1:3);
label=data(:,4);

close all;
subplot(2,2,1);
%         imshow(gtImg);
rgb=1;
y=r(label<=50,rgb);
x=find(label<=50);
scatter(x,y,3,'green');
hold on;

y2=input(label>=170,rgb);
x2=find(label>=170);
scatter(x2,y2,3,'red');

subplot(2,2,2);
normplot(y);

subplot(2,2,3);
hist(y-mean(y));

subplot(2,2,4);
normplot(y(2:end)-y(1:end-1));

out=zeros(1,3);
out(1)=std(r(label<=50,1));
out(2)=std(r(label<=50,2));
out(3)=std(r(label<=50,3));
out

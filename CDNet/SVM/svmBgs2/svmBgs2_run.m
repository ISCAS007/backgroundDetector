clear,clc;

CDNetDir='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\fall';
inputPath=[CDNetDir,'\input\'];
labelPath=[CDNetDir,'\groundtruth\'];
% inputFilename='in000001.jpg';
% groundTruthFilename='gt000001.png';
roiFilename=[CDNetDir,'\ROI.bmp'];
roiImg=imread(roiFilename);

temporalROIFilename=[CDNetDir,'\temporalROI.txt'];
temporalROI=load(temporalROIFilename);

kernel=[];
scale=0.5;
for i=temporalROI(1):temporalROI(2)
    input=getImg(inputPath,'in',i,'.jpg');
    label=getImg(labelPath,'gt',i,'.png');
    
    input=imresize(input,scale);
    
    [mask,kernel]=svmBgs2(input,kernel);
    
    gt=(label>=170);
    gt=imresize(gt,scale);
    
    pause(0.1);
    subplot(2,2,1),imshow(mask);
    subplot(2,2,2),imshow(gt);
    subplot(2,2,3),imshow(input);
    
    output=maskErrorVisulazation(mask,input,gt);
    subplot(2,2,4),imshow(output);
    
    numstr=num2str(i,'%.6d');
    imwrite(mask,['D:\firefoxDownload\matlab\dataset2012\basicBgs\result\bin',numstr,'.png'],'png');
end
featureRootDir='D:\firefoxDownload\matlab\dataset2012\PBAS_23\features-svm';
CDNetDir='D:\firefoxDownload\matlab\dataset2012\dataset\baseline\highway';
svmLearn(CDNetDir,featureRootDir);


featureRootDir='D:\firefoxDownload\matlab\dataset2012\SOBS_2_26\features-svm';
CDNetDir='D:\firefoxDownload\matlab\dataset2012\dataset\baseline\highway';
svmLearn(CDNetDir,featureRootDir);

error('if we have to train');

result=strfind(CDNetDir,'\');
datasetName=CDNetDir(result(end-1)+1:end);

featureDir=[featureRootDir,'\',datasetName,'\'];
mkdir(featureDir);

datasetName=strrep(datasetName,'\','-');
datasetName=[featureRootDir,'\',datasetName,'.mat'];

% inputPath=[CDNetDir,'\input\'];
% fgPath=[CDNetDir,'\groundtruth\'];
% inputFilename='in000001.jpg';
% groundTruthFilename='gt000001.png';
roiFilename=[CDNetDir,'\ROI.bmp'];
roiImg=imread(roiFilename);

temporalROIFilename=[CDNetDir,'\temporalROI.txt'];
temporalROI=load(temporalROIFilename);
% frameNum=1;
% fileName = num2str(frameNum, '%.6d');

[height,width]=size(roiImg);

% svmModel=train(feature,label);
% save(datasetName,'feature','label','svmModel');
data=load(datasetName);
% evaluate(data.svmModel);
svmModel=data.svmModel;

testNum=temporalROI(2)-temporalROI(1);
precision=zeros(1,testNum);
recall=zeros(1,testNum);
FMeasure=zeros(1,testNum);
TPSum=0;
TNSum=0;
FPSum=0;
FNSum=0;
for i=temporalROI(1):temporalROI(2)
    numstr=num2str(i,'%.6d');
    data=load([featureDir,numstr,'.mat']);
    %             out of memory
    %             predict=svmclassify(svmModel,data.feature);
    
    
    featureNum=size(data.feature,1);
    predict=zeros(featureNum,1);
    gap=20000;
    for j=1:gap:featureNum
        if(j+gap-1<=featureNum)
            predict(j:j+gap-1)=svmclassify(svmModel,data.feature(j:j+gap-1,:));
        else
            predict(j:featureNum)=svmclassify(svmModel,data.feature(j:featureNum,:));
        end
    end
    
    outROIIdx=data.label==85;
    predict=predict(~outROIIdx);
    label=data.label(~outROIIdx);
    
    label(label<=50)=0;
    label(label>=170)=1;
    
    
    TP=sum(and(label==1,predict==1));
    TN=sum(and(label==0,predict==0));
    FP=sum(and(label==0,predict==1));
    FN=sum(and(label==1,predict==0));
    
    TPSum=TPSum+TP;
    TNSum=TNSum+TN;
    FPSum=FPSum+TN;
    FNSum=FNSum+FN;
    
    j=i-temporalROI(1)+1;
    precision(j)=(TP+TN)/(TP+TN+FP+FN);
    
    if(TP+FN~=0)
        recall(j)=TP/(TP+FN);
    else
        recall(j)=1;
    end
    FMeasure(j)=2*precision(j)*recall(j)/(precision(j)+recall(j));
    
    fprintf('i is %d\n ..................................',i);
    fprintf('SVM :\n TP=%d \n TN=%d \n FP=%d \n FN=%d \n',...
        TP,TN,FP,FN);
    fprintf('SVM :\naccuracy = %.2f%%\n recall=%.2f%%\n FMeasure=%.2f%%\n', ...
        100*precision(j),100*recall(j),100*FMeasure(j));
end

PSum=(TPSum+TNSum)/(TPSum+TNSum+FPSum+FNSum);
RSum=TPSum/(TPSum+FNSum);
FSum=2*PSum*RSum/(PSum+RSum);
save('svmLearn.mat','precision','recall','FMeasure','PSum','RSum','FSum');

fprintf('P=%f \n R=%f \n F=%f \n',PSum,RSum,FSum);

fprintf(['max(precision)=%f \n max(recall)=%f \n',...
    'max(FMeasure)=%f \n'],max(precision),max(recall),max(FMeasure));

fprintf(['min(precision)=%f \n min(recall)=%f \n',...
    'min(FMeasure)=%f \n'],min(precision),min(recall),min(FMeasure));

fprintf(['mean(precision)=%f \n mean(recall)=%f \n',...
    'mean(FMeasure)=%f \n'],mean(precision),mean(recall),mean(FMeasure));
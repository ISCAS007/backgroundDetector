function svmBSTrain()
clc,clear

CDNetDatasetPath='D:\firefoxDownload\matlab\dataset2012\dataset\baseline\office';
result=strfind(CDNetDatasetPath,'\');
datasetName=CDNetDatasetPath(result(end-1)+1:end);
datasetName=strrep(datasetName,'\','-');
datasetName=[datasetName,'.mat'];

inputPath=[CDNetDatasetPath,'\input'];
groundTruthPath=[CDNetDatasetPath,'\groundtruth'];
% inputFilename='in000001.jpg';
% groundTruthFilename='gt000001.png';
roiFilename=[CDNetDatasetPath,'\ROI.bmp'];
temporalROIFilename=[CDNetDatasetPath,'\temporalROI.txt'];

temporalROI=load(temporalROIFilename);
% frameNum=1;
% fileName = num2str(frameNum, '%.6d');

featureNum=min(20,temporalROI(2)-temporalROI(1));
bgsStatus=[];

myfeatures=[];
labels=[];
for i=1:featureNum
    frameNum=i+temporalROI(1);
    fileName=['in',num2str(frameNum,'%.6d'),'.jpg'];
    input=imread([inputPath,'\',fileName]);
    fileName=['gt',num2str(frameNum,'%.6d'),'.png'];
    groundTruth=imread([groundTruthPath,'\',fileName]);
    
    bgsStatus=svmBS(bgsStatus,input);
    
    if(bgsStatus.Inited)
        myfeature=svmFeatureExtract(bgsStatus);
        label=groundTruth>=170;
        myfeatures=[myfeatures;myfeature];
        labels=[labels;label(:)];
    end
    
    disp('i is ...');
    disp(i);
end

save(datasetName,'myfeatures','labels');
size(labels)
% svmModel=train(myfeatures,labels);
% save('svmModel.mat','svmModel');

    function svmModel=train(feature,label)
        label=uint(label);
        [trainIdx, testIdx] = crossvalind('HoldOut',label, 1/2); % split the train and test labels 50%-50%
        idx=trainIdx;
        svmModel = svmtrain(feature(idx,:), label(idx), ...
                'BoxConstraint', Inf, 'Kernel_Function', 'rbf', 'rbf_sigma', 14.51);
        
        predTest = svmclassify(svmModel, feature(testIdx,:)); % matlab native svm function
        
        TP=sum(and(label(testIdx),predTest));
        TN=sum(and(~label(testIdx),~predTest));
        FP=sum(and(~label(testIdx),predTest));
        FN=sum(and(label(testIdx),~predTest));
        precision=(TP+TN)/(TP+TN+FP+FN);
        recall=TP/(TP+FN);
        fprintf('SVM (1-against-(n-1)):\naccuracy = %.2f%%\n recall=%.2f%%', ...
            100*precision,100*recall);
    end
end
function svmModel=graySVMBgsTrain(CDNetDir,featureRootDir)
%     featureGenerate(CDNetDir,featureRootDir);
svmModel=svmLearn(CDNetDir,featureRootDir);
end

function featureGenerate(CDNetDir,featureRootDir)
% use CDNet image dataset to generate svm features
% CDNetDir: the dir for CDNet dataset, eg: D:\firefoxDownload\matlab\dataset2012\dataset\baseline\highway
% bgsFGDir: the dir for the foreground(FG) output of background
% substraction algrithm(bgs)
% featureDir: the dir to store feature, eg:

result=strfind(CDNetDir,'\');
datasetName=CDNetDir(result(end-1)+1:end);
% bgsFGDir=[bgsFGRootDir,'\',datasetName,'\'];

featureDir=[featureRootDir,'\',datasetName,'\'];

mkdir(featureDir);

datasetName=strrep(datasetName,'\','-');
datasetName=[datasetName,'.mat'];

inputPath=[CDNetDir,'\input\'];
fgPath=[CDNetDir,'\groundtruth\'];
bgsFGDir=fgPath;
% inputFilename='in000001.jpg';
% groundTruthFilename='gt000001.png';
roiFilename=[CDNetDir,'\ROI.bmp'];
roiImg=imread(roiFilename);

temporalROIFilename=[CDNetDir,'\temporalROI.txt'];
temporalROI=load(temporalROIFilename);
% frameNum=1;
% fileName = num2str(frameNum, '%.6d');

[height,width,~]=size(roiImg);

historyNum=20;
currentNum=0;
historyInputs=zeros([height,width,1,historyNum],'uint8');
historyMasks=zeros([height,width,historyNum]);

for i=temporalROI(1):temporalROI(1)+historyNum-1
    currentNum=currentNum+1;
    historyInputs(:,:,:,currentNum)=rgb2gray(getImg(inputPath,'in',i,'.jpg'));
    historyMasks(:,:,currentNum)=getImg(bgsFGDir,'gt',i,'.png');
end

[aa,bb,cc,dd]=size(historyInputs);
for i=temporalROI(1)+historyNum:temporalROI(2)
    if(currentNum==historyNum)
        currentNum=1;
    else
        currentNum=currentNum+1;
    end
    
    historyInputs(:,:,:,currentNum)=rgb2gray(getImg(inputPath,'in',i,'.jpg'));
    historyMasks(:,:,currentNum)=getImg(bgsFGDir,'gt',i,'.png');
    
    %     feature=getFeature(historyInputs,historyMasks,currentNum);
    if(currentNum<historyNum)
        idx=[currentNum+1:historyNum,1:currentNum];
        feature=reshape(historyInputs(:,:,1,idx),aa*bb,historyNum);
    else
        feature=reshape(historyInputs,aa*bb,historyNum);
    end
    
    
    gtImg=getImg(fgPath,'gt',i,'.png');
    label=reshape(gtImg,[height*width,1]);
    
    featureFileName=num2str(i,'%.6d');
    save([featureDir,'\',featureFileName,'.mat'],'feature','label');
    fprintf('frame num is %s\n',featureFileName);
    clear feature label;
end


%% function
    function img=getImg(baseDir,prefix,frameNum,suffix)
        str=num2str(frameNum,'%.6d');
        img=imread([baseDir,prefix,str,suffix]);
    end
end

function svmModel=svmLearn(CDNetDir,featureRootDir)
% single video learn, background:forground=8000:2000

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
temporalROI(1)=temporalROI(1)+20;
temporalROI(2)=2000;

% frameNum=1;
% fileName = num2str(frameNum, '%.6d');

[height,width]=size(roiImg);

% [feature,label]=getTrainData();
% save(datasetName,'feature','label');

% load(datasetName,'feature','label');
% posLabelIdx=(label>=170);
% label(posLabelIdx)=1;
% label(~posLabelIdx)=0;

% svmModel=train(feature,label);
% save(datasetName,'feature','label','svmModel');
load(datasetName,'svmModel');

evaluate(svmModel);

    function [feature,label]=getTrainData()
        feature=[];
        label=[];
        
        posDataNum=1000;
        negDataNum=posDataNum*4;
        maxPosDNPerImg=100;
        maxNegDNPerImg=maxPosDNPerImg*4;
        posCount=0;
        negCount=0;
        for i=temporalROI(1):temporalROI(2)
            numstr=num2str(i,'%.6d');
            data=load([featureDir,numstr,'.mat']);
            
            if(posCount<posDataNum)
                posIdx=find(data.label>=170);
                if(length(posIdx)>maxPosDNPerImg)
                    randIdx=randperm(length(posIdx),maxPosDNPerImg);
                    feature=[feature;data.feature(posIdx(randIdx),:)];
                    label=[label;data.label(posIdx(randIdx))];
                    posCount=posCount+maxPosDNPerImg;
                else
                    feature=[feature;data.feature(posIdx,:)];
                    label=[label;data.label(posIdx)];
                    posCount=posCount+length(posIdx);
                end
            end
            
            if(negCount<negDataNum)
                negIdx=find(data.label<=50);
                if(length(negIdx)>maxNegDNPerImg)
                    randIdx=randperm(length(negIdx),maxNegDNPerImg);
                    feature=[feature;data.feature(negIdx(randIdx),:)];
                    label=[label;data.label(negIdx(randIdx))];
                    negCount=negCount+maxNegDNPerImg;
                else
                    feature=[feature;data.feature(negIdx,:)];
                    label=[label;data.label(negIdx)];
                    negCount=negCount+length(negIdx);
                end
            end
            
            if(posCount>=posDataNum && negCount>=negDataNum)
                break;
            else
                if(i==temporalROI(2))
                    error('no enough posData or negData');
                end
            end
            
            %             fprintf('i is %d posCount is %d negCount is %d\n',i,posCount,negCount);
        end
        
        
        
    end

    function svmModel=train(feature,label)
        %         label=uint(label);
        % First argument must be single or double.
        feature=double(feature);
        [trainIdx, testIdx] = crossvalind('HoldOut',label, 1/2); % split the train and test labels 50%-50%
        idx=trainIdx;
        svmModel = svmtrain(feature(idx,:), label(idx), ...
            'Kernel_Function', 'rbf');
        
        predTest = svmclassify(svmModel, feature(testIdx,:)); % matlab native svm function
        
        TP=sum(and(label(testIdx)==1,predTest==1));
        TN=sum(and(label(testIdx)==0,predTest==0));
        FP=sum(and(label(testIdx)==0,predTest==1));
        FN=sum(and(label(testIdx)==1,predTest==0));
        precision=(TP+TN)/(TP+TN+FP+FN);
        recall=TP/(TP+FN);
        FMeasure=2*precision*recall/(precision+recall);
        fprintf('SVM :\n TP=%d \n TN=%d \n FP=%d \n FN=%d \n',...
            TP,TN,FP,FN);
        fprintf('SVM :\naccuracy = %.2f%%\n recall=%.2f%%\n FMeasure=%.2f%%\n', ...
            100*precision,100*recall,100*FMeasure);
    end

    function evaluate(svmModel)
        
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
            load([featureDir,numstr,'.mat'],'feature','label');
            %             out of memory
            %             predict=svmclassify(svmModel,data.feature);
            
            
            featureNum=size(feature,1);
            predict=zeros(featureNum,1);
            gap=5000;
            for j=1:gap:featureNum
                if(j+gap-1<=featureNum)
                    predict(j:j+gap-1)=svmclassify(svmModel,double(feature(j:j+gap-1,:)));
                else
                    predict(j:featureNum)=svmclassify(svmModel,double(feature(j:featureNum,:)));
                end
            end
            
            outROIIdx=label==85;
            predict=predict(~outROIIdx);
            label=label(~outROIIdx);
            
            label(label<=50)=0;
            label(label>=170)=1;
            
            
            TP=sum(and(label==1,predict==1));
            TN=sum(and(label==0,predict==0));
            FP=sum(and(label==0,predict==1));
            FN=sum(and(label==1,predict==0));
            
            TPSum=TPSum+TP;
            TNSum=TNSum+TN;
            FPSum=FPSum+FP;
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
        save([featureDir,'\svmLearn.mat'],'precision','recall','FMeasure','PSum','RSum','FSum');
        
        fprintf('\n end................................................ \n');
        fprintf('P=%f \n R=%f \n F=%f \n',PSum,RSum,FSum);
        
        fprintf(['max(precision)=%f \n max(recall)=%f \n',...
            'max(FMeasure)=%f \n'],max(precision),max(recall),max(FMeasure));
        
        fprintf(['min(precision)=%f \n min(recall)=%f \n',...
            'min(FMeasure)=%f \n'],min(precision),min(recall),min(FMeasure));
        
        fprintf(['mean(precision)=%f \n mean(recall)=%f \n',...
            'mean(FMeasure)=%f \n'],mean(precision),mean(recall),mean(FMeasure));
    end
end
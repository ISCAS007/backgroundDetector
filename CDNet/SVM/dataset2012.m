function dataset2012(modelDir,featureRootDir)
% 对数据集dataset2012进行遍历的标准设置
root='D:\firefoxDownload\matlab\dataset2012\dataset';
% layernum=3;
pathlist1=dir(root);
filenum1=length(pathlist1);
filenamelist1={pathlist1.name};

% modelDir='D:\firefoxDownload\matlab\dataset2012\dataset\intermittentObjectMotion\abandonedBox';
result=strfind(modelDir,'\');
modelName=modelDir(result(end-1)+1:end);
modelName=strrep(modelName,'\','-');
modelName=[featureRootDir,'\',modelName,'.mat'];

modelData=load(modelName);
svmModel=modelData.svmModel;

% bgsFGRootDir=modelDir;

for ii=5:filenum1
    pathlist2=dir([root,'\',filenamelist1{ii}]);
    filenum2=length(pathlist2);
    filenamelist2={pathlist2.name};
    for jj=3:filenum2
        %     for j=3:4
        path=[root,'\',filenamelist1{ii},'\',filenamelist2{jj}];
        
        fprintf('ii=%d, jj=%d, %s\n',ii,jj,path);
        
        temporalROIFilename=[path,'\temporalROI.txt'];
        temporalROI=load(temporalROIFilename);
        
        result=strfind(path,'\');
        datasetName=path(result(end-1)+1:end);
        featureDir=[featureRootDir,'\',datasetName,'\'];
        evaluate_output(featureDir);
%         evaluate(svmModel,temporalROI,featureDir);
%                 featureGenerate(path,bgsFGRootDir,featureRootDir);
%         break;
    end
        break;
end

    function evaluate(svmModel,temporalROI,featureDir)
        
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
            
            %             fprintf('i is %d\n ..................................',i);
            %             fprintf('SVM :\n TP=%d \n TN=%d \n FP=%d \n FN=%d \n',...
            %                 TP,TN,FP,FN);
            %             fprintf('SVM :\naccuracy = %.2f%%\n recall=%.2f%%\n FMeasure=%.2f%%\n', ...
            %                 100*precision(j),100*recall(j),100*FMeasure(j));
        end
        
        PSum=(TPSum+TNSum)/(TPSum+TNSum+FPSum+FNSum);
        RSum=TPSum/(TPSum+FNSum);
        FSum=2*PSum*RSum/(PSum+RSum);
        save([featureDir,'\svmLearn.mat'],'precision','recall','FMeasure','PSum','RSum','FSum');
        
        %         fprintf('\n end................................................ \n');
        %         fprintf('P=%f \n R=%f \n F=%f \n',PSum,RSum,FSum);
        %
        %         fprintf(['max(precision)=%f \n max(recall)=%f \n',...
        %             'max(FMeasure)=%f \n'],max(precision),max(recall),max(FMeasure));
        %
        %         fprintf(['min(precision)=%f \n min(recall)=%f \n',...
        %             'min(FMeasure)=%f \n'],min(precision),min(recall),min(FMeasure));
        %
        %         fprintf(['mean(precision)=%f \n mean(recall)=%f \n',...
        %             'mean(FMeasure)=%f \n'],mean(precision),mean(recall),mean(FMeasure));
    end

    function evaluate_output(featureDir)
        %         save([featureDir,'\svmLearn.mat'],'precision','recall','FMeasure','PSum','RSum','FSum');
        outputData=load([featureDir,'\svmLearn.mat']);
        %         fprintf('%s\n',featureDir);
        fprintf('P=%f \n R=%f \n F=%f \n',outputData.PSum,outputData.RSum,outputData.FSum);
    end
end
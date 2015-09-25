clc,clear
dataset=load('dataset.mat');

subset=100000;
label=dataset.labels(1:10000);
feature=double(dataset.myfeatures(1:10000,1:26));

clear dataset;
%%avoid out of memory
poslabel=label(label==1);
posfeature=feature(label==1,:);
neglabel=label(label==0);
negfeature=feature(label==0,:);

num=length(poslabel)*5;
negidx=randperm(length(neglabel),num);
neglabel=neglabel(negidx);
negfeature=negfeature(negidx,:);

label=[poslabel;neglabel];
feature=[posfeature;negfeature];

[trainIdx, testIdx] = crossvalind('HoldOut',label, 1/2); % split the train and test labels 50%-50%
idx=trainIdx;
svmModel = svmtrain(feature(idx,:), label(idx), ...
'Kernel_Function', 'rbf');

predTest = svmclassify(svmModel, feature(testIdx,:)); % matlab native svm function

TP=sum(and(label(testIdx)==0,predTest==0));
TN=sum(and(label(testIdx)==1,predTest==1));
FP=sum(and(label(testIdx)==0,predTest==1));
FN=sum(and(label(testIdx)==1,predTest==0));
precision=(TP+TN)/(TP+TN+FP+FN);
recall=TP/(TP+FN);
FMeasure=2*precision*recall/(precision+recall);
fprintf('SVM (1-against-(n-1)):\naccuracy = %.2f%%\n recall=%.2f%%\n FMeasure=%.2f%%\n', ...
    100*precision,100*recall,100*FMeasure);

dataset=load('dataset.mat');
d=10000;
imax=length(dataset.labels)-d;

a=randi(imax);
label=dataset.labels(a:a+d);
feature=double(dataset.myfeatures(a:a+d,:));
predTest = svmclassify(svmModel, feature); % matlab native svm function

TP=sum(and(label==0,predTest==0));
TN=sum(and(label==1,predTest==1));
FP=sum(and(label==0,predTest==1));
FN=sum(and(label==1,predTest==0));
precision=(TP+TN)/(TP+TN+FP+FN);
recall=TP/(TP+FN);
FMeasure=2*precision*recall/(precision+recall);
fprintf('SVM (1-against-(n-1)):\naccuracy = %.2f%%\n recall=%.2f%%\n FMeasure=%.2f%%\n', ...
    100*precision,100*recall,100*FMeasure);


clear ; close all; clc

fprintf('Loading data ...\n');

%% Load Data
% load bgs_seven_step3_2.mat
load bgs_seven_step3_3.mat

% X=[ones(size(X,1),1) X];
M=2000;
N=2000;


validIdx1=find(Y==1);
validIdx2=find(Y==0);
idx1=randperm(length(validIdx1),M)';
idx2=randperm(length(validIdx2),10*M)';
train_idx=[validIdx1(idx1);validIdx2(idx2)];
idx1=randperm(length(validIdx1),N)';
idx2=randperm(length(validIdx2),10*N)';
test_idx=[validIdx1(idx1);validIdx2(idx2)];


fprintf('size of train data is %d \n',length(train_idx));
svm=svmtrain(X(train_idx,:),Y(train_idx),'kernel_function','rbf');
% polyminal no convergence
fprintf('trian result\n');
prec=svmclassify(svm,X(train_idx,:));
validate_yzbx(prec,Y(train_idx));
fprintf('test result\n');
prec=svmclassify(svm,X(test_idx,:));
validate_yzbx(prec,Y(test_idx));
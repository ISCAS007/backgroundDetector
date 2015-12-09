% use matlab's svm to train data from step2(matlab: bgs_seven_step2.m)
clc,clear
load bgs_seven_step2.mat;

seven=train{1};
[height,width,channel]=size(seven);
channel=channel-4;
groundtruth=label{1};
model_label=groundtruth;
model_label(groundtruth~=85)=0;

M=length(model);
N=length(train);
block=height*width;

N=min(M,N);
X=ones(N*height*width,channel+4);
Y=zeros(N*height*width,1);

meanModel=zeros(height,width,channel+4);
for i=1:M
   seven=model{i};
   meanModel=meanModel+seven;
end
meanModel=meanModel./M;
sigmaModel=0;
for i=1:M
    seven=model{i};
    sigmaModel=sigmaModel+(seven-meanModel).^2;
end
sigmaModel=1+sigmaModel./M;

for i=1:N
   seven_train=train{i};
   seven_model=model{i};
   seven=abs(seven_train-meanModel)./sigmaModel;

   tag=label{i};
   X(1+(i-1)*block:i*block,:)=reshape(seven,[block,channel+4]);
   Y(1+(i-1)*block:i*block,1)=reshape(tag,[block,1]);
end
clear model train label;

validIndex=(Y~=85);
Y=Y(validIndex);
Y(Y<85)=0;
Y(Y>85)=1;
X=X(validIndex,:);

save -mat-binary bgs_seven_step3.mat X Y
%options = statset('display','iter');
%svmstruct=svmtrain(X,Y,'kernel_function','linear','options',options);

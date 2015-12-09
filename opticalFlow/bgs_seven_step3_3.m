% get max and min threshold for background
clc,clear
load bgs_seven_step2.mat;

seven=train{1};
[height,width,channel]=size(seven);
groundtruth=label{1};
model_label=groundtruth;
model_label(groundtruth~=85)=0;

M=length(model);
N=length(train);
block=height*width;

X=ones(N*height*width,channel*2);
Y=zeros(N*height*width,1);

meanModel=zeros(block,channel);
for i=1:M
   seven=reshape(model{i},[block,channel]);
   meanModel=meanModel+seven;
end
meanModel=meanModel./M;
sigmaModel=0;
for i=1:M
    seven=reshape(model{i},[block,channel]);
    sigmaModel=sigmaModel+(seven-meanModel).^2;
end
sigmaModel=1+sigmaModel./M;

for i=1:N
   seven_train=reshape(train{i},[block,channel]);
   for j=1:M
      seven_model=reshape(model{i},[block,channel]);
      if(j==1)
         minGap=sum(abs(seven_model(1:3)-seven_train(1:3))./sigmaModel(1:3),2);
         minThreshold=seven_model;
         nearest_model=[seven_model,seven_train];
      else
         Gap=sum(abs(seven_model(1:3)-seven_train(1:3))./sigmaModel(1:3),2);
         mix_model=[seven_model,seven_train];
         nearest_model(Gap<minGap,:)=mix_model(Gap<minGap,:);
      end
   end
   
   tag=label{i};
   mix_sigmaModel=[sigmaModel,sigmaModel];
   X(1+(i-1)*block:i*block,:)=nearest_model./mix_sigmaModel;
   Y(1+(i-1)*block:i*block,1)=reshape(tag,[block,1]);
end
clear model train label;

validIndex=(Y~=85);
Y=Y(validIndex);
Y(Y<85)=0;
Y(Y>85)=1;
X=X(validIndex,:);

save bgs_seven_step3_3.mat X Y
% save -mat-binary bgs_seven_step3_2.mat X Y
%options = statset('display','iter');
%svmstruct=svmtrain(X,Y,'kernel_function','linear','options',options);

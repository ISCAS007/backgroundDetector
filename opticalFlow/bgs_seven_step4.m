% use octave to linear regression the data from step2(matlab bgs_seven_step2.m)
%  Linear regression with multiple variables
%% Initialization

%% ================ Part 1: Feature Normalization ================

%% Clear and Close Figures
clear ; close all; clc

fprintf('Loading data ...\n');

%% Load Data
%data = load('inputTrainingSet.txt');
load bgs_seven_step3.mat

%X = data(:, 1:2);
%y = data(:, 3);
%m = length(Y);

% Print out some data points
fprintf('First 10 examples from the dataset: \n');
disp([X(1:10,:) Y(1:10)])
%fprintf(' x = [%.0f %.0f], y = %.0f \n', [X(1:10,:) y(1:10,:)]');

% Scale features and set them to zero mean
fprintf('Normalizing Features ...\n');

[X mu sigma] = featureNormalize(X);
theta=7;
beta=[1;1;1;0.1;0.1;0.3;0.3];
[theta,beta]=logistic_regression(Y,X,1);
predict=X*beta-theta>0;
TP=sum(predict==1 & Y==1);
TN=sum(predict==0 & Y==0);
FP=sum(predict==1 & Y==0);
FN=sum(predict==0 & Y==1);
P=TP/(TP+FP);
R=TP/(TP+FN);
F=2*P*R/(P+R);
fprintf('P=%f,R=%f,F=%f\n',P,R,F);
fprintf('Program paused. Press enter to continue.\n');
pause;


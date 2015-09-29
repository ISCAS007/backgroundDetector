% D:\firefoxDownload\matlab\dataset2012\dataset\baseline\PETS2006
% bgsFGRootDir='D:\firefoxDownload\matlab\dataset2012\results-bgs';
% featureRootDir='D:\firefoxDownload\matlab\dataset2012\features-svm';

%%
% bgsFGRootDir='D:\firefoxDownload\matlab\dataset2012\PBAS_23\results';
% featureRootDir='D:\firefoxDownload\matlab\dataset2012\PBAS_23\features-svm';
% 
% CDNetDir='D:\firefoxDownload\matlab\dataset2012\dataset\baseline\highway';
% featureGenerate(CDNetDir,bgsFGRootDir,featureRootDir);
% 
% CDNetDir='D:\firefoxDownload\matlab\dataset2012\dataset\baseline\office';
% featureGenerate(CDNetDir,bgsFGRootDir,featureRootDir);
% 
% CDNetDir='D:\firefoxDownload\matlab\dataset2012\dataset\baseline\pedestrians';
% featureGenerate(CDNetDir,bgsFGRootDir,featureRootDir);

%%
% CDNetDir='D:\firefoxDownload\matlab\dataset2012\dataset\cameraJitter\traffic';
% bgsFGRootDir='D:\firefoxDownload\matlab\dataset2012\PBAS_23\results';
% featureRootDir='D:\firefoxDownload\matlab\dataset2012\PBAS_23\features-svm';
% featureGenerate(CDNetDir,bgsFGRootDir,featureRootDir);


%%
bgsFGRootDir='D:\firefoxDownload\matlab\dataset2012\PBAS_23\results';
featureRootDir='D:\firefoxDownload\matlab\dataset2012\PBAS_23\features-svm';
dataset2012(bgsFGRootDir,featureRootDir);

error('exist');

%%
bgsFGRootDir='D:\firefoxDownload\matlab\dataset2012\SOBS_2_26\results';
featureRootDir='D:\firefoxDownload\matlab\dataset2012\SOBS_2_26\features-svm';
dataset2012(bgsFGRootDir,featureRootDir);



clear,clc;

CDNetDir='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\fall';
featureRootDir='D:\firefoxDownload\matlab\dataset2012\basicBgs\feature-gray';

graySVMModel=graySVMBgsTrain(CDNetDir,featureRootDir);

% featureRootDir='D:\firefoxDownload\matlab\dataset2012\basicBgs\feature-color';
% colorSVMModel=colorSVMBgsTrain(CDNetDir,featureRootDir);
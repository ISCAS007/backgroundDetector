% D:\firefoxDownload\matlab\dataset2012\dataset\baseline\PETS2006
bgsFGRootDir='D:\firefoxDownload\matlab\dataset2012\results-bgs';
featureRootDir='D:\firefoxDownload\matlab\dataset2012\features-svm';
CDNetDir='D:\firefoxDownload\matlab\dataset2012\dataset\baseline\highway';
featureGenerate(CDNetDir,bgsFGRootDir,featureRootDir);

CDNetDir='D:\firefoxDownload\matlab\dataset2012\dataset\baseline\office';
featureGenerate(CDNetDir,bgsFGRootDir,featureRootDir);

CDNetDir='D:\firefoxDownload\matlab\dataset2012\dataset\baseline\pedestrians';
featureGenerate(CDNetDir,bgsFGRootDir,featureRootDir);
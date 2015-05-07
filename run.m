inputpath='D:\firefoxDownload\matlab';
filename='dataset2012\dataset\baseline\PETS2006';
outputpath=strrep(filename,'\','.');
layerAlgrithm([inputpath,'\',filename],['analyze\',outputpath,'.mat']);

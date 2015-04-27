inputpath='D:\firefoxDownload\matlab';
filename='dataset2014\dataset\dynamicBackground\fall';
outputpath=strrep(filename,'\','.');
layerAlgrithm([inputpath,'\',filename],['mat\',outputpath,'.mat']);
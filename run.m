inputpath='D:\firefoxDownload\matlab';
suffix='dataset2014\dataset\baseline\highway';
outputpath='F:\yzbx_programe\matlab\backgroundDetector\output';
filename=strrep(suffix,'\','.');
filename=strrep(filename,' ','-');
layerAlgrithm([inputpath,'\',suffix],[outputpath,'\',filename]);
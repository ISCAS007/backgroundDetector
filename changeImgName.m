src='D:\Program\matlab\dataset2012\dataset\dynamicBackground\fall';
des='D:\Program\matlab\bgslibrary_mfc\outputs\input';

dirinfo=dir([src,'\input']);
filelist={dirinfo.name};

roi=load([src,'\temporalROI.txt']);
for i=roi(1):roi(2)
   copyfile([src,'\input\',filelist{i+2}],[des,'\',num2str(i),'.jpg']);
end
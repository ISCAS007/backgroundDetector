function img=getImg(baseDir,prefix,frameNum,suffix)
str=num2str(frameNum,'%.6d');
img=imread([baseDir,prefix,str,suffix]);
end
function frame=getNextFrame(frameNum,filepath,filename)
    frameNum=frameNum+1;
    frame=imread([filepath,'\',filename{frameNum+2}]);
end
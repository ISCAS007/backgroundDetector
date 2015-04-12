function CAmask=ColorAmend(layermask,frame,layer)
    [width,height,channel]=size(frame);
    areaThreshold=width*height/1000;
    CAmask=~layermask;
    CAmask=bwareaopen(CAmask,round(areaThreshold));
end
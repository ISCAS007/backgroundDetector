function CAmask=ColorAmend(layermask,frame,layer)
    [width,height,channel]=size(frame);
    areaThreshold=width*height/1000;
    CAmask=~layermask;
    CAmask=bwareaopen(CAmask,round(areaThreshold));
    Layermask=layerFilter2(frame,layer);
    
    CAmask=maskMerge_yzbx(CAmask,Layermask);
end
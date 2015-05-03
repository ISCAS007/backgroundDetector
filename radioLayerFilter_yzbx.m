function [layermask,absdiff]=radioLayerFilter_yzbx(frame,layermax,layermin,layergap,rangeradio,layermean)
    [a,b,c]=size(frame);
    layerrange=layermax-layermin+2*layergap;
    absdiff=abs(double(frame)-layermean);
    h=fspecial('average',[max(round(a/50),5),max(round(b/50),5)]);
    absdiff=imfilter(absdiff,h);
    absdiff=absdiff./layerrange;
    mask=absdiff>rangeradio;
    ff=false(a,b);
    for i=1:c
        ff=ff|mask(:,:,i);
    end
    
%     areaThreshold=round(a*b/1000);
%     layermask=bwareaopen(ff,areaThreshold);
    layermask=ff;
end
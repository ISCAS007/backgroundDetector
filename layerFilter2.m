function layermask=layerFilter2(frame,layer)
    [width,height,~]=size(frame);
    layerrange=layer.layermax-layer.layermin+2*layer.layergap;
    range=layer.rangeradio.*double(layerrange);
    absdiff=imabsdiff(frame,uint8(layer.layerbase));
    h=fspecial('average',[max(round(width/50),5),max(round(height/50),5)]);
    absdiff=imfilter(absdiff,h);
    absdiff=absdiff>uint8(range);
    a=false(width,height);
    for i=1:3
        a=a|absdiff(:,:,i);
    end
    
    areaThreshold=round(width*height/1000);
    layermask=bwareaopen(a,areaThreshold);
end
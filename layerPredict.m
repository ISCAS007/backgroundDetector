function mask=layerPredict(layer,frame)
% predict forground mask
% mmgmask=maxminGapLayerFilter_yzbx(frame,layer.max,layer.min,layer.gap);
% rrmmask=ratioLayerFilter_yzbx(frame,layer.max,layer.min,layer.gap,layer.rangeratio,layer.mean);
% vecMask=getVectorMask_yzbx(frame,layer.mean,layer.pmaxnum,layer.pminnum);
% vmask=vectorLayerMask_yzbx(frame,vecMask,layer.pminSetMean,layer.pmaxSetMean,layer.mean,layer.vecgap);

[mask,dif]=tmp3(layer,frame);
mask=dif>layer.vecgap;
% fmask=(layer.fc>2);
% bmask=(layer.bc>2);
% fmask=bwareaopen(fmask,5);
% bmask=bwareaopen(bmask,5);
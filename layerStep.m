function [layer,mask]=layerStep(layer,frame)
mask=layerPredict(layer,frame);
layer=layerUpdate_yzbx(layer,frame);
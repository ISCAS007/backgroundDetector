function layer=layerUpdate(layermask,frame,layer)
    [width,height,~]=size(frame);
   
    %area(layermask)/width/height+(labda-1)/30=1;
    lambda=1-(sum(sum(layermask)))/(width*height);
    %layer.layergap in [0,255]
    %lambda in [1,30]
    lambda=1+uint8(lambda*20);  
    learnRate=0.05;
    randNum=uint8(rand(size(frame))<learnRate);
    mask=repmat(~layermask,[1,1,3]);
    layer.layergap=layer.layergap+uint8(mask)*lambda-randNum*(1+lambda/5);
    randNum=uint8(rand(size(frame))<learnRate);
    layer.layermax=max(layer.layermax,frame)-randNum;
    randNum=uint8(rand(size(frame))<learnRate);
    layer.layermin=min(layer.layermin,frame)+randNum;
    
    
    areaopen=layerFilter2(frame,layer);
    areaThreshold=round(width*height/1000);
    %areaopen/areaThreshold in [0,1000] => beta in [0,0.1]
    %layer.rangeradio in [0,0.5]
    beta=(0.3/1000)*double(sum(sum(areaopen)))/areaThreshold;
    randNum=double(rand(size(frame))<learnRate);
    areaopen3d=repmat(areaopen,[1,1,3]);
    layer.rangeradio=layer.rangeradio+beta*double(areaopen3d)-randNum*(0.005+beta/5);
    
    if(layer.frameNum<20)  %just want to smooth the update!.
        layer.layerbase=(layer.layerbase*layer.frameNum+double(frame))/(layer.frameNum+1);
    else
        layer.layerbase=layer.layerbase*(1-learnRate)+double(frame)*learnRate;
    end
    layer.frameNum=layer.frameNum+1;
end
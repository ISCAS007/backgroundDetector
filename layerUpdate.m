function layer=layerUpdate(layermask,frame,layer)
    lambda=1-(sum(sum(layermask)))/(size(frame,1)*size(frame,2));
    lambda=5+uint8(lambda*40);
    beta=1+lambda/5;
    learnRate=0.05;
    randNum=uint8(rand(size(frame))<learnRate);
    mask=repmat(~layermask,[1,1,3]);
    layer.layergap=layer.layergap+uint8(mask)*lambda-randNum*beta;
    randNum=uint8(rand(size(frame))<learnRate);
    layer.layermax=max(layer.layermax,frame)-randNum;
    randNum=uint8(rand(size(frame))<learnRate);
    layer.layermin=min(layer.layermin,frame)+randNum;
    layer.layerbase=(layer.layerbase*layer.frameNum+double(frame))/(layer.frameNum+1);
    layer.frameNum=layer.frameNum+1;
end
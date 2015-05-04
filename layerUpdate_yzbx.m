function layer=layerUpdate_yzbx(layer,frame)
    [a,b,c]=size(frame);
    areaThreshold=round(a*b/1000);
    
    [mask,maxdif,mindif]=maxminGapLayerFilter_yzbx(frame,layer.max,layer.min,layer.gap);
    
    mask3d=(maxdif<0)&(mindif>0);
    unfitRate=sum(sum(sum(mask3d)))/(a*b*c);
    layer.mmgnoise(1)=layer.mmgnoise(2);
    openmask=bwareaopen(mask,areaThreshold);
    noisemask=mask&(~openmask);
    layer.mmgnoise(2)=sum(noisemask(:))/areaThreshold;
    
    if(layer.mmgnoise(2)>10)
        
        if(layer.mmgnoise(2)>layer.mmgnoise(1))
           layer.gapinc=min(100,layer.gapinc*2);
        else 
            layer.gapinc=layer.gapinc*0.95;
        end
        disp('big mmgnoise');
        frameNum=layer.frameNum
        mmgnoise=layer.mmgnoise(2)
        gapinc=layer.gapinc
        meangap=mean(layer.gap(:))
    else
        layer.gapinc=layer.gapinc*0.9;
        disp('little mmgnoise');
        frameNum=layer.frameNum
        mmgnoise=layer.mmgnoise(2)
        gapinc=layer.gapinc
        meangap=mean(layer.gap(:))
    end
    %area(layermask)/width/height+(labda-1)/30=1;
%     lambda=1-(sum(sum(layermask)))/(a*b);
%     %layer.layergap in [0,255]
%     %lambda in [1,20]
%     lambda=1+uint8(lambda*20);
    maxdif(maxdif>0)=0;
    mindif(mindif<0)=0;
    gapdif=max(-maxdif,mindif);
    gapdif=min(gapdif,10);
    
    learnRate=0.05;
    randNum=double(rand(size(frame))<learnRate);
    mask=repmat(mask,[1,1,3]);
    layer.gap=layer.gap+double(mask).*(gapdif+layer.gapinc);
%     layer.gap=layer.gap-randNum.*layer.gap*learnRate;
    layer.gap=layer.gap-1-randNum;
    
    randNum=double(rand(size(frame))<learnRate);
    layer.max=max(layer.max,double(frame));
%     layer.max=layer.max-randNum.*layer.max*learnRate;
    layer.max=layer.max-1-randNum;
    randNum=double(rand(size(frame))<learnRate);
    layer.min=min(layer.min,double(frame));
%     layer.min=layer.min+randNum.*layer.min*learnRate;
    layer.min=layer.min+1+randNum;
    
    
    [~,dif]=ratioLayerFilter_yzbx(frame,layer.max,layer.min,layer.gap,layer.rangeratio,layer.mean);
    
    mask3d=dif<layer.rangeratio;
    unfitRate=sum(sum(sum(mask3d)))/(a*b*3);
%     radiomask3d=repmat(radiomask,[1,1,3]);
    
    randNum=double(rand(size(frame))<learnRate+unfitRate);
    layer.rangeratio=layer.rangeratio+dif.*double(mask3d)-randNum.*layer.rangeratio*learnRate;
    
    if(layer.frameNum<20)  %just want to smooth the update!.
        layer.mean=(layer.mean*layer.frameNum+double(frame))/(layer.frameNum+1);
    else
        layer.mean=layer.mean*(1-learnRate)+double(frame)*learnRate;
    end
    layer.frameNum=layer.frameNum+1;
    
    [vecMask,pmaxsetMask,pminsetMask]=getVectorMask_yzbx(frame,layer.mean,layer.pmaxnum,layer.pminnum);
    randNum=double(rand(a,b)<learnRate);
    layer.pmaxnum=layer.pmaxnum+uint32(pmaxsetMask)-uint32(randNum);
    layer.pminnum=layer.pminnum+uint32(pminsetMask)-uint32(randNum);
    
    [vectormask,dif]=vectorLayerMask_yzbx(frame,vecMask,layer.pminSetMean,layer.pmaxSetMean,layer.mean,layer.vecgap);
    unfitRate=sum(sum(vectormask))/(sum(sum(vecMask))+1);
%     减慢学习速度，防止前景消融的情况,待实验检验效果
    randNum=double(rand(a,b)<learnRate+unfitRate);
%     仅对vectormask 中的vecgap进行dif更新,而对全局的vecgap进行随机更新
    layer.vecgap=layer.vecgap+double(vectormask).*dif-(layer.vecgap+dif).*double(randNum)*learnRate;
    
%     basevecgap...
    [vecmask,vecdif]=tmp3(layer,frame);
%     mask=vecdif>layer.minvecgap;
    mask=vecdif>layer.vecgap;
    openmask=bwareaopen(mask,5);
    noisemask=mask&(~openmask);
    vecdif(~noisemask)=0;
    
    square=strel('square',5);
    vecdif=imdilate(vecdif,square);
    layer.vecgap=max(layer.vecgap,vecdif);
    
%     vecmask=bwareaopen(vecmask,areaThreshold*10);
%     if(sum(vecmask(:))/(a*b)<0.3)
%         cb=getCommonBlock(layer.bw1,vecmask);
%         layer.bw1=vecmask;
%         layer.vecgap(cb~=0)=layer.minvecgap;
%     end
end
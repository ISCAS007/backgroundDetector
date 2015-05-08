function layer=layerUpdate_yzbx(layer,frame)
    frameNum=layer.frameNum;
    [a,b,c]=size(frame);
    areaThreshold=round(a*b/1000);
    learnRate=layer.a;
 
    %%%%%%%%%%%%%%%%%%%%%%%%gap update
    if(frameNum==1)
        dif=max(double(frame)-layer.max,layer.min-double(frame));
        minarea=areaThershold;
        maskratio=[0.3,0.5];
        noiseratio=[0.3,0.5];
        layer.gap=adajustGap2d(layer.gap,dif,minarea,maskratio,noiseratio);
    else
        [mask1,dif1max,dif1min]=maxminGapLayerFilter_yzbx(frame,layer.max,layer.min,layer.gap);
        dif1=max(dif1max,dif1min);
        
        obj=imopen(mask1,strel('disk',5,8));
        noise=mask1&(~obj);
        
%         layer.gap=layer.gap*0.99;
        layer.gap=layer.gap-1;
        
        gapextent=dif1;
        gapextent(~noise)=0;
        noise=imdilate(noise,strel('disk',5,8));
        gapextent=imdilate(gapextent,strel('disk',5,8));
        noise=noise&(~obj);
%         gapextent(obj)=0;
        
        layer.gap(noise)=max(layer.gap(noise),gapextent(noise));
    end
    
%     layer.gap in [0~20]
    gaplarge20=layer.gap>20;
    gapless5=layer.gap<1;
    layer.max(gaplarge20)=min(10+layer.max(gaplarge20),255);
    layer.min(gaplarge20)=max(0,layer.min(gaplarge20)-10);
    layer.gap(gaplarge20)=layer.gap(gaplarge20)-10;
    
    layer.max(gapless5)=max(layer.max(gapless5)-10,0);
    layer.min(gapless5)=min(255,layer.min(gapless5)+10);
    layer.gap(gapless5)=layer.gap(gapless5)+10;
 
    
    %%%%%%%%%%%%%%%%%%%%%%ratio update 
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
    
    %%%%%%%%%%%%%%%%%%%%%%vec gap update
    
    if(frameNum==1)
        [~,dif]=getVecgapMask(layer,frame);
        minarea=areaThershold;
        maskratio=[0.3,0.5];
        noiseratio=[0.3,0.5];
        layer.vecgap=adajustGap2d(layer.vecgap,dif,minarea,maskratio,noiseratio);
    else
        [mask3,dif3]=getVecgapMask(layer,frame)
        
        obj=imopen(mask3,strel('disk',5,8));
        noise=mask3&(~obj);
        
        layer.vecgap=layer.vecgap*0.99;
        
        gapextent=dif3;
        gapextent(~noise)=0;
        noise=imdilate(noise,strel('disk',5,8));
        gapextent=imdilate(gapextent,strel('disk',5,8));
        noise=noise&(~obj);
%         gapextent(obj)=0;
        
        layer.gap(noise)=max(layer.gap(noise),gapextent(noise));
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%vec ratio update
    
        
%     [vectormask,dif]=vectorLayerMask_yzbx(frame,vecMask,layer.pminSetMean,layer.pmaxSetMean,layer.mean,layer.vecgap);
%     unfitRate=sum(sum(vectormask))/(sum(sum(vecMask))+1);
% %     减慢学习速度，防止前景消融的情况,待实验检验效果
%     randNum=double(rand(a,b)<learnRate+unfitRate);
% %     仅对vectormask 中的vecgap进行dif更新,而对全局的vecgap进行随机更新
%     layer.vecgap=layer.vecgap+double(vectormask).*dif-(layer.vecgap+dif).*double(randNum)*learnRate;
%     
% %     basevecgap...
%     [vecmask,vecdif]=tmp3(layer,frame);
% %     mask=vecdif>layer.minvecgap;
%     mask=vecdif>layer.vecgap;
%     openmask=bwareaopen(mask,5);
%     noisemask=mask&(~openmask);
%     vecdif(~noisemask)=0;
%     
%     square=strel('square',5);
%     vecdif=imdilate(vecdif,square);
%     layer.vecgap=max(layer.vecgap,vecdif);
    

%     vecmask=bwareaopen(vecmask,areaThreshold*10);
%     if(sum(vecmask(:))/(a*b)<0.3)
%         cb=getCommonBlock(layer.bw1,vecmask);
%         layer.bw1=vecmask;
%         layer.vecgap(cb~=0)=layer.minvecgap;
%     end

function [noise,obj]=getNoiseObj2d(mask,minarea)
obj=bwareaopen(mask,minarea);
noise=mask-obj;
obj=imerode(obj,strel('square',3));
noise=imdilate(noise,strel('square',5));

function gap=adajustGap2d(gap,dif,minarea,maskratio,noiseratio)
[a,b]=size(gap);
loop=0;
while loop<100
    loop=loop+1;
    mask=dif>gap;
    [noise,obj]=getNoiseObj2d(mask,minarea);
    mm=sum(mask(:))/a*b;
    if(any(obj))
       if(mm>=maskratio(1)&&mm<=maskratio(2))
          nn=sum(noise(:))/sum(mask(:));
          if(nn>=noiseratio(1)&&nn<=noiseratio(2))
            break; 
          end
       end
    end
    
end
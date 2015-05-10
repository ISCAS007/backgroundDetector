function [layer,mask]=layerStep(layer,frame)
% mask=layerPredict(layer,frame);
% layer=layerUpdate_yzbx(layer,frame);

    frameNum=layer.frameNum;
    [a,b,c]=size(frame);
    areaThreshold=round(a*b/1000);
    learnRate=layer.a;
 
    %%%%%%%%%%%%%%%%%%%%%%%%gap update
    if(frameNum==1)
        dif1=max(double(frame)-layer.max,layer.min-double(frame));
        minarea=areaThreshold;
        maskratio=[0.3,0.5];
        noiseratio=[0.3,0.5];
        layer.gap=adajustGap2d(layer.gap,dif1,minarea,maskratio,noiseratio);
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
	% if(frameNum==1)
		% dif2=double(frame)./max(layer.mean,1);
		
	% else
	
	% end
%     [~,dif]=ratioLayerFilter_yzbx(frame,layer.max,layer.min,layer.gap,layer.rangeratio,layer.mean);
%     
%     mask3d=dif<layer.rangeratio;
%     unfitRate=sum(sum(sum(mask3d)))/(a*b*3);
% %     radiomask3d=repmat(radiomask,[1,1,3]);
%     
%     randNum=double(rand(size(frame))<learnRate+unfitRate);
%     layer.rangeratio=layer.rangeratio+dif.*double(mask3d)-randNum.*layer.rangeratio*learnRate;
%     
%     if(layer.frameNum<20)  %just want to smooth the update!.
%         layer.mean=(layer.mean*layer.frameNum+double(frame))/(layer.frameNum+1);
%     else
%         layer.mean=layer.mean*(1-learnRate)+double(frame)*learnRate;
%     end
%     layer.frameNum=layer.frameNum+1;
%     
%     [vecMask,pmaxsetMask,pminsetMask]=getVectorMask_yzbx(frame,layer.mean,layer.pmaxnum,layer.pminnum);
%     randNum=double(rand(a,b)<learnRate);
%     layer.pmaxnum=layer.pmaxnum+uint32(pmaxsetMask)-uint32(randNum);
%     layer.pminnum=layer.pminnum+uint32(pminsetMask)-uint32(randNum);
    
    %%%%%%%%%%%%%%%%%%%%%%vec gap update
    
    if(frameNum==1)
        [~,dif3]=getVecgapMask(layer,frame);
        minarea=areaThreshold;
        maskratio=[0.3,0.5];
        noiseratio=[0.3,0.5];
        layer.vecgap=adajustGap2d(layer.vecgap,dif3,minarea,maskratio,noiseratio);
    else
        [mask3,dif3]=getVecgapMask(layer,frame);
        
        obj=imopen(mask3,strel('disk',5,8));
        noise=mask3&(~obj);
        
        layer.vecgap=layer.vecgap*0.99;
        
        gapextent=dif3;
        gapextent(~noise)=0;
        noise=imdilate(noise,strel('disk',5,8));
        gapextent=imdilate(gapextent,strel('disk',5,8));
        noise=noise&(~obj);
%         gapextent(obj)=0;
        
        % layer.gap(noise)=max(layer.gap(noise),gapextent(noise));
		layer.vecgap(noise)=max(layer.vecgap(noise),gapextent(noise));
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%vec ratio update
    if(frameNum==1)
        [~,dif4]=getVecMask4(layer,frame);
        minarea=areaThreshold;
        maskratio=[0.3,0.5];
        noiseratio=[0.3,0.5];
        layer.vecdifmax=adajustGap2d(layer.vecdifmax,dif4,minarea,maskratio,noiseratio);
    else
        [mask4,dif4]=getVecMask4(layer,frame);
        
        obj=imopen(mask4,strel('disk',5,8));
        noise=mask4&(~obj);
        
        layer.vecdifmax=layer.vecdifmax*0.99;
        
        gapextent=dif4;
        gapextent(~noise)=0;
        noise=imdilate(noise,strel('disk',5,8));
        gapextent=imdilate(gapextent,strel('disk',5,8));
        noise=noise&(~obj);
%         gapextent(obj)=0;
        
        % layer.gap(noise)=max(layer.gap(noise),gapextent(noise));
		layer.vecdifmax(noise)=max(layer.vecdifmax(noise),gapextent(noise));
    end
       
    %%%%%%%%%%%%%%%%%%%%%%%%%% predict, update , and show
    if(layer.frameNum<20)  %just want to smooth the update!.
        layer.mean=(layer.mean*layer.frameNum+double(frame))/(layer.frameNum+1);
    else
        layer.mean=layer.mean*(1-learnRate)+double(frame)*learnRate;
    end
	layer.frameNum=layer.frameNum+1;
    predict();
    show();

function [noise,obj]=getNoiseObj2d(mask,minarea)
obj=bwareaopen(mask,minarea);
noise=mask-obj;
obj=imerode(obj,strel('square',3));
noise=imdilate(noise,strel('square',5));
end

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
end

function predict()
	mask=mask1|mask3|mask4;
end

function show()
% set(h,'Name',[num2str(frameNum),'/',num2str(roiframeNum(2))]);
	figNum=3;
	subplot(2,figNum,1,'replace'),imshow(frame),title('frame');
	subplot(2,figNum,2,'replace'),imshow(mask),title('mask');
    subplot(2,figNum,3,'replace'),imshow(mask1),title('mask1');
%     subplot(2,figNum,4,'replace'),imshow(mask3dTo2d(mask2)),title('mask2');
    subplot(2,figNum,4,'replace'),imshow(mask2),title('mask2');
    subplot(2,figNum,5,'replace'),imshow(mask3),title('mask3');
    subplot(2,figNum,6,'replace'),imshow(mask4),title('mask4');
	pause(0.1);
end
end
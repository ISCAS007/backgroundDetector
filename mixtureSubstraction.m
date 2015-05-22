function [layer,mixtureMask]=mixtureSubstraction(layer,frame)
% init and update layer at the same time
    [a,b,c]=size(frame);
    [vector,light]=norm_yzbx();
    tmpMask=false(a,b);
    se=strel('disk',3);
    if(isempty(layer))
       layer=init(); 
       mixtureMask=false(a,b);
    else
        lightMask=getLightMask();
        
        [hardMask,crossDistance]=getHardMask();
        softMask=getSoftMask();
        mixtureMask=getMixtureMask();
        updateLightModel();
        updateVectorModel();
        
        maskShow();
    end
    
    function [vector,light]=norm_yzbx()
        vector=double(frame);
        light=sqrt(sum(vector.^2,3));
        not0=(light~=0);
        not0=repmat(not0,[1,1,3]);
        light3d=repmat(light,[1,1,3]);
        
        vector(~not0)=0;
        vector(not0)=vector(not0)./light3d(not0);
    end

    function maskShow()
        subplot(431);imshow(lightMask);title('lightMask');
        subplot(432);imshow(softMask);title('softMask');
        subplot(433);imshow(hardMask);title('hardMask');
        subplot(437);imshow(layer.lightMax/765);title('lightMax');
        subplot(438);imshow(layer.SoftModel);title('SoftModel');
        subplot(439);imshow(layer.HardModel);title('HardModel');
        subplot(4,3,10);imshow(light/765);title('light');
        subplot(4,3,11);imshow(vector);title('vector');
%         subplot(4,3,12);imshow(tmpMask);title('maxv|minv');
        subplot(4,3,12);imshow(tmpMask);title('tmpMask');
    end

    function layer=init()
        layer=struct(...
            'lightMin',zeros(a,b,'double'),...
            'lightMax',zeros(a,b,'double'),...
            'lightMinCount',zeros(a,b,'uint32'),...
            'lightMaxCount',zeros(a,b,'uint32'),...
            'model',zeros(a,b,c,'double'),...
            'SoftModel',zeros(a,b,c,'double'),...
            'HardModel',zeros(a,b,c,'double'),...
            'distanceMax',ones(a,b,'double')*0.01,...
            'distanceMaxCount',zeros(a,b,'uint32'),...
            'foreCount',zeros(a,b,'uint32'),...
            'minArea',round(a*b/1000),...
            'learnRate',0.05,...
            'floatValue',5,...
            'init',false(1,5),...
            'trainNum',20,...
            'recentFrame',frame,...
            'frameNum',1);
        
        layer.SoftModel=vector;
        layer.HardModel=vector;
        layer.lightMax=light;
        layer.lightMin=light;
    end
    
    function lightMask=getLightMask()
        lightMask=(light>layer.lightMax)|(light<layer.lightMin);
        if(layer.frameNum>layer.trainNum)
%             lightMask=imopen(lightMask,se);
%             lightMask=imfill(lightMask,'holes');
            tmpMask=medfilt2(lightMask,[5,5]);
        end
%         lightMask=bwareaopen(lightMask,layer.minArea);
        lightMask=medfilt2(lightMask,[5,5]);
    end  

    function [hardMask,crossDistance]=getHardMask()
        layer.model=layer.HardModel;
        [hardMask,crossDistance]=getVectorMask();
    end

    function softMask=getSoftMask()
        layer.model=layer.SoftModel;
        [softMask,~]=getVectorMask();
    end

    function [vectorMask,crossDistance]=getVectorMask()
        crossVector=cross(layer.model,vector);
        crossDistance=sum(crossVector.^2,3);
        vectorMask=crossDistance>layer.distanceMax;
    end

    function mixtureMask=getMixtureMask()
%         
%         vectorMask=imclose(hardMask|softMask,se);
        vectorMask=medfilt2(hardMask|softMask,[5,5]);
        if(layer.frameNum<layer.trainNum)
%             mixtureMask=(hardMask|softMask)&lightMask;
%             mixtureMask=imopen(hardMask|lightMask,se)&imopen(softMask|lightMask,se);
%             mixtureMask=imclose(mixtureMask,se);
%             mixtureMask=imclose(hardMask|lightMask,se)&imclose(softMask|lightMask,se);
            mixtureMask=medfilt2(vectorMask|lightMask,[5,5]);
        else
%            mixtureMask=imopen(hardMask|lightMask,se)&imopen(softMask|lightMask,se);
%             mixtureMask=imclose(mixtureMask,se);
%             mixtureMask=imclose(hardMask|lightMask,se)&imclose(softMask|lightMask,se);
            mixtureMask=medfilt2(vectorMask|lightMask,[5,5]);
        end     
%         mixtureMask=imfill(mixtureMask,'holes');
%         mixtureMask=bwareaopen(mixtureMask,layer.minArea);
    end
    
    function updateLightModel()
        if(layer.frameNum>layer.trainNum)
            layer.lightMax(~lightMask)=max(layer.lightMax(~lightMask),light(~lightMask));
            layer.lightMin(~lightMask)=min(layer.lightMin(~lightMask),light(~lightMask));
            layer.lightMax(lightMask)=layer.lightMax(lightMask)*(1-layer.learnRate)+...
                max(layer.lightMax(lightMask),light(lightMask))*layer.learnRate;
            layer.lightMin(lightMask)=layer.lightMin(lightMask)*(1-layer.learnRate)+...
                min(layer.lightMin(lightMask),light(lightMask))*layer.learnRate;
        else
            layer.lightMax=max(layer.lightMax,light);
            layer.lightMin=min(layer.lightMin,light);
        end
        
        maxc=(layer.lightMax>=light-5)&(layer.lightMax<=light);
        minc=(layer.lightMin>=light)&(layer.lightMin<=light+5);
        
        
        layer.lightMinCount(minc)=0;
        layer.lightMinCount((~minc)&(~lightMask))=layer.lightMinCount((~minc)&(~lightMask))+1;
        
        layer.lightMaxCount(maxc)=0;
        layer.lightMaxCount((~maxc)&(~lightMask))=layer.lightMaxCount((~maxc)&(~lightMask))+1;
        
        
        
        maxv=layer.lightMaxCount>20;
        minv=layer.lightMinCount>20;
%         tmpMask=maxv|minv;
        
        layer.lightMaxCount(maxv)=10;
        layer.lightMinCount(minv)=10;
        layer.lightMax(maxv)=layer.lightMax(maxv)-1;
        layer.lightMin(minv)=layer.lightMin(minv)+1;
       
    end

    function updateVectorModel()
        layer.distanceMax(~mixtureMask)=max(layer.distanceMax(~mixtureMask),crossDistance(~mixtureMask));
        dc=(layer.distanceMax>crossDistance*(1-layer.learnRate))&(layer.distanceMax<crossDistance);
        layer.distanceMaxCount(dc)=0;
        layer.distanceMaxCount((~dc)&(~mixtureMask))=layer.distanceMaxCount((~dc)&(~mixtureMask))+1;
        
        vc=layer.distanceMaxCount>20;
        layer.distanceMaxCount(vc)=10;
%         tmpMask=vc;
        
        layer.distanceMax(vc)=layer.distanceMax(vc)*(1-layer.learnRate);
        
        layer.foreCount(mixtureMask)=layer.foreCount(mixtureMask)+1;
        layer.HardModel(~mixtureMask)=layer.HardModel(~mixtureMask)*(1-layer.learnRate)+vector(~mixtureMask)*layer.learnRate;
        layer.SoftModel=layer.SoftModel*(1-layer.learnRate)+vector*layer.learnRate;
        
        layer.frameNum=layer.frameNum+1;
    end
end
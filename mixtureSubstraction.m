function [layer,mixtureMask]=mixtureSubstraction(layer,frame)
% init and update layer at the same time
    [a,b,c]=size(frame);
    [vector,light]=norm_yzbx();
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
        subplot(231);imshow(lightMask);title('lightMask');
        subplot(232);imshow(softMask);title('softMask');
        subplot(233);imshow(hardMask);title('hardMask');
    end

    function layer=init()
        layer=struct(...
            'lightMin',zeros(a,b,'double'),...
            'lightMax',zeros(a,b,'double'),...
            'ligthMinCount',zeros(a,b,'uint32'),...
            'lightMaxCount',zeros(a,b,'uint32'),...
            'model',zeros(a,b,c,'double'),...
            'SoftModel',zeros(a,b,c,'double'),...
            'HardModel',zeros(a,b,c,'double'),...
            'distanceMax',ones(a,b,'double')*0.01,...
            'distanceMaxCount',zeros(a,b,'uint32'),...
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
        lightMask=bwareaopen(lightMask,layer.minArea);
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
        if(layer.frameNum<layer.trainNum)
            mixtureMask=(hardMask|softMask)&lightMask;
        else
            mixtureMask=(hardMask|lightMask)&(softMask|lightMask);
        end     
    end
    
    function updateLightModel()
        layer.lightMax(~mixtureMask)=max(layer.lightMax(~mixtureMask),light(~mixtureMask));
        layer.lightMin(~mixtureMask)=min(layer.lightMin(~mixtureMask),light(~mixtureMask));
%         layer.lightMax=max(layer.lightMax,light);
%         layer.lightMin=min(layer.lightMin,light);
        maxc=(layer.lightMax>=light-5)&(layer.lightMax<=light);
        minc=(layer.lightMin>=light)&(layer.lightMin<=light+5);
        
        layer.lightMaxCount(maxc)=0;
        layer.lightMaxCount(~maxc&~lightMask)=layer.lightMaxCount(~maxc&~lightMask)+1;
        layer.lightMinCount(minc)=0;
        layer.lightMinCount(~minc&~lightMask)=layer.lightMinCount(~minc&~lightMask)+1;
        
        maxv=layer.lightMaxCount>20;
        minv=layer.lightMinCount>20;
        
        layer.lightMax(maxv)=layer.lightMax(maxv)-1;
        layer.lightMin(minv)=layer.lightMin(minv)-1;
       
    end

    function updateVectorModel()
        layer.distanceMax(~mixtureMask)=max(layer.distanceMax(~mixtureMask),crossDistance(~mixtureMask));
        dc=(layer.distanceMax>crossDistance-0.01)&(layer.distanceMax<crossDistance);
        layer.distanceMaxCount(dc&~mixtureMask)=0;
        
        vc=dc>20;
        layer.distanceMaxCount(vc&~mixtureMask)=layer.distanceMaxCount(vc&~mixtureMask)-0.01;
        
        layer.HardModel(~mixtureMask)=layer.HardModel(~mixtureMask)*(1-layer.learnRate)+vector(~mixtureMask)*layer.learnRate;
        layer.SoftModel=layer.SoftModel*(1-layer.learnRate)+vector*layer.learnRate;
        
        layer.frameNum=layer.frameNum+1;
    end
end
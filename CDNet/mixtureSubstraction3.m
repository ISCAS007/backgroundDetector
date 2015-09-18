function [layer,mixtureMask]=mixtureSubstraction3(layer,frame)
% init and update layer at the same time
[a,b,c]=size(frame);
[vector,light]=norm_yzbx();
tmpMask=edge(light,'canny');
se=strel('disk',3);
if(isempty(layer))
    layer=init();
    mixtureMask=false(a,b);
else
    lightMask=getLightMask();
    
    [hardMask,crossDistance]=getHardMask();
    softMask=getSoftMask();
    mixtureMask=getMixtureMask();
    [difmask,difmask3]=getDifMask();
    updateLightModel();
    updateVectorModel();
    updateDifModel(difmask3);
    maskShow();
    %         figure(2),imshow(difmask),title('difmask');
    subplot(4,3,12);imshow(difmask);title('difmask');
end

    function [vector,light]=norm_yzbx()
        vector=double(frame);
        light=sqrt(sum(vector.^2,3));
        
        not0=(light~=0);
        not0=repmat(not0,[1,1,3]);
        light3d=repmat(light,[1,1,3]);
        
        vector(~not0)=0;
        vector(not0)=vector(not0)./light3d(not0);
        
        light=rgb2gray(frame);
        light=medfilt2(light,[5,5]);
        light=imadjust(light);
    end

    function maskShow()
        figure(1);
        subplot(431);imshow(lightMask);title('lightMask');
        subplot(432);imshow(softMask);title('softMask');
        subplot(433);imshow(hardMask);title('hardMask');
        subplot(437);imshow(layer.lightMax);title('lightMax');
        subplot(438);imshow(layer.SoftModel);title('SoftModel');
        subplot(439);imshow(layer.HardModel);title('HardModel');
        subplot(4,3,10);imshow(light);title('light');
        subplot(4,3,11);imshow(vector);title('vector');
        %         subplot(4,3,12);imshow(tmpMask);title('tmpMask');
    end

    function layer=init()
        layer=struct(...
            'background',zeros(a,b,c,'uint8'),...
            'difmax',ones(a,b,c,'uint8')*20,...
            'difmax2',zeros(a,b,c,'uint8'),...
            'difmaxcount',zeros(a,b,c,'uint8'),...
            'difmax2count',zeros(a,b,c,'uint8'),...
            'lightMin',zeros(a,b,'double'),...
            'lightMax',zeros(a,b,'double'),...
            'lightMinCount',zeros(a,b,'uint32'),...
            'lightMaxCount',zeros(a,b,'uint32'),...
            'lightDifMin',5,...
            'model',zeros(a,b,c,'double'),...
            'SoftModel',zeros(a,b,c,'double'),...
            'HardModel',zeros(a,b,c,'double'),...
            'distanceMax',ones(a,b,'double')*0.01,...
            'distanceMaxCount',zeros(a,b,'uint32'),...
            'vectorDifMin',0,...
            'foreCount',zeros(a,b,'uint32'),...
            'minArea',round(a*b/1000),...
            'learnRate',0.05,...
            'floatValue',5,...
            'init',false(1,5),...
            'trainNum',20,...
            'recentFrame',frame,...
            'darkThreshold',sqrt(100*100*3),...
            'frameNum',1);
        
        layer.background=frame;
        layer.SoftModel=vector;
        layer.HardModel=vector;
        layer.lightMax=light;
        layer.lightMin=light;
    end

    function lightMask=getLightMask()
        dif=max(light-layer.lightMax,layer.lightMin-light);
        %         dif=layer.lightMin-light;
        lightMask=(light>layer.lightMax)|(light<layer.lightMin);
        lightMask=lightMask&(dif>layer.lightDifMin);
        if(layer.frameNum>layer.trainNum)
            %             lightMask=imopen(lightMask,se);
            %             lightMask=imfill(lightMask,'holes');
        end
        %         lightMask=bwareaopen(lightMask,layer.minArea);
        lightMask=medfilt2(lightMask,[5,5]);
        %           lightMask=imclose(lightMask,se);
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
        vectorMask=(crossDistance>layer.distanceMax)&(crossDistance>layer.vectorDifMin);
        vectorMask=medfilt2(vectorMask,[5,5]);
    end

    function [difmask,difmask3]=getDifMask()
        dif=(layer.background-frame)+(frame-layer.background);
        if(layer.frameNum<=5)
            max2mask=layer.difmax>=dif;
            layer.difmax=max(layer.difmax,dif);
            max2=max(layer.difmax2,dif);
            layer.difmax2(max2mask)=max2(max2mask);
            %           [a,b]=size(frame);
            difmask=false(a,b);
            difmask3=false(a,b,c);
        else
            difmask3=dif>layer.difmax+3;
            difmask=difmask3(:,:,1)&difmask3(:,:,2)&difmask3(:,:,3);
        end
    end

    function mask=getReConstructMask()
        vectorDifArea=imdilate(hardMask|softMask,se);
        shadowMask=(light<layer.lightMin)&(~vectorDifArea)&(layer.lightMax>layer.darkThreshold);
        andmask=hardMask&lightMask;
        ormask=(hardMask|lightMask)&(~shadowMask);
        mask=imreconstruct(andmask,ormask);
    end

    function mixtureMask=getMixtureMask()
        
        if(layer.frameNum<layer.trainNum)
            mixtureMask=getReConstructMask();
        else
            mixtureMask=getReConstructMask();
            mixtureMask=imclose(mixtureMask,se);
            mixtureMask=imfill(mixtureMask,'holes');
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
        
        layer.distanceMax(vc)=layer.distanceMax(vc)*(1-layer.learnRate);
        
        layer.foreCount(mixtureMask)=layer.foreCount(mixtureMask)+1;
        layer.HardModel(~mixtureMask)=layer.HardModel(~mixtureMask)*(1-layer.learnRate)+vector(~mixtureMask)*layer.learnRate;
        layer.SoftModel=layer.SoftModel*(1-layer.learnRate)+vector*layer.learnRate;
        
        layer.frameNum=layer.frameNum+1;
    end
    function updateDifModel(difmask3)
        %         difmask3=repmat(difmask,[1,1,3]);
        difmask=difmask3(:,:,1)|difmask3(:,:,2)|difmask3(:,:,3);
        for i=1:c
            difmask=medfilt2(difmask,[5,5]);
%            difmask3(:,:,i)=medfilt2(difmask3(:,:,i));
        end
        maskkernel=imerode(difmask,strel('disk',2));
        maskedge=difmask&(~maskkernel);
        maskedge3=repmat(maskedge,[1,1,3]);
        
        difmask3=repmat(difmask,[1,1,3]);
          
        dif=(frame-layer.background)+(layer.background-frame);
        
        layer.difmax(~difmask3)=max(layer.difmax(~difmask3),dif(~difmask3));
       
        maxupdate=(difmask3)|(layer.difmax==dif);
        layer.difmaxcount=layer.difmaxcount+uint8(~maxupdate);
        layer.difmaxcount(layer.difmax==dif)=0;
        
        dif2mask=(difmask3)|(layer.difmax==dif);
        layer.difmax2(~dif2mask)=max(layer.difmax2(~dif2mask),dif(~dif2mask));
        
        layer.difmax(maskedge3)=layer.difmax(maskedge3)+1;
        
        
        max2update=maxupdate|(layer.difmax2==dif);
        layer.difmax2count=layer.difmax2count+uint8(~max2update);
        layer.difmax2count(layer.difmax2==dif)=0;
        
        fitmask=layer.difmaxcount>20;
        layer.difmax(fitmask)=layer.difmax2(fitmask);
        layer.difmaxcount(fitmask)=layer.difmax2count(fitmask);
        layer.difmax2(fitmask)=layer.difmax2(fitmask)-10;
        layer.difmax2count(fitmask)=0;
        
        layer.backround(~difmask3)=frame(~difmask3);
        
    end
end
function layer=svmBS(layer,frame)
% init and update layer at the same time
[a,b,c]=size(frame);
if(isempty(layer))
    layer=init();
else
    mask=getDifMask();
    updateDifModel(mask);
end

    function layer=init()
        N=3;
        layer=struct(...
            'background',zeros(a,b,c,'uint8'),...
            'difmax',ones(a,b,c,'uint8')*20,...
            'difmax2',zeros(a,b,c,'uint8'),...
            'difmaxcount',zeros(a,b,c,'uint8'),...
            'difmax2count',zeros(a,b,c,'uint8'),...
            'Inited',false,...
            'Nmax',N,...
            'currentN',1,...
            'masks',false(a,b,N),...
            'inputs',zeros(a,b,c,N,'uint8'),...
            'frameNum',1);
        
        layer.inputs(:,:,:,1)=frame;
        layer.background=frame;
    end

    function [difmask]=getDifMask()
        dif=(layer.background-frame)+(frame-layer.background);
        if(layer.frameNum<=5)
            max2mask=layer.difmax>=dif;
            layer.difmax=max(layer.difmax,dif);
            max2=max(layer.difmax2,dif);
            layer.difmax2(max2mask)=max2(max2mask);
            %           [a,b]=size(frame);
            difmask=false(a,b);
%             difmask3=false(a,b,c);
        else
            if(layer.frameNum>layer.Nmax)
                layer.Inited=true;
            end
            
            difmask3=dif>layer.difmax+3;
            difmask=difmask3(:,:,1)|difmask3(:,:,2)|difmask3(:,:,3);
            difmask=medfilt2(difmask,[5,5]);
            difmask=imclose(difmask,strel('disk',3));
        end
    end

    function updateDifModel(difmask)
        
        maskkernel=imerode(difmask,strel('disk',1));
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
        
        layer.frameNum=layer.frameNum+1;
        
        layer.currentN=layer.currentN+1;
        if(layer.currentN>layer.Nmax)
           layer.currentN=1; 
        end
        layer.masks(:,:,layer.currentN)=mask;
        layer.inputs(:,:,:,layer.currentN)=frame;
        
    end
end
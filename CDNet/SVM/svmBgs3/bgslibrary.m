function [mask,kernel]=bgslibrary(input,kernel)
    
end

function [kernel]=bgslibraryUpdate(input,mask,kernel)

end

function [mask,kernel]=frameDif(input,kernel)
    %copy from E:\yzbx_programe\Matlab\gmm\backgroundDetector\CDNet\difModel.m
    % init and update layer at the same time
[a,b,c]=size(input);
if(isempty(kernel))
    kernel=init();
    mask=false(a,b);
else
    mask=getDifMask();
end

    function layer=init()
        layer=struct(...
            'background',zeros(a,b,c,'uint8'),...
            'difmax',ones(a,b,c,'uint8')*20,...
            'difmax2',zeros(a,b,c,'uint8'),...
            'difmaxcount',zeros(a,b,c,'uint8'),...
            'difmax2count',zeros(a,b,c,'uint8'),...
            'frameNum',1);
        
        layer.background=input;
    end

    function [difmask]=getDifMask()
        dif=(kernel.background-input)+(input-kernel.background);
        if(kernel.frameNum<=5)
            max2mask=kernel.difmax>=dif;
            kernel.difmax=max(kernel.difmax,dif);
            max2=max(kernel.difmax2,dif);
            kernel.difmax2(max2mask)=max2(max2mask);
            %           [a,b]=size(frame);
            difmask=false(a,b);
%             difmask3=false(a,b,c);
        else
            difmask3=dif>kernel.difmax+3;
            difmask=difmask3(:,:,1)|difmask3(:,:,2)|difmask3(:,:,3);
            difmask=medfilt2(difmask,[5,5]);
            difmask=imclose(difmask,strel('disk',3));
        end
    end
end

function [kernel]=frameDifUpdate(input,mask,kernel)
mask=mask;
    maskkernel=imerode(mask,strel('disk',1));
        maskedge=mask&(~maskkernel);
        maskedge3=repmat(maskedge,[1,1,3]);
        
        difmask3=repmat(mask,[1,1,3]);
          
        dif=(input-kernel.background)+(kernel.background-input);
        
        kernel.difmax(~difmask3)=max(kernel.difmax(~difmask3),dif(~difmask3));
       
        maxupdate=(difmask3)|(kernel.difmax==dif);
        kernel.difmaxcount=kernel.difmaxcount+uint8(~maxupdate);
        kernel.difmaxcount(kernel.difmax==dif)=0;
        
        dif2mask=(difmask3)|(kernel.difmax==dif);
        kernel.difmax2(~dif2mask)=max(kernel.difmax2(~dif2mask),dif(~dif2mask));
        
        kernel.difmax(maskedge3)=kernel.difmax(maskedge3)+1;
        
        
        max2update=maxupdate|(kernel.difmax2==dif);
        kernel.difmax2count=kernel.difmax2count+uint8(~max2update);
        kernel.difmax2count(kernel.difmax2==dif)=0;
        
        fitmask=kernel.difmaxcount>20;
        kernel.difmax(fitmask)=kernel.difmax2(fitmask);
        kernel.difmaxcount(fitmask)=kernel.difmax2count(fitmask);
        kernel.difmax2(fitmask)=kernel.difmax2(fitmask)-10;
        kernel.difmax2count(fitmask)=0;
        
        kernel.backround(~difmask3)=input(~difmask3);
        
        kernel.frameNum=kernel.frameNum+1;
end

function [mask,kernel]=modeBackGround(input,kernel)

end

function [kernel]=modeBackGroundUpdate(input,mask,kernel)

end

function [mask,kernel]=shadowKiller(input,kernel)

end

function [kernel]=shadowKillerUpdate(input,mask,kernel)

end

function [mask,kernel]=tracking(input,kernel)

end

function [kernel]=trackingUpdate(input,mask,kernel)

end


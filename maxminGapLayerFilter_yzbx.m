function [layermask,maxdif,mindif]=maxminGapLayerFilter_yzbx(frame,layermax,layermin,layergap)
    
    maxdif=double(frame)-(layermax+layergap);
    mindif=(layermin-layergap)-double(frame);
    mask=(maxdif>0|mindif>0);
    layermask=mask(:,:,1)|mask(:,:,2)|mask(:,:,3);
    
%     layermask=true(size(frame,1),size(frame,2));
%     maxdif=zeros(size(frame),'double');
%     mindif=zeros(size(frame),'double');
%     for i=1:3
%        mindif(:,:,i)=(layermin(:,:,i)-layergap(:,:,i))-double(frame(:,:,i));
%        maxdif(:,:,i)=double(frame(:,:,i))-(layermax(:,:,i)+layergap(:,:,i));
%        a=((layermin(:,:,i)-layergap(:,:,i))<=frame(:,:,i))...
%             &((layermax(:,:,i)+layergap(:,:,i))>=frame(:,:,i));
%        layermask=layermask&a; 
%     end

% %     layermask is foreground mask, and so to other mask;
%     layermask=~layermask;
    
%     mindif(mindif<0)=0;
%     maxdif(maxdif>0)=0;
end
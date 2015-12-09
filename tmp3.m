function [mask,vecdif]=tmp3(layer,frame)
layermean=layer.mean;
layerlight=sqrt(max(sum(layermean.^2,3),1));
framelight=sqrt(max(sum(frame.^2,3),1));

ff=double(frame);
for i=3:-1:1
%    layermean(:,:,i)=layer.mean(:,:,i)./(1+layer.mean(:,:,1)); 
%    ff(:,:,i)=ff(:,:,i)./(1+ff(:,:,1));
   
   layermean(:,:,i)=layermean(:,:,i)./layerlight;
   ff(:,:,i)=ff(:,:,i)./framelight;
end

vecdif=cross(layermean,ff,3);
vecdif=sum(vecdif.^2,3);
m=max(vecdif(:));
mask=vecdif/m;
mask=imadjust(mask);
function [mask,vecdif]=getVecgapMask(layer,frame)
layermean=layer.mean;
layermean=norm_yzbx(layermean);
ff=norm_yzbx(frame);
vecgap=layer.vecgap;

% layerlight=sqrt(max(sum(layermean.^2,3),1));
% framelight=sqrt(max(sum(frame.^2,3),1));

% ff=double(frame);
% for i=3:-1:1
% %    layermean(:,:,i)=layer.mean(:,:,i)./(1+layer.mean(:,:,1)); 
% %    ff(:,:,i)=ff(:,:,i)./(1+ff(:,:,1));
   
   % layermean(:,:,i)=layermean(:,:,i)./layerlight;
   % ff(:,:,i)=ff(:,:,i)./framelight;
% end

vecdif=cross(layermean,ff,3);
vecdif=sum(vecdif.^2,3);
% m=max(vecdif(:));
% mask=vecdif/m;
% mask=imadjust(mask);
mask=vecdif>vecgap;

function vector=norm_yzbx(vector)
	vector=double(vector);
	light=sqrt(sum(double(vector).^2,3));
	not0=(light~=0);
	not0=repmat(not0,[1,1,3]);
	light=repmat(light,[1,1,3]);
	
	vector(~not0)=0;
	vector(not0)=vector(not0)./light(not0);
function [vectormask,dif]=vectorLayerMask_yzbx(frame,vecMask,layerpminSetMean,layerpmaxSetMean,layermean,layervecgap)
vec1=layerpmaxSetMean-layermean;
vec2=layermean-layerpminSetMean;
vec=(vec1+vec2)/2;

fvec=double(frame)-layermean;
for i=3:-1:1
    vec(:,:,i)=vec(:,:,i)./(vec(:,:,1)+1);
    fvec(:,:,i)=fvec(:,:,i)./(fvec(:,:,1)+1);
end

dif=cross(vec,fvec,3);
dif=sum(dif.^2,3);
vectormask=vecMask&(dif>layervecgap);
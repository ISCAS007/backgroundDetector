function layermask=layerFilter(frame,layer)
    layermask=true(size(frame,1),size(frame,2));
    for i=1:3
       a=((layer.layermin(:,:,i)-layer.layergap(:,:,i))<=frame(:,:,i))...
            &((layer.layermax(:,:,i)+layer.layergap(:,:,i))>=frame(:,:,i));
       layermask=layermask&a; 
    end
end
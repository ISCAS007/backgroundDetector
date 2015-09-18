function sphere=rgb2sphere(rgb)
    s=size(rgb);
    if(length(s)==2)
        [a,b]=size(rgb);
        sphere=[];
        if(b==3)
            sphere=zeros(a,2);
            sphere(:,1)=atan(rgb(:,1)./rgb(:,2));
            r=sqrt(rgb(:,1).^2+rgb(:,2).^2);
            sphere(:,2)=atan(rgb(:,3)./r);
        end
    end
    
    if(length(s)==3)
        [a,b,c]=size(rgb);
        sphere=[];
        if(c==3)
            sphere=zeros(a,b,2);
            sphere(:,:,1)=atan(rgb(:,:,1)./rgb(:,:,2));
            r=sqrt(rgb(:,:,1).^2+rgb(:,:,2).^2);
            sphere(:,:,2)=atan(rgb(:,:,3)./r);
        end
    end
end
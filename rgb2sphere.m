function sphere=rgb2sphere(rgb)
    [a,b]=size(rgb);
    sphere=[];
    if(b==3)
        sphere=zeros(a,2);
        sphere(:,1)=atan(rgb(:,1)./rgb(:,2));
        r=sqrt(rgb(:,1).^2+rgb(:,2).^2);
        sphere(:,2)=atan(r./rgb(:,3));
    end
end
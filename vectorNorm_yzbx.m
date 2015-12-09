function [vector,light]=vectorNorm_yzbx(a)
    s=size(a);
    vector=[];
    light=[];
    if(length(s)==3)
       [vector,light]=norm_yzbx(a);
    end
    
    if(length(s)==2)
        vector=double(a);
        light=sqrt(sum(vector.^2,2));
        not0=(light~=0);
        not0=repmat(not0,[1,3]);
        light2d=repmat(light,[1,3]);
        
        vector(~not0)=0;
        vector(not0)=vector(not0)./light2d(not0);
    end
    
    function [vector,light]=norm_yzbx(frame)
        vector=double(frame);
        light=sqrt(sum(vector.^2,3));
        not0=(light~=0);
        not0=repmat(not0,[1,1,3]);
        light3d=repmat(light,[1,1,3]);
        
        vector(~not0)=0;
        vector(not0)=vector(not0)./light3d(not0);
    end
end
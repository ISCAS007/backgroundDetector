function output=maskErrorVisulazation(mask,input,gt)
    output=input;
    
    FPError=mask&(~gt);
    FNError=(~mask)&gt;
    
    FPError=imdilate(FPError,strel('disk',1));
    FNError=imdilate(FNError,strel('disk',1));
    
    r=output(:,:,1);
    g=output(:,:,2);
    b=output(:,:,3);
    
    r(FPError)=255;
    g(FPError)=0;
    b(FPError)=0;
    
    output(:,:,1)=r;
    output(:,:,2)=g;
    output(:,:,3)=b;
    
    %FNError
    r=output(:,:,1);
    g=output(:,:,2);
    b=output(:,:,3);
    
    r(FNError)=0;
    g(FNError)=255;
    b(FNError)=0;
    
    output(:,:,1)=r;
    output(:,:,2)=g;
    output(:,:,3)=b;
end
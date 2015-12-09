function rbgThreshold(frame)
    %size(frame)=[width,height,3]
    %class(frame)=uint8
    
    [width,height,channel]=size(frame);
    if(channel~=3||class(frame)~='uint8')
        disp('unexpected frame');
    else
        
    end
end
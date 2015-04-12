function [MinBound,MaxBound,updateCycle]=SBCBParameterUpdate(frame,mask,MinBound,MaxBound,updateCycle,SBCBNum)
% struct array    
cc=bwconncomp(mask);
NumObjects=cc.NumObjects;
Area=sum(sum(mask));
frameArea=sum(sum((frame(:,:,1)>0)|(frame(:,:,2)>0)|(frame(:,:,3)>0)));
[width,height]=size(mask);
if(Area<0.5*frameArea)
    if((NumObjects<max(width,height))&&(SBCBNum<max(width,height)))    % 
        updateCycle=updateCycle+5;
    end

    MinBound(2:3)=min(MinBound(2:3)+5,30);
    MaxBound(2:3)=min(MaxBound(2:3)+5,30);
else
    updateCycle=updateCycle-1;
    sub=uint8(rand(1)>0.5);
    MinBound=MinBound-sub(1);
    MaxBound=MaxBound-sub(1);
end

end
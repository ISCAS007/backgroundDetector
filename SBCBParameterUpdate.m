function [MinBound,MaxBound,updateCycle]=SBCBParameterUpdate(frame,mask,MinBound,MaxBound,updateCycle,CBNum)
% struct array    
cc=bwconncomp(mask);
NumObjects=cc.NumObjects;
Area=sum(sum(mask));
frameArea=sum(sum((frame(:,:,1)>0)|(frame(:,:,2)>0)|(frame(:,:,3)>0)));
[width,height]=size(mask);
if(Area<0.5*frameArea)
    if((updateCycle<20)&&(NumObjects<max(width,height))&&(CBNum<max(width,height)))    % 
        updateCycle=updateCycle+2;
    end

    MinBound(2:3)=min(MinBound(2:3)+1,10);
    MaxBound(2:3)=min(MaxBound(2:3)+1,10);
else
    updateCycle=updateCycle-1;
    sub=uint8(rand(1)>0.5);
    MinBound(2:3)=MinBound(2:3)-sub(1);
    MaxBound(2:3)=MaxBound(2:3)-sub(1);
end

end
function [SBCDmask,SBCBarea]=SBCBFilter(frame,SBCB,SBCBNum,CBMinBound,CBMaxBound)
% SBCB: static background CodeBook
% SBCDmask: static backgournd mask
% LearnLow=1;
% LearnHigh=2;
% LearnMin=3;
% LearnMax=4;
% LearnTimeArea=5;  [updatetime,maxarea,~]
% SBCB=zeros(channel,5,1);
SBCBarea=zeros(SBCBNum,1);
[width,height,channel]=size(frame);
    for i=1:SBCBNum
        minmask=uint8(SBCB(:,3,i))-CBMinBound;
        maxmask=uint8(SBCB(:,4,i))+CBMaxBound;
        b=true(width,height);
        for j=1:channel
            a=((frame(:,:,j)>=minmask(j))&(frame(:,:,j)<=maxmask(j)));
            b=a&b;
        end
        SBCBarea(i)=sum(sum(b));
    end
    
    if(SBCBNum==0)
       SBCDmask=false(width,height); 
    else
       SBCDmask=b;
    end
end
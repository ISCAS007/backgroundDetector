function [CB,CBNum,CBClock]=clearCB(CB,CBNum,frameNum,CBUpdateCycle)
    CBClock=0;
    LearnTimeArea=5;
    time=zeros(CBNum,1);
    time(:)=CB(1,LearnTimeArea,:);
    area=zeros(CBNum,1);
    area(:)=CB(2,LearnTimeArea,:);
    time=frameNum-time;
    idx=(time<CBUpdateCycle)|(area>CBNum)|(area>CBUpdateCycle);
    CB=CB(:,:,idx);
    CBNum=sum(idx);
end
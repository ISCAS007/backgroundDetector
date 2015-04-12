function [CB,CBNum]=DBCBUpdate(frame,CB,CBNum,time,CBBound)
% CB: static background CodeBook
% SBCDNum: maybe size(CB,3) or not, the true Number of SBCD.
LearnLow=1;
LearnHigh=2;
LearnMin=3;
LearnMax=4;
LearnTimeArea=5;  %[updatetime,maxarea,~]
% CB=zeros(channel,5,1);

% step 1: rand 20 number
[width,height,channel]=size(frame);
offset=[0:channel-1]*width*height;
num=width*height;
pixel=zeros(3,1,'uint8');
for i=1:num
%     for j=1:channel
%        pixel(j,i)=frame(randNum(i,1),randNum(i,2),j); 
%     end
    pixel=frame(offset+i);
    match=false;
    matchid=0;
    for j=1:CBNum
        for k=1:channel
           if((pixel(k)<CB(k,LearnLow,j))||(pixel(k)...
                   >CB(k,LearnHigh,j)))
              break; 
           end
           if(k==channel)
               match=true;
               matchid=j;
           end
        end
        if(match)
            break;
        end
    end
    
    if(match)   %match then change learnhigh-low,max-min
        CB(:,LearnHigh,matchid)=CB(:,LearnHigh,matchid)+...
            double(CB(:,LearnHigh,matchid)<(pixel(:)+CBBound));
        CB(:,LearnLow,matchid)=CB(:,LearnLow,matchid)-...
            double(CB(:,LearnLow,matchid)>(pixel(:)-CBBound));
        CB(:,LearnMax,matchid)=max(double(pixel(:)),CB(:,LearnMax,matchid));
        CB(:,LearnMin,matchid)=min(double(pixel(:)),CB(:,LearnMin,matchid));

        CB(1,LearnTimeArea,matchid)=time;
        CB(2:3,1:4,matchid)=min(CB(2:3,1:4,matchid),5);
%         CB(2,LearnTimeArea,matchid)=max(CB(2,LearnTimeArea,matchid),a);
    else    %unmatch then add CB

        CBNum=CBNum+1;
        CB(:,LearnHigh,CBNum)=pixel(:)+CBBound;
        CB(:,LearnLow,CBNum)=pixel(:)-CBBound;
        CB(:,LearnMax,CBNum)=pixel(:);
        CB(:,LearnMin,CBNum)=pixel(:);
        CB(1,LearnTimeArea,CBNum)=time;
%         CB(2,LearnTimeArea,matchid)=a;
    end
end

end
function [CB,CBNum]=SBCBUpdate(frame,CB,CBNum,time,CBBound)
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
num=width+height;
randNum=zeros(num,2);
randNum(:,1)=randi(width,num,1);
randNum(:,2)=randi(height,num,1)-1;

offset=[0:channel-1]*width*height;
%id=i+(j-1)*width
id=randNum*[1;width];
pixel=zeros(3,num,'uint8');
for i=1:num
%     for j=1:channel
%        pixel(j,i)=frame(randNum(i,1),randNum(i,2),j); 
%     end
    pixel(:,i)=frame(offset+id(i));
    match=false;
    matchid=0;
    for j=1:CBNum
        for k=1:channel
           if((pixel(k,i)<CB(k,LearnLow,j))||(pixel(k,i)...
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
            double(CB(:,LearnHigh,matchid)<(pixel(:,i)+CBBound));
        CB(:,LearnLow,matchid)=CB(:,LearnLow,matchid)-...
            double(CB(:,LearnLow,matchid)>(pixel(:,i)-CBBound));
        CB(:,LearnMax,matchid)=max(double(pixel(:,i)),CB(:,LearnMax,matchid));
        CB(:,LearnMin,matchid)=min(double(pixel(:,i)),CB(:,LearnMin,matchid));

        CB(1,LearnTimeArea,matchid)=time;
        
        CB(2:3,1:4,matchid)=min(CB(2:3,1:4,matchid),5);
%         CB(2,LearnTimeArea,matchid)=max(CB(2,LearnTimeArea,matchid),a);
    else    %unmatch then add CB

        CBNum=CBNum+1;
        CB(:,LearnHigh,CBNum)=pixel(:,i)+CBBound;
        CB(:,LearnLow,CBNum)=pixel(:,i)-CBBound;
        CB(:,LearnMax,CBNum)=pixel(:,i);
        CB(:,LearnMin,CBNum)=pixel(:,i);
        CB(1,LearnTimeArea,CBNum)=time;
%         CB(2,LearnTimeArea,matchid)=a;
    end
end


end
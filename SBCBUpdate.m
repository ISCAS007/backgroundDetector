function [SBCB,SBCBNum]=SBCBUpdate(frame,SBCB,SBCBNum,time,CBBound)
% SBCB: static background CodeBook
% SBCDNum: maybe size(SBCB,3) or not, the true Number of SBCD.
LearnLow=1;
LearnHigh=2;
LearnMin=3;
LearnMax=4;
LearnTimeArea=5;  %[updatetime,maxarea,~]
% SBCB=zeros(channel,5,1);

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
    for j=1:SBCBNum
        for k=1:channel
           if((pixel(k,i)<SBCB(k,LearnLow,j))||(pixel(k,i)...
                   >SBCB(k,LearnHigh,j)))
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
        SBCB(:,LearnHigh,matchid)=SBCB(:,LearnHigh,matchid)+...
            double(SBCB(:,LearnHigh,matchid)<(pixel(:,i)+CBBound));
        SBCB(:,LearnLow,matchid)=SBCB(:,LearnLow,matchid)-...
            double(SBCB(:,LearnLow,matchid)>(pixel(:,i)-CBBound));
        SBCB(:,LearnMax,matchid)=max(double(pixel(:,i)),SBCB(:,LearnMax,matchid));
        SBCB(:,LearnMin,matchid)=min(double(pixel(:,i)),SBCB(:,LearnMin,matchid));

        SBCB(1,LearnTimeArea,matchid)=time;
%         SBCB(2,LearnTimeArea,matchid)=max(SBCB(2,LearnTimeArea,matchid),a);
    else    %unmatch then add CB

        SBCBNum=SBCBNum+1;
        SBCB(:,LearnHigh,SBCBNum)=pixel(:,i)+CBBound;
        SBCB(:,LearnLow,SBCBNum)=pixel(:,i)-CBBound;
        SBCB(:,LearnMax,SBCBNum)=pixel(:,i);
        SBCB(:,LearnMin,SBCBNum)=pixel(:,i);
        SBCB(1,LearnTimeArea,SBCBNum)=time;
%         SBCB(2,LearnTimeArea,matchid)=a;
    end
end

end
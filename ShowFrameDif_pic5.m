function ShowRGBPlus_pic4()
datatype={'dynamicBackground-boats'};

len=length(datatype);
close all;
for i=1:len
   matname=[datatype{i},'.mat']
   data=load(matname);
   showmat(data,matname,i);
end

for i=1:len
   h=figure(i);
   saveas(h,[datatype{i},'-FrameDifference'],'jpg');
end
function showmat(data,matname,i)

rgb=data.rgb;
class=data.class;

[~,~,c,d]=size(rgb);
% outroi=find(class(3,3,1,:)==85);
unknown=find(class(3,3,1,:)==170);
motion=find(class(3,3,1,:)==255);
shadow=find(class(3,3,1,:)==50);
static=find(class(3,3,1,:)==0);

if(isempty(unknown))
   unknown=1; 
end
if(isempty(motion))
    disp('warning: empty motion !!!');
    disp(data.path);
    disp(data.roipoint);
    motion=2;
end
if(isempty(shadow))
    shadow=3;
end
if(isempty(static))
    static=4;
end

basename=matname(1:end-4);
figure(i)
title([basename,'-FrameDifference'])

MotionFD=zeros(1,length(motion));
StaticFD=zeros(1,length(static));

background=rgb(3,3,1,1);
label=class(3,3,1,1);
mnum=1;
snum=1;
for i=2:d
    current=rgb(3,3,1,i);
    % motion
    if(class(3,3,1,i)>50)
       MotionFD(mnum)=abs(current-background);
       mnum=mnum+1;
    % static
    else
        StaticFD(snum)=abs(current-background);
        snum=snum+1;
    end
    
    label=class(3,3,1,i);
    if(label<=50)
       background=rgb(3,3,1,i); 
    end
end

MotionFD=MotionFD(1:mnum-1);
StaticFD=StaticFD(1:snum-1);

subplot(1,2,1);
hist(StaticFD,20);
xlabel('value');
ylabel('frequency');
title('static frame difference');
subplot(1,2,2);
hist(MotionFD,20);
xlabel('value');
ylabel('frequency');
title('motion frame difference');
function ShowRGBPlus_pic4()
datatype={'dynamicBackground-boats'};

len=length(datatype);
close all;
for i=1:len
   matname=[datatype{i},'.mat']
   data=load(matname);
   showmat(data,matname,i*2);
end

for i=1:len
   h=figure(2*i);
   saveas(h,[datatype{i},'-RGBPlus1'],'jpg');
   h=figure(2*i+1);
   saveas(h,[datatype{i},'-RGBPlus2'],'jpg');
end
function showmat(data,matname,i)

M=5260;
N=5340;
rgb=data.rgb(:,:,:,M:N);
class=data.class(:,:,:,M:N);

[~,~,c,d]=size(rgb);
class(3,3,1,1)=170;
class(3,3,1,2)=255;
class(3,3,1,3)=50;
class(3,3,1,4)=0;
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
title([basename,'-RGB'])

marktype={'>','s','o','+'};
sizetype={36,36,36,3};
colortype={'r','g','b','k'};
plotdatas={static,motion};

pd=plotdatas{1};
R=rgb(3,3,1,pd);
R=R(:);
G=rgb(3,3,2,pd);
G=G(:);
B=rgb(3,3,3,pd);
B=B(:);

pd_gray=plotdatas{2};
gray=mean(rgb(3,3,:,pd_gray),3);
gray=gray(:);

plot(pd,R,'--+',pd,G+10,'--s',pd,B+20,':>',pd_gray,gray,':o');
xlabel('time');
ylabel('pixel value');
title('R,G+10,B+10');
legend('R','G+10','B+10','motion');

figure(i+1);
R_static=R;
R_motion=rgb(3,3,1,pd_gray);
R_motion=R_motion(:);
plot(pd,R_static,'--+',pd_gray,R_motion,':>');
xlabel('time');
ylabel('R value');
title('static,motion');
legend('static','motion');
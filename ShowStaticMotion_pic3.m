function ShowStaticMotion_pic3()
datatype={'baseline-highway','dynamicBackground-boats'};

len=length(datatype);
close all;
for i=1:len
   matname=[datatype{i},'.mat']
   data=load(matname);
   showmat(data,matname,i);
end

for i=1:len
    h=figure(i);
    saveas(h,[datatype{i},'-Sphere'],'jpg');
%     print(h,'-djpeg','-r300',[datatype,'-static-gray-',imagetype{j},'.jpeg'])
end

function showmat(data,matname,i)

rgb=data.rgb;
class=data.class;

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

for i=1:2
    pd=plotdatas{i};
    X=rgb(3,3,1,pd);
    Y=rgb(3,3,2,pd);
    Z=rgb(3,3,3,pd);
    subplot(1,2,1);
    scatter3(X,Y,Z,sizetype{i},colortype{i},marktype{i},'fill');
    hold on;
    
    subplot(1,2,2);
    newrgb=reshape(rgb(3,3,:,:),[c,d])';
    sphere=rgb2sphere(newrgb);
    A=sphere(pd,1);
    B=sphere(pd,2);
    scatter(A,B,sizetype{i},colortype{i},marktype{i},'fill');
    hold on;
end

subplot(1,2,1)
xlabel('R');
ylabel('G');
zlabel('B');
% legend('static','motion')

subplot(1,2,2)
xlabel('\alpha')
ylabel('\theta')
legend('static','motion')


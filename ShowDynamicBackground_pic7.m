function ShowDynamicBackground_pic7()
% datatype={'dynamicBackground'};
% subtype={'boats','canoe','fall','overpass','fountain01','fountain02'};

datatype={'shadow'};
subtype={'backdoor','bungalows','busStation','copyMachine','cubicle','peopleInShade'};

len=length(subtype);
close all;
for i=1:len
   matname=[datatype{1},'-',subtype{i},'.mat']
   data=load(matname);
   showmat(data,matname,i);
end

for i=1:len
   h=figure(i);
   saveas(h,[datatype{1},'-',subtype{i},'-dynamicBackground'],'jpg');
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
title([basename,'-dynamicBackground'])

marktype={'>','s','o','+'};
sizetype={36,36,36,3};
colortype={'r','g','b','k'};
plotdatas={static,motion,shadow};
len=length(plotdatas);

for i=1:len
    pd=plotdatas{i};
    r=rgb(3,3,1,pd);
    g=rgb(3,3,2,pd);
    scatter(r,g,sizetype{i},colortype{i},marktype{i});
    hold on;
end

xlabel('R');
ylabel('G');
legend('static','motion','shadow');
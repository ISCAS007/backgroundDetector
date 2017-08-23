function ShowStaticGray_pic1()
datatype='baseline';
datasubtype={'highway','office','pedestrians','PETS2006'};
imagetype={'scatter','hist','plot'};

close all;
for i=1:4
   for j=1:3
      matname=[datatype,'-',datasubtype{i},'.mat']
      data=load(matname);
      showmat(data,matname,i,j);
   end
end

for j=1:3
    h=figure(j);
    saveas(h,[datatype,'-static-gray-',imagetype{j}],'jpg');
%     print(h,'-djpeg','-r300',[datatype,'-static-gray-',imagetype{j},'.jpeg'])
end

function showmat(data,matname,i,j)

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
    motion=1;
end
if(isempty(shadow))
    shadow=1;
end
if(isempty(static))
    static=1;
end

basename=matname(1:end-4);
% h=figure('Name',[basename,': static gray feature']);
gray=mean(rgb,3);
gray_static=gray(3,3,1,static);
gray_static=gray_static(:);

figure(j)
subplot(2,2,i);
% set(gca,'FontSize',20);

if j==1
    scatter(static,gray_static,3);
    xlabel(gca,'time');
    ylabel(gca,'gray value');
end

if j==2
   hist(gray_static);
    xlabel(gca,'gray value');
    ylabel(gca,'frequency'); 
end

if j==3
    plot(static,gray_static);
    xlabel(gca,'time');
    ylabel(gca,'gray value');
end

% set(get(gca,'xlabel'),'fontsize',30)
% set(get(gca,'ylabel'),'fontsize',30)
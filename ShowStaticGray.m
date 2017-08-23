function ShowStaticGray()
% windows
% root='D:\firefoxDownload\matlab\dataset2012\dataset';

% linux
% root='/media/yzbx/Windows7_OS/ComputerVision/Dataset/dataset';
datacfg

pathlist1=dir(root);
filenum1=length(pathlist1);
filenamelist1={pathlist1.name};
for i=3:filenum1
%     if(i~=6)
%        continue; 
%     end
   pathlist2=dir(fullfile(root,filenamelist1{i}));
   filenum2=length(pathlist2);
   filenamelist2={pathlist2.name};
   for j=3:filenum2
%        if(j~=4)
%            continue;
%        end
       disp([i,j]);
       path=fullfile(root,filenamelist1{i},filenamelist2{j})
       matname=path2matname(path);
       data=load(matname);
       showmat(data,matname);
   end
end

function showmat(data,matname)

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

close all;
basename=matname(1:end-4);
% h=figure('Name',[basename,': static gray feature']);
gray=mean(rgb,3);
gray_static=gray(3,3,1,static);
gray_static=gray_static(:);
% sh1=subplot(1,3,1);
% sh1=figure('Name',[basename,': static gray feature scatter']);
sh1=figure(1);
scatter(static,gray_static,3);
xlabel(gca,'time');
ylabel(gca,'gray value');
% sh2=subplot(1,3,2);
% sh2=figure('Name',[basename,': static gray feature hist']);
sh2=figure(2);
hist(gray_static);
xlabel(gca,'gray value');
ylabel(gca,'frequency');
% sh3=subplot(1,3,3);
% sh3=figure('Name',[basename,': static gray feature plot']);
sh3=figure(3);
plot(static,gray_static);
xlabel(gca,'time');
ylabel(gca,'gray value');

saveas(sh1,[basename,'-static-gray-scatter'],'jpg');
saveas(sh2,[basename,'-static-gray-hist'],'jpg');
saveas(sh3,[basename,'-static-gray-plot'],'jpg');
% saveas(h,[basename,'-static-gray'],'jpg');
function dataset2012()
% 对数据集dataset2012进行遍历的标准设置
root='D:\firefoxDownload\matlab\dataset2012\dataset';
% layernum=3;
pathlist1=dir(root);
filenum1=length(pathlist1);
filenamelist1={pathlist1.name};

for i=7:filenum1
    %    if(i<6)
    %        continue;
    %    end
    pathlist2=dir([root,'\',filenamelist1{i}]);
    filenum2=length(pathlist2);
    filenamelist2={pathlist2.name};
    for j=3:filenum2
%         if(i==6&&j<4)
%             continue;
%         end
        path=[root,'\',filenamelist1{i},'\',filenamelist2{j}];
%         pathlist3=dir([path,'\input']);
%         filenum3=length(pathlist3);
%         filenamelist3={pathlist3.name};
%         
%         pathlist4=dir([path,'\groundtruth']);
%         filenamelist4={pathlist4.name};
%         filename=path2filename(path);
%         show_yzbx(filename,i,j);
%         roiframeNum=load([path,'\temporalROI.txt']);
%         frameNum=0;
			(path);
%         ReverseMatching(path);
                break;
    end
    %     break;
end

function filename=path2filename(path)
root='D:\firefoxDownload\matlab\dataset201*\dataset\';
start=length(root);
shortpath=path(start+1:end);
filename=strrep(shortpath,'\','-');
filename=[filename,'.mat'];

function show_yzbx(filename,i,j)
load(filename);
[~,~,~,d]=size(rgb);
%     outroi=find(class(3,3,1,:)==85);
unknown=find(class(3,3,1,:)==170);
motion=find(class(3,3,1,:)==255);
shadow=find(class(3,3,1,:)==50);
static=find(class(3,3,1,:)==0);

if(isempty(unknown))
    unknown=1;
end
if(isempty(motion))
    disp([i,j]);
    disp(filename);
    motion=1;
end
if(isempty(shadow))
    shadow=1;
end
if(isempty(static))
    shadow=1;
end

r=zeros(1,d);
g=zeros(1,d);
b=zeros(1,d);
r(:)=rgb(3,3,1,:);
g(:)=rgb(3,3,2,:);
b(:)=rgb(3,3,3,:);
% color=class(3,3,1,:);

% show2DScatter(r,g,static,unknown,motion,shadow,[filename,'-r,g'],[filename(1:end-4),'-rg'],'r','g');
% show2DScatter(g,b,static,unknown,motion,shadow,[filename,'-g,b'],[filename(1:end-4),'-gb'],'g','b');
% show2DScatter(g,b,static,unknown,motion,shadow,[filename,'-b,r'],[filename(1:end-4),'-br'],'b','r');
%
% show3DScatter(r,g,b,static,unknown,motion,shadow,[filename,'-r,g,b'],[filename(1:end-4),'-rgb'],'r','g','b');
showLight(r,g,b,static,unknown,motion,shadow,[filename,'-r,g,b,l'],[filename(1:end-4),'-rgbl']);

%     r=rr;
%     h=figure,scatter(static,r(static),5,'red'),title([filename,'-r_static']);
%     hold on,plot(1:d,r);
%     legend('static','r');
%     saveas(h,[filename,'-r_static'],'jpg');
%
%     h=figure,scatter(motion,r(motion),5,'red'),title([filename,'-r_motion']);
%     hold on,plot(1:d,r);
%     legend('motion','r');
%     saveas(h,[filename,'-r_motion'],'jpg');


function show2DScatter(r,g,static,unknown,motion,shadow,titlestr,filestr,xstr,ystr)
h=figure('Name',titlestr);
psize=7;
scatter(r(static),g(static),psize,'fill'),title(titlestr),xlabel(xstr),ylabel(ystr);
hold on,scatter(r(unknown),g(unknown),psize,'fill');
scatter(r(motion),g(motion),psize,'fill');
scatter(r(shadow),g(shadow),psize,'fill');
poly=polyfit(r(static),g(static),1);
x=1:255;
y=poly(1)*x+poly(2);
plot(x,y,'red');
legend('static','unknown','motion','shadow','fit line','Location','Best');
saveas(h,filestr,'jpg');
close(h);

function show3DScatter(r,g,b,static,unknown,motion,shadow,titlestr,filestr,xstr,ystr,zstr)
h=figure('Name',titlestr);
psize=7;
scatter3(r(static),g(static),b(static),psize,'fill');title(titlestr),xlabel(xstr),ylabel(ystr),zlabel(zstr);
hold on,scatter3(r(unknown),g(unknown),b(unknown),psize,'fill');
scatter3(r(motion),g(motion),b(motion),psize,'fill');
scatter3(r(shadow),g(shadow),b(shadow),psize,'fill');
x=min(50,min(r(static))):max(200,max(r(static)));

p=linefit3d(r(static),g(static),b(static));
y=p(2)+x*p(5);
z=p(3)+x*p(6);
plot3(x,y,z,'red');
legend('static','unknown','motion','shadow','fit line','Location','Best');
saveas(h,filestr,'jpg');
close(h);

function showLight(r,g,b,static,unknown,motion,shadow,titlestr,filestr)
l=sqrt(sum([r.^2;g.^2;b.^2],1));
len=length(l);
linewidth=2;
% markersize=10;
psize=10;
h=figure('Name',titlestr);title(titlestr);
hold on;
plot(1:len,r,'LineWidth',linewidth,...
    'Color',[1,0,0],...
    'DisplayName','r');
plot(1:len,g,'LineWidth',linewidth,...
    'Color',[0,1,0],...
    'DisplayName','g');
plot(1:len,b,'LineWidth',linewidth,...
    'Color',[0,0,1],...
    'DisplayName','b');
plot(1:len,l,'LineWidth',linewidth,...
    'Color',[1,1,0],...
    'DisplayName','l');
scatter(static,l(static),psize,'fill','DisplayName','static');
scatter(unknown,l(unknown),psize,'fill','DisplayName','unknown');
scatter(motion,l(motion),psize,'fill','DisplayName','motion');
scatter(shadow,l(shadow),psize,'fill','DisplayName','shadow');
xlabel('t');
ylabel('r,g,b,l');
legend('toggle');
legend('Location','BestOutside');
saveas(h,filestr,'jpg');
close(h);
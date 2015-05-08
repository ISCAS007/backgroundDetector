function layer=ReverseMatching(root)
% reverse Matching and reverse learn by groundtruth.

% global var ***************
roiframeNum=load([root,'\temporalROI.txt']);

pathlist3=dir([root,'\input']);
filenamelist3={pathlist3.name};

pathlist4=dir([root,'\groundtruth']);
filenamelist4={pathlist4.name};


input=[];
gtruth=[];
frameNum=roiframeNum(1);
dif1=[];
dif2=[];
dif3=[];
dif4=[];
mask1=[];
mask2=[];
mask3=[];
mask4=[];
h=figure;
set(h,'numberTitle','off');
% global var end****************

% init layer **************
readFrame();
% frameNum=frameNum-1;
[a,b,c]=size(input);

layer=struct(...
'max',zeros(a,b,c,'double'),...
'min',zeros(a,b,c,'double'),...
'gap',ones(a,b,c,'double')*5,...
'mean',zeros(a,b,c,'double'),...
'rangeratio',ones(a,b,c,'double')*0.5,...
'fc',zeros(a,b,'uint32'),...
'bc',ones(a,b,'uint32'),...
'dc',zeros(a,b,'uint32'),...
'pminSetMean',zeros(a,b,c,'double'),...
'pmaxSetMean',zeros(a,b,c,'double'),...
'pminnum',zeros(a,b,'uint32'),...
'pmaxnum',zeros(a,b,'uint32'),...
'vecgap',ones(a,b,'double')*0.01,...
'vecdifmax',zeros(a,b,'double'),...
'vecdifmin',zeros(a,b,'double'),...
'vecdifmean',zeros(a,b,'double'),...
'vecdifratio',ones(a,b,'double')*0.5,...
'minvecgap',0.01,...
'mmgnoise',zeros(1,2,'double'),...
'mmrnoise',zeros(1,2,'double'),...
'vecnoise',zeros(1,2,'double'),...
'gapinc',5,...
'minarea',a*b/1000,...
'bw1',false(a,b),...
'a',0.05,...
'frameNum',1);

layer.mean=double(input);
layer.max=double(input);
layer.min=double(input);
% init layer end **************
lh=figure;
while frameNum<=roiframeNum(2)
	readFrame();
	layerFilter();
    showFrame();
    
    light=sqrt(double(sum(input.^2,3)));
    light=light/max(light(:));
    figure(lh);
    imshow(imadjust(light));
    %layerUpdate may change mask for update convinience.
	layerUpdate();  
end

function readFrame()
	input=imread([root,'\input\',filenamelist3{frameNum+2}]);
	gtruth=imread([root,'\groundtruth\',filenamelist4{frameNum+2}]);
    gtruth=(gtruth==255);
	frameNum=frameNum+1;
end
function showFrame()
	set(h,'Name',[num2str(frameNum),'/',num2str(roiframeNum(2))]);
    figNum=3;
    figure(h);
	subplot(2,figNum,1,'replace'),imshow(input),title('input');
	subplot(2,figNum,2,'replace'),imshow(gtruth),title('groundtruth');
    subplot(2,figNum,3,'replace'),imshow(mask3dTo2d(mask1)),title('mask1');
%     subplot(2,figNum,4,'replace'),imshow(mask3dTo2d(mask2)),title('mask2');
    subplot(2,figNum,4,'replace'),imshow(mask3dTo2d(mask1)|mask4),title('mask1|mask4');
    subplot(2,figNum,5,'replace'),imshow(mask3),title('mask3');
    subplot(2,figNum,6,'replace'),imshow(mask4),title('mask4');
	pause(0.1);
end
function layerFilter()
% mask1=(frame<(max+gap))&(frame>(min-gap))
    dif1max=double(input)-layer.max;
    dif1min=layer.min-double(input);
    dif1=max(dif1max,dif1min);
% 	mask1=(double(input)>(layer.max+layer.gap))|(double(input)<(layer.min-layer.gap));
    mask1=(double(input)>layer.max)|(double(input)<layer.min);
% mask2=(frame-mean)>(max-min+2*gap).*rangeratio
	dif2=abs(double(input)-layer.mean)./(layer.max-layer.min+2*layer.gap);
	mask2=abs(double(input)-layer.mean)>((layer.max-layer.min+2*layer.gap).*layer.rangeratio);
% mask3=cross(frame,vector)>vecgap
	[mask3,dif3]=getVecgapMask(layer,input);
    [mask4,dif4]=getVecMask4(layer,input);
end	
function layerUpdate()
    if(layer.frameNum<100)
        mask1=repmat(gtruth,[1,1,3]);
        mask2=repmat(gtruth,[1,1,3]);
        mask3=gtruth;
        mask4=gtruth;
    end
    
    layer.gap(mask1)=dif1(mask1)-layer.a*layer.gap(mask1)/1;
    layer.gap(~mask1)=dif1(~mask1)+layer.a*layer.gap(~mask1)/1+10;
    
% 	layer.max=max(layer.max,double(mask_yzbx(input,gtruth)));
% 	layer.min=min(layer.min,double(mask_yzbx(input,gtruth)));
    layer.max(~mask1)=max(layer.max(~mask1),double(input(~mask1)));
    layer.min(~mask1)=min(layer.min(~mask1),double(input(~mask1)));
    
    layer.mean(~mask2)=layer.mean(~mask2)*(1-layer.a)+double(input(~mask2))*layer.a;
%     layer.rangeratio(mask2)=dif2(mask2).*(1-layer.rangeratio(mask2)*layer.a/1);
    layer.rangeratio(~mask2)=dif2(~mask2).*(1+layer.rangeratio(~mask2)*layer.a/1)*1.1;
    
    layer.vecgap(mask3)=dif3(mask3)-layer.a*layer.vecgap(mask3)/1;
    layer.vecgap(~mask3)=dif3(~mask3)+layer.a*layer.vecgap(~mask3)/1+0.01;
    
    layer.vecdifmax(~mask4)=max(layer.vecdifmax(~mask4),dif4(~mask4));
    layer.vecdifmin(~mask4)=min(layer.vecdifmin(~mask4),dif4(~mask4));
    layer.vecdifmean(~mask4)=layer.vecdifmean(~mask4)*(1-layer.a)+dif4(~mask4)*layer.a;
%     layer.vecdifratio(mask4)=dif4(mask4).*(1-layer.vecdifratio(mask4)*layer.a/1);
    layer.vecdifratio(~mask4)=dif4(~mask4).*(1+layer.vecdifratio(~mask4)*layer.a/1)*1.1;
end

function mask=mask3dTo2d(maski)
    mask=maski(:,:,1)|maski(:,:,2)|maski(:,:,3);
%     mask=maski(:,:,1)&maski(:,:,2)&maski(:,:,3);
end

end
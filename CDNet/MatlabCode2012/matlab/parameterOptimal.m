function OptParam=parameterOptimal()
% inputPath: input path
% groundtruePath: groundtrue path
% resultPath: restore the result
% inputPath,groundtruePath,resultPath

countMax=10:20;
floatValue=3:10;
path='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\fall';
resultPath='E:\yzbx_programe\Matlab\gmm\MatlabCode2012\matlab\result';

OptParam=zeros(length(countMax),length(floatValue));

for i=1:length(countMax)
    for j=1:length(floatValue)
%             countMax(i)
%             floatValue(j)
            result=getResult(path,resultPath,countMax(i),floatValue(j));
            OptParam(i,j)=result;
    end
end

end

function result=getResult(path,resultPath,countMax,floatValue)
    layer=[];
    input=[];
    gtruth=[];
    
        
%     range=load([path,'\temporalROI.txt']);
%     range(2)=range(1)+200;
    range=[1400,1600];
    frameNum=range(1)-20;
    pathlist3=dir([path,'\input']);
%     pathlist3=dir(inputPath);
    filenamelist3={pathlist3.name};

    pathlist4=dir([path,'\groundtruth']);
%     pathlist4=dir(groundtruePath);
    filenamelist4={pathlist4.name};
    F=0;
    
    while frameNum<=range(2)
       readFrame();
       [layer,mixtureMask]=mixtureSubstraction(layer,input,countMax,floatValue);
%        imwrite(mixtureMask,[resultPath,'\',filenamelist4{frameNum+2}],'jpg');
       
       if(frameNum>=range(1))
            F=F+getF(gtruth,mixtureMask);
       end
       subplot(131);imshow(input);title(['input-',num2str(countMax)]);
       subplot(132);imshow(gtruth);title(['gtruth-',num2str(floatValue)]);
       subplot(133);imshow(mixtureMask);title(['mixtureMask',num2str(frameNum)]);
       pause(0.01);
       frameNum=frameNum+1;
    end
    
    result=F/(range(2)-range(1)+1);
    
    function readFrame()
    input=imread([path,'\input\',filenamelist3{frameNum+2}]);
    gtruth=imread([path,'\groundtruth\',filenamelist4{frameNum+2}]);
%     gtruth=(gtruth==255);
%     frameNum=frameNum+1;
%     pause(0.1);
    end

    function F=getF(imGT,imBinary)
        TP = sum(sum(imGT==255&imBinary==1));		% True Positive 
        TN = sum(sum(imGT<=50&imBinary==0));		% True Negative
        FP = sum(sum((imGT<=50)&imBinary==1));	% False Positive
        FN = sum(sum(imGT==255&imBinary==0));		% False Negative
        
%         if(TP+FP==0)
%             precision=1;
%         else
%             precision=TP/(TP+FP);
%         end
%         
%         if(TP+FN==0)
%             recall=1;
%         else
%             recall=TP/(TP+FN);
%         end
%         
%         F=2*precision*recall/(precision+recall)
% Percentage of Wrong Classifications
        PWC=100 * (FN + FP) / (TP + FN + FP + TN);
        F=PWC;
    end
end



function [layer,mixtureMask]=mixtureSubstraction(layer,frame,countMax,floatValue)
% init and update layer at the same time
    [a,b,c]=size(frame);
    [vector,light]=norm_yzbx();
    tmpMask=false(a,b);
%     se=strel('disk',3);
    if(isempty(layer))
       layer=init(); 
       mixtureMask=false(a,b);
    else
        lightMask=getLightMask();
        
        [hardMask,crossDistance]=getHardMask();
        softMask=getSoftMask();
        mixtureMask=getMixtureMask();
        updateLightModel();
        updateVectorModel();
        
%         maskShow();
    end
    
    function [vector,light]=norm_yzbx()
        vector=double(frame);
        light=sqrt(sum(vector.^2,3));
        not0=(light~=0);
        not0=repmat(not0,[1,1,3]);
        light3d=repmat(light,[1,1,3]);
        
        vector(~not0)=0;
        vector(not0)=vector(not0)./light3d(not0);
    end

    function maskShow()
        subplot(431);imshow(lightMask);title('lightMask');
        subplot(432);imshow(softMask);title('softMask');
        subplot(433);imshow(hardMask);title('hardMask');
        subplot(437);imshow(layer.lightMax/765);title('lightMax');
        subplot(438);imshow(layer.SoftModel);title('SoftModel');
        subplot(439);imshow(layer.HardModel);title('HardModel');
        subplot(4,3,10);imshow(light/765);title('light');
        subplot(4,3,11);imshow(vector);title('vector');
%         subplot(4,3,12);imshow(tmpMask);title('maxv|minv');
        subplot(4,3,12);imshow(tmpMask);title('tmpMask');
    end

    function layer=init()
        layer=struct(...
            'lightMin',zeros(a,b,'double'),...
            'lightMax',zeros(a,b,'double'),...
            'lightMinCount',zeros(a,b,'uint32'),...
            'lightMaxCount',zeros(a,b,'uint32'),...
            'model',zeros(a,b,c,'double'),...
            'SoftModel',zeros(a,b,c,'double'),...
            'HardModel',zeros(a,b,c,'double'),...
            'distanceMax',ones(a,b,'double')*0.01,...
            'distanceMaxCount',zeros(a,b,'uint32'),...
            'countMax',countMax,...
            'foreCount',zeros(a,b,'uint32'),...
            'minArea',round(a*b/1000),...
            'learnRate',0.05,...
            'floatValue',floatValue,...
            'init',false(1,5),...
            'trainNum',20,...
            'recentFrame',frame,...
            'frameNum',1);
        
        layer.SoftModel=vector;
        layer.HardModel=vector;
        layer.lightMax=light;
        layer.lightMin=light;
    end
    
    function lightMask=getLightMask()
        lightMask=(light>layer.lightMax)|(light<layer.lightMin);
        if(layer.frameNum>layer.trainNum)
%             lightMask=imopen(lightMask,se);
%             lightMask=imfill(lightMask,'holes');
            tmpMask=medfilt2(lightMask,[5,5]);
        end
%         lightMask=bwareaopen(lightMask,layer.minArea);
        lightMask=medfilt2(lightMask,[5,5]);
    end  

    function [hardMask,crossDistance]=getHardMask()
        layer.model=layer.HardModel;
        [hardMask,crossDistance]=getVectorMask();
    end

    function softMask=getSoftMask()
        layer.model=layer.SoftModel;
        [softMask,~]=getVectorMask();
    end

    function [vectorMask,crossDistance]=getVectorMask()
        crossVector=cross(layer.model,vector);
        crossDistance=sum(crossVector.^2,3);
        vectorMask=crossDistance>layer.distanceMax;
    end

    function mixtureMask=getMixtureMask()
%         
%         vectorMask=imclose(hardMask|softMask,se);
        vectorMask=medfilt2(hardMask|softMask,[5,5]);
        if(layer.frameNum<layer.trainNum)
%             mixtureMask=(hardMask|softMask)&lightMask;
%             mixtureMask=imopen(hardMask|lightMask,se)&imopen(softMask|lightMask,se);
%             mixtureMask=imclose(mixtureMask,se);
%             mixtureMask=imclose(hardMask|lightMask,se)&imclose(softMask|lightMask,se);
            mixtureMask=medfilt2(vectorMask|lightMask,[5,5]);
        else
%            mixtureMask=imopen(hardMask|lightMask,se)&imopen(softMask|lightMask,se);
%             mixtureMask=imclose(mixtureMask,se);
%             mixtureMask=imclose(hardMask|lightMask,se)&imclose(softMask|lightMask,se);
            mixtureMask=medfilt2(vectorMask|lightMask,[5,5]);
        end     
%         mixtureMask=imfill(mixtureMask,'holes');
%         mixtureMask=bwareaopen(mixtureMask,layer.minArea);
    end
    
    function updateLightModel()
        if(layer.frameNum>layer.trainNum)
            layer.lightMax(~lightMask)=max(layer.lightMax(~lightMask),light(~lightMask));
            layer.lightMin(~lightMask)=min(layer.lightMin(~lightMask),light(~lightMask));
            layer.lightMax(lightMask)=layer.lightMax(lightMask)*(1-layer.learnRate)+...
                max(layer.lightMax(lightMask),light(lightMask))*layer.learnRate;
            layer.lightMin(lightMask)=layer.lightMin(lightMask)*(1-layer.learnRate)+...
                min(layer.lightMin(lightMask),light(lightMask))*layer.learnRate;
        else
            layer.lightMax=max(layer.lightMax,light);
            layer.lightMin=min(layer.lightMin,light);
        end
        
        maxc=(layer.lightMax>=light-layer.floatValue)&(layer.lightMax<=light);
        minc=(layer.lightMin>=light)&(layer.lightMin<=light+layer.floatValue);
        
        
        layer.lightMinCount(minc)=0;
        layer.lightMinCount((~minc)&(~lightMask))=layer.lightMinCount((~minc)&(~lightMask))+1;
        
        layer.lightMaxCount(maxc)=0;
        layer.lightMaxCount((~maxc)&(~lightMask))=layer.lightMaxCount((~maxc)&(~lightMask))+1;
        
        
        
        maxv=layer.lightMaxCount>layer.countMax;
        minv=layer.lightMinCount>layer.countMax;
%         tmpMask=maxv|minv;
        
        layer.lightMaxCount(maxv)=ceil(layer.countMax/2);
        layer.lightMinCount(minv)=ceil(layer.countMax/2);
        layer.lightMax(maxv)=layer.lightMax(maxv)-1;
        layer.lightMin(minv)=layer.lightMin(minv)+1;
       
    end

    function updateVectorModel()
        layer.distanceMax(~mixtureMask)=max(layer.distanceMax(~mixtureMask),crossDistance(~mixtureMask));
        dc=(layer.distanceMax>crossDistance*(1-layer.learnRate))&(layer.distanceMax<crossDistance);
        layer.distanceMaxCount(dc)=0;
        layer.distanceMaxCount((~dc)&(~mixtureMask))=layer.distanceMaxCount((~dc)&(~mixtureMask))+1;
        
        vc=layer.distanceMaxCount>layer.countMax;
        layer.distanceMaxCount(vc)=ceil(layer.countMax/2);
%         tmpMask=vc;
        
        layer.distanceMax(vc)=layer.distanceMax(vc)*(1-layer.learnRate);
        
        layer.foreCount(mixtureMask)=layer.foreCount(mixtureMask)+1;
        layer.HardModel(~mixtureMask)=layer.HardModel(~mixtureMask)*(1-layer.learnRate)+vector(~mixtureMask)*layer.learnRate;
        layer.SoftModel=layer.SoftModel*(1-layer.learnRate)+vector*layer.learnRate;
        
        layer.frameNum=layer.frameNum+1;
    end
end
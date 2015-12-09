function [mask,kernel]=svmBgs2(input,kernel)
if(isempty(kernel))
    kernel=struct(...
        'gray',[],...
        'color',[]);
end

[mask,kernel.gray]=graySVMBgs(input,kernel.gray);
mask=bwareaopen(mask,20);

if(kernel.gray.frameNum>=kernel.gray.historyNum)
    [mask,kernel.color]=colorSVMBgs(input,mask,kernel.color);
end
fprintf('frameNum is %d \n',kernel.gray.frameNum);
end

function [mask,kernel]=graySVMBgs(input,kernel)
% use d gray image and d mask as history information
[a,b,c]=size(input);
if(c==1)
    gray=input;
else
    gray=rgb2gray(input);
end
mask=false(a,b);

if(~isempty(kernel))
    if(kernel.currentNum==kernel.historyNum)
        kernel.currentNum=1;
    else
        kernel.currentNum=kernel.currentNum+1;
    end
    
    kernel.inputHistory(:,:,kernel.currentNum)=gray;
    kernel.frameNum=kernel.frameNum+1;
    
    if(kernel.frameNum>=kernel.historyNum)
        mask=getGraySVMBgsMask(kernel);
    end
else
    kernel=initKernel(gray);
end

    function kernel=initKernel(gray)
        [aa,bb,cc]=size(gray);
        
        if(cc~=1)
            error('the input must be gray image in graySVMBgs');
        end
        
        d=30;
        load('svmModel.mat','graySVMModel');
        kernel=struct(...
            'inputHistory',zeros(aa,bb,cc,d,'uint8'),...
            'historyNum',d,...
            'currentNum',1,...
            'svmModel',graySVMModel,...
            'frameNum',1);
        
        kernel.inputHistory(:,:,1,1)=gray;
    end

    function mask=getGraySVMBgsMask(kernel)
        [aa,bb,cc,dd]=size(kernel.inputHistory);
        %generate ordered history feature
        if(kernel.currentNum<kernel.historyNum)
            idx=[kernel.currentNum+1:kernel.historyNum, ...
                1:kernel.currentNum];
            feature=reshape(kernel.inputHistory(:,:,1,idx),aa*bb,kernel.historyNum);
        else
            feature=reshape(kernel.inputHistory,aa*bb,kernel.historyNum);
        end
        
        %generate mask
        featureNum=size(feature,1);
        predict=zeros(featureNum,1);
        gap=10000;
        
        for j=1:gap:featureNum
            if(j+gap-1<=featureNum)
                predict(j:j+gap-1)=svmclassify(kernel.svmModel,feature(j:j+gap-1,:));
            else
                predict(j:featureNum)=svmclassify(kernel.svmModel,feature(j:featureNum,:));
            end
        end
        
        mask=reshape(predict,[aa,bb]);
    end
end

function [mask,kernel]=colorSVMBgs(input,mask,kernel)
% use d gray image and d mask as history information
[a,b,c]=size(input);
if(c==1)
    error('input must be rgb color image');
end

if(~isempty(kernel))
    if(kernel.currentNum==kernel.historyNum)
        kernel.currentNum=1;
    else
        kernel.currentNum=kernel.currentNum+1;
    end
    
    kernel.inputHistory(:,:,:,kernel.currentNum)=input;
    kernel.labelHistory(:,:,kernel.currentNum)=mask;
    kernel.frameNum=kernel.frameNum+1;
    
    if(kernel.frameNum>=kernel.historyNum)
        mask=getColorSVMBgsMask(kernel);
        kernel.labelHistory(:,:,kernel.currentNum)=mask;
    end
else
    kernel=initKernel(input,mask);
end

    function kernel=initKernel(input,mask)
        [aa,bb,cc]=size(input);
        
        if(cc==1)
            error('the input must be color image in colorSVMBgs');
        end
        
        d=3;
        load('svmModel.mat','colorSVMModel');
        kernel=struct(...
            'inputHistory',zeros(aa,bb,cc,d,'uint8'),...
            'labelHistory',false(aa,bb,d),...
            'historyNum',d,...
            'currentNum',1,...
            'svmModel',colorSVMModel,...
            'frameNum',1);
        
        kernel.inputHistory(:,:,:,1)=input;
        kernel.labelHistory(:,:,1)=mask;
    end

    function mask=getColorSVMBgsMask(kernel)
        [aa,bb,cc,dd]=size(kernel.inputHistory);
        %generate ordered history feature
        if(kernel.currentNum<kernel.historyNum)
            index=[kernel.currentNum+1:kernel.historyNum, ...
                1:kernel.currentNum];
            feature=getFeature(kernel.inputHistory(:,:,:,index),kernel.labelHistory(:,:,index));
        else
            feature=getFeature(kernel.inputHistory,kernel.labelHistory);
        end
        
        %generate mask
        featureNum=aa*bb;
        predict=zeros(featureNum,1);
        gap=10000;
        
        for j=1:gap:featureNum
            if(j+gap-1<=featureNum)
                predict(j:j+gap-1)=svmclassify(kernel.svmModel,feature(j:j+gap-1,:));
            else
                predict(j:featureNum)=svmclassify(kernel.svmModel,feature(j:featureNum,:));
            end
        end
        
        mask=reshape(predict,[aa,bb]);
        
        function feature=getFeature(inputs,masks)
            [aaa, bbb, ccc, ddd]=size(inputs);
            currentInput=inputs(:,:,:,ddd);
            currentMask=masks(:,:,ddd);
            inputs=reshape(inputs,aaa*bbb,ccc*ddd);
            masks=reshape(masks,aaa*bbb,ddd);
            
            windowSize=[3,5];
            thresholds=[5,10];
            w=length(windowSize);
            t=length(thresholds);
            inputSimility=zeros(aaa*bbb,w*t);
            count=0;

            for jj=1:w
                dw=floor(windowSize(jj)/2);
                idx=ceil(windowSize(jj)^2/2);
                
                enlargeImg=zeros(aaa+dw*2,bbb+dw*2);
                for kk=1:t
                    neighbor3=true(windowSize(jj)^2,aaa*bbb);
                    for mm=1:ccc
                        enlargeImg(dw+1:dw+aaa,dw+1:dw+bbb)=currentInput(:,:,mm);
                        neighbor=im2col(enlargeImg,...
                            [windowSize(jj) windowSize(jj)],'sliding');
                        neighbor=bsxfun(@minus,neighbor,neighbor(idx,:));
                        neighbor3=and(neighbor3,neighbor<thresholds(kk));
                    end
                    
                    count=count+1;
                    inputSimility(:,count)=sum(neighbor3)-1;
                    fprintf('count is %d\n',count);
                    
                end
            end
            
            maskSimility=zeros(aaa*bbb,w);
            for jj=1:w
                dw=floor(windowSize(jj)/2);
                img=false(aaa+2*dw,bbb+2*dw);
                img(dw+1:dw+aaa,dw+1:dw+bbb)=currentMask;
                
                neighbor=im2col(img,[windowSize(jj),windowSize(jj)],'sliding');
                
                maskSimility(:,jj)=sum(neighbor);
            end
            
            %inputs,masks,neighbour
            feature=[inputs,masks,inputSimility,maskSimility];
        end
        
    end
end
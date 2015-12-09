function [mask,kernel]=svmBgs1(input,kernel)
[mask,kernel]=basicBgs(input,kernel);
mask=bwareaopen(mask,20);
[mask,kernel]=svmBgs(input,mask,kernel,200);
kernel=updateKernel(mask,kernel);
fprintf('frameNum is %d \n',kernel.frameNum);
end

function [mask,kernel]=basicBgs(input,kernel)
[a,b,c]=size(input);
if(isempty(kernel))
    kernel=initKernel(input);
    mask=zeros(a,b);
else
    layerNum=max(kernel.layerNum(:));
    
    bg=false(a,b);
    for i=1:layerNum
        bgMask=(kernel.layerNum>=i);

        for j=1:c
            u=kernel.mean(:,:,j,i);
            in=input(:,:,j);
            sigma=kernel.std(:,:,j,i);
            
            bgMask=bgMask&(abs(double(u)-double(in))<3*sigma);
        end
        
        bg=bg|bgMask;
    end
    
    mask=~bg;
end

    function kernel=initKernel(input)
        [a,b,c]=size(input);
        d=20;
        layerNum=3;
        kernel=struct(...
            'mean',zeros(a,b,c,layerNum,'double'),...
            'std',ones(a,b,c,layerNum,'double')*5,...
            'layerNum',ones(a,b,'uint8'),...
            'inputHistory',zeros(a,b,c,d,'uint8'),...
            'labelHistory',false(a,b,d),...
            'historyNum',d,...
            'currentNum',1,...
            'frameNum',1);
        
        kernel.mean(:,:,:,1)=input;
        kernel.inputHistory(:,:,:,1)=input;
    end
end

function [mask,kernel]=svmBgs(input,mask,kernel,basicBgsNum)
[a,b,c]=size(input);
num=kernel.currentNum;
if(num==kernel.historyNum)
    num=1;
else
    num=num+1;
end
kernel.inputHistory(:,:,:,num)=input;
kernel.labelHistory(:,:,num)=mask;
kernel.currentNum=num;

if(kernel.frameNum>=3+basicBgsNum)
    inputs=zeros(a,b,c,3);
    masks=zeros(a,b,3);
    num=kernel.currentNum;
    
    for i=3:-1:1
        num=num-1;
        if(num==0)
            num=kernel.historyNum;
        end
        inputs(:,:,:,i)=kernel.inputHistory(:,:,:,num);
        masks(:,:,i)=255*kernel.labelHistory(:,:,num);
    end
    
    data=getFeature(inputs,masks,3);
    mask=getMask(data,input);
end

    function feature=getFeature(inputs,masks,currentNum)
        [aa, bb, cc, dd]=size(inputs);
        currentInput=inputs(:,:,:,currentNum);
        currentMask=masks(:,:,currentNum);
        inputs=reshape(inputs,aa*bb,cc*dd);
        masks=reshape(masks,aa*bb,dd);
        
        windowSize=[3,5];
        thresholds=[5,10];
        w=length(windowSize);
        t=length(thresholds);
        inputSimility=zeros(aa*bb,w*t);
        count=0;
        
%         pack;
        for jj=1:w
            dw=floor(windowSize(jj)/2);
            idx=ceil(windowSize(jj)^2/2);
            
            enlargeImg=zeros(aa+dw*2,bb+dw*2);
            for kk=1:t
                neighbor3=true(windowSize(jj)^2,aa*bb);
                for mm=1:cc
                    enlargeImg(dw+1:dw+aa,dw+1:dw+bb)=currentInput(:,:,mm);
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
        
        maskSimility=zeros(aa*bb,w);
        for jj=1:w
            dw=floor(windowSize(jj)/2);
            img=false(aa+2*dw,bb+2*dw);
            img(dw+1:dw+aa,dw+1:dw+bb)=currentMask;
            
            neighbor=im2col(img,[windowSize(jj),windowSize(jj)],'sliding');
            
            maskSimility(:,jj)=sum(neighbor);
        end
        
        %inputs,masks,neighbour
        feature=[inputs,masks,inputSimility,maskSimility];
    end

    function mask=getMask(data,input)
        [a,b,c]=size(input);
        featureNum=size(data,1);
        predict=zeros(featureNum,1);
        gap=10000;
        
        tmpData=...
            load('D:\firefoxDownload\matlab\dataset2012\PBAS_23\features-svm\intermittentObjectMotion-abandonedBox.mat');
        svmModel=tmpData.svmModel;
        clear tmpData;
        for j=1:gap:featureNum
            if(j+gap-1<=featureNum)
                predict(j:j+gap-1)=svmclassify(svmModel,data(j:j+gap-1,:));
            else
                predict(j:featureNum)=svmclassify(svmModel,data(j:featureNum,:));
            end
        end
%         predict=svmclassify(svmModel,data);
        
        mask=reshape(predict,[a,b]);
    end
end

function kernel=updateKernel(mask,kernel)
%update std,mean,layerNum
[a,b,c,d]=size(kernel.inputHistory);
input=kernel.inputHistory(:,:,:,kernel.currentNum);
kernel=layerSplit(mask,kernel,input);
kernel=NBHSpread(mask,kernel,input);

kernel.frameNum=kernel.frameNum+1;


    function kernel=layerSplit(mask,kernel,input)
        layerNum=max(kernel.layerNum(:));
        
        for i=1:layerNum
            layerMask=(kernel.layerNum==i)&(~mask);
            
            if(i==1)
                bgMask=layerMask;
                for j=1:c
                    bgMean=double(input(:,:,j));
                    kernelMean=kernel.mean(:,:,j,i);
                    kernelMean(bgMask)=(kernelMean(bgMask)*d+bgMean(bgMask))/(d+1);
                    kernel.mean(:,:,j,i)=kernelMean;
                    
                    bgStd=abs(double(input(:,:,j))-double(kernelMean));
                    kernelStd=kernel.std(:,:,j,i);
                    kernelStd(bgMask)=(kernelStd(bgMask)*d+bgStd(bgMask))/(d+1);
                    kernel.std(:,:,j,i)=kernelStd;
                end
            else
                layerR=kernel.mean(:,:,1,1:i);
                difR=zeros(a,b,1,i);
                inputR=double(input(:,:,1));
                for k=1:i
                    difR(:,:,1,k)=abs(layerR(:,:,1,k)-inputR);
                end
                
                [~,layerR]=min(difR,[],4);
                
                for k=1:i
                    bgMask=(layerR==k)&layerMask;
                    
                    for j=1:c
                        bgMean=input(:,:,j);
                        kernelMean=kernel.mean(:,:,j,1:i);
                        
                        kernelMean(bgMask)=(kernelMean(bgMask)*d+bgMean(bgMask))/(d+1);
                        kernel.mean(:,:,j,i)=kernelMean;
                        
                        bgStd=abs(double(input(:,:,j))-double(kernelMean));
                        kernelStd=kernel.std(:,:,j,i);
                        kernelStd(bgMask)=(kernelStd(bgMask)*d+bgStd(bgMask))/(d+1);
                        kernel.std(:,:,j,i)=kernelStd;
                    end
                    
                end
            end
        end
        
    end

    function kernel=NBHSpread(mask,kernel,input)
%         neighbourhood spread
       [a,b,c]=size(input);
       
       edgeArea=(mask-imerode(mask,strel('disk',1)));
       [row,col,~]=find(edgeArea);
       
       for i=1:length(col)
           x=row(i);
           y=col(i);
           
           if(x>1&&(~mask(x-1,y)))
               spreadBg(x,y,-1,0);
               continue;
           end
               
           if(x<a&&(~mask(x+1,y)))
              spreadBg(x,y,1,0);
               continue;
           end
           
           if(y>1&&(~mask(x,y-1)))
               spreadBg(x,y,0,-1);
               continue;
           end
           
           if(y<b&&(~mask(x,y+1)))
               spreadBg(x,y,0,1);
               continue;
           end
       end
       
        function spreadBg(x,y,dx,dy)
            [a,b,c,d]=size(kernel.inputHistory);
            bgMean=input(x+dx,y+dy,:);
            layerNum=kernel.layerNum(x,y);
            kernelMean=kernel.mean(x,y,:,1:layerNum);
            
            if(layerNum==1)
                for j=1:c
                    kernelMean(1,1,j,1)=(kernelMean(1,1,j,1)*d+bgMean(j))/(d+1);
                    kernel.mean(x,y,j,1)=kernelMean(1,1,j,1);

                    bgStd=abs(double(bgMean(j))-double(kernelMean(1,1,j,1)));
                    kernelStd=kernel.std(x,y,j,1);
                    kernelStd=(kernelStd*d+bgStd)/(d+1);
                    kernel.std(x,y,j,1)=kernelStd;
                end
            else
                layerR=kernel.mean(x,y,1,1:layerNum);
                difR=zeros(layerNum,1);
%                 inputR=double(input(:,:,1));
                inputR=double(bgMean(1));
                for k=1:layerNum
                    difR(k)=abs(layerR(k)-inputR);
                end
                
                [~,layerR]=min(difR,[],1);
                
                for j=1:c
                    kernelMean(1,1,j,layerR)=(kernelMean(1,1,j,layerR)*d+bgMean(j))/(d+1);
                    kernel.mean(x,y,j,layerR)=kernelMean(1,1,j,layerR);

                    bgStd=abs(double(bgMean(j))-double(kernelMean(1,1,j,layerR)));
                    kernelStd=kernel.std(x,y,j,layerR);
                    kernelStd=(kernelStd*d+bgStd)/(d+1);
                    kernel.std(x,y,j,layerR)=kernelStd;
                end
            end
        end
    end
end
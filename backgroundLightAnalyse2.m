function backgroundLightAnalyse2()
% 求整幅图中，像素之间的关系
% root='D:\firefoxDownload\matlab\dataset2012\dataset\shadow\bungalows';
root='D:\Program\matlab\dataset2012\dataset\dynamicBackground\fall';
% root='/media/yzbx/杞欢/firefoxDownload/matlab/dataset2012/dataset/dynamicBackground/fall';
roi=load([root,'\temporalROI.txt']);
roi(1)=1450;

staticImgRange=[];
staticImgMean=[];
staticImgMode=[];
staticFrameDif=[];

motionImgRange=[];
motionImgMean=[];
motionImgMode=[];
motionFrameDif=[];

spaceAnalyse();

% img=imread([groundTruthPath,'\',filelist{frameNum+2}]);
    function frame=getFrame(filepath,filelist,frameNum)
        frame=imread([filepath,'\',filelist{frameNum+2}]);
    end

    function spaceAnalyse()
        groundTruthPath=[root,'\groundtruth'];
        infolist=dir(groundTruthPath);
        groundTruthlist={infolist.name};
        
        inputPath=[root,'\input'];
        infolist=dir(inputPath);
        inputlist={infolist.name};
        
        frameNum=roi(1);
        groundTruth=getFrame(groundTruthPath,groundTruthlist,frameNum);
        [a,b]=size(groundTruth);
        motionCount=zeros(a,b);
        staticCount=motionCount;
        K=1000;
        
        staticSum=zeros(a,b);
        motionSum=staticSum;
        
        staticMax=zeros(a,b);
        motionMax=staticMax;
        
        staticMin=ones(a,b)*1000;
        motionMin=staticMin;
        
        frameDifNum=randi([2,K],1,1);
        while frameNum<=roi(2)
            if(frameNum-roi(1)>K)
                break;
            end
            
           groundTruth=getFrame(groundTruthPath,groundTruthlist,frameNum);
           input=getFrame(inputPath,inputlist,frameNum);
           gray=rgb2gray(input);
           static=(groundTruth==0);
           motion=(groundTruth==255);
           
          staticSum(static)=staticSum(static)+double(gray(static));
          motionSum(motion)=motionSum(motion)+double(gray(motion));
          staticCount=staticCount+double(static);
          motionCount=motionCount+double(motion);
          
          staticMax(static)=max(staticMax(static),double(gray(static)));
          staticMin(static)=min(staticMin(static),double(gray(static)));
          
          motionMax(motion)=max(motionMax(motion),double(gray(motion)));
          motionMin(motion)=min(motionMin(motion),double(gray(motion)));
          
           
          if(frameNum-roi(1)==frameDifNum)
                frameDif=abs(double(gray)-double(lastgray));
                display('get frameDif');
                staticFrameDif=frameDif(static);
%                 staticFrameDif(~static)=-1;
                
                motionFrameDif=frameDif(motion);
%                 motionFrameDif((~motion)=-1;
          end
            
          lastgray=gray;
           frameNum=frameNum+1;
           
        end
        
        
        save(['backgroundLightAnalyse2-1'],'staticMax','staticMin','staticSum',...
            'staticCount','motionMax','motionMin','motionSum','motionCount',...
            'staticFrameDif','motionFrameDif');
        
        staticImgRange=staticMax-staticMin;
        staticImgMean=double(staticSum)./double(staticCount);
        staticImgMode=mode(staticImgRange);
        
        motionImgRange=motionMax-motionMin;
        motionImgMean=double(motionSum)./double(motionCount);
        motionImgMode=mode(motionImgRange);
        
        
        show(groundTruth,input,K);
    end

    function show(groundTruth,input,K)
        h=figure;
        subplot(231),imshow(groundTruth),title('groundTruth');
        subplot(232),imshow(input),title('input');
        subplot(233),imshow(imadjust(staticImgRange/max(staticImgRange(:)))),title('staticImgRange');
        subplot(234),imshow(imadjust(staticImgMean/max(staticImgMean(:)))),title('staticImgMean');
        subplot(235),imshow(imadjust(motionImgRange/max(motionImgRange(:)))),title('motionImgRange');
        subplot(236),imshow(imadjust(motionImgMean/max(motionImgMean(:)))),title('motionImgMean');
        
        pause(1);
        saveas(h,['backgroundLightAnalyse2-1-',int2str(K)],'bmp');
%         close(h);
        
        h=figure;
        scatterSize=3;
        subplot(221),scatter(staticImgMean(:),staticImgRange(:),scatterSize),title('static');
        subplot(222),scatter(motionImgMean(:),motionImgRange(:),scatterSize),title('motion');
        
        subplot(223),hist(staticFrameDif(:)),title('staticFrameDif');
        subplot(224),hist(motionFrameDif(:)),title('motionFrameDif');
        pause(1);
        saveas(h,['backgroundLightAnalyse2-1-',int2str(K)],'bmp');
    end
    
    function img=lableImg(img,a,b)
%         lable the sample position in img
       [m,n,c]=size(img);
       if(c==1)
          g1=im2double(img);
%           g1(img)=1;
          img=cat(3,g1,g1,g1);
       else
          img=im2double(img);
       end
       
       color=[1,0,0];
       for i=a-5:a+5
          for j=b-5:b+5
              if(i>=1&&j>=1&&i<=m&&j<=n)
                 img(i,j,:)=color(:);
              end
          end
       end
    end

end
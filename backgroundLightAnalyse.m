function backgroundLightAnalyse()
% root='D:\firefoxDownload\matlab\dataset2012\dataset\shadow\bungalows';
root='D:\Program\matlab\dataset2012\dataset\dynamicBackground\fall';
roi=load([root,'\temporalROI.txt']);
roiImg=imread([root,'\ROI.bmp']);
roiMask=(roiImg~=0);

minLight=0;
maxLight=80;
darkArea=getInputArea(minLight,maxLight);
minLight=81;
maxLight=160;
modestArea=getInputArea(minLight,maxLight);
minLight=161;
maxLight=255;
brightArea=getInputArea(minLight,maxLight);

unstableArea=(~darkArea)&(~modestArea)&(~brightArea);
unstableArea(~roiMask)=false;

minValue=0;
maxValue=50;
background=getGroundTruthArea(minValue,maxValue);

minValue=0;
maxValue=0;
static=getGroundTruthArea(minValue,maxValue);


minValue=255;
maxValue=255;
motion=getGroundTruthArea(minValue,maxValue);

h=figure;
subplot(251),imshow(darkArea),title('darkArea');
subplot(252),imshow(modestArea),title('modestArea');
subplot(253),imshow(brightArea),title('brightArea');
subplot(254),imshow(background),title('background');
subplot(255),imshow(motion),title('motion');
subplot(2,5,10),imshow(unstableArea),title('unstableArea');

motionPixel2d=zeros(roi(2)-roi(1),1)-1;
staticPixel2d=motionPixel2d;
shadowPixel2d=motionPixel2d;

motionPixel3d=zeros(roi(2)-roi(1),3)-1;
staticPixel3d=motionPixel3d;
shadowPixel3d=motionPixel3d;

count=1;
show(darkArea&static);
show(modestArea&static);
show(brightArea&static);
show(unstableArea&static);
% img=imread([groundTruthPath,'\',filelist{frameNum+2}]);
    function frame=getFrame(filepath,filelist,frameNum)
        frame=imread([filepath,'\',filelist{frameNum+2}]);
    end

    function area=getInputArea(minLight,maxLight)
        inputPath=[root,'\input'];
        infolist=dir(inputPath);
        inputlist={infolist.name};
        
        frameNum=roi(1);
        input=getFrame(inputPath,inputlist,frameNum);
        [a,b,c]=size(input);
        area=true(a,b);
        
        K=500;
        for i=1:K
            input=getFrame(inputPath,inputlist,frameNum+i);
            gray=rgb2gray(input);
            mask=(gray<minLight)|(gray>maxLight);
            area(mask)=false;
        end
        
        area(~roiMask)=false;
    end

    function area=getGroundTruthArea(minLight,maxLight)
        groundTruthPath=[root,'\groundtruth'];
        infolist=dir(groundTruthPath);
        groundTruthlist={infolist.name};
        
        frameNum=roi(1);
        groundTruth=getFrame(groundTruthPath,groundTruthlist,frameNum);
        [a,b]=size(groundTruth);
        area=true(a,b);
        
        K=500;
        for i=1:K
            groundTruth=getFrame(groundTruthPath,groundTruthlist,frameNum+i);

            mask=(groundTruth<minLight)|(groundTruth>maxLight);
            area(mask)=false;
        end
        
        area(~roiMask)=false;
    end

    function show(targetArea)
        idx=find(targetArea(:));
        showNum=min(length(idx),10);
        randNum=randperm(length(idx));
        
        groundTruthPath=[root,'\groundtruth'];
        infolist=dir(groundTruthPath);
        groundTruthlist={infolist.name};
        
        inputPath=[root,'\input'];
        infolist=dir(inputPath);
        inputlist={infolist.name};
        
         for i=1:showNum
            pos=idx(randNum(i));    
            frameNum=roi(1);
            groundTruth=getFrame(groundTruthPath,groundTruthlist,frameNum);
            s=size(groundTruth);
            [a,b]=ind2sub(s,pos);
            
            motionPixel2d=zeros(roi(2)-roi(1),1)-1;
            staticPixel2d=motionPixel2d;
            shadowPixel2d=motionPixel2d;
            
            motionPixel3d=zeros(roi(2)-roi(1),3)-1;
            staticPixel3d=motionPixel3d;
            shadowPixel3d=motionPixel3d;
            
            getSample=false;
%             for j=1:frameNumK
            while frameNum<=roi(2)
                groundTruth=getFrame(groundTruthPath,groundTruthlist,frameNum);
                input=getFrame(inputPath,inputlist,frameNum);
                gray=rgb2gray(input);
                
                if(~getSample&&groundTruth(pos)==255)
                    inputSample=input;
                    groundTruthSample=groundTruth;
                    getSample=true;
                end
                
                
               
                if(groundTruth(pos)==0)
                    staticPixel2d(frameNum-roi(1)+1)=gray(a,b);
                    staticPixel3d(frameNum-roi(1)+1,:)=input(a,b,:);
                end
                
                if(groundTruth(pos)==50)
                    shadowPixel2d(frameNum-roi(1)+1)=gray(a,b);
                    shadowPixel3d(frameNum-roi(1)+1,:)=input(a,b,:);
                end
                
                if(groundTruth(pos)==255)
                    motionPixel2d(frameNum-roi(1)+1)=gray(a,b);
                    motionPixel3d(frameNum-roi(1)+1,:)=input(a,b,:);
                end
                
                frameNum=frameNum+1;         
            end
            
            if(getSample)
                subplot(256),imshow(lableImg(groundTruthSample,a,b)),title('groundTruth');
                subplot(257),imshow(lableImg(inputSample,a,b)),title('input');
                pause(1);
            end
            saveData(a,b);
%             func(h);
%             saveas(h,['PBAS-',int2str(i),'-',int2str(a),'-',int2str(b)],'bmp');
%             close(h);

        end
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

    function saveData(a,b)
       save(['backgroundLightAnalyse-',num2str(count)],'staticPixel2d','staticPixel3d','motionPixel2d','motionPixel3d','shadowPixel2d','shadowPixel3d');
       saveas(h,['backgroundLightAnalyse-',num2str(count),'-',int2str(a),'-',int2str(b)],'bmp');
       count=count+1;
    end
end
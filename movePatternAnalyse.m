function movePatternAnalyse()
    root='/media/yzbx/软件/firefoxDownload/matlab/dataset2012/dataset/dynamicBackground/fall';
    roi=load([root,'/temporalROI.txt']);
    roi(1)=1460;
    
    roiImg=imread([root,'/ROI.bmp']);
    roiMask=(roiImg~=0);
    
    [height,width]=size(roiImg);
    
    maxSampleNum=5;
%     queue=input+groundTruth
    queue=zeros(height,width,maxSampleNum*2,'uint8');
    queuePoint=1;
    movePatternDetect();
    
    function frame=getFrame(filepath,filelist,frameNum)
        frame=imread([filepath,'/',filelist{frameNum+2}]);
    end
    
    function pushToQueue(img,gt)
        queue(:,:,queuePoint)=img;
        queue(:,:,queuePoint+maxSampleNum)=gt;
        queuePoint=queuePoint+1;
        if(queuePoint>maxSampleNum)
            queuePoint=1;
        end
    end

    function [input,gt]=getImgFromQueue(queueNum)
        realPos=queuePoint+queueNum-1;
        if(realPos>maxSampleNum)
            realPos=realPos-maxSampleNum;
        end
        
        input=queue(:,:,realPos);
        gt=queue(:,:,realPos+maxSampleNum);
    end

    function lengthImg=getMovePatternLength()
        lengthImg=zeros(height,width,'uint8');
%         bigger queueNum meanning fresher frame
%         from fresher frame to older frame
        for queueNum=maxSampleNum:-1:1
            [~,gt]=getImgFromQueue(queueNum);
            
            len=maxSampleNum-queueNum+1;
            area=(lengthImg==(len-1))&(gt==255);
            lengthImg(area)=len;
        end
    end
    
    function vector=extractMovePattern(pos,len)
        vector=zeros(1,len,'uint8');
        [h,w]=ind2sub([height,width],pos);
%         vector from old to fresh, sub increase
%         queue from old to fresh, sub increase
        p=queuePoint;
        if(p>len)
                vector(1:len)=queue(h,w,p-len:p-1);
        else
                vector(len-p+2:len)=queue(h,w,1:p-1);
                vector(1:len-p+1)=queue(h,w,maxSampleNum-len+p:maxSampleNum);
        end
            
    end
    function result=movePatternMatched(input,sample,pos1,pos2)
     
        result=false;
        input=double(input)/255;
        sample=double(sample)/255;
        [a,b]=ind2sub([height,width],pos1);
        inputPos(1)=a/height;
        inputPos(2)=b/width;
        
        [a,b]=ind2sub([height,width],pos2);
        samplePos(1)=a/height;
        samplePos(2)=b/width;
        
%         max(posDif)=sum((1,1).^2)=2;
        posDif=sum((inputPos-samplePos).^2);
        posThreshold=0.1*length(input);
     
        if(max(abs(input-sample))<10/255&&posDif<posThreshold)
            result=true;
        end
    end

     function mask=getMovePatternMask(grayImg,fgCount,output)
        minSampleNum=2;
%         lengthImg=getMovePatternLength();
           lengthImg=fgCount;
           lengthImg(output)=0;
%         for i=1:width*height
%             if(lengthImg(i)>minSampleNum)
%                 
%             end
%         end
        mask=zeros(height,width,'uint8');
        for len=maxSampleNum:-1:minSampleNum
            idx1=find(lengthImg==len-1);
            idx2=find(lengthImg==len); 
            m=length(idx1);
            n=length(idx2);
            for i=1:m
%                 [h,w]=ind2sub([height,width],idx1(i));
                input=extractMovePattern(idx1(i),len-1);
                input(end+1)=grayImg(idx1(i));
                for j=1:n
                    sample=extractMovePattern(idx2(j),len);
                    if(movePatternMatched(input,sample,idx1(i),idx2(j)))
                        mask(idx1(i))=len;
                        break;
                    end
                end
            end
        end
     end
 
    function movePatternDetect()
        groundTruthPath=[root,'/groundtruth'];
        infolist=dir(groundTruthPath);
        groundTruthlist={infolist.name};
        
        inputPath=[root,'/input'];
        infolist=dir(inputPath);
        inputlist={infolist.name};
        
        frameNum=roi(1);
        groundTruth=getFrame(groundTruthPath,groundTruthlist,frameNum);
        [a,b]=size(groundTruth);
       
        K=40;
        fgCount=zeros(a,b);
        while frameNum<=roi(2)
            if(frameNum-roi(1)>K)
                break;
            end
            
           groundTruth=getFrame(groundTruthPath,groundTruthlist,frameNum);
           input=getFrame(inputPath,inputlist,frameNum);
           gray=rgb2gray(input);
          
         
          if(frameNum-roi(1)<maxSampleNum)
                pushToQueue(gray,groundTruth);
          else
              output=(rand(a,b)<0.8)&(groundTruth==255);
              mask=getMovePatternMask(gray,fgCount,output);
              figure;
              subplot(221),imshow(mask~=0),title('movePattern');
              subplot(222),imshow(groundTruth),title('gt');
              subplot(223),imshow(gray),title('input');
              subplot(224),imshow(output),title('output');
              pause(0.5);
               pushToQueue(gray,groundTruth);
          end
          
           fgCount=fgCount+1;
           fgCount(groundTruth~=255)=0;
           frameNum=frameNum+1;
        end
      
    end

end
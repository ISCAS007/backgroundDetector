function edgeAnalyse()
% D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\overpass
root='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\overpass';
roi=load([root,'\temporalROI.txt']);

motionK=getMotionK();
h=figure;
imshow(motionK);
saveas(h,'edgeAnalyse','bmp');
close(h);
show(motionK);

% img=imread([groundTruthPath,'\',filelist{frameNum+2}]);
    function frame=getFrame(filepath,filelist,frameNum)
        frame=imread([filepath,'\',filelist{frameNum+2}]);
    end

    function motionK=getMotionK()
%        get the postion of shadow which is shadow for K times or more.
        groundTruthPath=[root,'\groundtruth'];
        infolist=dir(groundTruthPath);
        filelist={infolist.name};
        frameNum=roi(1);
        groundTruth=getFrame(groundTruthPath,filelist,frameNum);
        [a,b]=size(groundTruth);
        motionCount=zeros(a,b,'uint8');
        K=50;
        while frameNum<=roi(2)
           groundTruth=getFrame(groundTruthPath,filelist,frameNum);
           if(isa(groundTruth,'uint8'))
               motion=(groundTruth==255);
               motionCount=motionCount+uint8(motion);
           else
              error('error: file type isnot uint8');
           end
           motionK=motionCount>=K;
%            if(sum(sum(shadowK))>100)
%                break;
%            end
           
           frameNum=frameNum+1;
        end
    end

    function show(motionK)
        idx=find(motionK(:));
        showNum=min(length(idx),10);
        randNum=randperm(length(idx));
        
        groundTruthPath=[root,'\groundtruth'];
        infolist=dir(groundTruthPath);
        filelist={infolist.name};
        
        inputPath=[root,'\input'];
        infolist=dir(inputPath);
        inputlist={infolist.name};
       
        
         for i=1:showNum
            
            frameNum=roi(1);
            groundTruth=getFrame(groundTruthPath,filelist,frameNum);
            
            pos=idx(randNum(i));    
            s=size(groundTruth);
            [a,b]=ind2sub(s,pos);
            
            while frameNum<=roi(2)
                groundTruth=getFrame(groundTruthPath,filelist,frameNum);
                input=getFrame(inputPath,inputlist,frameNum);
                
                if(groundTruth(pos)==255)
                    inputSample=input;
                    groundTruthSample=groundTruth;
                    break;
                end
                
                frameNum=frameNum+1;
%                 inputLBP=getLBP(input,a,b);
              
            end
            
            a,b,
            h=figure;
            subplot(221),imshow(groundTruthSample),title('groundTruth');
            subplot(222),imshow(inputSample),title('input');
            gray=rgb2gray(inputSample);
            subplot(223),imshow(edge(gray,'sobel')),title('sobel');
            subplot(224),imshow(edge(gray,'canny')),title('canny');
            pause(1);
            saveas(h,['edgeAnalyse-',int2str(i),'-',int2str(a),'-',int2str(b)],'bmp');
            close(h);
%             display(shadow);
%             display(background);
        end
    end
    
end
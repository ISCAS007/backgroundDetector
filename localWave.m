function localWave()
% root='D:\firefoxDownload\matlab\dataset2012\dataset\shadow\bungalows';
% root='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\fall';
root='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\boats';
roi=load([root,'\temporalROI.txt']);

motionK=getMotionK();
h=figure;
imshow(motionK);
saveas(h,'localWave','bmp');
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

    function border=isBorder(s,a,b,neighbor)
%         test if the pos out of boundery
        i=a+neighbor(1);
        j=b+neighbor(2);
        if(i>=1&&j>=1&&i<=s(1)&&j<=s(2))
           border=false;
        else
           border=true;
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
            
            
%             shadow=[];
            ground=zeros(roi(2)-roi(1),1);
            label=zeros(roi(2)-roi(1),1);
%             motion=zeros(roi(2)-roi(1),1);
%             static=zeros(roi(2)-roi(1),1);
            neighborGround=zeros(roi(2)-roi(1),1);
            neighborLabel=zeros(roi(2)-roi(1),1);
            getSample=false;
         
            neighbor=zeros(2,1);
%             for j=1:frameNumK
            while frameNum<=roi(2)
                groundTruth=getFrame(groundTruthPath,filelist,frameNum);
                input=getFrame(inputPath,inputlist,frameNum);
                
                if(~getSample&&groundTruth(pos)==255)
                    inputSample=input;
                    groundTruthSample=groundTruth;
                    getSample=true;
                    neighbor=randi([-5,5],2,1);
                    border=isBorder(s,a,b,neighbor);
                    while ((neighbor(1)==0&&neighbor(2)==0)||border)
                        neighbor=randi([-5,5],2,1);
                        border=isBorder(s,a,b,neighbor);
                    end
                end
                
                frameNum=frameNum+1;
%                 inputLBP=getLBP(input,a,b);
                gray=rgb2gray(input);
                info=double(gray(a,b));
                
                ground(frameNum-roi(1))=info;
                label(frameNum-roi(1))=0;
%                 display(info);
                if(groundTruth(pos)==255)
%                           motion(end+1)=sqrt(sum(info.^2));
                    label(frameNum-roi(1))=1;
                end
                
                neighborGround(frameNum-roi(1))=gray(a+neighbor(1),b+neighbor(2));
                neighborLabel(frameNum-roi(1))=(groundTruth(a+neighbor(1),b+neighbor(2))==255);
            end
            
            a,b,neighbor
            h=figure;
            subplot(221),imshow(lableImg(groundTruthSample,a,b,neighbor)),title('groundTruth');
            subplot(222),imshow(lableImg(inputSample,a,b,neighbor)),title('input');
%             subplot(233),hist(log(shadow)/log(3)),title('shadow');
%             subplot(223),hist(log(static)/log(3)),title('static');
%             subplot(224),hist(log(motion)/log(3)),title('motion');
            localPlot(ground,label,neighborGround,neighborLabel);
            pause(0.1);
            saveas(h,['localWave-',int2str(i),'-',int2str(a),'-',int2str(b)],'bmp');
            close(h);
%             display(shadow);
%             display(background);
        end
    end
    
    function localPlot(ground,label,neighborGround,neighborLabel)
%         m=length(ground);
        static=find(label==0);
        motion=find(label==1);
        subplot(223),scatter(static,ground(static),3,'filled'),hold on;
        scatter(motion,ground(motion),3,'filled'),title('center');
        
        static=find(neighborLabel==0);
        motion=find(neighborLabel==1);
        subplot(224),scatter(static,neighborGround(static),3,'filled'),hold on;
        scatter(motion,neighborGround(motion),3,'filled'),title('neighbor');
        %         legend('static','motion','Location','NorthOutside');
    end

    function img=lableImg(img,a,b,neighbor)
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
       
       color=[1,1,0];
       a=a+neighbor(1);
       b=b+neighbor(2);
       for i=a-5:a+5
          for j=b-5:b+5
              if(i>=1&&j>=1&&i<=m&&j<=n)
                 img(i,j,:)=color(:);
              end
          end
       end
    end

end
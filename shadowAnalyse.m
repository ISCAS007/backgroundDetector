<<<<<<< HEAD
function shadowAnalyse()
% analyse the feature of shadow in one picture
% 求取阴影与背景亮度的关系，阴影颜色与背景颜色的关系
% 阴影计数大于10,取100到200帧，背景亮度
root='D:\firefoxDownload\matlab\dataset2012\dataset\shadow\bungalows';
roi=load([root,'\temporalROI.txt']);

[shadowK,frameNumK]=getshadowK();
h=figure;
imshow(shadowK);
saveas(h,'shadowK','bmp');
close(h);
display('get shadowK');

getHistogram(shadowK,frameNumK);

    function frame=getFrame(filepath,filelist,frameNum)
        frame=imread([filepath,'\',filelist{frameNum+2}]);
    end

    function [shadowK,frameNumK]=getshadowK()
%        get the postion of shadow which is shadow for K times or more.
        groundTruthPath=[root,'\groundtruth'];
        infolist=dir(groundTruthPath);
        filelist={infolist.name};
        frameNum=roi(1);
        groundTruth=getFrame(groundTruthPath,filelist,frameNum);
        [a,b]=size(groundTruth);
        shadowCount=zeros(a,b,'uint8');
        K=50;
        while frameNum<=roi(2)
           groundTruth=getFrame(groundTruthPath,filelist,frameNum);
           if(isa(groundTruth,'uint8'))
               shadow=(groundTruth==50);
               shadowCount=shadowCount+uint8(shadow);
           else
              error('error: file type isnot uint8');
           end
           shadowK=shadowCount>=K;
%            if(sum(sum(shadowK))>100)
%                break;
%            end
           
           frameNum=frameNum+1;
        end
        
        frameNumK=frameNum-roi(1);
    end

    function getHistogram(shadowK,frameNumK)
%         get the light Histogram of shadow,background,motion
        idx=find(shadowK(:));
        if(frameNumK<100)
            frameNumK=100;
        end
        
        groundTruthPath=[root,'\groundtruth'];
        infolist=dir(groundTruthPath);
        filelist={infolist.name};
        
        inputPath=[root,'\input'];
        infolist=dir(inputPath);
        inputlist={infolist.name};
        
        showNum=min(length(idx),10);
        randNum=randperm(length(idx));
%         randNum=randNum(1:showNum);
        for i=1:showNum
            
            pos=idx(randNum(i));
%             display(i);
            
            frameNum=roi(1);
            groundTruth=getFrame(groundTruthPath,filelist,frameNum);
            s=size(groundTruth);
            
            shadow=[];
            motion=[];
            static=[];
            getShadowSample=false;
%             for j=1:frameNumK
            while frameNum<=roi(2)
                groundTruth=getFrame(groundTruthPath,filelist,frameNum);
                input=getFrame(inputPath,inputlist,frameNum);
                
                if(~getShadowSample&&groundTruth(pos)==50)
                    inputShadowSample=input;
                    shadowGroundTruth=groundTruth;
                    getShadowSample=true;
                end
                
                [a,b]=ind2sub(s,pos);
                
                info=double(input(a,b,:));
%                 display(info);
                if(groundTruth(pos)==50)
                    shadow(end+1)=sqrt(sum(info.^2));
                else
                   if(groundTruth(pos)==0)
                        static(end+1)=sqrt(sum(info.^2));
                   else
                       if(groundTruth(pos)==255)
                          motion(end+1)=sqrt(sum(info.^2));
                       end
                   end
                end
                frameNum=frameNum+1;
               
            end
            
            a,b
            h=figure;
            subplot(231),imshow(lableImg(shadowGroundTruth,a,b)),title('groundTruth');
            subplot(232),imshow(lableImg(inputShadowSample,a,b)),title('input');
            subplot(233),hist(shadow),title('shadow');
            subplot(234),hist(static),title('static');
            subplot(235),hist(motion),title('motion');
            pause(0.1);
            saveas(h,['shadow-',int2str(i),'-',int2str(a),'-',int2str(b)],'bmp');
            close(h);
%             display(shadow);
%             display(background);
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

    
end

=======
function shadowAnalyse()
% analyse the feature of shadow in one picture
% 求取阴影与背景亮度的关系，阴影颜色与背景颜色的关系
% 阴影计数大于10,取100到200帧，背景亮度
% root='D:\firefoxDownload\matlab\dataset2012\dataset\shadow\bungalows';
root='D:\Program\matlab\dataset2012\dataset\shadow\bungalows';
roi=load([root,'\temporalROI.txt']);

[shadowK,frameNumK]=getshadowK();
h=figure;
imshow(shadowK);
saveas(h,'shadowK','bmp');
close(h);
display('get shadowK');

getHistogram(shadowK,frameNumK);

    function frame=getFrame(filepath,filelist,frameNum)
        frame=imread([filepath,'\',filelist{frameNum+2}]);
    end

    function [shadowK,frameNumK]=getshadowK()
%        get the postion of shadow which is shadow for K times or more.
        groundTruthPath=[root,'\groundtruth'];
        infolist=dir(groundTruthPath);
        filelist={infolist.name};
        frameNum=roi(1);
        groundTruth=getFrame(groundTruthPath,filelist,frameNum);
        [a,b]=size(groundTruth);
        shadowCount=zeros(a,b,'uint8');
        K=50;
        while frameNum<=roi(2)
           groundTruth=getFrame(groundTruthPath,filelist,frameNum);
           if(isa(groundTruth,'uint8'))
               shadow=(groundTruth==50);
               shadowCount=shadowCount+uint8(shadow);
           else
              error('error: file type isnot uint8');
           end
           shadowK=shadowCount>=K;
%            if(sum(sum(shadowK))>100)
%                break;
%            end
           
           frameNum=frameNum+1;
        end
        
        frameNumK=frameNum-roi(1);
    end

    function getHistogram(shadowK,frameNumK)
%         get the light Histogram of shadow,background,motion
        idx=find(shadowK(:));
        if(frameNumK<100)
            frameNumK=100;
        end
        
        groundTruthPath=[root,'\groundtruth'];
        infolist=dir(groundTruthPath);
        filelist={infolist.name};
        
        inputPath=[root,'\input'];
        infolist=dir(inputPath);
        inputlist={infolist.name};
        
        showNum=min(length(idx),10);
        randNum=randperm(length(idx));
%         randNum=randNum(1:showNum);
        for i=1:showNum
            
            pos=idx(randNum(i));
%             display(i);
            
            frameNum=roi(1);
            groundTruth=getFrame(groundTruthPath,filelist,frameNum);
            s=size(groundTruth);
            
            shadow=[];
            motion=[];
            static=[];
            getShadowSample=false;
%             for j=1:frameNumK
            while frameNum<=roi(2)
                groundTruth=getFrame(groundTruthPath,filelist,frameNum);
                input=getFrame(inputPath,inputlist,frameNum);
                
                if(~getShadowSample&&groundTruth(pos)==50)
                    inputShadowSample=input;
                    shadowGroundTruth=groundTruth;
                    getShadowSample=true;
                end
                
                [a,b]=ind2sub(s,pos);
                
                info=double(input(a,b,:));
%                 display(info);
                if(groundTruth(pos)==50)
                    shadow(end+1)=sqrt(sum(info.^2));
                else
                   if(groundTruth(pos)==0)
                        static(end+1)=sqrt(sum(info.^2));
                   else
                       if(groundTruth(pos)==255)
                          motion(end+1)=sqrt(sum(info.^2));
                       end
                   end
                end
                frameNum=frameNum+1;
               
            end
            
            a,b
            h=figure;
            subplot(231),imshow(lableImg(shadowGroundTruth,a,b)),title('groundTruth');
            subplot(232),imshow(lableImg(inputShadowSample,a,b)),title('input');
            subplot(233),hist(shadow),title('shadow');
            subplot(234),hist(static),title('static');
            subplot(235),hist(motion),title('motion');
            pause(0.1);
            save(['shadowAnalyse-',int2str(i)],'shadow','static','motion');
            saveas(h,['shadow-',int2str(i),'-',int2str(a),'-',int2str(b)],'bmp');
            close(h);
%             display(shadow);
%             display(background);
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

    
end

>>>>>>> dd44f5ba96dc3af1af99d4d47216a069c00c198a

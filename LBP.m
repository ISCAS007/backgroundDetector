function LBP()
datacfg;
root=fullfile(root,'shadow','bungalows');
roi=load(fullfile(root,'temporalROI.txt'));

motionK=getMotionK();
h=figure;
imshow(motionK);
saveas(h,'motion','jpg');
close(h);
show(motionK);

% img=imread([groundTruthPath,'\',filelist{frameNum+2}]);
    function frame=getFrame(filepath,filelist,frameNum)
        frame=imread(fullfile(filepath,filelist{frameNum+2}));
    end

    function imgLBP=getLBP(img,i,j)
        img=rgb2gray(img);
        [m,n,~]=size(img);
        
        imgLBP=zeros(m,n);
        
        if(i==1||i==m||j==1||j==n)
            warning('LBP.getLBP: i==1||i==m||j==1||j==n');
        else
            pow=0;
            for p=i-1:i+1
                for q =j-1:j+1
%                     if img(p,q) >= img(i,j)
%                         if p~=i || q~=j         
%                             %有的文章这里是3*3的顺时针编码，我就按处理顺序编码了。
%                             %反正都是特征描述啥的，只要按相同规则就行了。
%                             imgLBP(i,j)=imgLBP(i,j)+2^pow;
%                             
%                         end
%                     end
%                     pow=pow+1;

                    dif=img(p,q)-img(i,j);
                    if(dif>=-5&&dif<=5)
                       dif=1;
                    else
                       if(dif<-5)
                           dif=0;
                       else
                           dif=2;
                       end
                    end
                    
                    if(p~=i||q~=j)
                        imgLBP(i,j)=imgLBP(i,j)+dif*3^pow;
                        pow=pow+1;
                    end
                end
            end
        end
        
        
                
    end
    
    function motionK=getMotionK()
%        get the postion of shadow which is shadow for K times or more.
        groundTruthPath=fullfile(root,'groundtruth');
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
        
        groundTruthPath=fullfile(root,'groundtruth');
        infolist=dir(groundTruthPath);
        filelist={infolist.name};
        
        inputPath=fullfile(root,'input');
        infolist=dir(inputPath);
        inputlist={infolist.name};
        
         for i=1:showNum
            pos=idx(randNum(i));    
            frameNum=roi(1);
            groundTruth=getFrame(groundTruthPath,filelist,frameNum);
            s=size(groundTruth);
            
            shadow=[];
            motion=[];
            static=[];
            getSample=false;
%             for j=1:frameNumK
            while frameNum<=roi(2)
                groundTruth=getFrame(groundTruthPath,filelist,frameNum);
                input=getFrame(inputPath,inputlist,frameNum);
                
                if(~getSample&&groundTruth(pos)==255)
                    inputSample=input;
                    groundTruthSample=groundTruth;
                    getSample=true;
                end
                
                [a,b]=ind2sub(s,pos);
                
                inputLBP=getLBP(input,a,b);
                info=double(inputLBP(a,b));
%                 display(info);
                if(groundTruth(pos)==50)
%                     shadow(end+1)=sqrt(sum(info.^2));
                    shadow(end+1)=info;
                else
                   if(groundTruth(pos)==0)
%                         static(end+1)=sqrt(sum(info.^2));
                        static(end+1)=info;
                   else
                       if(groundTruth(pos)==255)
%                           motion(end+1)=sqrt(sum(info.^2));
                            motion(end+1)=info;
                       end
                   end
                end
                frameNum=frameNum+1;
               
            end
            
            a,b
            h=figure;
            subplot(231),imshow(lableImg(groundTruthSample,a,b)),title('groundTruth');
            subplot(232),imshow(lableImg(inputSample,a,b)),title('input');
            subplot(233),hist(log(shadow)/log(3)),title('shadow');
            subplot(234),hist(log(static)/log(3)),title('static');
            subplot(235),hist(log(motion)/log(3)),title('motion');
            pause(0.1);
            saveas(h,['LBP-',int2str(i),'-',int2str(a),'-',int2str(b)],'jpg');
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
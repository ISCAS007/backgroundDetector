function PBAS2()
% root='D:\firefoxDownload\matlab\dataset2012\dataset\shadow\bungalows';
root='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\fall';
roi=load([root,'\temporalROI.txt']);

motionK=getMotionK();
h=figure;
imshow(motionK);
saveas(h,'PBAS','bmp');
close(h);
show(motionK);

% img=imread([groundTruthPath,'\',filelist{frameNum+2}]);
    function frame=getFrame(filepath,filelist,frameNum)
        frame=imread([filepath,'\',filelist{frameNum+2}]);
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
            pos=idx(randNum(i));    
            frameNum=roi(1);
            groundTruth=getFrame(groundTruthPath,filelist,frameNum);
            s=size(groundTruth);
            
%             shadow=[];
            ground=[];
            label=[];
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
                
%                 inputLBP=getLBP(input,a,b);
                gray=rgb2gray(input);
                info=double(gray(a,b));
                
                ground(end+1)=info;
                label(end+1)=0;
%                 display(info);
                if(groundTruth(pos)==50)
%                     shadow(end+1)=sqrt(sum(info.^2));
%                     shadow(end+1)=info;
                    static(end+1)=info;
                    
                else
                   if(groundTruth(pos)==0)
%                         static(end+1)=sqrt(sum(info.^2));
                        static(end+1)=info;
                        
                   else
                       if(groundTruth(pos)==255)
%                           motion(end+1)=sqrt(sum(info.^2));
                            motion(end+1)=info;
                            label(end)=1;
                       end
                   end
                end
                frameNum=frameNum+1;
               
            end
            
            a,b
            h=figure;
            subplot(221),imshow(lableImg(groundTruthSample,a,b)),title('groundTruth');
            subplot(222),imshow(lableImg(inputSample,a,b)),title('input');
%             subplot(233),hist(log(shadow)/log(3)),title('shadow');
%             subplot(223),hist(log(static)/log(3)),title('static');
%             subplot(224),hist(log(motion)/log(3)),title('motion');
            PBAS_Show(ground,label);
            pause(0.1);
            saveas(h,['PBAS-',int2str(i),'-',int2str(a),'-',int2str(b)],'bmp');
            close(h);
%             display(shadow);
%             display(background);
        end
    end
    
    function PBAS_Show(ground,label)
        m=length(ground);
        n=35;
        
        history=ground(1:n);
        
        X=zeros((m-n)*(n+1),1);
%         X=[];
%         Y=[];
%         C=[];
        Y=X;
        C=zeros((m-n)*(n+1),3);
        count=1;
        red=[1,0,0];
        green=[0,1,0];
        blue=[0,0,0];
        start=false;
        for i=n+1:m
            if(start)
                for j=1:n
                    X(count)=i;
                    Y(count)=history(j);
                    C(count,:)=green(:);
    %                 X(end+1)=i;
    %                 Y(end+1)=history(j);
    %                 C(end+1,:)=[0,1,0];
                    count=count+1;
                end

                if(label(i)==0)
                    r=randi(n,1,1);
                    history(r)=ground(i);
                    X(count)=i;
                    Y(count)=ground(i);
                    C(count,:)=blue(:);
                else
                    X(count)=i;
                    Y(count)=ground(i);
                    C(count,:)=red(:);
                end
                
                count=count+1;
            else
                if(label(i)==1)
                   start=true; 
                end
            end
            
            if(count>=100*(n+1))
                break;
            end
        end
        count=count-1;
        X=X(1:count);
        Y=Y(1:count);
        C=C(1:count,:);
        subplot(223),scatter(X,Y,3,C,'filled'),title('PBAS');
        
%         label=label(X);
%         ground=ground(X);
        static=find(label==0);
        motion=find(label==1);
        subplot(224),scatter(static,ground(static),3,'filled'),hold on;

        scatter(motion,ground(motion),3,'filled'),title('static+motion');
        %         legend('static','motion','Location','NorthOutside');
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
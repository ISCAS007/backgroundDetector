function subsense_improve_test2()
root='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\boats';
resultPath='E:\matlab\subsense\results\dynamicBackground\boats\';

roiImg=imread([root,'\ROI.bmp']);
roiMask=(roiImg~=0);
[height,width]=size(roiMask);


groundTruthPath=[root,'\groundtruth\'];
inputPath=[root,'\input\'];

temporalROI=load([root,'\temporalROI.txt']);
temporalROI(1)=6940;
temporalROI(2)=7200;
newB=[];
for frameNum=temporalROI(1):temporalROI(2)
    gt=getImg(groundTruthPath,'gt',frameNum,'.png');
    in=getImg(inputPath,'in',frameNum,'.jpg');
    out=getImg(resultPath,'bin',frameNum,'.png');
    
    if(isempty(newB))
        newB=in;
    end
    
    %    out=(out~=0);
    %    out=imfill(out,'holes');
    A_BG=find(out==0);
    B_FG=find(out~=0);
    
    if(size(B_FG,1)~=0)
        [I,J]=ind2sub([height,width],A_BG);
        A=[I,J];
        [I,J]=ind2sub([height,width],B_FG);
        B=[I,J];
        
        D=A*B';
        [~,idx]=min(D,[],2);
        matchFG=B(idx,:);
        matchFG_1d=sub2ind([height,width],matchFG(:,1),matchFG(:,2));
        
        in_2d=reshape(in,height*width,3);
        newB_2d=reshape(in,height*width,3);
        D_IN2BG=(in_2d(A_BG,:)-newB_2d(A_BG,:)).^2;
        D_IN2FG=(in_2d(A_BG,:)-in_2d(matchFG_1d,:)).^2;
        
        newFGLabel=sum(D_IN2FG,2)>sum(D_IN2BG,2);
        
        newFG=out;
        newFG(A_BG(newFGLabel))=1;
        subplot(231);
        imshow(newFG);
        title('newFG');
        
    end
    
    show();
    title(num2str(frameNum));
    pause(0.5);
    
    for i=1:3
        r_g_b=in(:,:,i);
        new_r_g_b=newB(:,:,i);
        r_g_b(out~=0)=new_r_g_b(out~=0);
        newB(:,:,i)=r_g_b;
    end
end

    function show()
        errorMask=(gt>=170)&(out==0);
        labelMask=imdilate(errorMask,strel('disk',1));
        inputSample=in;
        rgb=inputSample(:,:,1);
        g=inputSample(:,:,2);
        b=inputSample(:,:,3);
        
        rgb(labelMask)=255;
        g(labelMask)=0;
        b(labelMask)=0;
        
        inputSample(:,:,1)=rgb;
        inputSample(:,:,2)=g;
        inputSample(:,:,3)=b;
        
        subplot(233);
        imshow(inputSample);
        title('error');
        
        subplot(234);
        imshow(out);
        title('out');
        
        subplot(236);
        imshow(gt);
        title('gt');
    end
end

function img=getImg(baseDir,prefix,frameNum,suffix)
str=num2str(frameNum,'%.6d');
img=imread([baseDir,prefix,str,suffix]);
end

function baseFunction_yzbx()

%init
frameNum=0;
filepath='D:\firefoxDownload\matlab\dataset2014\dataset\dynamicBackground\boats\input';
filelist=dir(filepath);
filenum=length(filelist)-2;
filename={filelist.name};
frame=getNextFrame();
[width,height,channel]=size(frame);

videoPlayer = vision.VideoPlayer('Position', [740, 50, 350, 200]);
difPlayer = vision.VideoPlayer('Position', [740, 300, 350, 200]);
areaOpenPlayer = vision.VideoPlayer('Position', [740, 550, 350, 200]);
colorPlayer=vision.VideoPlayer('Position',[740,700,350,200]);

framedif=[];
bw=[];
color=[];

SBColorSet=[];
SBColorWeight=[];
DBColorSet=[];
DBColorWeight=[];
FOColorSet=[];
FOColorWeight=[];
%loop
if(filenum<2||~strcmp(class(frame),'uint8')||channel~=3)
    disp('filenum < 2 or class(frame)~=uint8 ');
    return
end

while frame<filenum
    oldframe=frame;
    frame=getNextFrame();
    if(frameNum==2)
        init();
    else
        init();
    end
    
    display();
end
%function define
    function frame=getNextFrame()
        frameNum=frameNum+1;
        frame=imread([filepath,'\',filename{frameNum+2}]);
        frame=rgb2lab(frame);
    end

    function labImage=rgb2lab(rgbImage)
        colorTransform = makecform('srgb2lab');
        labImage = applycform(rgbImage, colorTransform);
    end

    function init()
        %use rgb distance or lab distance ?
        framedif=oldframe-frame;
        
%         framedif1=double(framedif(:,:,1));
        framedif2=double(framedif(:,:,2));
        framedif3=double(framedif(:,:,3));
        %gray to bw?
        framedif=rgb2gray(framedif);
        
        framedif123=sqrt(framedif2.^2+framedif3.^2);
%         imshow(framedif123);
        
        %bwareaopen,imopen,imclose,imerode,imdilate,imconstructe,imcomplement
        minThreshold=prctile(framedif123(:),80);
        minarea=max(30,floor(width*height/1000));
        bw=bwareaopen(framedif123>minThreshold,minarea);
%         imshow(bw);
        
        %color segmentation
        mincolorGap=10;
        minarea=30;
        area=bwarea(bw);
        if(area<minarea)
            color=bw;
        else
            cc=bwconncomp(bw);
            objbasic=regionprops(cc,'basic');
            objnum=cc.NumObjects;
            for i=1:ojbnum
                c=objbasic(i).Centroid;
                a=objbasic(i).Area;
                FOColorSet(:,i)=frame(c(1),c(2),:);
                FOColorWeight=a/area;
            end
            
%             FOColorWeight=colorKNN(FOColorSet,frame,bw)/area;
        end
    end
    
    function knnmask=colorKNN(colorset,pic,roi)
        num=size(colorset,2);
        distance=zeros(size(pic,1),size(pic,2),num);
        for i=1:num
            distance(:,:,i)=sqrt(double((pic(:,:,2)-colorset(2,i)).^2+...
                (pic(:,:,3)-colorset(3,i)).^2));
        end
        [value,label]=min(distance,[],3);
        maxcolorGap=30;
        label(value>maxcolorGap)=0;
        weight=zeros(num,1);
        for i=1:num
            weight(i)=sum(roi(label==i));
        end
    end
    function process()
        
    end
    function display()
        videoPlayer.step(frame);
        difPlayer.step(imadjust(framedif));
        areaOpenPlayer.step(bw);
        colorPlayer.step(color);
    end
end


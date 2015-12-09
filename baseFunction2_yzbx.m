%use framedif to detect backgroud
%write by yzbx
%the detection function change to point-wise, not region-wise;
function baseFunction2_yzbx()

%init
frameNum=0;
filepath='D:\firefoxDownload\matlab\dataset2014\dataset\dynamicBackground\boats\input';
filelist=dir(filepath);
filenum=length(filelist)-2;
filename={filelist.name};
colorTransform = makecform('srgb2lab');
frame=getNextFrame();
[width,height,channel]=size(frame);
minarea=max(30,floor(width*height/1000));
videoPlayer = vision.VideoPlayer('Position', [840, 50, 350, 200],'Name','origin frame');
difPlayer = vision.VideoPlayer('Position', [840, 300, 350, 200],'Name','frame-oldframe');
areaOpenPlayer = vision.VideoPlayer('Position', [840, 550, 350, 200],'Name','area open');
colorSegPlayer=vision.VideoPlayer('Position',[840,700,350,200],'Name','color seg');
maskPlayer=vision.VideoPlayer('Position',[400,700,350,200],'Name','mask');

framedif=[];
framebw=[];
framecolorSeg=[];
framemask=[];

LearnLow=1;
LearnHigh=2;
LearnMin=3;
LearnMax=4;
LearnTimeArea=5;
CacheSize=ceil((width+height)/2);
% SBColorSet=zeros(channel,4,1,'uint8');
% SBColorNum=0;
DBColorSet=zeros(channel,5,1);
DBColorNum=0;
% FOColorSet=zeros(channel,4,1,'uint8');
% FOColorNum=0;
mindifThreshold=5^2*3;
CBBound=uint8([10;10;10]);
CBMaxBound=uint8([20;20;20]);
CBMinBound=uint8([20;20;20]);

%loop
if(filenum<2||~isa(frame,'uint8')||channel~=3)
    disp('filenum < 2 or class(frame)~=uint8 ');
    return
end
trainningFrameNum=300;
while frame<filenum
    oldframe=frame;
    frame=getNextFrame();
    if(frameNum<trainningFrameNum)
        init();
        if(frameNum==trainningFrameNum)
           clearCB(); 
        end
    else
        detect();
    end
    
    display();
end
%function define
    
    function frame=getNextFrame()
        frameNum=frameNum+1;
        frame=imread([filepath,'\',filename{frameNum+2}]);
%         frame =applycform(frame, colorTransform);
    end
    
    function init()
        area=preDeal();
        
        if(area>=minarea)
            cc=bwconncomp(framebw);
            objbasic=regionprops(cc,'basic');
            objnum=cc.NumObjects;
            pixel=uint8([0;0;0]);
            for i=1:objnum
                c=round(objbasic(i).Centroid);
                %use maxarea to spliter
                a=objbasic(i).Area;
                pixel(:)=frame(c(2),c(1),:);
                
             
                match=false;
                matchid=0;
                for j=1:DBColorNum
                   for k=1:channel
                       if((pixel(k)<DBColorSet(k,LearnLow,j))||(pixel(k)...
                               >DBColorSet(k,LearnHigh,j)))
                          break; 
                       end
                       if(k==channel)
                           match=true;
                           matchid=j;
                       end
                   end 
                   
                   if(match)
                       break;
                   end
                end
                
                if(match)   %match then change learnhigh-low,max-min
                    %remove from framecolorSeg
                    framecolorSeg(cc.PixelIdxList{i})=0;
                    
                    DBColorSet(:,LearnHigh,matchid)=DBColorSet(:,LearnHigh,matchid)+...
                        double(DBColorSet(:,LearnHigh,matchid)<(pixel+CBBound));
                    DBColorSet(:,LearnLow,matchid)=DBColorSet(:,LearnLow,matchid)-...
                        double(DBColorSet(:,LearnLow,matchid)>(pixel-CBBound));
                    DBColorSet(:,LearnMax,matchid)=max(double(pixel),DBColorSet(:,LearnMax,matchid));
                    DBColorSet(:,LearnMin,matchid)=min(double(pixel),DBColorSet(:,LearnMin,matchid));
                    
                    DBColorSet(1,LearnTimeArea,matchid)=frameNum;
                    DBColorSet(2,LearnTimeArea,matchid)=max(DBColorSet(2,LearnTimeArea,matchid),a);
                else    %unmatch then add CB
                    
                    DBColorNum=DBColorNum+1;
                    DBColorSet(:,LearnHigh,DBColorNum)=pixel+CBBound;
                    DBColorSet(:,LearnLow,DBColorNum)=pixel-CBBound;
                    DBColorSet(:,LearnMax,DBColorNum)=pixel;
                    DBColorSet(:,LearnMin,DBColorNum)=pixel;
                    DBColorSet(1,LearnTimeArea,DBColorNum)=frameNum;
                    DBColorSet(2,LearnTimeArea,DBColorNum)=a;
                end
                
            end
           
%           FOColorWeight=colorKNN(FOColorSet,frame,bw)/area;
        end
    end
    
%     function knnmask=colorKNN(colorset,pic,roi)
%         num=size(colorset,2);
%         distance=zeros(size(pic,1),size(pic,2),num);
%         for i=1:num
%             distance(:,:,i)=sqrt(double((pic(:,:,2)-colorset(2,i)).^2+...
%                 (pic(:,:,3)-colorset(3,i)).^2));
%         end
%         [value,label]=min(distance,[],3);
%         maxcolorGap=30;
%         label(value>maxcolorGap)=0;
%         weight=zeros(num,1);
%         for i=1:num
%             weight(i)=sum(roi(label==i));
%         end
%     end

    function clearCB()
        time=zeros(DBColorNum,1);
        time(:)=DBColorSet(1,LearnTimeArea,:);
        time=frameNum-time;
        idx=(time<frameNum/2);
        DBColorSet=DBColorSet(:,:,idx);
        DBColorNum=sum(idx);
    end
    function area=preDeal()
        framedif=oldframe-frame;
        framedif123=framedif(:,:,1).^2+framedif(:,:,2).^2+framedif(:,:,3).^2;
        framedif=rgb2gray(framedif);
       
        framebw=bwareaopen(framedif123>mindifThreshold,minarea);
        framebw=imfill(framebw,'holes');
        area=bwarea(framebw);
        framecolorSeg=framebw;
        framemask=framebw;
    end
    function detect()
        %use rgb distance or lab distance ?
        area=preDeal();
        
        if(area>=minarea)
            cc=bwconncomp(framebw);
            objbasic=regionprops(cc,'basic');
            objnum=cc.NumObjects;
            regionmask=false(width,height);
            x1=uint32([0;0]);
            x2=uint32([0;0]);
            for i=1:objnum
                x1=uint32(objbasic(i).Centroid-[height/3,width/3]);
                x2=uint32(objbasic(i).Centroid+[height/3,width/3]);
                x1=uint32(max(1,x1));
                x2=uint32(min(uint32([height,width]),x2));
                
                regionmask(x1(2):x2(2),x1(1):x2(1))=1;
            end
            
            
            for i=1:objnum
                minmask=uint8(DBColorSet(:,LearnMin,i))-CBMinBound;
                maxmask=uint8(DBColorSet(:,LearnMax,i))+CBMaxBound;
                b=true(width,height);
                for j=1:channel
                    a=((frame(:,:,j)>=minmask(j))&(frame(:,:,j)<=maxmask(j)));
                    b=a&b;
                end
                regionmask(b==1)=0;
            end
            
            framemask=regionmask;
        else
            framemask(:)=0;
        end
    end
    function display()
        videoPlayer.step(frame);
%         difPlayer.step(imadjust(framedif));
        areaOpenPlayer.step(framebw);
        colorSegPlayer.step(framecolorSeg);
        maskPlayer.step(framemask);
    end
end


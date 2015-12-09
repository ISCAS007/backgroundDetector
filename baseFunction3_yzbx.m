%use framedif to detect backgroud
%write by yzbx
%the detection function change to point-wise, not region-wise;
function baseFunction3_yzbx()

%init
frameNum=1800;
% filepath='E:\yzbx_programe\Matlab\Data\boats\input';
% otherpath='E:\yzbx_programe\Matlab\Data\boats\groundtruth';
filepath='D:\firefoxDownload\matlab\dataset2014\dataset\dynamicBackground\boats\input';
otherpath='D:\firefoxDownload\matlab\dataset2014\dataset\dynamicBackground\boats\groundtruth';
filelist=dir(filepath);
otherlist=dir(otherpath);
filenum=length(filelist)-2;
filename={filelist.name};
othername={otherlist.name};
colorTransform = makecform('srgb2lab');
otherframe=[];
frame=getNextFrame();
[width,height,channel]=size(frame);
minarea=max(30,floor(width*height/1000));
videoPlayer = vision.VideoPlayer('Position', [840, 50, 350, 200],'Name','origin frame');
SBCBPlayer = vision.VideoPlayer('Position', [840, 350, 350, 200],'Name','SBCB');
DBCBPlayer = vision.VideoPlayer('Position', [440, 50, 350, 200],'Name','DBCB');
ColorAmendPlayer=vision.VideoPlayer('Position',[440,350,350,200],'Name','ColorAmend');

SBCBmask=[];
DBCBmask=[];
CAmask=[];
LearnLow=1;
LearnHigh=2;
LearnMin=3;
LearnMax=4;
LearnTimeArea=5;
DBCBUpdateCycle=10;
SBCBUpdateCycle=10;
DBCBClock=0;
SBCBClock=0;
SBCB=zeros(channel,5,1);
SBCBNum=0;
DBCB=zeros(channel,5,1);
DBCBNum=0;
mindifThreshold=5^2*3;
factor=0.1;
CBBound=uint8([200;5;5]);
DBCBMaxBound=uint8([200/factor;20;20]*factor);
DBCBMinBound=uint8([200/factor;20;20]*factor);
SBCBMaxBound=uint8([200/factor;20;20]*factor);
SBCBMinBound=uint8([200/factor;20;20]*factor);
%loop
if(filenum<2||~isa(frame,'uint8')||channel~=3)
    disp('filenum < 2 or class(frame)~=uint8 ');
    return
end
filenum=min(filenum,2100);
trainningFrameNum=100;
while frameNum<filenum
    oldframe=frame;
    DBCBClock=DBCBClock+1;
    SBCBClock=SBCBClock+1;
    frame=getNextFrame();
    if(frameNum<trainningFrameNum+1800)
        [SBCB,SBCBNum]=SBCBUpdate(frame,SBCB,SBCBNum,frameNum,CBBound);
        SBCBarea=zeros(SBCBNum,1);
        [SBCBmask,SBCBarea]=SBCBFilter(frame,SBCB,SBCBNum,SBCBMinBound,SBCBMaxBound);
        SBCB(2,LearnTimeArea,:)=SBCBarea(:);
        [SBCBMinBound,SBCBMaxBound,SBCBUpdateCycle]=SBCBParameterUpdate(frame,SBCBmask,SBCBMinBound,SBCBMaxBound,SBCBUpdateCycle,SBCBNum);
        
        DBframe=imabsdiff(mask_yzbx(frame,~SBCBmask),mask_yzbx(oldframe,~SBCBmask));
        [DBCB,DBCBNum]=DBCBUpdate(DBframe,DBCB,DBCBNum,frameNum,CBBound);
        DBCBarea=zeros(DBCBNum,1);
        [DBCBmask,DBCBarea]=SBCBFilter(DBframe,DBCB,DBCBNum,DBCBMinBound,DBCBMaxBound);
        DBCB(2,LearnTimeArea,:)=DBCBarea(:);
        [DBCBMinBound,DBCBMaxBound,DBCBUpdateCycle]=DBCBParameterUpdate(DBframe,DBCBmask,DBCBMinBound,DBCBMaxBound,DBCBUpdateCycle,DBCBNum);
        
        CAmask=ColorAmend(frame);
        if(DBCBClock>=DBCBUpdateCycle)
           [DBCB,DBCBNum,DBCBClock]=clearCB(DBCB,DBCBNum,frameNum,DBCBUpdateCycle); 
        end
        if(SBCBClock>=SBCBUpdateCycle)
            [SBCB,SBCBNum,SBCBClock]=clearCB(SBCB,SBCBNum,frameNum,SBCBUpdateCycle);
        end
    else
        SBCBmask=SBCBFilter(frame,SBCB,SBCBNum,SBCBMinBound,SBCBMaxBound);
        DBframe=imabsdiff(mask_yzbx(frame,~SBCBmask),mask_yzbx(oldframe,~SBCBmask));
        DBCBmask=SBCBFilter(DBframe,DBCB,DBCBNum,DBCBMinBound,DBCBMaxBound);
        CAmask=ColorAmend(frame);
%         [SBCBMinBound,SBCBMaxBound,SBCBUpdateCycle]=SBCBParameterUpdate(mask,SBCBMinBound,SBCBMaxBound,SBCBUpdateCycle,SBCBNum);
%         detect();
    end
    
    display();
end
%function define
    
    function frame=getNextFrame()
        frameNum=frameNum+1;
        frame=imread([filepath,'\',filename{frameNum+2}]);
        otherframe=imread([otherpath,'\',othername{frameNum+2}]);
        frame =applycform(frame, colorTransform);
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
                matchid=1;
                for j=1:DBCBNum
                   for k=1:channel
                       if((pixel(k)<DBCB(k,LearnLow,j))||(pixel(k)...
                               >DBCB(k,LearnHigh,j)))
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
                    
                    DBCB(:,LearnHigh,matchid)=DBCB(:,LearnHigh,matchid)+...
                        double(DBCB(:,LearnHigh,matchid)<(pixel+CBBound));
                    DBCB(:,LearnLow,matchid)=DBCB(:,LearnLow,matchid)-...
                        double(DBCB(:,LearnLow,matchid)>(pixel-CBBound));
                    DBCB(:,LearnMax,matchid)=max(double(pixel),DBCB(:,LearnMax,matchid));
                    DBCB(:,LearnMin,matchid)=min(double(pixel),DBCB(:,LearnMin,matchid));
                    
                    DBCB(1,LearnTimeArea,matchid)=frameNum;
                    DBCB(2,LearnTimeArea,matchid)=max(DBCB(2,LearnTimeArea,matchid),a);
                else    %unmatch then add CB
                    
                    DBCBNum=DBCBNum+1;
                    DBCB(:,LearnHigh,DBCBNum)=pixel+CBBound;
                    DBCB(:,LearnLow,DBCBNum)=pixel-CBBound;
                    DBCB(:,LearnMax,DBCBNum)=pixel;
                    DBCB(:,LearnMin,DBCBNum)=pixel;
                    DBCB(1,LearnTimeArea,matchid)=frameNum;
                    DBCB(2,LearnTimeArea,matchid)=a;
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
            for i=1:objnum  %use objnum.BoundingBox[
                x1=uint32(objbasic(i).Centroid-[height/3,width/3]);
                x2=uint32(objbasic(i).Centroid+[height/3,width/3]);
                x1=uint32(max(1,x1));
                x2=uint32(min(uint32([height,width]),x2));
                
                regionmask(x1(2):x2(2),x1(1):x2(1))=1;
            end
            
            
            for i=1:DBCBNum
                minmask=uint8(DBCB(:,LearnMin,i))-DBCBMinBound;
                maxmask=uint8(DBCB(:,LearnMax,i))+DBCBMaxBound;
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
        SBCBPlayer.step(mask_yzbx(frame,SBCBmask));      
        DBCBPlayer.step(adapt_yzbx(mask_yzbx(DBframe,DBCBmask)));
        ColorAmendPlayer.step(mask_yzbx(frame,CAmask));
    end
    
%f=frame, m=mask, s=expand size, p=preimter, b=boundingBox
    function newm=colorExpand(f,m,s,b)
        p=bwperim(m);
        nump=length(p);
        select=[1:10:nump];
        selp=p(select);
        
        newm=m;
        numsel=length(selp);
      
        self=f(b(1):b(1)+b(3)*s,b(2):b(2)+b(4)*s,:);
        for i=1:numsel
             minmask=uint8(f(selp(i))-5);
             maxmask=uint8(f(selp(i))+5);
             b=true(size(self,1),size(self,2));
             for j=1:channel
                a=((self(:,:,j)>=minmask(j))&(self(:,:,j)<=maxmask(j)));
                b=a&b;
             end
             newm(b(1):b(1)+b(3)*s,b(2):b(2)+b(4)*s)=...
                 newm(b(1):b(1)+b(3)*s,b(2):b(2)+b(4)*s)|b;
        end
      
    end
end


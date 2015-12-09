function mask=codebook2()
frameNum=0;
% filepath='D:\firefoxDownload\matlab\dataset2014\dataset\dynamicBackground\boats\input';
filepath='D:\firefoxDownload\matlab\dataset2014\dataset\baseline\highway\input';
filelist=dir(filepath);
filenum=length(filelist)-2;
filename={filelist.name};
frame=getNextFrame();
[width,height,channel]=size(frame);
imageLen=width*height;
%cb,numEntries,t
CB(imageLen,1)=struct('t',[],'numEntries',[],'cb',struct('learnHigh',...
    [0,0,0],'learnLow',[0,0,0], 'max',[0,0,0],'min',[0,0,0],...
    't_last_update',0,'stale',0));
% CB=arrayfun(@structinit,CB); failed
[CB(1:imageLen).numEntries]=deal(0);
% for cbj=1:imageLen
%     CB(cbj).t=0;    %t CB(c).t=CB(c).t
%     CB(cbj).numEntries=uint8(0);    %numEntries CB(c).numEntries=CB(c).numEntries
%     %learnHigh,learnLow,max,min,[t_last_update,stale]=1,2,3,4,5
%     CB(cbj).cb=struct('learnHigh',[0,0,0],'learnLow',[0,0,0],...
%               'max',[0,0,0],'min',[0,0,0],'t_last_update',0,'stale',0);   %cb CB(c).cb=CB(c).cb
% end
CBBounds=ones(channel,1,'uint8')*10;
minMod=ones(channel,1,'uint8')*20;
maxMod=ones(channel,1,'uint8')*20;
mask=zeros(width,height);

videoPlayer = vision.VideoPlayer('Position', [740, 50, 350, 200]);
difPlayer = vision.VideoPlayer('Position', [740, 300, 350, 200]);

while frameNum<filenum
    frame=getNextFrame();
    pixel=zeros(3,1);
    if frameNum<=30
        c=0;
        for x=1:width
            for y=1:height
                c=c+1;
                pixel=frame(x,y,:);
                pixel=pixel(:);
                updateCodeBook(pixel,c);
            end
        end
        
        if frameNum==30
           for c=1:imageLen
                clearStaleEntries(c);
           end
        end
    else
        c=0;
        for x=1:width
            for y=1:height
                c=c+1;
                pixel=frame(x,y,:);
                pixel=pixel(:);
                mask(c)= backgroundDiff(pixel,c);
            end
        end
    end
    
    videoPlayer.step(frame);
    difPlayer.step(mask);
end

function frame=getNextFrame()
    frameNum=frameNum+1;
    frame=imread([filepath,'\',filename{frameNum+2}]);
end

    function i=updateCodeBook(pixel,c)
       if(CB(c).numEntries==0)
           CB(c).t=0;
       end
       
       CB(c).t=CB(c).t+1;
       high=pixel+CBBounds;
       low=pixel-CBBounds;
       mi=0;
       match=false;
       for i=1:CB(c).numEntries
           mi=i;
           matchChannel=sum(CB(c).cb(i).learnLow<=pixel&pixel<=...
                       CB(c).cb(i).learnHigh);
           
%            for n=1:channel
%                if(CB(c).cb(i).learnLow(n)<=pixel(n)&&pixel(n)<=...
%                        CB(c).cb(i).learnHigh(n))
%                    matchChannel=matchChannel+1;
%                end                   
%            end
           
           if(matchChannel==channel)
               CB(c).cb(i).t_last_update=CB(c).t;
               CB(c).cb(i).max=max(CB(c).cb(i).max,pixel);
               CB(c).cb(i).min=min(CB(c).cb(i).min,pixel);
%                for n=1:channel
%                     CB(c).cb(i).max(n)=max(CB(c).cb(i).max(n),pixel(n));
%                     CB(c).cb(i).min(n)=min(CB(c).cb(i).min(n),pixel(n));
%                end
               match=true;
               break;
           end
       end
        
       if(~match)
          len=CB(c).numEntries;
          CB(c).cb(len+1)=struct('learnHigh',high,'learnLow',low,...
              'max',pixel,'min',pixel,'t_last_update',CB(c).t,'stale',0);
%           CB(c).cb(len+1).learnHigh=high;
%           CB(c).cb(len+1).learnLow=low;
%           CB(c).cb(len+1).max=pixel;
%           CB(c).cb(len+1).min=pixel;
%           
%           CB(c).cb(len+1).t_last_update=CB(c).t;
%           CB(c).cb(len+1).stale={0};
          CB(c).numEntries=CB(c).numEntries+1;
          mi=mi+1;
       end
       
%        for s=1:CB(c).numEntries
%           negRun=CB(c).t-CB(c).cb(s).t_last_update;
%           CB(c).cb(s).stale=max(CB(c).cb(s).stale,negRun);
%        end
        negRun=CB(c).t-[CB(c).cb.t_last_update];
        value=max([CB(c).cb.stale],negRun);
        y=num2cell(value);
        [CB(c).cb.stale]=deal(y{:});
        
        CB(c).cb(mi).learnHigh=[CB(c).cb(mi).learnHigh]+...
            uint8(CB(c).cb(mi).learnHigh<high);
        CB(c).cb(mi).learnLow=[CB(c).cb(mi).learnLow]-...
                uint8(CB(c).cb(mi).learnLow>low);
%        for n=1:channel
%           if(CB(c).cb(mi).learnHigh(n)<high(n))
%               CB(c).cb(mi).learnHigh(n)=CB(c).cb(mi).learnHigh(n)+1;
%           end
%           
%           if(CB(c).cb(mi).learnLow(n)>low(n))
%               CB(c).cb(mi).learnLow(n)=CB(c).cb(mi).learnLow(n)-1;
%           end
%        end
    end

    function y=backgroundDiff(pixel,c)
       matchChannel=0;
       for i=1:CB(c).numEntries;
           matchChannel=sum(CB(c).cb(i).min-minMod<=pixel&...
                       pixel<=CB(c).cb(i).max+maxMod);
%           matchChannel=0;
%          
%           for n=1:channel
%               if(CB(c).cb(i).min(n)-minMod(n)<=pixel(n)&&...
%                       pixel(n)<=CB(c).cb(i).max(n)+maxMod(n))
%                     matchChannel=matchChannel+1;
%               else
%                   break;
%               end
%           end
%           
%           if(matchChannel==channel)
%               match=true;
%               break;
%           end
       end
       
       if(matchChannel==channel)
           y=0;
       else
           y=255;
       end
    end

    function numCleared=clearStaleEntries(c)
        staleThresh=floor(CB(c).t/2);
%         keep=zeros(CB(c).numEntries,1);
%         keepCnt=0;
        
        keep=[CB(c).cb.stale]<=staleThresh;
        keepCnt=sum(keep);
%         for i=1:CB(c).numEntries
%             if(CB(c).cb(i).stale>staleThresh)
%                keep(i)=0;
%             else
%                 keep(i)=1;
%                 keepCnt=keepCnt+1;
%             end
%         end
        
        
%         foo=cell(keepCnt,1);
%         k=0;
%         for j=1:CB(c).numEntries
%            if(keep(j))
%                foo{k}=CB(c).cb{j};
%                foo{k}.stale=0;
%                foo{k}.t_last_update=0;
%                k=k+1;
%            end
%         end
        
        CB(c).t=0;
        CB(c).cb=CB(c).cb(keep);
        [CB(c).cb.stale]=deal(0);
        [CB(c).cb.t_last_update]=deal(0);
        numCleared=CB(c).numEntries-keepCnt;
        CB(c).numEntries=keepCnt;
        
    end
end
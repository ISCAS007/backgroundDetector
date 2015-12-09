function track_yzbx()
maskpath='D:\Program\matlab\bgslibrary_mfc\outputs\foreground';
inputpath='D:\Program\matlab\bgslibrary_mfc\outputs\input';

infolist=dir(maskpath);
masklist={infolist.name};

infolist=dir(inputpath);
inputlist={infolist.name};
fileNum=length(inputlist)-2;
frameNum=1;
input=getFrame(inputpath,inputlist,frameNum);
mask=getFrame(maskpath,masklist,frameNum);
[height,width]=size(mask);
minarea=floor(height*width/1000);

param=getKalmanParam();
oldblob={};
newblob={};
blobInit=false;
mingroupid=1;
groupid=1;
blobid=1;
minblobid=0;
groupinfo.boudary=zeros(0,4);
groupinfo.center=zeros(0,2);
groupinfo.group=zeros(0,1);
maxdistmat=[];
for frameNum=450:fileNum
    input=getFrame(inputpath,inputlist,frameNum);
    mask=getFrame(maskpath,masklist,frameNum);
    [area,center,boundary,pixellist]=blobInfo();
    newblob.area=area;
    newblob.center=center;
    newblob.pixellist=pixellist;
    newblob.boundary=boundary;
    newblob.input=input;
    newblob.mask=mask;
    
    
    [feature,point]=blobFeature();
    newblob.feature=feature;
    [tmp,~]=size(newblob.feature);
    newblob.time=ones(tmp,1)*frameNum;
    newblob.status=ones(tmp,1);
    newblob.point=point;
    newblob.group=zeros(tmp,1);
    newblob.grouptmp=zeros(tmp,1);
    newblob.newcount=zeros(tmp,1);
    newblob.lostcount=zeros(tmp,1);
    output_yzbx(newblob);
    
    [newblob,oldblob,pair,featuredeleteidx]=blobMatchAndUpdate(newblob,oldblob);
    
    output_yzbx(oldblob);
    oldblob=featureGrounpUpdate(newblob,oldblob,pair);
    
    output_yzbx(oldblob);
    %     oldblob.feature=oldblob.feature(~featuredeleteidx,:);
    %     oldblob.status=oldblob.status(~featuredeleteidx);
    %     oldblob.lostcount=oldblob.lostcount(~featuredeleteidx);
    %     oldblob.newcount=oldblob.newcount(~featuredeleteidx);
    %     oldblob.group=oldblob.group(~featuredeleteidx);
    
    figure(1),imshow(mask),title(masklist{frameNum+2});
end
    function output_yzbx(blob)
        size(blob.feature)
        size(blob.status)
        size(blob.lostcount)
        size(blob.newcount)
        size(blob.group)
    end
    function frame=getFrame(filepath,filelist,frameNum)
        frame=imread([filepath,'\',filelist{frameNum+2}]);
    end
    function param=getKalmanParam()
        param.motionModel           = 'ConstantAcceleration';
        param.initialLocation       = 'Same as first detection';
        param.initialEstimateError  = 1E5 * ones(1, 3);
        param.motionNoise           = [25, 10, 1];
        param.measurementNoise      = 25;
        param.segmentationThreshold = 0.05;
    end
    function [area,center,boundary,pixellist]=blobInfo()
        mask=imfill(mask==255,'holes');
        mask=bwareaopen(mask,minarea);
        cc=bwconncomp(mask);
        area=regionprops(cc,'Area');
        center=regionprops(cc,'Centroid');
        boundary=regionprops(cc,'BoundingBox');
        pixellist=cc.PixelIdxList;
    end

    function [newblob,oldblob,pair,featuredeleteidx]=blobMatchAndUpdate(newblob,oldblob)
        if(~blobInit)
            pair=[];
            %             oldblob=newblob;
            oldblob.feature=newblob.feature;
            oldblob.point=newblob.point;
            oldblob.status=newblob.status;
            oldblob.newcount=newblob.newcount;
            oldblob.lostcount=newblob.lostcount;
            oldblob.group=newblob.group;
            oldblob.grouptmp=newblob.grouptmp;
            oldblob.input=newblob.input;
            oldblob.mask=newblob.mask;
            oldblob.time=newblob.time;
            
            [newfeaturenum,~]=size(newblob.feature);
            featuredeleteidx=false(1,newfeaturenum);
            blobInit=true;
        else
            
            
            pair=matchFeatures(newblob.feature,oldblob.feature);
            newmatch=newblob.point(pair(:,1),:);
            oldmatch=oldblob.point(pair(:,2),:);
            figure(2),showMatchedFeatures(newblob.input,oldblob.input,newmatch,...
                oldmatch,'montage');
            title(inputlist{frameNum+2});
            
            newblobnum=length(newblob.area);
            %             oldblobnum=length(oldblob.area);
            %             matchmat=zeros(newblobnum,oldblobnum);
            newlocation=floor(newblob.point.Location);
            oldlocation=floor(newblob.point.Location);
            
            %             [pairnum,~]=size(pair);
            %             newblobgroup=false(newblobnum,pairnum);
            [newfeaturenum,~]=size(newblob.feature);
            %             oldblobpair=false(oldblobnum,pairnum);
            minblobid=blobid;
            
            for i=1:newfeaturenum
                newind=sub2ind([height,width],newlocation(i,2),oldlocation(i,1));
                %                 oldind=sub2ind([height,width],oldlocation(i,2),oldlocation(i,1));
                for j=1:newblobnum
                    %                     if(blob.pixellist
                    if(~isempty(find(newblob.pixellist{j}==newind,1,'first')))
                        %                         newblobgroup(j,i)=true;
                        newblob.grouptmp(i)=j+blobid;
                        break;
                    end
                end
                
            end
            blobid=blobid+newblobnum;
            
            
            %            update matched feature, add new feature
            for i=1:newfeaturenum
                j=find(pair(:,1)==i,1,'first');
                if(~isempty(j))
                    j=pair(j,2);
                    oldblob.feature(j,:)=newblob.feature(i,:);
                    %                     if(strcmp(oldblob.status(j),'normal'))
                    if(oldblob.status(j)==2)
                        oldblob.time(j)=frameNum;
                        continue;
                    end
                    
                    %                     if(strcmp(oldblob.status(j),'lost'))
                    if(oldblob.status(j)==3)
                        %                         oldblob.status(j)='normal';
                        oldblob.status(j)=2;
                        oldblob.time(j)=frameNum;
                        continue;
                    end
                    
                    %                     if(strcmp(oldblob.status(j),'new'))
                    if(oldblob.status(j)==1)
                        oldblob.newcount(j)=oldblob.newcount(j)+1;
                        if(oldblob.newcount(j)>2)
                            %                             oldblob.status(j)='normal';
                            oldblob.status(j)=2;
                        end
                        oldblob.time(j)=frameNum;
                    end
                else
                    oldblob.feature(end+1,:)=newblob.feature(i,:);
                    oldblob.point(end+1)=newblob.point(i);
                    oldblob.status(end+1)=1;
                    oldblob.newcount(end+1)=1;
                    oldblob.lostcount(end+1)=0;
                    oldblob.group(end+1)=0;
                    oldblob.grouptmp(end+1)=newblob.grouptmp(i);
                    oldblob.time(end+1)=frameNum;
                end
            end
            
            [oldfeaturenum,~]=size(oldblob.feature);
            featuredeleteidx=false(oldfeaturenum,1);
            %            update unmatched old feature, lost or need detete
            for i=1:oldfeaturenum
                if(oldblob.time(i)<frameNum)
                    %                     if(strcmp(oldblob.status(i),'normal'))
                    if(oldblob.status(i)==2)
                        %                         oldblob.status(i)='lost';
                        oldblob.status(i)=3;
                        oldblob.time(i)=frameNum;
                        oldblob.lostcount(i)=1;
                        continue;
                    end
                    %                     if(strcmp(oldblob.status(i),'lost'))
                    if(oldblob.status(i)==3)
                        %                         oldblob.status(i)='lost';
                        oldblob.status(i)=3;
                        oldblob.time(i)=frameNum;
                        oldblob.lostcount(i)=oldblob.lostcount(i)+1;
                        if(oldblob.lostcount(i)>3)
                            featuredeleteidx(i)=true;
                        end
                        continue;
                    end
                    %                     if(strcmp(oldblob.status(i),'new'))
                    if(oldblob.status(i)==1)
                        %                         oldblob.status(i)='lost';
                        oldblob.status(i)=3;
                        oldblob.time(i)=frameNum;
                        featuredeleteidx(i)=true;
                        continue;
                    end
                    
                end
            end
            oldblob.input=newblob.input;
            oldblob.mask=newblob.mask;
        end
    end

    function blobSpeed(oldblob,newblob)
        num=length(newblob.center);
        for i=1:num
            
        end
        if ~isTrackInitialized
            if isObjectDetected
                % Initialize a track by creating a Kalman filter when the ball is
                % detected for the first time.
                initialLocation = detectedLocation;
                kalmanFilter = configureKalmanFilter(param.motionModel, ...
                    initialLocation, param.initialEstimateError, ...
                    param.motionNoise, param.measurementNoise);
                
                isTrackInitialized = true;
                trackedLocation = correct(kalmanFilter, detectedLocation);
                label = 'Initial';
            else
                trackedLocation = [];
                label = '';
            end
            
        else
            % Use the Kalman filter to track the ball.
            if isObjectDetected % The ball was detected.
                % Reduce the measurement noise by calling predict followed by
                % correct.
                predict(kalmanFilter);
                trackedLocation = correct(kalmanFilter, detectedLocation);
                label = 'Corrected';
            else % The ball was missing.
                % Predict the ball's location.
                trackedLocation = predict(kalmanFilter);
                label = 'Predicted';
            end
        end
    end

    function [feature,point]=blobFeature()
        gray=rgb2gray(input);
        gray(~mask)=0;
        point=detectSURFFeatures(gray);
        %         plot(point.selectStrongest(100));
        [feature,point]=extractFeatures(gray,point);
        %         blob.feature=fea;
        %         blob.point=point;
        %         [nele,~]=hist(gray,10);
    end

    function [newblob,oldblob,validgroupmatchmat]=trackmerge(mergegroup,newblob,oldblob,validgroupmatchmat)
        [m,n]=size(mergegroup);
        i=1;
        j=1;
        while i<=m
            while j<=n
                if(i~=j&&mergegroup(i,j)~=0)
                    mergegroup(j,i)=0;
                    mingid=min(i,j);
                    maxgid=max(i,j);
                    mergegroup(mingid,:)=mergegroup(mingid,:)+mergegroup(maxgid,:);
                    mergegroup(:,mingid)=mergegroup(:,mingid)+mergegroup(:,maxgid);
                    %                     [len,~]=size(mergegroup);
                    %                     idx=[1:maxgid-1 maxgi+1:len];
                    %                     mergegroup=mergegroup(idx,idx);
                    mergegroup(maxgid,:)=0;
                    mergegroup(:,maxgid)=0;
                    
                    
                    
                    validgroupmatchmat(mingid,:)=validgroupmatchmat(mingid,:)|validgroupmatchmat(maxgid,:);
                    %                  validgroupmatchmat(:,mingid)=validgroupmatchmat(:,mingid)|validgroupmatchmat(:,maxgid);
                    %                     validgroupmatchmat=validgroupmatchmat(idx,:);
                    validgroupmatchmat(maxgid,:)=false;
                    
                    maxdistmat(mingid,:)=max(maxdistmat(mingid,:),maxdistmat(maxgid,:));
                    maxdistmat(:,mingid)=max(maxdistmat(:,mingid),maxdistmat(:,maxgid));
                    %                     maxdistmat=maxdistmat(idx,idx);
                    
                    %                     newgroupid=mergegroup(i,j);
                    %                     groupinfo.boundary(mingid,:)=newblob.boundary(newgroupid,:);
                    %                     groupinfo.center(mingid,:)=newblob.center(newgroupid,:);
                    
                    fidx= oldblob.group==mingroupid+maxgid-1;
                    oldblob.group(fidx)=mingroupid+mingid-1;
                end
                
                j=j+1;
            end
            %             [m,n]=size(mergegroup);
            i=i+1;
        end
    end

    function [oldblob,validmatchmat]=tracksplit(splitgroup,newblob,oldblob,pair,validmatchmat)
        [m,n]=size(splitgroup);
        i=1;
        j=1;
        while i<=m
            while j<=n
                if(i~=j&&splitgroup(i,j)~=0)
                    splitgroup(j,i)=0;
                    mingid=min(i,j);
                    maxgid=max(i,j);
                    %                  splitgroup(mingid,:)=splitgroup(mingid,:)+splitgroup(maxgid,:);
                    %                  splitgroup(:,mingid)=splitgroup(:,mingid)+splitgroup(:,maxgid);
                    %                     [len,~]=size(splitgroup);
                    %                     idx=[1:maxgid-1 maxgid+1:len];
                    %                     splitgroup=splitgroup(idx,idx);
                    
                    splitgroup(maxgid,:)=0;
                    splitgroup(:,maxgid)=0;
                    validmatchmat(maxgid,:)=0;
                    validmatchmat(:,maxgid)=0;
                    
                    
                    %                  validgroupmatchmat(mingid,:)=validgroupmatchmat(mingid,:)|validgroupmatchmat(maxgid,:);
                    % %                  validgroupmatchmat(:,mingid)=validgroupmatchmat(:,mingid)|validgroupmatchmat(:,maxgid);
                    %                  validgroupmatchmat=validgroupmatchmat(idx,:);
                    
                    addgroupinfo(newblob.boundary(maxgid,:),newblob.center(maxgid,:));
                    %                     maxdistmat(end+1,:)=0;
                    %                     maxdistmat(:,end+1)=0;
                    %                  maxdistmat=maxdistmat(idx,idx);
                    
                    %                     newgroupid=splitgroup(i,j);
                    %                     groupinfo.boundary(end+1,:)=newblob.boundary(maxgid,:);
                    %                     groupinfo.center(end+1,:)=newblob.center(maxgid,:);
                    
                    %                  fidx= oldblob.group==mingroupid+maxgid-1;
                    %                  oldblob.group(fidx)=mingroupid+mingid-1;
                    [pairnum,~]=size(pair);
                    
                    for k=1:pairnum
                        newfeatureid=pair(i,1);
                        oldfeatureid=pair(i,2);
                        
                        if(newblob.grouptmp(newfeatureid)==maxgid+minblobid)
                            oldblob.group(oldfeatureid)=groupid-1;
                        end
                        
                    end
                    
                    %                     groupid=groupid+1;
                end
                
                j=j+1;
            end
            [m,n]=size(splitgroup);
            i=i+1;
        end
    end

    function addgroupinfo(boundary,center)
        groupinfo.center(end+1,:)=center;
        groupinfo.boundary(end+1,:)=boundary;
        groupinfo.group(end+1)=groupid;
        groupid=groupid+1;
        maxdistmat(end+1,:)=0;
        maxdistmat(:,end+1)=0;
        
        [m,n]=size(maxdistmat);
        
        for i=1:m
            c=groupinfo.center(i,:);
            
            dif=center-c;
            maxdistmat(i,n)=sum(dif.^2);
            maxdistmat(n,i)=maxdistmat(i,n);
        end
    end

    function oldblob=featureGrounpUpdate(newblob,oldblob,pair)
        %         create new group, update group track status, split and merge
        %         group
        [featurenum,~]=size(oldblob.feature);
        grouptmp2id=zeros(0,2);
        %         mingroupid=groupid;
        
        
        tmp=oldblob.group(oldblob.group>0);
        if(isempty(tmp))
            mingroupid=groupid;
        else
            mintmp=min(tmp);
            mingroupid=mintmp(1);
        end
        
        %         bind grouptmp to group
        % new group, new maxdistmat and groupinfo
        for i=1:featurenum
            %             if(strcmp(oldblob.status(i),'normal')&&oldblob.group(i)==0)
            if(oldblob.status(i)==2&&oldblob.group(i)==0&&oldblob.grouptmp(i)>minblobid)
                id=find(grouptmp2id(:,1)==oldblob.grouptmp(i),1,'first');
                if(isempty(id))
                    grouptmp2id(end+1,1)=oldblob.grouptmp(i);
                    grouptmp2id(end,2)=groupid;
                    oldblob.group(i)=groupid;
                    
                    newblobid=oldblob.grouptmp(i)-minblobid;
                    addgroupinfo(newblob.boundary(newblobid,:),newblob.center(newblobid,:));
                    
                    %                     groupid=groupid+1;
                    %                     groupinfo.boundary(end+1,:)=zeros(1,4);
                    %                     groupinfo.center(end+1,:)=zeros(1,2);
                    %                     groupinfo.group(end+1)=groupid;
                    % %                     oldblob.boundary(end+1,:)=
                    %                     [s1,s2]=size(maxdistmat);
                    %                     tmp=maxdistmat;
                    %                     maxdistmat=zeros(s1+1,s2+1);
                    %                     maxdistmat(1:s1,1:s2)=tmp;
                else
                    oldblob.group(i)=grouptmp2id(id,2);
                end
                %             else
                %                 %                 if(strcmp(oldblob.status(i),'normal')&&oldblob.group(i)~=0)
                %                 if(oldblob.status(i)==2&&oldblob.group(i)~=0)
                %                     if(oldblob.group(i)<mingroupid)
                %                         mingroupid=oldblob.group(i);
                %                     end
                %                 end
            end
        end
        
        newblobnum=length(newblob.area);
        matchmat=zeros(groupid-mingroupid,newblobnum);
        
        %        matchmat(i,j) old group i and new group j's matched feature num.
        [pairnum,~]=size(pair);
        for i=1:pairnum
            newfeatureid=pair(i,1);
            oldfeatureid=pair(i,2);
            newgroupid=newblob.grouptmp(newfeatureid)-minblobid;
            
            if(newgroupid>0)
                oldgroupid=oldblob.group(oldfeatureid)-mingroupid+1;
                %             if(strcmp(oldblob.status(oldfeatureid),'normal'))
                if(oldblob.status(oldfeatureid)==2)
                    matchmat(oldgroupid,newgroupid)=matchmat(oldgroupid,newgroupid,1)+1;
                end
            end
        end
        
        
        %       trackarray[i]:  group i's valid feature num.
        trackarray=zeros(groupid-mingroupid,1);
        [oldfeaturenum,~]=size(oldblob.feature);
        for i=1:oldfeaturenum
            %             if(strcmp(oldblob.status(oldfeatureid),'normal'))
            if(oldblob.status(i)==2)
                oldgroupid=oldblob.group(i)-mingroupid+1;
                trackarray(oldgroupid)=trackarray(oldgroupid)+1;
            end
        end
        
        %         objtracker=[id][status][count]
        %         validmatchmat(i,j)=true meanning old group i matched new group j;
        validmatchmat=matchmat>3;
        validmatchmat(trackarray>3,:)=false;
        [m,n]=size(validmatchmat);
        
        ismerged=sum(validmatchmat,1)>1;
        mergegroup=zeros(m,n);
        for i=1:n
            if(ismerged(i))
                idx=find(validmatchmat(:,i));
                %                 distance=zeros(length(idx));
                
                for j=1:length(idx)
                    for k=1:length(idx)
                        if(j~=k)
                            oldgroupidj=idx(j)+mingroupid-1;
                            oldgroupidk=idx(k)+mingroupid-1;
                            centeridj=find(groupinfo.group==oldgroupidj,1,'first');
                            centeridk=find(groupinfo.group==oldgroupidk,1,'first');
                            %                             dif=oldblob.center(idx(j))-oldblob.center(idx(k));
                            %                             threshold=oldblob.boundary(1:2)+oldblob.boundary(1:2)+10;
                            dif=groupinfo.center(centeridj)-groupinfo.center(centeridk);
                            threshold=groupinfo.boundary(centeridj)-groupinfo.boundary(centeridk);
                            threshold=threshold(1:2);
                            dif=sum(dif.^2);
                            threshold=sum(threshold.^2);
                            
                            gidj=idx(j);
                            gidk=idx(k);
                            maxdist=maxdistmat(gidj,gidk);
                            
                            if(dif>maxdist)
                                maxdistmat(gidj,gidk)=dif;
                            else
                                dif=maxdist;
                            end
                            
                            if(dif<=threshold)
                                %                           do merge,
                                mergegroup(gidj,gidk)=i;
                            end
                        end
                    end
                end
            end
        end
        
        [newblob,oldblob,validmatchmat]=trackmerge(mergegroup,newblob,oldblob,validmatchmat);
        
        splitgroup=zeros(m,n);
        issplit=sum(validmatchmat,2)>1;
        for i=1:m
            if(issplit(i))
                idx=find(validmatchmat(i,:));
                
                %                 distance=zeros(length(idx));
                for j=1:length(idx)
                    for k=1:length(idx)
                        if(j~=k)
                            %                             dif=newblob.center(idx(j))-newblob.center(idx(k));
                            %                             threshold=newblob.boundary(1:2)+newblob.boundary(1:2)+10;
                            oldgroupidj=idx(j)+mingroupid-1;
                            oldgroupidk=idx(k)+mingroupid-1;
                            centeridj=find(groupinfo.group==oldgroupidj,1,'first');
                            centeridk=find(groupinfo.group==oldgroupidk,1,'first');
                            dif=groupinfo.center(centeridj)-groupinfo.center(centeridk);
                            threshold=groupinfo.boundary(centeridj)-groupinfo.boundary(centeridk);
                            threshold=threshold(1:2);
                            
                            dif=sum(dif.^2);
                            threshold=sum(threshold.^2);
                            if(dif>threshold)
                                %                           do split, record in objtracker
                                splitgroup(i,j)=m;
                            end
                        end
                    end
                end
            end
        end
        
        [oldblob,validmatchmat]=tracksplit(splitgroup,newblob,oldblob,pair,validmatchmat);
        
        [oldblob]=normalGroupUpdate(oldblob,newblob,validmatchmat);
    end

    function [oldblob]=normalGroupUpdate(oldblob,newblob,validmatchmat)
        oneoldidx=(sum(validmatchmat,1)==1);
        [m,n]=size(validmatchmat);
        for i=1:m
            if(oneoldidx(i))
                j=find(validmatchmat(i,:),1,'first');
                if(sum(validmatchmat(:,j)==1))
                    idx=find(groupinfo.group==mingroupid+i-1,1,'first');
                    groupinfo.center(idx,:)=newblob.center(j,:);
                    groupinfo.boundary(idx,:)=newblob.center(j,:);
                end
            end
        end
        
        %         update maxdistinfo
        %       only the matched groud update center and boundary.
        offset=find(groupinfo.group==mingroupid,1,'first');
        [m,n]=size(maxdistmat);
        for i=offset:m
            for j=1:n
                if(j<i)
                    dif=groupinfo.center(i)-groupinfo.center(j);
                    dist=sum(dif.^2);
                    if(maxdistmat(i,j)<dist)
                        maxdistmat(i,j)=dist;
                        maxdistmat(j,i)=dist;
                    end
                end
            end
        end
    end
end
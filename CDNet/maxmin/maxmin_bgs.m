function [model,mask]=maxmin_bgs(model,input)
% init and update layer at the same time
[a,b,c]=size(input);
if(isempty(model))
    model=init(input);
    mask=false(a,b);
else
    mask=getMask(model,input);
    model=updateModel(model,mask,input);
end

    function model=init(input)
        model=struct(...
            'Max',zeros(a,b,c,'uint8'),...
            'Min',zeros(a,b,c,'uint8'),...
            'MaxHitCount',ones(a,b,'uint8'),...
            'MinHitCount',ones(a,b,'uint8'),...
            'MaxUpdateTime',ones(a,b,'uint32'),...
            'MinUpdateTime',ones(a,b,'uint32'),...
            'MaxErrorAccTime',zeros(a,b,c,'uint8'),...
            'MinErrorAccTime',zeros(a,b,c,'uint8'),...
            'time',1);
        
        initGap=5;
        model.Max=input+initGap;
        model.Min=input-initGap;
    end

    function [mask]=getMask(model,input)
        abnormal=(input>model.Max+3)|(input+3<model.Min);
        mask=abnormal(:,:,1)|abnormal(:,:,2)|abnormal(:,:,3);
        mask=bwareaopen(mask,10);
        mask=bwfill(mask,'holes');
    end

    function model=updateModel(model,mask,input)
        learnGap=3;
        model.time=model.time+1;
        MaxHitMasks=input>(model.Max-learnGap);
        MinHitMasks=(input+learnGap)<model.Min;
        MaxHitMask=mask&(MaxHitMasks(:,:,1)|...
            MaxHitMasks(:,:,2)|MaxHitMasks(:,:,3));
        MinHitMask=mask&(MinHitMasks(:,:,1)|...
            MinHitMasks(:,:,2)|MinHitMasks(:,:,3));
        model.MaxUpdateTime(MaxHitMask)=model.time;
        model.MinUpdateTime(MinHitMask)=model.time;
        
        recentRange=20;
        MaxNotUpdateRecent=(model.time-model.MaxUpdateTime)>recentRange;
        MinNotUpdateRecent=(model.time-model.MinUpdateTime)>recentRange;
        model.MaxHitCount(MaxNotUpdateRecent)=floor(model.MaxHitCount(MaxNotUpdateRecent)/2);
        model.MinHitCount(MinNotUpdateRecent)=floor(model.MinHitCount(MinNotUpdateRecent)/2);
        
        if(floor(model.time/10)*10==model.time)
           model.MaxHitCount=model.MaxHitCount-1;
           model.MinHitCount=model.MinHitCount-1;
        end
        
        model.MaxHitCount=model.MaxHitCount+uint8(MaxHitMask);
        model.MinHitCount=model.MinHitCount+uint8(MinHitMask);
        
        MaxNotHitRecent=(model.MaxHitCount==0)&MaxNotUpdateRecent;
        MaxNotHitRecents=repmat(MaxNotHitRecent,[1,1,3]);
        increment=1+(model.Max-model.Min)/20;
        increment=uint8(increment);
        model.Max(MaxNotHitRecents)=model.Max(MaxNotHitRecents)-increment(MaxNotHitRecents);
        masks=repmat(mask,[1,1,3]);
        modelMax=max(model.Max,input);
        model.Max(masks)=modelMax(masks);
        
        MinNotHitRecent=(model.MinHitCount==0)&(MinNotUpdateRecent);
        MinNotHitRecents=repmat(MinNotHitRecent,[1,1,3]);
        model.Min(MinNotHitRecents)=model.Min(MinNotHitRecents)+increment(MinNotHitRecents);
        modelMin=min(model.Min,input);
        model.Min(masks)=modelMin(masks);
        
        model.MaxCount(MaxNotHitRecent)=1;
        model.MinCount(MinNotHitRecent)=1;
    end

end
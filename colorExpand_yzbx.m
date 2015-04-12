function newm=colorExpand_yzbx(f,m,s)
%f=frame, m=mask, s=expand size, p=preimter, b=boundingBox
    p=bwperim(m);
    p=find(p~=0);
    rp=regionprops(m,'BoundingBox')
    b=uint32(round(rp(1).BoundingBox));
    nump=length(p);
    select=[1:10:nump];
    selp=p(select);
    
    newm=m;
    numsel=length(selp);
    region(1)=uint32(b(1)+b(3)*s);
    region(2)=uint32(b(2)+b(4)*s);
    region=min(region,uint32([size(f,1),size(f,2)]));
    
    self=f(b(2):region(2),b(1):region(1),:);
    [width,height,channel]=size(f);
    off=[0:channel-1]*width*height;
    for i=1:numsel     
         bb=true(size(self,1),size(self,2));
         for j=1:channel
            minmask=uint8(f(selp(i)+off(j))-5);
            maxmask=uint8(f(selp(i)+off(j))+5);
            a=((self(:,:,j)>=minmask)&(self(:,:,j)<=maxmask));
            bb=a&bb;
         end
         newm(b(2):region(2),b(1):region(1))=...
             newm(b(2):region(2),b(1):region(1))|bb;
    end

end
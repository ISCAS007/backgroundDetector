function [cross,point]=trajectorycross(tra,objid1,objid2)
% tra={ojbid,frameid,xleft,yleft,xright,yright] 
    cross=false;
    point=zeros(0,2);
    tra1=tra(find(tra(:,1)==objid1),:);
    tra2=tra(find(tra(:,1)==objid2),:);
    
    m1=size(tra1,1);
    m2=size(tra2,1);
    
    if(m1>=2&&m2>=2)
        i=1;
        j=1;
       
        while(i<m1&&j<m2)
             fi=tra1(i,2);
            fj=tra2(j,2);
        
            if(fi>tra2(j+1,2))
                j=j+1;
                continue;
            end
            
            if(fj>tra1(i+1,2))
               i=i+1; 
               continue;
            end
            
            box1=tra1(i,3:6);
            box2=tra1(i+1,3:6);
            xa=[box1(1)+box1(3),box1(2)+box1(4)]/2;
            xb=[box2(1)+box2(3),box2(2)+box2(4)]/2;
            
            box1=tra2(j,3:6);
            box2=tra2(j+1,3:6);
            xc=[box1(1)+box1(3),box1(2)+box1(4)]/2;
            xd=[box2(1)+box2(3),box2(2)+box2(4)]/2;
            
            p=linecrosspoint(xa,xc,xb,xd);
            if(sum((p-xa).*(p-xb)<=0)==2&&sum((p-xc).*(p-xd)<=0)==2)
               cross=true;
               point=[point;p];
            end
            
            if(fi<=fj)
               i=i+1; 
            else
                j=j+1;
            end
        end
    end
    
end
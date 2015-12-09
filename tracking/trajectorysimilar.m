function [similarity]=trajectorysimilar(obj,objset)
%     find pagerank of obj in objset
%     obj=[objid,frameid,trajectory]
%     trajectory=[x1,y1,x2,y2,...]
%     box are normal and resampled.
    [m,n]=size(objset);
    n=n-2;
    similarity=zeros(1,m);
    st=0.3;
    
    for i=1:m
        tra1=obj(3:end);
        tra2=objset(i,3:end);
        dif=abs(tra1-tra2);
        if(dif(1)>st||dif(2)>st||dif(end-1)>st||dif(end)>st)
            similarity(i)=0;
        else            
            vec1=tra1(3:end)-tra1(1:end-2);
            vec2=tra2(3:end)-tra2(1:end-2);
%             x/y
            v1=atan(vec1(1:2:end)./vec1(2:2:end));
            v2=atan(vec2(1:2:end)./vec2(2:2:end));
            bindist=abs(v1-v2)>0.5;
            
            if(sum(bindist)>4)
                similarity(i)=0;
            else
%                 x=tra(1:2:end), y=tra(2:2:end)
%                 tra=[x1,y1,x2,y2,...xk,yk]
                vecdif=abs(v1-v2);
                similarity(i)=1-mean(dif)-abs(sum(tra1(1:2:end)-...
                    tra2(1:2:end)))-abs(sum(tra1(2:2:end)-tra2(2:2:end)))-mean(vecdif);
%                 similarity(i)=1-mean(dif)-abs(sum(tra1-tra2))/5-mean(vecdif)-abs(sum(v1-v2))/5;
%                 similarity(i)=1-mean(vecdif);
            end
        end
    end
    
   
end
function pmin=minFilter_yzbx(frame,filterSize)
% just like meanFilter for picture, this the minfilter for frame.

[a,b,c]=size(frame);

if(c==1)
   disp('error: frame need to be rgb pic'); 
end

if(filterSize==0)
    filterSize=[5,5];
    display(filterSize);
end

[x,y]=floor((filterSize-1)/2);

pmin=frame;
for j=1:a
    if(j<=x)
        u=x+1;
    else
        if(j+x>a)
            u=a-x;
        else
            u=j;
        end
    end
    for k=1:b
        if(v<=y)
            v=y+1;
        else
            if(k+y>b)
                v=b-y;
            else
                v=k;
            end
        end
        
        area=frame(u-x:u+x,v-y:v+y,:);
        pmin(j,k,:)=min(min(area,2),1);
    end
end
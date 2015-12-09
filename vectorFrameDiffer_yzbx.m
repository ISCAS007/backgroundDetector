function difmask=vectorFrameDiffer_yzbx(pmax,pmin,frame,thershold)
% get the vector difference among pmax,pmin and frame by threshold

c=size(frame,3);
if(c==1)
   disp('error: frame must be rgb pic!!!');
else
    pmid=(pmax+pmin)/2;
    pvec1=pmax-pmin;
    pvec2=double(frame)-pmid;
    pvec1=pvec1+1;  %avoid divide 0
    pvec2=pvec2+1; 

    for i=3:-1:1
        pvec1(:,:,i)=pvec1(:,:,i)./pvec1(:,:,1);
        pvec2(:,:,i)=pvec2(:,:,i)./pvec2(:,:,1);
    end
    
    if(thershold==0)
        a=cross([1,1,1],[1.1,0.9,1.1]);
        thershold=sum(a.^2)*3;
        display(thershold);
    end
    
    pvec3=cross(pvec1,pvec2,3);
    difmask=sum(pvec3.^2,3)>thershold;
    outmask=(frame(:,:,1)>pmax(:,:,1))|(frame(:,:,1)<pmin(:,:,1));
    difmask=difmask|outmask;
end


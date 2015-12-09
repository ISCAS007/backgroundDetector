load baseline-PETS2006;

param=linefit3d(rgb(3,3,1,:),rgb(3,3,2,:),rgb(3,3,3,:));
[a,b,c,d]=size(rgb);
data=rgb(3,3,:,:);
data=reshape(data,c,d);
pmax=zeros(3,1);
pmin=zeros(3,1);
pmaxnum=0;
pminnum=0;
recordmax=zeros(3,d);
recordmin=zeros(3,d);
recordmaxnum=zeros(1,d);
recordminnum=zeros(1,d);
for i=2:d
   if(i==2)
       [~,pmaxidx]=max(data(1,1:2),[],2);
       [~,pminidx]=min(data(1,1:2),[],2);
       pmaxnum=1;
       pminnum=1;
       pmax=data(:,pmaxidx);
       pmin=data(:,pminidx);
   else
       if(data(1,i)>pmax(1))
           pmax=pmax*0.95+data(:,i)*0.05;
           pmaxnum=pmaxnum+1;
       else
          if(data(1,i)<pmin(1))
             pmin=pmin*0.95+data(:,i)*0.05;
             pminnum=pminnum+1;
          else
              if(pmaxnum>pminnum)
                  pmin=pmin*0.95+data(:,i)*0.05;
                  pminnum=pminnum+1;
              else
                  pmax=pmax*0.95+data(:,i)*0.05;
                  pmaxnum=pmaxnum+1;
              end
          end
       end
   end
   
   recordmax(:,i)=pmax;
   recordmin(:,i)=pmin;
   recordmaxnum(i)=pmaxnum;
   recordminnum(i)=pminnum;
end
save('record.mat','recordmax','recordmaxnum','recordmin','recordminnum');

tmp2p=(pmax+pmin)/2;
tmp2p=tmp2p-tmp2p(1);
tmp2v=pmax-pmin;
tmp2v=tmp2v/tmp2v(1);
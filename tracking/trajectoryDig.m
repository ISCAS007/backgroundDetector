function trajectoryDig()
    csvpath='D:\Program\matlab\bgslibrary_mfc\dataset\data1.csv';
    sql=csvread(csvpath,1,0);
    
    
%     imgpath='D:\Program\matlab\bgslibrary_mfc\outputs\foreground\00000009.png';
    imgpath='readVideo1.png';
    img=imread(imgpath);
    [height,width,~]=size(img);
    normtra=trajectorynorm(sql,width,height);
    
%     display(size(normtra));
    [m,n]=size(normtra);
    n=floor((n-2)/2);
    
    ratio=max(width,height);
    line=normtra(:,3:end);
    line(:,1:2:end)=line(:,1:2:end)*ratio;
    line(:,2:2:end)=line(:,2:2:end)*ratio;
    point=zeros(m*n,2);
    x=line(:,1:2:end);
    y=line(:,2:2:end);
    point(:,1)=x(:);
    point(:,2)=y(:);
    org=img;
    img=insertShape(img,'Line',line,'Color','red'); 
    img=insertMarker(img,point);
    imshow(img);
    imwrite(img,'trajectories.png','png');
    
    display('the assciation between trajectories');
    sim=zeros(m,m);
    for i=1:m
        obj=normtra(i,:);
        similarity=trajectorysimilar(obj,normtra);
        sim(i,:)=similarity;
    end
    
    save('sim.mat','sim');
    
    threshold=0.0;
    adjmat=sim>threshold;
    
   
    for i=1:m
        idx=find(adjmat(i,:));
        
        minidx=m;
        for k=1:length(idx)
            tmp=min(find(adjmat(:,idx(k))));
            if(tmp<minidx)
               minidx=tmp; 
            end
        end
%         minidx=min(min(adjmat(:,idx)));
        
        for k=1:length(idx)
            if(minidx~=idx(k))
            adjmat(minidx,:)=adjmat(minidx,:)|adjmat(idx(k),:);
            adjmat(idx(k),:)=false;
            end
        end
    end
%     
    gray=rgb2gray(org);
    edgeimg=edge(gray,'canny',0.6);
    rgbmask=repmat(edgeimg,[1,1,3]);
    rgb=repmat(gray,[1,1,3]);
    rgb(~rgbmask)=0;
    rgb(rgbmask)=255;
    emptyimg=zeros(size(org),class(org));
    for i=1:m
       if(sum(adjmat(i,:))>1)
           display(find(adjmat(i,:)));
           newline=line(adjmat(i,:),:);
           img=insertShape(emptyimg,'Line',newline,'Color','white'); 
           [m,n]=size(newline);
           n=n/2;
           newpoint=zeros(m*n,2);
            x=newline(:,1:2:end);
            y=newline(:,2:2:end);
            newpoint(:,1)=x(:);
            newpoint(:,2)=y(:);
            
           img=insertMarker(img,newpoint);
           img(img>0)=255;
           figure,imshow(img);
           imwrite(img,['trajectory-',num2str(i),'.png']);
       end
    end
end
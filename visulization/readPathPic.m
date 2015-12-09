% [I,map,alpha] = imread('im.png');
% h = imshow(I);
% set(h,'AlphaData',alpha)
function readPathPic()
%     loadpath();
    
    data=load('path.mat');
    
    pathdata=data.pathdata;
    figure,imshow(path2mask(pathdata(1)));
    figure,imshow(path2mask(pathdata(2)));
    figure,imshow(path2mask(pathlinker(pathdata(1),pathdata(2))));
    
    showAll(pathdata);
    
    p1=[1,3,5];
    p2=[2,4,6,8];
    p3=[3,5,8,9];
    p4=[2,1,3,5,6];
    p5=[1,3,1,4,7];
    
    showPeople(p1,pathdata);
    showPeople(p2,pathdata);
    showPeople(p3,pathdata);
    showPeople(p4,pathdata);
    showPeople(p5,pathdata);
end

function loadpath()
    picpath='D:\firefoxDownload\matlab';
    piclist=dir(fullfile('D:\firefoxDownload\matlab','*.png'));
    picnamelist={piclist.name};
    picnum=length(piclist);

    pathdata(picnum).x=[];
    pathdata(picnum).y=[];
    for i=1:picnum
       [pic,map,alpha]=imread([picpath,'\',picnamelist{i}]);
       h=imshow(pic);
       set(h,'AlphaData',alpha)
       [x,y]=find(alpha~=0);
       pathdata(i).x=x;
       pathdata(i).y=y;
    end
    save('path.mat','pathdata');
end

function pathdata=pathlinker(pathdata1,pathdata2)
    xoff=pathdata1.x(end);
    yoff=pathdata1.y(end);
    
    
    x=[pathdata1.x(:);pathdata2.x(:)+xoff];
    y=[pathdata1.y(:);pathdata2.y(:)+yoff];
    pathdata.x=x;
    pathdata.y=y;
    
%     len1=length(path1.x);
%     len2=length(path2.x);
%     path2.x=xoff+path2.x;
%     path2.y=yoff+path2.y;
%     path=[path1,path2];
    
%     path=path1;
%     for i=1:len2
%        path(len1+i).x=xoff+path2(i).x;
%        path(len1+i).y=yoff+path2(i).y;
%     end 
end

function mask=path2mask(path)
    xmax=max(path.x);
    ymax=max(path.y);
    mask=false(xmax,ymax);
    ind=sub2ind([xmax,ymax],path.x,path.y);
    mask(ind)=true;
%     len=length(path.x);
%     for i=1:len
%         mask(path.x,path.y)=true;
%     end
end

function showAll(path)
    len=length(path);
    
    for i=1:len
       if(i==1)
           xmax=max(path(i).x);
           ymax=max(path(i).y);
       else
           xmax=max(xmax,max(path(i).x));
           ymax=max(ymax,max(path(i).y));
       end
       [i,xmax,ymax]
    end
    
    mask=false(xmax,ymax);
    size(mask)
    for i=1:len
       ind=sub2ind([xmax,ymax],path(i).x,path(i).y);
       mask(ind)=true;
    end
    size(mask)
    
    figure,imshow(mask),title('allpath');
end

function showlinkpath(p,path)
    len=length(p);
    
    for i=1:len
       if(i==1)
           xmax=max(path(p(i)).x);
           ymax=max(path(p(i)).y);
       else
           xmax=max(xmax,max(path(p(i)).x));
           ymax=max(ymax,max(path(p(i)).y));
       end
       [i,p(i),xmax,ymax]
    end
    
    mask=false(xmax,ymax);
    size(mask)
    for i=1:len
       ind=sub2ind([xmax,ymax],path(p(i)).x,path(p(i)).y);
       mask(ind)=true;
    end
    size(mask)
    
    figure,imshow(mask),title('people');
end

function showPeople(p,path)
    len=length(p);
    
    for i=2:len
       if(i==2)
           linkpath=pathlinker(path(p(i-1)),path(p(i)));
       else
           linkpath=pathlinker(linkpath,path(p(i)));
       end
    end
    
    figure,imshow(path2mask(linkpath)),title('linkpath');
end

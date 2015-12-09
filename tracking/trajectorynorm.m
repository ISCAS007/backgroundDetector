function [normtra]=trajectorynorm(tra,width,height)
% norm tra=[id,frame,box] to [id,frame,x1,y1,x2,y2,...xn,yn]
    n=20;
    minid=min(tra(:,1));
    maxid=max(tra(:,1));
    if(minid==0)
       warning('modify index from 0 to 1');
       tra(:,1)=tra(:,1)+1;
       minid=1;
       maxid=maxid+1;
    end
    
    normtra=zeros(maxid,2*n+2);
    ratio=max(width,height);
%     rawpoints=zeros(0,2*n);
    for i=minid:maxid
       id=(tra(:,1)==i);
       obji=tra(id,:);
       normtra(i,1)=i;
       normtra(i,2)=obji(1,2);
       m=size(obji,1);
       rawpoints=zeros(m,2);
       for j=1:m
          rawpoints(j,1)= (obji(j,3)+obji(j,5))/2/ratio;
%           keey the frame ratio
          rawpoints(j,2)=(obji(j,4)+obji(j,6))/2/ratio;
       end
       
       gap=pathlength(rawpoints)/(n-1);
       d=0;
       k=5;
       normtra(i,3)=rawpoints(1,1);
       normtra(i,4)=rawpoints(1,2);
       j=1;
       while j<m
           dist=sqrt(sum((rawpoints(j+1,:)-rawpoints(j,:)).^2));
           if(dist+d>=gap)
                if(dist<0.0001)
                    normtra(i,k)=rawpoints(j+1,1);
                    normtra(i,k+1)=rawpoints(j+1,2);
                else
                    normtra(i,k)=rawpoints(j,1)+(gap-d)*(rawpoints(j+1,1)-rawpoints(j,1))/dist;
                    normtra(i,k+1)=rawpoints(j,2)+(gap-d)*(rawpoints(j+1,2)-rawpoints(j,2))/dist;
                end
                rawpoints(j,1)=normtra(i,k);
                rawpoints(j,2)=normtra(i,k+1);
                k=k+2;
                d=0;
           else
               d=d+dist;
               j=j+1;
           end    
       end
       
       if(k<2*n+2)
           warning('add last point');
           display(normtra(i,:));
           normtra(i,k:k+1)=rawpoints(end,:);
       end
    end
    
    function len=pathlength(points)
        len=0;
        mm=size(points,1);
        for ii=1:mm-1
            len=len+sqrt(sum((points(ii+1,:)-points(ii,:)).^2));
        end
    end
%   javascript in norm line.
%   var I = PathLength(points) / (n - 1); // interval length
% 	var D = 0.0;
% 	var newpoints = new Array(points[0]);
% 	for (var i = 1; i < points.length; i++)
% 	{
% 		var d = Distance(points[i - 1], points[i]);
% 		if ((D + d) >= I)
% 		{
% 			var qx = points[i - 1].X + ((I - D) / d) * (points[i].X - points[i - 1].X);
% 			var qy = points[i - 1].Y + ((I - D) / d) * (points[i].Y - points[i - 1].Y);
% 			var q = new Point(qx, qy);
% 			newpoints[newpoints.length] = q; // append new point 'q'
% 			points.splice(i, 0, q); // insert 'q' at position i in points s.t. 'q' will be the next i
% 			D = 0.0;
% 		}
% 		else D += d;
% 	}
% 	if (newpoints.length == n - 1) // somtimes we fall a rounding-error short of adding the last point, so add it if so
% 		newpoints[newpoints.length] = new Point(points[points.length - 1].X, points[points.length - 1].Y);
% 	return newpoints;
end
function p=linefit3d(x,y,z)
% fit 3d line for(x,y,z)
% return line: (x,y,z)=(x0,y0,z0)+a*(t1,t2,t3)
% parameter=(x0,y0,z0,t1,t2,t3)
p1=polyfit(x,y,1);
p2=polyfit(x,z,1);
% y=p1(1)*x+p1(2)
% z=p2(1)*x+p2(2)
% (y-p1(2))/p1(1)=(z-p2(2))/p2(1)=(x-0)/1
p=[0,p1(2),p2(2),1,p1(1),p2(1)];
% data=p(4:6)'*x+p(1:3)'*ones(size(x));
% dif=sum(abs(data-[x;y;z]),1);
% disp('mean fit difference');
% disp(mean(dif));
% disp('max fit difference');
% disp(max(dif));
end
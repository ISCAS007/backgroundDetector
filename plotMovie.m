n=50;
h=gca;
axisvector=[1,1,1];
M=moviein(n);
for i=1:n
%        rotate(h,p(4:6),360/n);
%        rotate(h,[0,0,1],36);
%        a=i/n*2*pi;
%        sin(a),cos(a),0
%        view(h,sin(a),cos(a));
   camorbit(360/n,0,'data',axisvector);
   pause(0.1);
   drawnow;
   M(:,i)=getframe;
end

movie(M,2);
boats=[343233	6726	1207618	245712893	325];
canoe=[	586860	813	456509	28418908	0];
fall=[	17372666	4162404	965331	1012627503	376080];
fountain01=[66947	176396	10556	93106659	0];
fountain02=[	242552	8769	24677	123953562	0];
overpass=[	1326047	42379	651845	145600382	12354];

result=[boats;canoe;fall;fountain01;fountain02;overpass];

for i=1:6
   tp=result(i,1);
   fp=result(i,2);
   fn=result(i,3);
   tn=result(i,4);
   
%    p=(tp+tn)/(tp+fp+fn+tn);
   p=tp/(tp+fp);
   r=tp/(tp+fn);
   
   f=2*p*r/(p+r);
   
   fprintf('i=%d p=%f r=%f f=%f \n',i,p,r,f);
   
      p=(tp+tn)/(tp+fp+fn+tn);
%    p=tp/(tp+fp);
   r=tp/(tp+fn);
   
   f=2*p*r/(p+r);
   
   fprintf('my: i=%d p=%f r=%f f=%f \n',i,p,r,f);
end
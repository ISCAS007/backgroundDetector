% PBAS
% boats=[343233	6726	1207618	245712893	325];
% canoe=[	586860	813	456509	28418908	0];
% fall=[	17372666	4162404	965331	1012627503	376080];
% fountain01=[66947	176396	10556	93106659	0];
% fountain02=[	242552	8769	24677	123953562	0];
% overpass=[	1326047	42379	651845	145600382	12354];

%subsense
% boats=[755296	115472	795555	245604147	376];
% canoe=[	718408	6048	324961	28413673	0];
% fall=[	16517929	2557319	1820068	1014232588	317752];
% fountain01=[	69683	40633	7820	93242422	0];
% fountain02=[	248637	9779	18592	123952552	0];
% overpass=[	1616451	99891	361441	145542870	12028];
% 
% result=[boats;canoe;fall;fountain01;fountain02;overpass];

result=dlmread('CDNetResult.csv','\t',0,1);
% result=uint64(result);
[m,n]=size(result);
for i=1:m
   tp=result(i,1);
   fp=result(i,2);
   fn=result(i,3);
   tn=result(i,4);
   
%    p=(tp+tn)/(tp+fp+fn+tn);
   p=tp/(tp+fp);
   r=tp/(tp+fn);
   
   f=2*p*r/(p+r);
   
   fprintf('i=%d p=%f r=%f f=%f \n',i,p,r,f);
   
%       p=(tp+tn)/(tp+fp+fn+tn);
% %    p=tp/(tp+fp);
%    r=tp/(tp+fn);
%    
%    f=2*p*r/(p+r);
%    
%    fprintf('my: i=%d p=%f r=%f f=%f \n',i,p,r,f);
end





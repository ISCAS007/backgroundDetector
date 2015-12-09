function validate_yzbx(prec,y)
N=length(y);
TP=sum(prec==1&y==1);
TN=sum(prec==0&y==0);
FP=sum(prec==1&y==0);
FN=sum(prec==0&y==1);
P=TP/(TP+FP);
R=TP/(TP+FN);
if(TP~=0)
    F=2*P*R/(P+R);
else
    warning('TP==0 !!!!!!!!!!!!!!!!!!!!!!!\n');
    F=0;
end
fprintf('********************************\n');
fprintf('TP=%f,TN=%f,FP=%f,FN=%f,N=%d\n',TP/N,TN/N,FP/N,FN/N,N);
fprintf('P=%f,R=%f,F=%f\n',P,R,F);
end
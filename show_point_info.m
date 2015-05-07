function show_point_info(point_info)
%point_info=zeros(5,5,3,size(wanted,2),filenum);
[a,b,c,d,e]=size(point_info);

% normalize
sum_point_info=sum(point_info,3);
for i=1:c
    point_info(:,:,i,:,:)=point_info(:,:,i,:,:)./sum_point_info;
end

r=ones(1,e);
g=ones(1,e);
b=ones(1,e);
if(a==1)
    i=1;
    r(:)=point_info(1,1,1,i,:);
    g(:)=point_info(1,1,2,i,:);
    b(:)=point_info(1,1,3,i,:);
    l=(r+g+b)/3;
    figure,plot(1:e,r,1:e,g);
    title('r,g');
    legend('r','g');
    figure,plot(1:e,g,1:e,b);
    title('g,b');
    legend('g','b');
    figure,plot(1:e,r,1:e,b);
    title('r,b');
    legend('r','b');
    figure,plot(1:e,r,1:e,l);
    title('r,l');
    legend('r','l');
    r_g=(r+1)./(g+1);
    r_b=(r+1)./(b+1);
    r_l=(r+1)./(l+1);
    figure,plot(1:e,r_g);
    title('r:g');
    figure,plot(1:e,r_b);
    title('r:b');
    figure,plot(1:e,r_l);
    title('r:l');
    rg=r-g;
    rb=r-b;
    rl=r-l;
    figure,plot(1:e,rg);
    title('r-g');
    figure,plot(1:e,rb);
    title('r-b');
    figure,plot(1:e,rl);
    title('r-l');
else
    if(a==3)    
        for i=1:c
           r(:)=point_info(1,1,1,i,:);
           g(:)=point_info(1,1,2,i,:);
           figure,plot(1:e,r,1:e,g);
           title(['point',num2str(i),' r:g']);
           legend('r','g');
        end
    else
        for i=1:a
            for j=1:b
                r(:)=point_info(i,j,1,1,:);
                g(:)=point_info(i,j,2,1,:);
                figure,plot(1:e,r,1:e,g);
                title(['point',num2str(i),' r:g']);
                legend('r','g');
            end
        end
    end
end

end
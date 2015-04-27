load pos.mat;
[a,b,c,d,e]=size(point_info);

% normalize
% sum_point_info=sum(point_info,3);
% for i=1:c
%     point_info(:,:,i,:,:)=point_info(:,:,i,:,:)./sum_point_info;
% end

r=ones(1,e);
g=ones(1,e);
b=ones(1,e);
pos=1;
r(:)=point_info(1,1,1,pos,:);
g(:)=point_info(1,1,2,pos,:);
b(:)=point_info(1,1,3,pos,:);

figure,scatter(r(2:end),b(2:end));
for i=2:90
   text(r(i),b(i),num2str(i)); 
end
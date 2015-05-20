% load pos.mat;
data=load('baseline-highway.mat');
point_info=data.rgb;
[~,~,~,e]=size(point_info);

% normalize
% sum_point_info=sum(point_info,3);
% for i=1:c
%     point_info(:,:,i,:,:)=point_info(:,:,i,:,:)./sum_point_info;
% end

r=ones(1,e);
g=ones(1,e);
b=ones(1,e);
color=ones(1,e);
pos=1;
r(:)=point_info(1,1,1,:);
g(:)=point_info(1,1,2,:);
b(:)=point_info(1,1,3,:);
color(:)=data.class(1,1,1,:);

figure,scatter(r(1:end),b(1:end),3,color);
% for i=round(linspace(1,e,20))
%    text(r(i),b(i),num2str(i)); 
% end
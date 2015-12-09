K=3;
x=zeros(K,1);
y=zeros(K,1);
for count=1:K
    load(['backgroundLightAnalyse-',num2str(count),'.mat']);
    x(count)=mean(staticPixel2d);
    y(count)=max(staticPixel2d)-min(staticPixel2d);
    
    figure;
    
    idx=(staticPixel2d~=-1);
    set=staticPixel2d(idx);
    dif=set(2:end)-set(1:end-1);
    subplot(131),scatter(1:length(dif),abs(dif)),title('static-motion-frameDif');
    hold on;
    idx=(motionPixel2d~=-1);
    set=motionPixel2d(idx);
    dif=set(2:end)-set(1:end-1);
    scatter(1:length(dif),abs(dif)),legend('static','motion','Location','SouthOutside');
    
    idx=(staticPixel3d(:,1)~=-1);
    set=staticPixel3d(idx,:);
    subplot(132),scatter3(set(:,1),set(:,2),set(:,3)),title('static-motion-rgb');
    hold on;
    idx=(motionPixel3d(:,1)~=-1);
    set=motionPixel3d(idx,:);
    scatter3(set(:,1),set(:,2),set(:,3)),legend('static','motion','Location','SouthOutside');
    
    idx=(staticPixel3d(:,1)~=-1);
    set=staticPixel3d(idx,:);
%     [set,~]=vectorNorm_yzbx(set);
%     subplot(133),scatter3(set(:,1),set(:,2),set(:,3)),title('static-motion-rgb-norm');
    set=rgb2sphere(set);
    subplot(133),scatter(set(:,1),set(:,2)),title('static-motion-rgb-norm');

    hold on;
    idx=(motionPixel3d(:,1)~=-1);
    set=motionPixel3d(idx,:);
%     [set,~]=vectorNorm_yzbx(set);
%     scatter3(set(:,1),set(:,2),set(:,3)),legend('static','motion','Location','SouthOutside');
    set=rgb2sphere(set);
    scatter(set(:,1),set(:,2)),legend('static','motion','Location','SouthOutside');

end

figure,scatter(x,y),title('(mean,max-min)');
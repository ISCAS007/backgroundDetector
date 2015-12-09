close all;

for i=1:3
    figure;
    subplot(2,2,1);
    %         imshow(gtImg);
    rgb=i;
    y=r(label<=50,rgb);
    x=find(label<=50);
    scatter(x,y,3,'green');
    hold on;
    
    y2=input(label>=170,rgb);
    x2=find(label>=170);
    scatter(x2,y2,3,'red');
    
    subplot(2,2,2);
    normplot(y);
    
    subplot(2,2,3);
    hist(y-mean(y));
    
    subplot(2,2,4);
    normplot(y(2:end)-y(1:end-1));
end
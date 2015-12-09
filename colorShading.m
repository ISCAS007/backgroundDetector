function dif=colorShading(rgb1,rgb2)
    w=[1,1,1]';
    dif=sqrt((rgb1-rgb2).^2))*w;
end
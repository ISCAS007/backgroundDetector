function [vecMask,pmaxsetMask,pminsetMask]=getVectorMask_yzbx(rgb,pixelmean,pmaxnum,pminnum)
% 获得可以进行线性拟合的像素点
% pixel-pixel.mean>[10,10,10]
% pmaxsetMask 上界达到要求的像素点索引
% pminsetMask 下界达到要求的像素点索引
% 可以进行线性拟合的像素点的索引
% 建议随机减少pmaxnum,pminnum.防止样本出现因为长久不更新而带来误差的问题
% 注意：线性拟合仅针对背景像素点

[a,b,c]=size(rgb);
numgap=10;
pixelgap=10;
rgbgap=double(rgb)-pixelmean;
pmaxsetMask=true(a,b);
pminsetMask=true(a,b);
for i=1:c
   pmaxsetMask=pmaxsetMask&(rgbgap(:,:,i)>pixelgap);
   pminsetMask=pminsetMask&(rgbgap(:,:,i)<-pixelgap);
end

vecMask=pmaxsetMask&pminsetMask&(pmaxnum>numgap)&(pminnum>numgap);
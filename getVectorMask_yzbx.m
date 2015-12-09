function [vecMask,pmaxsetMask,pminsetMask]=getVectorMask_yzbx(rgb,pixelmean,pmaxnum,pminnum)
% ��ÿ��Խ���������ϵ����ص�
% pixel-pixel.mean>[10,10,10]
% pmaxsetMask �Ͻ�ﵽҪ������ص�����
% pminsetMask �½�ﵽҪ������ص�����
% ���Խ���������ϵ����ص������
% �����������pmaxnum,pminnum.��ֹ����������Ϊ���ò����¶�������������
% ע�⣺������Ͻ���Ա������ص�

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
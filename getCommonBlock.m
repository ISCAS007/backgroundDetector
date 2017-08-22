function commonBlock=getCommonBlock(bw1,bw2)
% 求两个二值图像的相交连通块

[label1,num1]=bwlabel(bw1,8);
[label2,num2]=bwlabel(bw2,8);
[label3,num3]=bwlabel(bw1&bw2,8);

commonBlock=zeros(size(bw1));
for i=1:num3
    idx=find(label3==i,1,'first');
%     commonBlock(label1==label1(idx))=i;
    commonBlock(label2==label2(idx))=i;
end

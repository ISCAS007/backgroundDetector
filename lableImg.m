function img=lableImg(img,a,b)
%         lable the sample position in img
[m,n,c]=size(img);
if(c==1)
    g1=im2double(img);
    %           g1(img)=1;
    img=cat(3,g1,g1,g1);
else
    img=im2double(img);
end

color=[1,0,0];
for i=a-5:a+5
    for j=b-5:b+5
        if(i>=1&&j>=1&&i<=m&&j<=n)
            img(i,j,:)=color(:);
        end
    end
end
end
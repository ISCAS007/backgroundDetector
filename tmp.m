root='D:\Program\matlab\dataset2012\dataset\baseline\highway\groundtruth';
pic1='gt000580.png';
pic2='gt000581.png';

img1=imread([root,'\',pic1]);
img2=imread([root,'\',pic2]);

figure;
imshow(img1);
figure;
imshow(img2);

a1=sum(img1,2);
b1=find(a1>0, 1, 'last' );

a2=sum(img2,2);
b2=find(a2>0, 1, 'last' );

c=zeros(1,999-580+1);
for i=580:999
%    pic1=pic2;
   pic2=['gt000',int2str(i),'.png'];
   img1=img2;
   img2=imread([root,'\',pic2]);
   a1=sum(img1,2);
    b1=find(a1>0, 1, 'last' );
    a2=sum(img2,2);
    b2=find(a2>0, 1, 'last' );
   c(i-580+1)=b2-b1;
end

max(c)
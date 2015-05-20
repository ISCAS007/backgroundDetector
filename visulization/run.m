picpath='D:\firefoxDownload\matlab';
[pic,map,alpha]=imread([picpath,'\','v3.png']);
h=imshow(pic);
title('pic');
set(h,'AlphaData',alpha)
figure,imshow(alpha),title('alpha');
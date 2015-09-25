function rgbpic=adapt_yzbx(rgbpic)
for i=1:3
%     rgbmax=max(max(rgbpic(:,:,i)));
%     rgbpic(:,:,i)=rgbpic(:,:,i)*(255/rgbmax);
    rgbpic(:,:,i)=imadjust(rgbpic(:,:,i));
end
end
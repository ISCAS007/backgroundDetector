function mkframe=mask_yzbx(frame,mask)
    mkframe=frame;
    mask=uint8(mask);
    mkframe(:,:,1)=mkframe(:,:,1).*mask;
    mkframe(:,:,2)=mkframe(:,:,2).*mask;
    mkframe(:,:,3)=mkframe(:,:,3).*mask;
	mkframe=adapt_yzbx(mkframe);
end
function [vx,vy]=opticalFlow(input1,input2)
    [vx,vy]=getVxVy(input1,input2);
end

function [ux,uy]=getVxVy(input0,input)
	im1=double(rgb2gray(input0))/256.0;
	im2=double(rgb2gray(input))/256.0;
	winSize = 21;
	[ux, uy, l1, l2] = LucasKanade(im1, im2, winSize);
end
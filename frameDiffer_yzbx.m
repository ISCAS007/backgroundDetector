function difmask=frameDiffer_yzbx(frame1,frame2,threshold)
% find the difference of 'frame1' and 'frame2' by thershold 'threshold'
dif=frame1-frame2;
dif=sum(dif.^2,3);

if(threshold==0)
    threshold=25;
    display(threshold);
end
difmask=dif>threshold;
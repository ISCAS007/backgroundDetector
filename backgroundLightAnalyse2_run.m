load('backgroundLightAnalyse2-1');

figure;
static=(staticCount>0);
staticImgRange=staticMax(static)-staticMin(static);
staticImgMean=double(staticSum(static))./double(staticCount(static));
subplot(221),hist(staticImgRange),title('staticImgRange');

motion=(motionCount>0);
motionImgRange=motionMax(motion)-motionMin(motion);
motionImgMean=double(motionSum(motion))./double(motionCount(motion));
subplot(222),hist(motionImgRange),title('motionImgRange');

subplot(223),scatter(staticImgMean,staticImgRange),title('staticMean-Range');
subplot(224),scatter(motionImgMean,motionImgRange),title('motionMean-Range');

% figure;
% subplot(221),scatter(staticMax(static),staticImgRange),title('staticMax-Range');
% subplot(222),scatter(staticMin(static),staticImgRange),title('staticMin-Range');
% subplot(223),scatter(motionMax(motion),motionImgRange),title('motionMax-Range');
% subplot(224),scatter(motionMin(motion),motionImgRange),title('motionMin-Range');

staticMax=staticMax(static);
staticMin=staticMin(static);
motionMax=motionMax(motion);
motionMin=motionMin(motion);

figure;
subplot(221),hist(staticMax),title('staticMax');
subplot(222),hist(staticMin),title('staticMin');
subplot(223),hist(motionMax),title('motionMax');
subplot(224),hist(motionMin),title('motionMin');

staticRandNumSet=randi([1,length(staticMax)],1,10);
motionRandNumSet=randi([1,length(motionMax)],1,10);
for i=1:10
   figure
   staticRandNum=staticRandNumSet(i);
   motionRandNum=motionRandNumSet(i);
   
   staticMaxValue=staticMax(staticRandNum);
   staticMinValue=staticMin(staticRandNum);
   staticMeanValue=staticImgMean(staticRandNum);
   
   motionMaxValue=motionMax(motionRandNum);
   motionMinValue=motionMin(motionRandNum);
   motionMeanValue=motionImgMean(motionRandNum);
   
   
   subplot(231),hist(staticImgRange(staticMax==staticMaxValue)),title(...
       ['staticMax-',num2str(staticMaxValue)]);
   subplot(232),hist(staticImgRange(staticMin==staticMinValue)),title(...
       ['staticMin-',num2str(staticMinValue)]);
   subplot(233),hist(staticImgRange(staticImgMean==staticMeanValue)),title(...
       ['staticMean-',num2str(staticMeanValue)]);
   subplot(234),hist(staticImgRange(motionMax==motionMaxValue)),title(...
       ['motionMax-',num2str(motionMaxValue)]);
   subplot(235),hist(motionImgRange(motionMin==motionMinValue)),title(...
       ['motionMin-',num2str(motionMinValue)]);
   subplot(236),hist(motionImgRange(motionImgMean==motionMeanValue)),title(...
       ['motionMean-',num2str(motionMeanValue)]);
end
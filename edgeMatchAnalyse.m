function edgeMatchAnalyse()
root='D:\Program\matlab\dataset2012\dataset\dynamicBackground\fall';
des='D:\Program\matlab\bgslibrary_mfc\outputs\foreground';

roiImg=imread([root,'\ROI.bmp']);
roiMask=(roiImg~=0);
[height,width]=size(roiMask);

groundTruthPath=[root,'\groundtruth'];
infolist=dir(groundTruthPath);
groundTruthlist={infolist.name};

inputPath=[root,'\input'];
infolist=dir(inputPath);
inputlist={infolist.name};

outputPath=des;
infolist=dir(outputPath);
outputlist={infolist.name};

% if(isempty(fg))
%     fg=[1480,1500];
% end
% fg=[1480,1500];
fg=[1465,1500];
roi=load([root,'\temporalROI.txt']);
figure;
for frameNum=fg(1):fg(2)
   gt=imread([groundTruthPath,'\',groundTruthlist{frameNum+2}]);
   in=imread([inputPath,'\',inputlist{frameNum+2}]);
   out=imread([outputPath,'\',outputlist{frameNum+2-roi(1)+1}]);
   
   out=(out~=0);
   out=imfill(out,'holes');
   
   if(frameNum-fg(1)>0)
        pos=edgeMatch(out,lastGt==255);
   end
   
   lastGt=gt;
   show();
   pause(0.5);
end

    function pos=getCenter(objMask)
        if(~islogical(objMask))
           error('not logical'); 
        end
        cen=regionprops(objMask,'centroid');
        pos=s.Centroid;
    end

    function match=edgeMatch(des,src)
        minarea=100;
        des=bwareaopen(des,minarea);
        src=bwareaopen(src,minarea);
        ccsrc=bwconncomp(src);
        ccdes=bwconncomp(des);
        possrc=regionprops(ccsrc,'Centroid');
        posdes=regionprops(ccdes,'Centroid');
    end

    function show()
        subplot(221);
        imshow(fp./max(fp(:)));
        subplot(222);
        imshow(fn./max(fn(:)));


        errorMask=(gt==255)&(out==0);
        labelMask=imdilate(errorMask,strel('disk',1));
        inputSample=in;
        r=inputSample(:,:,1);
        g=inputSample(:,:,2);
        b=inputSample(:,:,3);

        r(labelMask)=255;
        g(labelMask)=0;
        b(labelMask)=0;

        inputSample(:,:,1)=r;
        inputSample(:,:,2)=g;
        inputSample(:,:,3)=b;

        subplot(223);
        imshow(inputSample);

        subplot(224);
        imshow(out); 
    end
end
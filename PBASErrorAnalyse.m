function PBASErrorAnalyse()
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

fp=zeros(height,width);
fn=zeros(height,width);

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
%    if(frameNum==fg(1))
%        inputSample=in;
%        gtSample=gt;
%        errorPointImg=zeros(height,width);
%        if(sum(sum(gt==255))==0)
%           fg(1)=fg(1)+1;
%        else
%           pos1=getObjectLeftTop(gt==255);
%        end
%    end
%    
%    if(frameNum>=fg(1)&&frameNum<=fg(2))
%        if(sum(sum(gt==255))==0)
% %           fg(2)=frameNum;
%        else
%           pos2=getObjectLeftTop(gt==255);
%           errorPoint=(gt==255)&(out==0);
%           errorPointImg=addErrorPoint(errorPointImg,pos1,errorPoint,pos2);
%        end
%        
%    end
   
   fp=fp+double(gt<=50&out~=0);
   fn=fn+double(gt==255&out==0);
   
   show();
   pause(0.5);
end

save('PBASErrorAnalyse','fp','fn','errorPointImg','inputSample','gtSample','fg');

    function pos=getObjectLeftTop(objMask)
        if(~islogical(objMask))
           error('objMask is not logical'); 
        end
        a1=sum(objMask,1);
        left=find(a1>0, 1, 'first' );
        right=find(a1>0,1,'last');
        a2=sum(objMask,2);
        top=find(a2>0, 1, 'first' );
        bottom=find(a2>0,1,'last');
        pos=[left,top,right,bottom];
    end

    function errorPointImg=addErrorPoint(errorPointImg,pos1,errorPoint,pos2)
        
        pos2(3)=min(pos1(3)-pos1(1)+pos2(1),width);
        pos2(4)=min(pos1(4)-pos1(2)+pos2(2),height);
        
        pos1(3)=pos1(1)+pos2(3)-pos2(1);
        pos1(4)=pos1(2)+pos2(4)-pos2(2);
        
        errorPointImg(pos1(2):pos1(4),pos1(1):pos1(3))=...
            errorPointImg(pos1(2):pos1(4),pos1(1):pos1(3))+...
            double(errorPoint(pos2(2):pos2(4),pos2(1):pos2(3)));
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

%%
% 
% D:\Program\matlab\matlabPublish\matlab_PBASErrorAnalyse.PNG
% 

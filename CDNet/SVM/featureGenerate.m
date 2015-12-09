function featureGenerate(CDNetDir,bgsFGRootDir,featureRootDir)
% use CDNet image dataset to generate svm features
% CDNetDir: the dir for CDNet dataset, eg: D:\firefoxDownload\matlab\dataset2012\dataset\baseline\highway
% bgsFGDir: the dir for the foreground(FG) output of background
% substraction algrithm(bgs)
% featureDir: the dir to store feature, eg:

result=strfind(CDNetDir,'\');
datasetName=CDNetDir(result(end-1)+1:end);
bgsFGDir=[bgsFGRootDir,'\',datasetName,'\'];
featureDir=[featureRootDir,'\',datasetName,'\'];

mkdir(featureDir);

datasetName=strrep(datasetName,'\','-');
datasetName=[datasetName,'.mat'];

inputPath=[CDNetDir,'\input\'];
fgPath=[CDNetDir,'\groundtruth\'];
% inputFilename='in000001.jpg';
% groundTruthFilename='gt000001.png';
roiFilename=[CDNetDir,'\ROI.bmp'];
roiImg=imread(roiFilename);

temporalROIFilename=[CDNetDir,'\temporalROI.txt'];
temporalROI=load(temporalROIFilename);
% frameNum=1;
% fileName = num2str(frameNum, '%.6d');

[height,width,~]=size(roiImg);

historyNum=3;
currentNum=2;
historyInputs=zeros([height,width,3,historyNum]);
historyMasks=zeros([height,width,historyNum]);

str=num2str(temporalROI(1)-2,'%.6d');
if(exist([bgsFGDir,'bin',str,'.png'],'file')==0)
    warning('set first two img as zero');
else
    input=getImg(inputPath,'in',temporalROI(1)-2,'.jpg');
    if(size(input,3)==1)
        warning('need to change gray img to rgb img');
        error('debug ...');
    end
    
    historyInputs(:,:,:,1)=input;
    historyInputs(:,:,:,2)=getImg(inputPath,'in',temporalROI(1)-1,'.jpg');
    
    historyMasks(:,:,1)=getImg(bgsFGDir,'bin',temporalROI(1)-2,'.png');
    historyMasks(:,:,2)=getImg(bgsFGDir,'bin',temporalROI(1)-1,'.png');
end



for i=temporalROI(1):temporalROI(2)
    if(currentNum==historyNum)
        currentNum=1;
    else
        currentNum=currentNum+1;
    end
    
    historyInputs(:,:,:,currentNum)=getImg(inputPath,'in',i,'.jpg');
    historyMasks(:,:,currentNum)=getImg(bgsFGDir,'bin',i,'.png');
    
    feature=getFeature(historyInputs,historyMasks,currentNum);
    gtImg=getImg(fgPath,'gt',i,'.png');
    label=reshape(gtImg,[height*width,1]);
    
    featureFileName=num2str(i,'%.6d');
    save([featureDir,'\',featureFileName,'.mat'],'feature','label');
    fprintf('frame num is %s\n',featureFileName);
    clear feature label;
end


%% function
    function img=getImg(baseDir,prefix,frameNum,suffix)
        str=num2str(frameNum,'%.6d');
        img=imread([baseDir,prefix,str,suffix]);
    end

    function feature=getFeature(inputs,masks,currentNum)
        [aa, bb, cc, dd]=size(inputs);
        currentInput=inputs(:,:,:,currentNum);
        currentMask=masks(:,:,currentNum);
        inputs=reshape(inputs,aa*bb,cc*dd);
        masks=reshape(masks,aa*bb,dd);
        
        windowSize=[3,5];
        thresholds=[5,10];
        w=length(windowSize);
        t=length(thresholds);
        inputSimility=zeros(aa*bb,w*t);
        count=0;
        
        for jj=1:w
            dw=floor(windowSize(jj)/2);
            idx=ceil(windowSize(jj)^2/2);
            
            enlargeImg=zeros(aa+dw*2,bb+dw*2);
            for kk=1:t
                neighbor3=true(windowSize(jj)^2,aa*bb);
                for mm=1:cc
                    enlargeImg(dw+1:dw+aa,dw+1:dw+bb)=currentInput(:,:,mm);
                    neighbor=im2col(enlargeImg,...
                        [windowSize(jj) windowSize(jj)],'sliding');
                    neighbor=bsxfun(@minus,neighbor,neighbor(idx,:));
                    neighbor3=and(neighbor3,neighbor<thresholds(kk));
                end
                
                count=count+1;
                inputSimility(:,count)=sum(neighbor3)-1;
                fprintf('count is %d\n',count);
                
            end
        end
        
        maskSimility=zeros(aa*bb,w);
        for jj=1:w
            dw=floor(windowSize(jj)/2);
            img=false(aa+2*dw,bb+2*dw);
            img(dw+1:dw+aa,dw+1:dw+bb)=currentMask;
            
            neighbor=im2col(img,[windowSize(jj),windowSize(jj)],'sliding');
            
            maskSimility(:,jj)=sum(neighbor);
        end
        
        %inputs,masks,neighbour
        feature=[inputs,masks,inputSimility,maskSimility];
    end

end
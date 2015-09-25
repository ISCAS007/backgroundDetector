% inputpath='D:\firefoxDownload\matlab';
% % D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\boats\input
% filename='dataset2012\dataset\dynamicBackground\boats';
% outputpath=strrep(filename,'\','.');
% layerAlgrithm([inputpath,'\',filename],['analyze\',outputpath,'.mat']);
function difModel_run()
% root='D:\firefoxDownload\matlab\dataset2012\dataset';
% root='D:\Program\matlab\dataset2012\dataset';
root='D:\firefoxDownload\matlab\dataset2012\dataset';
outroot='D:\firefoxDownload\matlab\dataset2012\results-bgs';
% layernum=3;
pathlist1=dir(root);
filenum1=length(pathlist1);
filenamelist1={pathlist1.name};


for i=3:filenum1
    %    if(i<6)
    %        continue;
    %    end
    pathlist2=dir([root,'\',filenamelist1{i}]);
    filenum2=length(pathlist2);
    filenamelist2={pathlist2.name};
    for j=4:filenum2
        path=[root,'\',filenamelist1{i},'\',filenamelist2{j}];
        input=[];
        gtruth=[];
        pathlist3=dir([path,'\input']);
        filenamelist3={pathlist3.name};

        pathlist4=dir([path,'\groundtruth']);
        filenamelist4={pathlist4.name};
        
        roi=load([path,'\temporalROI.txt']);
        outpath=[outroot,'\',filenamelist1{i},'\',filenamelist2{j},'\'];
        layer=[];
        for frameNum=roi(1)-50:roi(2)
           readFrame();
           [layer,mask]=difModel(layer,input);
           imwrite(mask,[outpath, 'mask', num2str(frameNum, '%.6d'),'.png'],'png');
%            ooo=[outpath, 'bin', num2str(frameNum, '%.6d')]
           showFrame();
        end
%         hmask=figure;
%         imshow(mask_yzbx(input,mask));
%         saveas(hmask,filenamelist2{3},'jpg');
%         close(hmask);
%         break;
    end
        break;
end

    function readFrame()
        input=imread([path,'\input\',filenamelist3{frameNum+2}]);
        gtruth=imread([path,'\groundtruth\',filenamelist4{frameNum+2}]);
    %     gtruth=(gtruth==255);
%         frameNum=frameNum+1;
        pause(0.1);
    end

    function showFrame()
       subplot(434);imshow(input);title(['input',num2str(frameNum)]);
       subplot(435);imshow(gtruth);title('groundtruth');
       subplot(436);imshow(mask_yzbx(input,mask));title('mask'); 
    end
end
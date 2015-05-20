% inputpath='D:\firefoxDownload\matlab';
% % D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\boats\input
% filename='dataset2012\dataset\dynamicBackground\boats';
% outputpath=strrep(filename,'\','.');
% layerAlgrithm([inputpath,'\',filename],['analyze\',outputpath,'.mat']);
function run()
root='D:\firefoxDownload\matlab\dataset2012\dataset';
% layernum=3;
pathlist1=dir(root);
filenum1=length(pathlist1);
filenamelist1={pathlist1.name};

for i=7:filenum1
    %    if(i<6)
    %        continue;
    %    end
    pathlist2=dir([root,'\',filenamelist1{i}]);
    filenum2=length(pathlist2);
    filenamelist2={pathlist2.name};
    for j=3:filenum2
%         if(i==6&&j<4)
%             continue;
%         end
        path=[root,'\',filenamelist1{i},'\',filenamelist2{j}];
        frameNum=1;
        input=[];
        gtruth=[];
        pathlist3=dir([path,'\input']);
        filenamelist3={pathlist3.name};

        pathlist4=dir([path,'\groundtruth']);
        filenamelist4={pathlist4.name};
        
        layer=[];
        while frameNum<500
           readFrame();
           [layer,mask]=mixtureSubstraction(layer,input);
           showFrame();
        end
        
        break;
    end
    %     break;
end

    function readFrame()
        input=imread([path,'\input\',filenamelist3{frameNum+2}]);
        gtruth=imread([path,'\groundtruth\',filenamelist4{frameNum+2}]);
    %     gtruth=(gtruth==255);
        frameNum=frameNum+1;
        pause(0.1);
    end

    function showFrame()
       subplot(234);imshow(input);
       subplot(235);imshow(gtruth);
       subplot(236);imshow(mask);
    end
end
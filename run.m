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

% (7,3)=shadow-backdoor, (6,5)=inter-sofa,
% (5,5)=dynamic-fall,(3,3)=baseline-PEXT2006
a=zeros(1,7);
a(7)=3;
a(6)=5;
a(5)=5;
a(3)=3;
start=[1,350,1,1];
over=[150,500,360,150];
num=0;
for i=3:filenum1
    %    if(i<6)
    %        continue;
    %    end
    pathlist2=dir([root,'\',filenamelist1{i}]);
    filenum2=length(pathlist2);
    filenamelist2={pathlist2.name};
    for j=3:filenum2
        if(i==3||i==5||i==6||i==7)
            j=a(i);
            num=num+1;
        else
            break;
        end
        path=[root,'\',filenamelist1{i},'\',filenamelist2{j}];
        frameNum=start(num);
        input=[];
        gtruth=[];
        pathlist3=dir([path,'\input']);
        filenamelist3={pathlist3.name};

        pathlist4=dir([path,'\groundtruth']);
        filenamelist4={pathlist4.name};
        
        layer=[];
        while frameNum<=over(num)
           readFrame();
           [layer,mask]=mixtureSubstraction2(layer,input);
           showFrame();
        end
        hmask=figure;
        imshow(mask_yzbx(input,mask));
        saveas(hmask,filenamelist2{3},'jpg');
        close(hmask);
        break;
    end
%         break;
end

    function readFrame()
        input=imread([path,'\input\',filenamelist3{frameNum+2}]);
        gtruth=imread([path,'\groundtruth\',filenamelist4{frameNum+2}]);
    %     gtruth=(gtruth==255);
        frameNum=frameNum+1;
        pause(0.1);
    end

    function showFrame()
       subplot(434);imshow(input);title(['input',num2str(frameNum)]);
       subplot(435);imshow(gtruth);title('groundtruth');
       subplot(436);imshow(mask_yzbx(input,mask));title('mixtureMask');
       
    end
end
function dataset2012()
% 对数据集dataset2012进行遍历的标准设置
root='D:\firefoxDownload\matlab\dataset2012\dataset';
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
   for j=3:filenum2
%        if(i==6&&j<4)
%           continue;
%        end
       path=[root,'\',filenamelist1{i},'\',filenamelist2{j}];
%        pathlist3=dir([path,'\input']);
%        filenum3=length(pathlist3);
%        filenamelist3={pathlist3.name};
%        
%        pathlist4=dir([path,'\groundtruth']);
%        filenamelist4={pathlist4.name};
%        filename=path2filename(path);
       
       % roiframeNum=load([path,'\temporalROI.txt']);
%        frameNum=0;
       % multiObjectTracking_yzbx(path,roiframeNum);
	   ReverseMatching(path);
       break;
   end
   break;
end
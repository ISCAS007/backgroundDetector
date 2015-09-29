function dataset2012(bgsFGRootDir,featureRootDir)
% 对数据集dataset2012进行遍历的标准设置
root='D:\firefoxDownload\matlab\dataset2012\dataset';
% layernum=3;
pathlist1=dir(root);
filenum1=length(pathlist1);
filenamelist1={pathlist1.name};

for i=4:filenum1
    pathlist2=dir([root,'\',filenamelist1{i}]);
    filenum2=length(pathlist2);
    filenamelist2={pathlist2.name};
    for j=6:filenum2
        path=[root,'\',filenamelist1{i},'\',filenamelist2{j}];
        featureGenerate(path,bgsFGRootDir,featureRootDir);
    end
    break;
end

end
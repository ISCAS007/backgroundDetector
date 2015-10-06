# 利用svm进行前景提取

# 流程
- img->特征提取->svm学习->应用
- 特征：imgs(3 history x 3 color),masks(3 history),neighbor similary (3 color x 2 window size x 2 thresholds), neighbor label(2 window size)
- 四个目录：CDNet数据目录(roi,temporalRoi,in,fg)，bgs处理后目录(mask)，特征保存目录(feature,label,svmStruct)，svm处理后目录(mask)
- 基本函数：featureGenerate(CDNetDir,bgsFGRootDir,featureRootDir),svmLearn(CDNetDir,featureRootDir),foregroundModify(CDNetDir,bgsFGRootDir,featureRootDir,svmFGRootDir)

- 遍历函数 dataset2012,需要进行个人定制，并结合使用featureGenerate_run生成所有特征，或者是svmTest进行svmModel测试

- feature

| feature | descripbe |
|:-------:|-----------|
| inputs(3x3) | [a b c d]=size(inputs).color num c=3,history num d=3 |
| masks(3)  | [a b d]=size(masks),history num d=3 |
| neighbor similary (2x2) | window size[3x3,5x5] x thresholds [5,10] |
| neighbor status (2) | window size [3x3,5x5] |

- filename

| file | filename |
|:----:|:--------:|
| input image i | in00...i.jpg |
| groundtruth image i | gt00...i.png |
| feature mat i | 00...i.mat |
| bgs foreground i | mask00...i.png |

- groundtruth label

| label | value |
|-------|-------|
| Static | 0 |
| hard shadow | 50 |
| Outside ROI | 85 |
| Unknow | 170 |
| Motion | 255 |

- roi img

| 特征 | 说明 |
|----|----|
| 全为0或全为1 | 正常 |
| 含0，1，以及255 | 正常 |
| 三通道或一通道 | 正常 |
| 大小 | 可能与输入不匹配 |

- output
| svmModel | .\PBAS_23\features-svm\intermittentObjectMotion-abandonedBox.mat |
|----------|------------------------------------------------------------------|
| result | .\PBAS_23\features-svm\intermittentObjectMotion\abandonedBox\svmLearn.mat |

# 选择
- 提取邻域特征时图像的边缘可以补零或者利用对称
- 特征在线或离线提取
- 单种视频学习或多种视频学习

# PBAS在动态场景下F值从0.68提高0.73
```
%%分类器
CDNetDir='D:\firefoxDownload\matlab\dataset2012\dataset\intermittentObjectMotion\abandonedBox';
svmLearn(CDNetDir,featureRootDir);
```

- ii=5, jj=3, D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\boats
P=0.699368 
 R=0.452305 
 F=0.549336 
- ii=5, jj=4, D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\canoe
P=0.675534 
 R=0.798184 
 F=0.731755 
- ii=5, jj=5, D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\fall
P=0.606624 
 R=0.946326 
 F=0.739321 
- ii=5, jj=6, D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\fountain01
P=0.767102 
 R=0.801011 
 F=0.783690 
- ii=5, jj=7, D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\fountain02
P=0.632544 
 R=0.919183 
 F=0.749389 
- ii=5, jj=8, D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\overpass
P=0.858052 
 R=0.736328 
 F=0.792543 

# PBAS在
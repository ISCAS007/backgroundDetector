# 利用svm进行前景提取

# 流程
- img->特征提取->svm学习->应用
- 特征：imgs(3 history x 3 color),masks(3 history),neighbor similary (3 color x 2 window size x 2 thresholds), neighbor label(2 window size)
- 四个目录：CDNet数据目录(roi,temporalRoi,in,fg)，bgs处理后目录(mask)，特征保存目录(feature,label,svmStruct)，svm处理后目录(mask)
- 基本函数：featureGenerate(CDNetDir,bgsFGRootDir,featureRootDir),svmLearn(CDNetDir,featureRootDir),foregroundModify(CDNetDir,bgsFGRootDir,featureRootDir,svmFGRootDir)

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

# 选择
- 提取邻域特征时图像的边缘可以补零或者利用对称
- 特征在线或离线提取
- 单种视频学习或多种视频学习
# 利用svm进行前景提取

# 流程
- img->特征提取->svm学习->应用
- 特征：imgs(3 history x 3 color),masks(3 history),neighbor similary (3 color x 2 window size x 2 thresholds), neighbor label(2 window size)
- 四个目录：CDNet数据目录(roi,temporalRoi,in,fg)，bgs处理后目录(mask)，特征保存目录(feature,label,svmStruct)，svm处理后目录(mask)
- 基本函数：featureGenerate(CDNetDir,bgsFGDir,featureDir),svmLearn(CDNetDir,featureDir),foregroundModify(bgsFGDir,featureDir,svmFGDir)
# 选择
- 提取邻域特征时图像的边缘可以补零或者利用对称
- 
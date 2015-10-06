# graySVMBgs svmBgs2.m
- 利用N=20个灰度图像生成逐点的特征，标签即CDNet提供的groundtruth
- 相比之前的特征，此次特征按时间顺序排列，因此利用之前的分类器可能无法得到最佳分类结果
- graySVMBgs不使用mask信息

# colorSVMBgs svmBgs2.m 
- 利用N=3个rgb图像和N=3个mask生成特征
- 相比之前的特征，此次特征同样按时间顺序排列
- colorSVMBgs 会利用修正后的mask来更新历史mask信息
- 两个svm分类器大同小异，主要区别在于颜色通道数

# svmBgsTrain_run.m 
- 调用graySVMBgsTrain.m 以及 colorSVMBgsTrain.m
- graySVMBgsTrain 需要的特征均可来自CDNet
- colorSVMBgsTrain 需要的特征要来自CDNet 及graySVMBgs的分类输出

# 值得注意的问题
- 初始的InputHistory和labelHistory 不应该被训练
- 数据的类型问题，double还是uint8，出于内存的考虑，用uint8
- 训练时feature必须为double或者single,在这里我选择double,因此在预测分类时也要进行类型转换.
- 当训练结果不收敛时，可以去掉svmtrain的一些约束，或者更换内核函数。

# graySVMBgs的结果
```
P=0.829743 
 R=0.251509 
 F=0.386011 
max(precision)=0.871811 
 max(recall)=1.000000 
max(FMeasure)=0.925549 
min(precision)=0.768600 
 min(recall)=0.000000 
min(FMeasure)=0.000000 
mean(precision)=0.829743 
 mean(recall)=0.845177 
mean(FMeasure)=0.792249 
```

可以看出来，结果非常差。后面的colorSVMBgs则没必要做下去。
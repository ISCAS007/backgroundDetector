# backgroundDetector
background substraction

1. color segmentation
2. areaOpen
3. connect area
4. pixel change curve
5. knn algrithm
6. road map


% mask1=(frame<(max+gap))&(frame>(min-gap))
	mask1=(double(input)<(layer.max+layer.gap))&(double(input)>(layer.min-layer.gap));
% mask2=(frame-mean)>(max-min+2*gap).*rangeratio
	mask2=(double(input)-layer.mean)>(layer.max-layer.min).*layer.rangeratio;
% mask3=cross(frame,vector)>vecgap

1. 基本函数
	dataset2012:	加载数据目录到工作空间，对所有测试进行遍历
	minFilter_yzbx,maxfilter_yzbx:	利用相邻像素的值，初始化layer.max,layer.min
	playMovie:	用于演示动态视频
	getvecgapMask: mask3, vector=(frame-mean)/light

2. 近期重要的
	layerUpdate_yzbx	更新layer
	layerInit	初始化layer
	
3. 分析函数
	ReverseMatching 逆向匹配学习，得到最好的初始化学习参数
	dataExtract 抽取数据，主要困难在roiPoint的选取，要保证存在前景
	dataAnalyze 分析数据，rgb三维分布，max,min,mean统计信息，曲线拟合信息
	datafit 拟合数据, 本想在较小的数据集上学习分析，但结果却失败了，因为5x5的数据难以可视化，调节参数，调错十分困难,但后期可能用到
	
3. 中期不成熟的函数
	vectorLayerMask_yzbx: 求向量差mask,但归一化是利用(1,b/r,g/r)
	vectorFrameDiffer_yzbx:	综合上下界及向量差，归一化利用(1,b/r,g/r)

# 相关工作
在github 上搜索关键词 background subtraction, foreground detection 等
其中最著名的一个是bgslibrary
	
	

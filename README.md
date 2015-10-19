# PBAS 模拟程序分析
- PBAS.m, PBAS2.m 两个程序一样，只是输入有点区别
- 加入少量图片


#CDNet
2015年6月29日

- unknown=find(class(3,3,1,:)==170);
- motion=find(class(3,3,1,:)==255);
- shadow=find(class(3,3,1,:)==50);
- static=find(class(3,3,1,:)==0);
#tracking 
2015年6月25日
track\readme.md
# background visulization
2015年6月18日： 分析系列程序
1. backgroundLightAnalyse.m 主要针对单个像素点的像素序列，输入.mat文件给_run文件分析
2. backgroundLightAnalyse2.m
针对图片中所有的像素点在整个时间域上的最大值，最小值，平均值等等，输出.mat文件给_run文件分析
3. backgroundLightAnalyse_run.m
4. backgroundLightAnalyse2_run.m
5. backgroundLightAnalyse_shadow.m 
6. dataAnalyze.m 对.mat文件中的rgb,class数据进行分析
7. changeImgName.m 更改图片的文件名，从而利用BGSlibrary 进行分析
8. PBASErrorAnalyse.m 对PBAS算法的输出结果进行分析，统计背景出错频率图及前景出错频率图
2015年6月16日：
edgeAnalyse.m  :分析边
LBP.m  : 分析local binary pattern 直方图
localWave.m : 分析局部像素之间的关系
PBAS.m：分析PBAS算法的背景模型s
shadowAnalyse.m：分析阴影的直方图s


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
	
	

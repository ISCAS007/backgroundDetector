# 使用Octave 运行程序
- optical flow 用octave运行
- Octave save 得到的*.mat，其默认的格式Matlab 不支持
- 但Matlab save 得到的*.mat，其默认的模式Octave 支持

# 使用线性回归和SVM对照，了解参数设置
- seven: r,g,b,dx,dy,vx,vy
- 先归一化，不同的optical flow函数和梯度函数，对应的值域可能不同
- linear regression: 使用来自github 的 https://github.com/quinnliu/MachineLearning/
- svm: 使用Matlab R2013a 自带的svmtrain,svmclassify

# file
- bgs_seven.m : bgs_seven.mat
- bgs_seven_step2.m : bgs_seven_step2.mat
- bgs_seven_step3.m : bgs_seven_step3.mat
- bgs_seven_step4.m : bgs_seven_step4.mat

# result
- 对于svm，数据并不是越多越好，如对于

```
x=rand(N,k);
a=b*rand(k,1);
y=x*a+rand(N,1);
```
随着N的增加，svm分类的F值可能下降，甚至对于linear svm不收敛。
- 对于CDNet,使用svm对背景差(bgs_seven_step3_2.m,bgs_seven_step4_2.m)的效果并不好，极容易出现过拟合(F=0.2)，并且训练内数据的结果也不好(F=0.6)。说明背景差并不是非常好的特征，可能需要包含背景的内容。
-  对于背景+前景(bgs_seven_step3_3.m,bgs_seven_step4_2.m),train F=0.8, test F=0.6

```
Loading data ...
size of train data is 22000 
trian result
********************************
TP=0.087864,TN=0.891864,FP=0.017227,FN=0.003045,N=22000
P=0.836073,R=0.966500,F=0.896568
test result
********************************
TP=0.061591,TN=0.885773,FP=0.023318,FN=0.029318,N=22000
P=0.725375,R=0.677500,F=0.700620
```
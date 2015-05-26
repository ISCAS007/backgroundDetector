filename='analyze\in000003.jpg';
img=imread(filename);
i=rgb2gray(img);
bw=edge(i,'sobel',10);
vector=double(img);
light=sqrt(sum(vector.^2,3));
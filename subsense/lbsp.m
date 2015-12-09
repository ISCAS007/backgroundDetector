function distance=lbsp(input,backgroundModel)
% out is the lbsp of input
input=rgb2gray(input);
backgroundModel=rgb2gray(backgroundModel);

[m,n]=size(input);
inputCol=im2col(input,[5,5],'sliding');
idx=[1,3,5,7,8,9,11,12,14,15,17,18,19,21,23,25];
input_c=inputCol(13,:);
inputCol=inputCol(idx,:);
inter_lbsp=bsxfun(@minus,inputCol,input_c);
model_c=reshape(backgroundModel(3:m-2,3:n-2),[1,(m-4)*(n-4)]);
intra_lbsp=bsxfun(@minus,inputCol,model_c);

xor_distance=xor(abs(inter_lbsp)<=5,abs(intra_lbsp)<=5);
ham_distance=sum(xor_distance,1);
distance=zeros(m,n);
distance(3:m-2,3:n-2)=reshape(ham_distance,[m-4,n-4]);
end
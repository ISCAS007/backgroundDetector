function features=svmFeatureExtract(bgsStatus)


% Nmax=bgsStatus.Nmax;
[img,b,c,n]=size(bgsStatus.inputs);
% inputs=zeros(a*b,c*n);
% [a,b,c,n]=size(bgsStatus.inputs);
% for i=1:n
%     input=bgsStatus.inputs(:,:,:,i);
%     for j=1:c
%         inputs(:,j+(i-1)*c)=input(:,j);
%     end
% end
inputs=reshape(bgsStatus.inputs,[img*b,c*n]);

% mask=zeros(a*b,n);
% for i=1:n
%    mask=bgsStatus.masks(:,:,i);
%    masks(:,i)=mask(:);
% end
masks=reshape(bgsStatus.masks,[img*b,n]);

% features=zeros(a*b,c*n+n+2*3+2);
currentN=bgsStatus.currentN;
input=bgsStatus.inputs(:,:,:,currentN);
mask=bgsStatus.masks(:,:,currentN);

windowSize=[3,5];
thresholds=[5,10];
w=2;
t=2;
inputSimility=zeros(img,b,c*w*t);
count=1;
for i=1:c
    for j=1:w
        for k=1:t
%                         inputSimility(:,:,count)=nlfilter(input(:,:,i),...
%                             [windowSize(j) windowSize(j)],...
%                             @(x) similarNum(x,thresholds(k)));
            inputSimility(:,:,count)=mySimNum(input(:,:,i),...
                windowSize(j),windowSize(j),thresholds(k));
            
            count=count+1;
            fprintf('count is %d\n',count);
        end
    end
end
inputSimility=reshape(inputSimility,[img*b,c*w*t]);

maskSimility=zeros(img,b,w);
for i=1:w
    %     maskSimility(:,:,i)=nlfilter(mask,...
    %         [windowSize(j) windowSize(j)],...
    %         @(x) sum(x(:)));
    maskSimility(:,:,i)=mySimSum(mask,windowSize(j),windowSize(j));
end
maskSimility=reshape(maskSimility,[img*b,w]);

%inputs,masks,neighbour
features=[inputs,masks,inputSimility,maskSimility];

    function num=similarNum(x,threshold)
        [aa,bb,cc]=size(x);
        if(cc~=1)
            error('nlfilter can only deal with 2d image [m n]!');
        end
        x=double(x);
        
        idx=floor(([aa bb]+1)/2);
        center=x(idx(1),idx(2));
        
        y=x(:)-center;
        num=sum(y.^2>threshold^2);
    end

    function aa=enlargeImg(img,dm,dn)
        [mm, nn]=size(img);
        
        dm2=floor(dm/2);
        dn2=floor(dn/2);
        aa=zeros(mm+floor(dm/2)*2,nn+2*floor(dn/2));
        aa(1+dm2:dm2+mm,1+dn2:nn+dn2)=img;
        aa(1+dm2:dm2+mm,1:dn2)=img(1:mm,2:dn2+1);
        aa(1+dm2:mm+dm2,dn2+nn+1:dn2+nn+dn2)=img(1:mm,nn-dn2:nn-1);
        aa(1:dm2,1:2*dn2+nn)=aa(dm2+2:2*dm2+1,1:2*dn2+nn);
        aa(mm+dm2+1:mm+dm2*2,1:2*dn2+nn)=aa(mm:mm+dm2-1,1:2*dn2+nn);
    end

    function sim=mySimSum(img,dm,dn)
%         maskSimility(:,:,i)=nlfilter(mask,...
%         [windowSize(j) windowSize(j)],...
%         'sliding', ...
%         @(x) sum(x(:)));
        [aa, bb]=size(img);
        img=enlargeImg(img,dm,dn);
        
        neighbor=im2col(img,[dm,dn],'sliding');
        sim=reshape(sum(neighbor),aa,bb);
        
    end

    function num=mySimNum(img,dm,dn,threshold)
        [aa, bb]=size(img);
        img=enlargeImg(img,dm,dn);
        
        
        neighbor=im2col(img,[dm dn],'sliding');
        idx=ceil(dm*dn/2);
        center=neighbor(idx,:);
        neighbor=bsxfun(@minus, neighbor, center);
        
        num=sum(neighbor.^2>threshold^2);
        num=reshape(num,aa,bb);
    end
end
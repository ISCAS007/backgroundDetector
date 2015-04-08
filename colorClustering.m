function colorClustering(rgbPic)
    cform=makecform('srgb2lab');
    labPic=applycform(rgbPic,cform);
    ab=double(labPic(:,:,2:3));
    nrows=size(ab,1);
    ncols=size(ab,2);
    ab=reshape(ab,nrows*ncols,2);
    nColors=6;
    [cluster_idx cluster_center]=kmeans(ab,nColors,'distance','sqEuclidean',...
        'Replicates',3);
    pixel_labels=reshape(cluster_idx,nrows,ncols);
    imshow(pixel_labels);
    
    segmented_images=cell(1,nColors);
    rgb_label=repmat(pixel_labels,[1,1,3]);
    
    for k=1:nColors
        color=rgbPic;
        color(rgb_label~=k)=0;
        segmented_images{k}=color;
    end
    
    imshow(segmented_images{1});
    figure,imshow(segmented_images{2});
    figure,imshow(segmented_images{3});
    
    mean_cluster_val = zeros(nColors,1);
    for k = 1:nColors
        mean_cluster_val(k) = mean(cluster_center(k));
    end
    [mean_cluster_val,idx] = sort(mean_cluster_val);
    blue_cluster_num = idx(2);

    L = labPic(:,:,1);
    blue_idx = find(pixel_labels == blue_cluster_num);
    L_blue = L(blue_idx);
    is_light_blue = im2bw(L_blue,graythresh(L_blue));
    
    nuclei_labels = repmat(uint8(0),[nrows ncols]);
    nuclei_labels(blue_idx(is_light_blue==false)) = 1;
    nuclei_labels = repmat(nuclei_labels,[1 1 3]);
    blue_nuclei = rgbPic;
    blue_nuclei(nuclei_labels ~= 1) = 0;
    figure,imshow(blue_nuclei), title('blue nuclei');
end
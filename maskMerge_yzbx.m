function mask=maskMerge_yzbx(mask1,mask2)
    cc1=bwconncomp(mask1);
    rp1=regionprops(cc1,'Centroid','PixelIdxList');
    len1=length(rp1);
    
    cc2=bwconncomp(mask1);
    rp2=regionprops(cc2,'Centroid','PixelIdxList');
    len2=length(rp2);
    masksize=size(mask1);
    if(len1<len2)
        mask=mergeAIntoB(rp1,rp2,len1,len2,masksize);
    else
        mask=mergeAIntoB(rp2,rp1,len2,len1,masksize);
    end
    
    
    function C=mergeAIntoB(A,B,lenA,lenB,masksize)
        %lenA<lenB, the object of C must less than or equal A
        C=false(masksize);
        for i=1:lenA
           for j=1:lenB
               ABpixel=intersect(A(i).PixelIdxList,B(j).PixelIdxList);
               AB=length(ABpixel);
               MinAB=min(length(A(i).PixelIdxList),length(B(j).PixelIdxList));
               if(5*AB>MinAB)
                   C(ABpixel)=1;
               end
           end
        end
    end
end
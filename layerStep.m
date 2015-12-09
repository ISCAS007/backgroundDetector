function [layer,mask]=layerStep(layer,frame)
% mask=layerPredict(layer,frame);
% layer=layerUpdate_yzbx(layer,frame);
% notepad++ and matlab edit together cause problem!!!
if(layer.frameNum==151)
   disp('stop ....'); 
end
figrow=4;
figcol=4;
frameNum=layer.frameNum;
[a,b,c]=size(frame);
areaThreshold=round(a*b/1000);
learnRate=layer.a;
minarea=areaThreshold;
% maskratio=[0.1,0.3];
% noiseratio=0.4;
objsize=5;
noisesize=3;
% hmat=fspecial('gaussian',[noisesize,noisesize],1);
hmat=fspecial('average',[noisesize,noisesize]);

%%%%%%%%%%%%%%%%%%%%%%%%prediction
% mask1=prediction1();
% mask2=prediction2();
% mask3=prediction3();
% mask4=prediction4();
% prediction5() is independent of layer.mean
% layer.mean=layer.hmean;
% hmask5=prediction5();
% layer.mean=layer.smean;
% smask5=prediction5();
mask5=prediction5();
update5(mask5);
%%%%%%%%%%%%%%%%%%%%%%%%gap update
% update1();
%%%%%%%%%%%%%%%%%%%%%%ratio update
% update2();
%%%%%%%%%%%%%%%%%%%%%%vec gap update
% update3();

% if(frameNum==1)
%     [~,dif3]=getVecgapMask(layer,frame);
%     range=[0,3];
%     layer.vecgap=adajustGap2d(layer.vecgap,dif3,minarea,maskratio,noiseratio,range);
%     [mask3,~]=getVecgapMask(layer,frame);
% else
layer.mean=layer.hmean;
[hmask3,dif3]=getVecgapMask(layer,frame);
mask3=hmask3;
layer.mean=layer.smean;
[smask3,~]=getVecgapMask(layer,frame);
update3(dif3);
% end

%%%%%%%%%%%%%%%%%%%%%%%vec ratio update


%%%%%%%%%%%%%%%%%%%%%%%%%% mask200 update
% mask200=framedif200();
maskbw=framedifbw();
maskdifedge=framedifedge();
[lcmask,vcmask,cmask]=getRecentMask();
% maskedge=edge(imadjust(rgb2gray(frame)),'prewitt');

%%%%%%%%%%%%%%%%%%%%%%%%%% predict, update , and show
% if(layer.frameNum<20)  %just want to smooth the update!.
%     layer.mean=(layer.mean*layer.frameNum+double(frame))/(layer.frameNum+1);
% else
%     layer.mean=layer.mean*(1-learnRate)+double(frame)*learnRate;
% end

hmask=predict(hmask3,mask5);
smask=predict(smask3,mask5);
% mask=hmask;
mask=modifyMask(hmask,smask);
layer.smean=layer.smean*(1-learnRate)+double(frame)*learnRate;
layer.hmean(~mask)=layer.hmean(~mask)*(1-learnRate)+double(frame(~mask))*learnRate;

% layer.hmean=layer.smean;
layer.recentFrame=frame;
layer.frameNum=layer.frameNum+1;
if(layer.frameNum>layer.trainNum)
   layer.init=true(size(layer.init)); 
end
% show();

%%%%%%%%%%%%%%%%%%%%%%%%% funciton
    function mask=modifyMask(hmask,smask)
%         for predition5() is independent of hmean and smean.
        
%         light=sqrt(sum(double(frame).^2,3));
%         mask5=(layer.lmax<light)|(layer.lmin>light);
        difmask=hmask&(~smask)&(~mask5);
        mask=hmask&(~difmask);
    end

    function [noise,obj]=getNoiseObj2d(mask,minarea)
        obj=bwareaopen(mask,minarea);
        noise=mask-obj;
        obj=imerode(obj,strel('square',3));
        noise=imdilate(noise,strel('square',5));
    end

    function gap=adajustGap2d(gap,dif,minarea,maskratio,noiseratio,range)
        [a,b,c]=size(gap);
        if(c==3)
            disp('expeted 2d gap but here is 3d gap');
        end
        % range=[1,255]; flag=1
        % range=[0,1]; flag=0.00001
        loop=0;
        flag=(range(2)-range(1))/range(2);
        while (loop<20)&&(flag>0.00001)
            gap(:)=(range(1)+range(2))/2;
            mask=dif>gap;
            [noise,obj]=getNoiseObj2d(mask,minarea);
            mm=sum(mask(:))/(a*b);
            if(mm<maskratio(1))
                range(2)=gap(1);
            else
                if(mm>maskratio(2))
                    range(1)=gap(1);
                else
                    display(range);
                    if(any(obj))
                        disp('with foreground');
                    end
                    disp('adjust ok');
                    break;
                end
            end
            flag=(range(2)-range(1))/range(2);
            loop=loop+1;
        end
    end

    function gap=adajustGap3d(gap,dif,minarea,maskratio,noiseratio,range)
        [a,b,c]=size(gap);
        if(c==1)
            disp('expeted 3d gap but here is 2d gap');
        end
        % range=[1,255]; flag=1
        % range=[0,1]; flag=0.00001
        loop=0;
        flag=(range(2)-range(1))/range(2);
        while (loop<20)&&(flag>0.00001)
            gap(:)=(range(1)+range(2))/2;
            mask3d=dif>gap;
            mask=mask3d(:,:,1)|mask3d(:,:,2)|mask3d(:,:,3);
            [noise,obj]=getNoiseObj2d(mask,minarea);
            mm=sum(mask(:))/(a*b);
            
            if(mm<maskratio(1))
                range(2)=gap(1);
            else
                if(mm>maskratio(2))
                    range(1)=gap(1);
                else
                    %                loop=loop+1;
                    %                nn=sum(noise(:))/sum(mask(:));
                    %               if(nn>=noiseratio(1)&&nn<=noiseratio(2))
                    %                 break;
                    %               else
                    %
                    %               end
                    display(range);
                    if(any(obj))
                        disp('with foreground');
                    end
                    disp('adjust ok');
                    break;
                end
            end
            
            flag=(range(2)-range(1))/range(2);
            loop=loop+1;
        end
    end

    function mask=framedif200()
        dif=double(frame)-layer.mean;
        dif=sum(dif.^2,3);
        dif=dif/max(dif(:));
        dif=imadjust(dif);
        mask=dif>0.8;
        %         mask=bwareaopen(mask,minarea);
    end

    function mask=framedifbw()
        dif=double(frame)-layer.mean;
        dif=sum(dif.^2,3);
        dif=dif/max(dif(:));
        dif=imadjust(dif);
        
        mask=im2bw(dif,graythresh(dif));
        %         mask=bwareaopen(mask,minarea);
    end

    function mask=framedifedge()
        dif=double(frame)-double(layer.recentFrame);
        dif=sum(dif.^2,3);
        dif=dif/max(dif(:));
        dif=imadjust(dif);
        mask=edge(dif);
        %         mask=bwareaopen(mask,minarea);
    end
    
    function [lmask,vmask,cmask]=getRecentMask()
        light=sqrt(sum(frame.^2,3));
        reclight=sqrt(sum(layer.recentFrame.^2,3));
        vec=norm_yzbx(frame);
        recvec=norm_yzbx(layer.recentFrame);
        
        dif=double(sum((frame-layer.recentFrame).^2,3));
        ldif=sum((light-reclight).^2,3);
        crossvec=cross(vec,recvec);
        vdif=sum(crossvec.^2,3);
        
        cmask=imadjust(dif./max(dif(:)));
        cmask=im2bw(cmask,graythresh(cmask));
        
        lmask=imadjust(ldif./max(ldif(:)));
        lmask=im2bw(lmask,graythresh(lmask));
        
        vmask=imadjust(vdif./max(vdif(:)));
        vmask=im2bw(vmask,graythresh(vmask));
    end

    function mask=predict(mask3,mask5)
        if(layer.init(3)&&layer.init(5))
            mask=mask3|mask5|maskdifedge;
        else
            mask=maskdifedge|maskbw;
        end
        
        mask=bwareaopen(mask,minarea);
    end

    function show()
        % set(h,'Name',[num2str(frameNum),'/',num2str(roiframeNum(2))]);
%         figNum=5;
        subplot(figrow,figcol,1,'replace'),imshow(frame),title('frame');
        subplot(figrow,figcol,2,'replace'),imshow(mask5),title('mask5');
        subplot(figrow,figcol,3,'replace'),imshow(layer.hmean/255),title('hmean');
        subplot(figrow,figcol,4,'replace'),imshow(layer.smean/255),title(['smean at num ',num2str(frameNum)]);
        subplot(figrow,figcol,5,'replace'),imshow(mask3),title('mask3');
        subplot(figrow,figcol,6,'replace'),imshow(mask),title('hmask');
        subplot(figrow,figcol,7,'replace'),imshow(smask),title('smask');
%         subplot(figrow,figcol,8,'replace'),imshow(maskedge),title('maskedge');
        subplot(figrow,figcol,9,'replace'),imshow(maskdifedge),title('edge(f-c)');
        subplot(figrow,figcol,10,'replace'),imshow(maskbw),title('f-mean');
        subplot(figrow,figcol,11,'replace'),imshow(lcmask),title('l.c-f');
        subplot(figrow,figcol,12,'replace'),imshow(vcmask),title('v.c-f');
        subplot(figrow,figcol,13,'replace'),imshow(cmask),title('c-f');
%         pause(0.1);
    end

    function mask1=prediction1()
        if(frameNum==1)
            dif1=max(double(frame)-layer.max,layer.min-double(frame));
            range=[0,255];
            layer.gap=adajustGap3d(layer.gap,dif1,minarea,maskratio,noiseratio,range);
            [mask1,~,~]=maxminGapLayerFilter_yzbx(frame,layer.max,layer.min,layer.gap);
        else
            layer.mean=layer.hmean;
            [mask1,dif1max,dif1min]=maxminGapLayerFilter_yzbx(frame,layer.max,layer.min,layer.gap);
            dif1=max(dif1max,dif1min);
            dif1(dif1<0)=0;
            
            obj=imopen(mask1,strel('disk',objsize,8));
            noise=mask1&(~obj);
            
            %     gapextent=sum(dif1.^2,3);
            gapextent=dif1;
            noise3d=repmat(noise,[1,1,3]);
            gapextent(~noise3d)=0;
            noise=imdilate(noise,strel('disk',noisesize,8));
            % gapextent=imdilate(gapextent,strel('disk',noisesize,8));
            for i=1:3
                gapextent(:,:,i)=imfilter(gapextent(:,:,i),hmat);
            end
            noise=noise&(~obj);
            %         gapextent(obj)=0;
            difsum=sum(abs(gapextent(:)));
            basedif=difsum/sum(noise(:))/3;
            layer.gap=layer.gap+gapextent*basedif-difsum/(a*b*c);
            
            % nn=sum(noise(:))/(a*b);
            % display(nn);
            % layer.gap=layer.gap*(1-noiseratio+nn)-0.1;
            
            % layer.gap(noise)=max(layer.gap(noise),gapextent(noise)*1+0.1);
        end
        
        %     layer.gap in [0~20]
        % gaplarge20=layer.gap>20;
        % gapless5=layer.gap<1;
        
        % layer.max(gaplarge20)=min(10+layer.max(gaplarge20),255);
        % layer.min(gaplarge20)=max(0,layer.min(gaplarge20)-10);
        % layer.gap(gaplarge20)=layer.gap(gaplarge20)-10;
        
        % layer.max(gapless5)=max(layer.max(gapless5)-10,0);
        % layer.min(gapless5)=min(255,layer.min(gapless5)+10);
        % layer.gap(gapless5)=layer.gap(gapless5)+10;
        
        layer.max=max(layer.max,double(frame));
        layer.min=min(layer.min,double(frame));
    end
    function mask2=prediction2()
        % if(frameNum==1)
        % dif2=double(frame)./max(layer.mean,1);
        
        % else
        
        % end
        %     [~,dif]=ratioLayerFilter_yzbx(frame,layer.max,layer.min,layer.gap,layer.rangeratio,layer.mean);
        %
        %     mask3d=dif<layer.rangeratio;
        %     unfitRate=sum(sum(sum(mask3d)))/(a*b*3);
        % %     radiomask3d=repmat(radiomask,[1,1,3]);
        %
        %     randNum=double(rand(size(frame))<learnRate+unfitRate);
        %     layer.rangeratio=layer.rangeratio+dif.*double(mask3d)-randNum.*layer.rangeratio*learnRate;
        %
        %     if(layer.frameNum<20)  %just want to smooth the update!.
        %         layer.mean=(layer.mean*layer.frameNum+double(frame))/(layer.frameNum+1);
        %     else
        %         layer.mean=layer.mean*(1-learnRate)+double(frame)*learnRate;
        %     end
        %     layer.frameNum=layer.frameNum+1;
        %
        %     [vecMask,pmaxsetMask,pminsetMask]=getVectorMask_yzbx(frame,layer.mean,layer.pmaxnum,layer.pminnum);
        %     randNum=double(rand(a,b)<learnRate);
        %     layer.pmaxnum=layer.pmaxnum+uint32(pmaxsetMask)-uint32(randNum);
        %     layer.pminnum=layer.pminnum+uint32(pminsetMask)-uint32(randNum);
        
    end

    function vector=norm_yzbx(vector)
        vector=double(vector);
        light=sqrt(sum(double(vector).^2,3));
        not0=(light~=0);
        not0=repmat(not0,[1,1,3]);
        light=repmat(light,[1,1,3]);
        
        vector(~not0)=0;
        vector(not0)=vector(not0)./light(not0);
    end
    function update3(mask3)
        vector=norm_yzbx(frame);
        hvector=norm_yzbx(layer.mean);
        dif=cross(vector,hvector);
        dif=sum(dif.^2,3);
        
        %         mask3=dif>vecgap;
        
        diff=imadjust(dif/max(dif(:)));
%         subplot(figrow,figNum,7,'replace'),imshow(diff),title('v.diff');
        mask=im2bw(diff,graythresh(diff));
%         subplot(figrow,figcol,8,'replace'),imshow(mask),title('v.diff');
        if(sum(mask3(:))<sum(mask(:))&&~layer.init(3))
            mask=mask3;
%             disp('update3:: mask3 ..................');
        else
            layer.init(3)=true;
%             disp('update3:: mask ...................');
        end
        
        mask=bwareaopen(mask,minarea);
        %         layer.lmax(mask)=layer.lmean(mask);
        %         layer.lmin(mask)=layer.lmean(mask);
        gap=0.01*5;
        hit=(dif>=layer.vecgap-gap)&(dif<=layer.vecgap);
        layer.vecgapc(hit)=0;
        layer.vecgapc((~hit)&(~mask))=layer.vecgapc((~hit)&(~mask))+1;
        %         layer.vecgapc=layer.vecgapc.*mask3+1;
        
        layer.vecgap(~mask)=max(layer.vecgap(~mask),dif(~mask));
        
        %         step=min(layer.vecgap*learnRate,0.01);
        max20=layer.vecgapc>20;
        layer.vecgap=layer.vecgap-double(max20)*0.01;
        layer.vecgapc(max20)=10;
        
        %         obj=imopen(mask3,strel('disk',objsize,8));
        %         noise=mask3&(~obj);
        %
        %         gapextent=dif3;
        %         gapextent(~noise)=0;
        %         noise=imdilate(noise,strel('disk',noisesize,8));
        %         gapextent=imdilate(gapextent,strel('disk',noisesize,8));
        %         noise=noise&(~obj);
        %         %         gapextent(obj)=0;
        %         nn=sum(noise(:))/(a*b);
        %         display(nn);
        %         % layer.gap=layer.gap*(1-learnRate*5+nn)-0.1;
        %         layer.vecgap=layer.vecgap*(1-noiseratio+nn)-0.0001;
        %         % layer.gap(noise)=max(layer.gap(noise),gapextent(noise));
        %         layer.vecgap(noise)=max(layer.vecgap(noise),gapextent(noise));
    end

    function update4()
        if(frameNum==1)
            [~,dif4]=getVecMask4(layer,frame);
            range=[0,3];
            layer.vecdifmax=adajustGap2d(layer.vecdifmax,dif4,minarea,maskratio,noiseratio,range);
            [mask4,~]=getVecMask4(layer,frame);
        else
            layer.mean=layer.hmean;
            [mask4,dif4]=getVecMask4(layer,frame);
            
            obj=imopen(mask4,strel('disk',objsize,8));
            noise=mask4&(~obj);
            
            
            
            gapextent=dif4;
            gapextent(~noise)=0;
            noise=imdilate(noise,strel('disk',noisesize,8));
            gapextent=imdilate(gapextent,strel('disk',noisesize,8));
            noise=noise&(~obj);
            %         gapextent(obj)=0;
            nn=sum(noise(:))/(a*b);
            display(nn);
            layer.vecdifmax=layer.vecdifmax*(1-noiseratio+nn)-0.0001;
            
            % layer.gap(noise)=max(layer.gap(noise),gapextent(noise));
            layer.vecdifmax(noise)=max(layer.vecdifmax(noise),gapextent(noise));
        end
    end

    function mask5=prediction5()
        light=sqrt(sum(double(frame).^2,3));
        mask5=(layer.lmax<light)|(layer.lmin>light);
    end

    function update5(mask5)
        light=sqrt(sum(double(frame).^2,3));
        dif=(abs(light-layer.lmean));
        mask=imadjust(dif/max(dif(:)));
        %         mask=im2bw(dif,graythresh(dif));
        mask=im2bw(mask,graythresh(mask));
%         if(sum(mask5(:))<sum(mask(:)))
%             mask=mask5;
%         end
        if(sum(mask5(:))<sum(mask(:))&&~layer.init(5))
            mask=mask5;
%             disp('update5::mask5............');
        else
            layer.init(5)=true;
%             disp('update5::mask.............');
        end
        
        mask=bwareaopen(mask,minarea);
        %         layer.lmax(mask)=layer.lmean(mask);
        %         layer.lmin(mask)=layer.lmean(mask);
        gap=5;
       
        maxc=(light>layer.lmax-gap)&(light<layer.lmax);
        minc=(light>layer.lmin)&(light<layer.lmin+gap);
        layer.lmaxc(maxc)=0;
        layer.lminc(minc)=0;
        layer.lmaxc(~maxc&~mask)=layer.lmaxc(~maxc&~mask)+1;
        layer.lminc(~minc&~mask)=layer.lminc(~minc&~mask)+1;
        layer.lmean=layer.lmean*(1-learnRate)+light*learnRate;
        layer.lmax(~mask)=max(layer.lmax(~mask),light(~mask));
        layer.lmin(~mask)=min(layer.lmin(~mask),light(~mask));
        
        max20=layer.lmaxc>20;
        min20=layer.lminc>20;
        layer.lmax=layer.lmax-double(max20);
        layer.lmaxc(max20)=15;
        layer.lmin=layer.lmin+double(min20);
        layer.lminc(min20)=15;
    end
end
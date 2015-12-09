classdef subsensePlusOpticalFlow
    
    properties
        inited=false;
        N=30;   %history num
        alpha=1;    %distance=alpha*distance_lbsp+1*distance_rgbv
        learnRate=0.05;
        a;b;
        % 'St',false(a,b),...
        % 'St0',false(a,b),...
        % 'foreground',false(a,b),...
        % 'V',ones(a,b,'double'),...
        % 'Dmin',zeros(a,b,'double'),...
        % 'R',ones(a,b,'double')*5,...
        % 'T',ones(a,b,'double')*20,...
        % 'lbsp_distance',zeros(a,b,'double'),...
        % 'rgbv',zeros(a,b,5,'double'),...
        % 'rgbv_history',zeros([a,b,5,N],'double'),...
        % 'lbsp_history',zeros(a,b,'double'),...
        % 'frameNum',1);
        St;St0;foreground;V;Dmin;R;T;lbsp_distance;rgbv;rgbv_history;lbsp_history;frameNum;
    end
    
    methods
        function [model]=process(model,input1,input2)
            
%             [model.a,model.b,model.c]=size(input1);
            if(~model.inited)
                disp('init model start ..........');
                model=init(model,input1,input2);
                model.inited=true;
                disp('init model end ............');
            else
                
                model=getMask(model,input1,input2);
                model=updateModel(model,input1,input2);
            end
        end
        
        function model=init(model,input1,input2)
            model=subsensePlusOpticalFlow();
            N=model.N;
            alpha=model.alpha;    %distance=alpha*distance_lbsp+1*distance_rgbv
            learnRate=model.learnRate;
            [a,b,~]=size(input1);
            model.a=a;
            model.b=b;
            [vx,vy]=opticalFlow(input1,input2);
            lbsp_distance=lbsp(input1,input2);
            rgbv=reshape(double(input2),[a*b,3]);
            rgbv=[rgbv vx(:) vy(:)];
            rgbv=reshape(rgbv,[model.a,model.b,5]);
            
            model.St=false(a,b);
            model.St0=false(a,b);
            model.foreground=false(a,b);
            model.V=ones(a,b,'double');
            model.Dmin=zeros(a,b,'double');
            model.R=ones(a,b,'double')*5;
            model.T=ones(a,b,'double')*20;
            model.lbsp_distance=zeros(a,b,'double');
            model.rgbv=zeros(a,b,5,'double');
            model.rgbv_history=zeros([a,b,5,N],'double');
            model.lbsp_history=zeros(a,b,'double');
            model.frameNum=1;
            
            model.rgbv_history(:,:,:,model.frameNum)=rgbv;
            model.lbsp_history=lbsp_distance;
            model.lbsp_distance=lbsp_distance;
        end
        
        function [model]=getMask(model,input1,input2)
            [a,b,~]=size(input1);
            [vx,vy]=opticalFlow(input1,input2);
            %         lbsp_distance belong to [0,1]
            model.lbsp_distance=lbsp(input1,input2);
            rgbv=reshape(double(input2),[a*b,3]);
            rgbv=[rgbv vx(:) vy(:)];
            rgbv=reshape(rgbv,[a,b,5]);
            
            %         Dmin=rgbv_distance or distance
            model=getRGBVDistance(model,rgbv);
            
            %         distance=a*lbsp+(1-a)*rgbv_distance;
            %         model.mask=distance>model.R;
        end
        
        function [model]=getRGBVDistance(model,rgbv)
            % rgb and v must in a vector together
            % big v alwasy mean a different rgb, so band them together is better
            % in fact, d=w'*[r g b vx vy], here the vx,vy can be exp(vx0)-1 and
            % exp(vy0)-1,
            % lbsp cannot band with them becasue distance_lbsp=ham(lbsp1,lbsp2)
            a=model.a;
            b=model.b;
            N=model.N;
            alpha=model.alpha;    %distance=alpha*distance_lbsp+1*distance_rgbv
            learnRate=model.learnRate;
            
            dif=bsxfun(@minus,model.rgbv_history,rgbv);
            wvx=1;
            wvy=1;
            w=[1,1,1,wvx,wvy];
            w=reshape(w,[1 1 5 1]);
            dif=bsxfun(@times,abs(dif),w);
            %         dif from [a,b,5,n] to [a,b,1,n]
            dif=sum(dif,3);
            
            R=model.R-alpha*model.lbsp_distance;
            R=repmat(R,[1,1,1,N]);
            neighbor_count=sum(dif<R,4);
            model.St=reshape(neighbor_count<2,[a,b]);
            rgbv_distance=min(abs(dif),[],4);
            rgbv_distance=reshape(rgbv_distance,[a,b]);
            Dmin=rgbv_distance+alpha*model.lbsp_distance;
            
            %         update Dmin
            model.foreground=medfilt2(model.St,[5 5]);
            Dmin=model.Dmin*(1-learnRate)+learnRate*Dmin;
            model.Dmin(model.foreground)=Dmin(model.foreground);
            
            %         update lbsp_history, the usage of lbsp_history is waiting ...
            lbsp_history=model.lbsp_history*(1-learnRate)+learnRate*model.lbsp_distance;
            model.lbsp_history(model.foreground)=lbsp_history(model.foreground);
            
            model.rgbv=rgbv;
        end
        
        function model=updateModel(model,input1,input2)
            %         Dmin,lbsp_history update in getRGBVDistance();
            %         update V,the noise rate
            N=model.N;
            alpha=model.alpha;    %distance=alpha*distance_lbsp+1*distance_rgbv
            learnRate=model.learnRate;
            
            [a,b,~]=size(input1);
            Xt=xor(model.St0,model.St);
            model.V(Xt)=model.V(Xt)+1;
            model.V(~Xt)=model.V(~Xt)-0.1;
            
            %         update R, the threshold of distance.
            %         R soft belong to [1,9], Dmin belong to [0,1]
            model.Dmin=model.Dmin./max(model.Dmin(:));
            R_upper_bound=(1+model.Dmin*2).^2;
            
            op_mask=model.R<R_upper_bound;
            model.R(op_mask)=model.R(op_mask)+model.V(op_mask);
            V_inv=1./model.V;
            model.R(~op_mask)=model.R(~op_mask)-V_inv(~op_mask);
            
            %         update T, the pixel update neighbor's rate.
            T_inc=1./(model.V .* model.Dmin);
            T_dec=model.V ./ model.Dmin;
            model.T(model.St)=model.T(model.St)+T_inc(model.St);
            model.T(~model.St)=model.T(~model.St)-T_dec(~model.St);
            %         model.T belong to [2,256]
            model.T=min(model.T,256);
            model.T=max(model.T,2);
            
            model=updateModelHistory(model);
            model.frameNum=model.frameNum+1;
        end
        
        function model=updateModelHistory(model)
            %         model.foreground=medfilt2(model.St,[5 5]);
            %       model.lbsp_history is update in getRGBVDistance();
            N=model.N;
            alpha=model.alpha;    %distance=alpha*distance_lbsp+1*distance_rgbv
            learnRate=model.learnRate;
            
            a=model.a;
            b=model.b;
            if(model.frameNum<N)
                model.rgbv_history(:,:,:,model.frameNum+1)=model.rgbv;
            else
                x=randi(N,1);
                rgbv_history=reshape(model.rgbv_history(:,:,:,x),[a*b,5]);
                %             op_mask is the foreground's edge.
                op_mask=imerode(model.foreground,strel('disk',1));
                op_mask=model.foreground & (~op_mask);
                
                %             update the foreground's edge by 1/T
                local_update_rate=1./model.T;
                op_mask=rand(a,b)<local_update_rate & op_mask;
                %             update the background by 100%
                op_mask=op_mask | (~model.foreground);
                
                op_mask=reshape(op_mask,[a*b 1]);
                
                %             replace the history by rgbv;
                rgbv=reshape(model.rgbv,[a*b,5]);
                rgbv_history(op_mask,:)=rgbv(op_mask,:);
                model.rgbv_history(:,:,:,x)=reshape(rgbv_history,[a,b,5,1]);
            end
        end
        
    end
    
end
function [mask,kernel]=bgs_sigma(input,kernel)
    [a,b,c]=size(input);
    if(~isempty(kernel))
        
    else
       kernel=initKernel(input);
       mask=zeros(a,b);
    end
end

function kernel=initKernel(input)
    [aa,bb,cc]=size(input);
    dd=3;
    kernel=struct(...
            'u',zeros(aa,bb,cc,'single'),...
            'sigma',zeros(aa,bb,cc,'single'),...
            'historyNum',dd,...
            'futureNum',dd,...
            'currentNum',0,...
            'frameNum',1);
   
        kernel.u=single(input);
   
end
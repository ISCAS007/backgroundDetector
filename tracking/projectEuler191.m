N=500;
CN=0;
            %        CN: combinatorial number(组合数)
            
LNum=1;
AONum=N-LNum;

for ANum=0:AONum
    ONum=AONum-ANum;
    
    for A_AA_Num=ceil(ANum/2):ANum
        
        if(A_AA_Num<=ONum+1+LNum)
            AA_Num=ANum-A_AA_Num;
            A_Num=A_AA_Num-AA_Num;
            
            A_AA_CN=nchoosek(A_AA_Num,A_Num);
            
            A_AA_O_CN=A_AA_CN*nchoosek(ONum+1+LNum,A_AA_Num);
            
            CN=CN+A_AA_O_CN*nchoosek(ONum+1,LNum);
          
        end
    end
end

% CN=CN*N;

LNum=0;
AONum=N-LNum;

for ANum=0:AONum
    ONum=AONum-ANum;
    
    for A_AA_Num=ceil(ANum/2):ANum
        
        if(A_AA_Num<=ONum+1+LNum)
            AA_Num=ANum-A_AA_Num;
            A_Num=A_AA_Num-AA_Num;
            
            A_AA_CN=nchoosek(A_AA_Num,A_Num);
            
            A_AA_O_CN=A_AA_CN*nchoosek(ONum+1+LNum,A_AA_Num);
            
            CN=CN+A_AA_O_CN*nchoosek(ONum+1,LNum);
          
        end
    end
end
% 
% AONum=N-LNum;
% for ANum=0:AONum
%     ONum=AONum-ANum;
%     
%     for A_AA_Num=ceil(ANum/2):ANum
%         
%         if(A_AA_Num<=ONum+1)
%             AA_Num=ANum-A_AA_Num;
%             A_Num=A_AA_Num-AA_Num;
%             
%             %        CN: combinatorial number(组合数)
%             A_AA_CN=nchoosek(A_AA_Num,A_Num);
%             
%             A_AA_O_CN=A_AA_CN*nchoosek(ONum+1,A_AA_Num);
%             CN=CN+A_AA_O_CN;
%         end
%     end
% end

classdef myClass
    properties
        a
        hello
        str
    end
    
    methods 
        function c=addOne(c)
            c.a=c.a+1;
            c.str='hello world';
            c.hello=1:5;
        end
    end
end
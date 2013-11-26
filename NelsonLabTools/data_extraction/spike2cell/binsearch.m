function index=binsearch(data,key)
%BINSEARCH performs binary search
%
%  INDEX=BINSEARCH(DATA,KEY)
%    DATA is an array of records to search
%    KEY is the value to find.
% 
% binsearch returns the index of the highest item in DATA lower then KEY
%   or the index of some item equal to KEY.
%
% adapted from ADR

for i=1:length(key)

  if(key(i)>data(end))
     index(i)=length(data)
  else
    low = 1;
    mid = 1;
    high = length(data);                    
    while (low < (high-1))
        mid = floor( (low + high)/2);
        tmp = floor(data(mid));
        if key(i) == tmp
  	 low = mid;
           high = mid;
        end
        if key(i) < tmp
  	 high = mid;
        end
        if key(i) > tmp
  	low = mid;
        end
    end
    index(i)=low;  
  end
end

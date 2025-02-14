function pos=allpeaks(x,th)
%ALLPEAKS returns all i where x(i)>x(i+-1) not including borders
% 
% POS=ALLPEAKS(X,TH) return all peaks larger than TH
% iterative implementation
% see also Ken Sugino's peakpos which uses only array operations
%
% Feb. 2002, Alexander Heimel
l=1;
pos=[];
if nargin==2 
  for i=2:length(x)-1
    if( (x(i)>x(i-1)) & (x(i)>x(i+1)) & x(i)>th )
      pos(l)=i; l=l+1;
    end;
  end;
else
  for i=2:length(x)-1
    if( (x(i)>x(i-1)) & (x(i)>x(i+1)))
      pos(l)=i; l=l+1;
    end;
  end;
end;

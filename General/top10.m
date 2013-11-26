function t = top10( x )
%DEPRECATED, CAN BE REMOVED
if numel(x) <= 10 
    t = min(x);
    return
else
    p =  100 - 10/numel(x)*100;
    t = prctile(x, p);
end
function t = top100( x )
if numel(x) <= 100
    t = min(x);
    return
else
    p =  100 - 100/numel(x)*100;
    t = prctile(x, p);
end
function out = adapterodeAK(in, idx, thresh)

in = double(in); 
si = size(in);
center = floor(si(1)/2)+1;
minval = min(in(idx));
medianval = median(in(idx));
if (in(center,center)<thresh | medianval<(thresh*1.5))
    out = minval;
    return
end
maxval = max(in(idx));
adapt = 255*((minval+1)/(maxval+1));
adapt = adapt + ((255-adapt)*(adapt/255));
out = uint8(floor(adapt));
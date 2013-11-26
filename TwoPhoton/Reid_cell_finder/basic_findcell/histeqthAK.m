function out = histeqthAK(in,thresh)

si = size(in);
centeridx = floor(si(1)/2) + 1;
centerpix = in(centeridx,centeridx);

% check threshold
if (centerpix < thresh)
    out = centerpix;
    return
end

in = histeq(in);
out = in(centeridx,centeridx);
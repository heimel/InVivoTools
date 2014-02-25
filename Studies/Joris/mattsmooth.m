function y = mattsmooth(x,win)

%Moving window

[sz,sz2] = size(x);

nwins = (sz2-win);

y = zeros(1,sz2);
for n = 1:nwins
    winx = n:n+win;
    xval(n) = median(winx);
    y(xval(n)) = mean(x(winx));
end

%pad
y(1:(xval(1)-1)) = y(xval(1));
y((xval(end)+1):end) = y(xval(end-1));

return
function y = movingavr(x, n);
if n==1
        y = x;
        return;
end

w = floor(n/2);
B = ones(2*w+1,1)/(2*w+1);
y = filter(B,1,x);
y(1:end-w) = y(1+w:end);
y(end-w+1:end) = y(end-w);


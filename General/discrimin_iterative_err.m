function err=discrimin_iterative_err(X,data,g)

l = length(X);
a = X(1:(l/2));
c = X((l/2)+1:end);
len = size(data,1);

newdat = repmat(a,len,1).*(data - repmat(c,len,1));

STAT = manova(newdat,g); err = STAT.ratio,
input('test')

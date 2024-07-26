function y = find_peak2(a,b,c,d)

global f;
global ff;

% check buffer (already calculated?)
if ff(a,b,c,d) ~= 0
	y = ff(a,b,c,d);
	return;
end

% look around
dim = size(f);

if f(a,b,c,d) == 0 
	y = 0;
	return;
end

iv = [-1,0,1];
jv = [-1,0,1];
kv = [-1,0,1];
lv = [-1,0,1];

if (a == 1)
	iv(1) = [];
end
if (a == dim(1))
	iv(3) = [];
end

if (b == 1)
	jv(1) = [];
end
if (b == dim(2))
	jv(3) = [];
end

if (c == 1)
	kv(1) = [];
end
if (c == dim(3))
	kv(3) = [];
end
if (d == 1)
	lv(1) = [];
end
if (d == dim(4))
	lv(3) = [];
end

in = length(iv);
jn = length(jv);
kn = length(kv);
ln = length(lv);

fm = zeros(in,jn,kn,ln);

for i = 1:in
	for j = 1:jn
		for k = 1:kn
			for l = 1:ln
				fm(i,j,k,l) = f(a+iv(i),b+jv(j),c+kv(k),d+lv(l));
			end
		end
	end
end

m = max(max(max(max(fm))));

% if current position is the maximum
if f(a,b,c,d) >= m
	y = sub2ind(dim,a,b,c,d);
	ff(a,b,c,d) = y;
	return
end

% if not, recursively calculate
mi = find(fm == m);
[i,j,k,l] = ind2sub(size(fm),mi(1));
y = find_peak2(a+iv(i),b+jv(j),c+kv(k),d+lv(l));
ff(a,b,c,d) = y;

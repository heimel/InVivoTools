function [vE,nE] = count_class(ci,thN)

[a,b] = sort(ci);

numC = 0;
i = 1;

while (i <= length(a))
	value = a(i);
	j = 1;
	while (((i+j) <= length(a)) & (a(i+j) == value) )
		j = j+1;
	end
	numC = numC +1;
	vE(numC) = value;
	nE(numC) = j;
	i = i+j;
end

index = find(nE >= thN);
nE = nE(index);
vE = vE(index);

[a,b] = sort(-nE);
nE = nE(b);
vE = vE(b);


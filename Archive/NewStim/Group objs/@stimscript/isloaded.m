function v = isloaded(S)

v = 1;

i = 1;
l = numStims(S);
while (i<=l&v==1),
	v = isloaded(S.Stims{i});
	i = i + 1;
end;

if l==0, v = 0; end;

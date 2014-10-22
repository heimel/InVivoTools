function TI = reggrow3D(f,S,T,seed)
% [g,NR,SI,TI]
f = double(f);
SI = bwmorph3D(S);
J = find(SI);
S1 = f(J);
TI = false(size(f));
seedvalue = mean(S1(:));
for K = 1:length(S1)
    S = abs(f - seedvalue) <= T;
    TI = TI|S;
%     seedvalue = mean(mean(f(S1)))
end
% TI=TI|seed;
% [g,NR] = bwlabel(imreconstruct(seed,TI));
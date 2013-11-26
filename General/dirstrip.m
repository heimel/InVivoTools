function d = dirstrip(ds)

%  D = DIRSTRIP(DS)
%
%  Removes '.' and '..' from a directory structure returned by the function
%  "DIR".

g = {ds.name}; [B,I] = setdiff(g,{'.','..'}); d = ds(I);

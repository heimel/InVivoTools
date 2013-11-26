function b = isloaded(cca)

%  ISLOADED - Is the COMPOSE_CA stimulus loaded?
%
%    B = ISLOADED(MYCOMPOSE_CA)
% 
%    Returns 1 if the MYCOMPOSE_CA stim is loaded.
%  

b = 1; i = 1; l = numStims(cca);

if l==0, b = 0; end;

while (b&(i<=l)), b = b&isloaded(cca.stimlist{i}); i=i+1; end;

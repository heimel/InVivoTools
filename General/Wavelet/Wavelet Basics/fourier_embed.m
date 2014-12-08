function F = fourier_embed(filter,ns)
%FOURIER_EMBED
%
% USAGE:
%   FF = fourier_embed(filter,ns)
% INPUT:
%   filter - cellular array of filters
%   ns     - embedding length
% OUTPUT:
%   FF - matrix of filter Fourier components
% VERSION:
%   Stiliyan, 24.10.03

F = zeros(length(filter),ns);
for k=1:length(filter)
    fil = filter{k};
    %  L = length(fil);  % changed on 2014-12-08 by AH
    L = min(length(fil),ns);  
    l = floor(L/2);
    F(k,1:l+1) = fil(l+1:L);
    F(k,ns-l+1:ns) = fil(1:l);
end
F = fft(F,[],2)/ns;
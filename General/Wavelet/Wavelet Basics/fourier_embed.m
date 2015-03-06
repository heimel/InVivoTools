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
    L = length(fil);  
    l = floor((L-1)/2);
    F(k,1:l+1) = fil(l+1:L);
    if ns >= l % normal situation
        F(k,ns-l+1:ns) = fil(1:l);
    else % added case 2014-12-09 by AH
        F(k,1:l) = fil(1:l);
    end
end
F = fft(F,[],2)/ns;
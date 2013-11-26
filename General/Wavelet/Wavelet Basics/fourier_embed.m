% USAGE:
%   FF = fourier_embed(filter,ns)
% INPUT:
%   filter - cellular array of filters
%   ns     - embeding length
% OUTPUT:
%   FF - matrix of filter Fourier components
% VERSION:
%   Stiliyan, 24.10.03


function F = fourier_embed(filter,ns)
F=zeros(length(filter),ns);
for k=1:length(filter)
    L=length(filter{k});
    fil=filter{k};
    l=floor(L/2);
    F(k,1:l+1)=fil(l+1:L);
    F(k,ns-l+1:ns)=fil(1:l);
end
F=fft(F,[],2)/ns;
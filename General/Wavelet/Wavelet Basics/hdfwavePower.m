function [Power] =  hdfwavePower(Data, Ffilter)
%calculates power spectral density function using Morlet wavelet
%
% Inputs:
% Data : Data in (samples x channels x trials)
% Ffilters : Morlet wavelets in frequency domain
%
% Outputs:
% AChn in (frequencies x samples x channels)

NOFSW = size(Data, 3);
Nchan = size(Data,2);

Wtemp = zeros(size(Ffilter,1),size(Ffilter,2),Nchan);
Power = zeros(size(Wtemp));

for k = 1:NOFSW
    for j = 1:Nchan
        Wtemp(:,:,j) = gaborspaceF(Data(:,j,k),Ffilter);
        %        Power(:,:,j)  = Power(:,:,j) + abs(Wtemp(:,:,j));
    end
    Power  = Power + abs(Wtemp);
end

function [Phase] =  hdfwavePhase(Data, Ffilter)
%calculates power spectral density function using Morlet wavelet
%
% Inputs:
% Data : Data in (samples x channels x trials)
% Ffilters : Morlet wavelets in frequency domain
%
% Outputs:
% Phase in (frequencies x samples x channels)


NOFSW = size(Data, 3);
Nchan = size(Data,2);

Wtemp = zeros(size(Ffilter,1),size(Ffilter,2),Nchan);

Chn = zeros(size(Wtemp));
Phase = zeros(size(Wtemp));

for k = 1:NOFSW
    for j = 1:Nchan
        Wtemp(:,:,j) = gaborspaceF(Data(:,j,k),Ffilter);
        Phase(:,:,j)  = Phase(:,:,j) + angle(Wtemp(:,:,j));
    end
end
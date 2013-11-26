function [fc, freqs] = fouriercoeffs(data,sr)

%  FOURIERCOEFFS - find Fourier coefficients for data
%
%  Uses FFT to compute the Fourier coefficients for a vector of data.
%
%  [FC,FREQS]=FOURIERCOEFFS(DATA,SR)
%
%  where DATA is a vector of data and SR is the sampling rate (in seconds),
%  returns FC the Fourier coefficients and FREQS, the frequency of
%  each coefficient.
%
%  The coefficients are returned as complex numbers.  The relationship between
%  the coefficients and the values returned by FFT are in FFT's help file.
%
%  See also:  FFT

fc = fft(data);

fc(1) = fc(1)/(length(data));
fc(2:end) = (2/(length(data)))*(real(fc(2:end))-sqrt(-1)*imag(fc(2:end)));
freqs = (0:length(data)-1)/(sr*length(data));

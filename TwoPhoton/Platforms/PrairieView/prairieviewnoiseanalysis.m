function [im,fcx,freqx,fcy,freqy] = prairieviewnoiseanalysis(filename, linesx, linesy, note)
% PRAIRIEVIEWNOISEANALSYS - Analyze noise in prairieview recording
%
%  [IM,FCX,FREQX,FCY,FREQY] = PRAIRIEVIEWNOISEANALYSIS(FILENAME,LINESX,LINESY,NOTE)
%
%  Performs fourier analysis on a Prairieview image file and plots the results.
%
%  FILENAME is name of file without extension (e.g., no '.tif')
%  LINESX are the lines to analyze in X (e.g., 1:50).  It is best to restrict the
%     fourier analysis to a location where there is an object present.
%  LINESY are the lines to analyze in Y (e.g., 1:50)
%  NOTE is a note to be included in the plot
%
%  IM is the image, FCX are the fourier coefficients in X and FREQX are the
%  frequencies measured in X, FCY are the fourier coefficients in Y and FREQY
%  are the frequencies measured in Y.
%
%  This function has not been updated for PrairieView 2.2.


im = double(imread([filename '.tif']));

dts = readprairieconfigvalue([filename(1:end-4) '.pcf'],'Dwell time (us)') * 1e-6;
dtl = readprairieconfigvalue([filename(1:end-4) '.pcf'],'Scanline period (us)') * 1e-6;

fprintf(1,['Sample interval is ' num2str(dts) ' and line interval is ' num2str(dtl) '.\n']);

figure;

subplot(2,2,1);
mn = min(min(im)); mx = max(max(im));
image(rescale(im,[mn mx],[0 255])); colormap(gray(256));
[d,fp]=fileparts(filename);
title([fp ' : ' note],'interp','none');

for i=linesx,
	[fcx(i,:),freqx]=fouriercoeffs(im(i,:),dts);
end;
for i=linesy,
	[fcy(i,:),freqy]=fouriercoeffs(im(:,i),dtl);
end;

subplot(2,2,3); plot(freqx,mean(abs(fcx))); a = axis; axis([0 a(2)/2 a(3) a(4)]);
title('Fourier coeffs in X');
subplot(2,2,4); plot(freqy,mean(abs(fcy))); a = axis; axis([0 a(2)/2 a(3) a(4)]);
title('Fourier coeffs in Y');

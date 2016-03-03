function [gct,filename] = CreateGammaCorrectionTable( rgb, luminance, fittype, filename)
% CREATEGAMMACORRECTIONTABLE creates and stores a gamma correction table from luminance measurements 
%
% [GCT,FILENAME] = CREATEGAMMACORRECTIONTABLE( RGB, LUMINANCE, FITTYPE, FILENAME )
%
%   RGB = Nx1 or Nx3 (RGB) array with RGB values given to the monitor
%   LUMINANCE = Nx1 or Nx3 array with luminance values measured for the RGB
%           values. RGB values should either range between [0,1] or [0,255]
%           LUMINANCE values will be normalized before constructing the 
%           gamma correction table.
%           When Nx3 arrays are used, the luminances for the 
%           3 colors are supposed to havebeen measured separately
%
%     If you want to create a linear table, add a very small non-zero
%     point to bypass an error in FitGammaPoly (which ignores everything
%     smaller)
%
%  GCT will be a table as used for LOADGAMMACORRECTIONTABLE. 
%  In FILENAME the GCT is stored as text (see LOADGAMMACORRECTIONTABLE for
%  format).
%
%  FITTYPE is optional, and can be POWER (default)
%
%  2012, Alexander Heimel
%


if nargin<4
    filename = [];
end
if isempty(filename)
    filename = ['gct_' host '.txt'];
end
if nargin<3
    fittype = [];
end
if isempty(fittype)
    fittype = 'extpow';
end
if nargin<1
    rgb = repmat( (0:0.1:1)',1,3);
    warning('CREATEGAMMACORRECTIONTABLE: no rgb data given. Using test data.');
end
if nargin<2
    luminance = 10*rand(1)*(rgb.^3+ 0.1*max(rgb(:))*rand(size(rgb)));
    warning('CREATEGAMMACORRECTIONTABLE: no luminance data given. Using test data.');
end
    luminance = luminance- min(luminance(:));


if size(rgb,1)==1
    rgb = rgb';
end
if size(luminance,1)==1
    luminance = luminance';
end


if any(size(rgb)~=size(luminance))
    error('CREATEGAMMACORRECTION: Sizes of RGB and LUMINANCE tables do not match.');
end
    
% need to get size of GammaTable
%StimWindowGlobals
%ShowStimScreen
%currLut = Screen('ReadNormalizedGammaTable', StimWindow);
%CloseStimScreen

n_entries = 256; %size(currLut,1);
n_entries = n_entries - 1;


% normalized rgb input
if max(rgb(:))>1 % suppose 255
    nrgb = rgb / 255; % rescale to [0,1], n stands for normalized
else
    nrgb = rgb;
end

nluminance = luminance ./ repmat( max(luminance),size(luminance,1),1);

% fit
frgb = linspace(0,1,1000)';
switch lower(fittype)
    case 'best'
        [fluminance,par] = FitGamma(nrgb,nluminance,frgb);
    case 'pow' % simple gamma power function
        [fluminance,par] = FitGamma(nrgb,nluminance,frgb,1);
        fprintf(1,'Found exponent %g\n\n',par(1));
    case 'extpow'
        [fluminance,par] = FitGamma(nrgb,nluminance,frgb,2);
        fprintf(1,'Found exponent %g, offset %g\n\n',par(1),par(2));
    otherwise
        error('CREATEGAMMACORRECTIONTABLE: Type of fit is not implemented.');
end

figure;
hold on
plot(nrgb,nluminance)
plot(frgb,fluminance,'r');

trgb = (0:n_entries)/n_entries;
if ndims(trgb)==2 && size(trgb,1)>1
    n_cols = 3;
else 
    n_cols =1;
end

for c=1:n_cols
    for i=1:length(trgb)
        tintensity(i,c) = (findclosest(fluminance(:,c),trgb(i)) - 1)/(size(fluminance,1)-1);
    end
end
%plot(trgb,tintensity);

table(:,1)=trgb*255;
table(:,2:(1+n_cols)) = tintensity * 255 /max(tintensity);
%

if isempty(fileparts(filename))
    filename = fullfile(fileparts(which('monitor_calibrations.m')),filename);
end

save(filename,'table','-ascii');
filename

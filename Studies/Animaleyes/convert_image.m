function convert_image(name,cs,nocolor,ppd)
%CONVERT_IMAGE reads image and shows it as using specified contrast sensititivity
%
%   CONVERT_IMAGE(NAME,CS,NOCOLOR,PPD)
%         NAME is name of jpg image file
%         CS contains 2xN matrix contrast sensitivity, with in the first
%         row the spatial frequencies and in the second row the sensitivities.
%         see or use CONTRAST_SENSITIVITIES for some example curves
%         if NOCOLOR, final image is transformed to gray scale
%         PPD is the pixels per degee of the original image
%
%    Example:
%        contrast_sensitivities;
%        img=convert_image('images/fieke.jpg',cs_squirrel,0,8.7);
%
% 2003-2014, Alexander Heimel (heimel@brandeis.edu)
%
global img

if nargin<4
    ppd = [];
  % laptop settings:
  % 1024 pixels in 27 cm at 50 cm viewing distance
%   ppd = 1024 / 27 * 2 * pi * 50 /360; 
%  ppd = 1024 / 27 * 2 * pi * 50 /360; 

  %desktop settings
  % 1600 pixels in 35 cm at 50 cm viewing distance
  %ppd=1600/ 35 * 2 * pi * 50 /360;
  
  %real world for fieke.jpg
  % 250 pixels in 100cm at 200cm viewing distance
  % ppd=250 / 100 * 2 * pi * 200 /360; 
end

if nargin<3
  nocolor=0;
end
if nargin<2
  cs = [];
end
if nargin<1
    name = '';
end

p = pwd;
cd(getdesktopfolder);
if isempty(name)
    [name,pathname] = uigetfile(...
        {'*.jpg;*.png;*.jpeg;*.tif','Image files';...
        '*.*','All Files (*.*)'},'Select image');
end
cd(p);

name = fullfile(pathname,name);


if min(size(name))==1
  img=imread(name,'jpg');
else
  img=name;
end



if isempty(ppd)
    prompt = {'Width original image (cm): ',...
        'Image taken from distance (cm):'};
    def = {'20','200'};
    answer = inputdlg(prompt,'Size questions',1,def);
    ppd = size(img,2) / eval(answer{1}) * 2 * pi * eval(answer{2}) / 360; 

end


if isempty(cs)
   animal = 'mouse';
   cs = contrast_sensitivities(animal);
else
   animal = 'cs';    
end


%close all
%img=img(1:50,1:50);

% make rows and columns odd
if mod(size(img,1),2)==0
  img=img(1:end-1,:,:);
end
if mod(size(img,2),2)==0
  img=img(:,1:end-1,:);
end

% make square
if size(img,1)>size(img,2)
  img=img(1:size(img,2),:,:);
else
  img=img(:,1:size(img,1),:);
end


if nocolor
  img=rgb2gray(img);  % transform to gray image
end


if size(img,3)==3 
  % rgb image
  h=image(img);
  sz=size(img);
  set_size(gca,sz(1:2));
  set_size(gcf,sz(1:2));
  cimg=rgb2squirrel(img);
  cimg(:,:,2)=convert_fourier(cimg(:,:,2),cs,ppd); % M signal
  cimg(:,:,3)=convert_fourier(cimg(:,:,3),cs,ppd); % S signal
  cimg(:,:,1)=cimg(:,:,2);
  figure;
  image(uint8(cimg));
  set_size(gca,sz(1:2));
  set_size(gcf,sz(1:2));
else
  % gray image
  colormap(gray);
  h=imagesc(img);
  set_size(gca,size(img));
  set_size(gcf,size(img));
  
  cimg=convert_fourier(img,cs,ppd);
  
  figure;
  colormap(gray);
  h=imagesc(cimg);
  set_size(gca,size(img))
  set_size(gcf,size(img))
end
[pth,filename,ext] = fileparts(name);
filename = [filename '_' animal];
ext = '.png';
filename = save_figure([filename ext],pth);
logmsg(['Saved as ' filename]);

%%%%%%%%%
function img2=convert_fourier(img,cs,ppd)

%  contrast_sensitivities;
    
% when restricting fouriers, there is a lot of spill over
fimg=fft2(img);

nrow=size(img,1);
ncol=size(img,2);
if ncol~=ncol
  error('Image not square');
end

% FFT matrix
%  0,0 0,.....

maskr=[ (1:floor( (nrow-1)/2))  (floor( (nrow-1)/2):-1:1) ];
maskrs=maskr(ones(1,ncol-1),:)';
maskc=[ (1:floor( (ncol-1)/2))  (floor( (ncol-1)/2):-1:1) ];
maskcs=maskc(ones(1,nrow-1),:);
mask=sqrt(maskrs.^2 + maskcs.^2);


totalmask=ones( nrow,ncol);
totalmask(2:end,2:end)=mask;
totalmask(1,2:end)=maskc;
totalmask(2:end,1)=maskr';

%sfs=unique(mask); % has to be divided by ncol to get cycles per pixels
%cs_sfs=interp1(cs(1,:)/ppd,cs(2,:),sfs/ncol);

cs_human = contrast_sensitivities('human');

% rescale to relative contrastsensitivities:
cs(2,:)=cs(2,:)./interp1q(cs_human(1,:)',cs_human(2,:)',cs(1,:)')';
cs(2,(cs(2,:)>1))=1; % to avoid saturation, where contrast detection
                         % is better than human

% get sf in cycles per pixel:
cs(1,:)=cs(1,:)/ppd; 

totalmask=totalmask/ncol;      % to get sf in cycles per pixel
mask2=interp1q(cs(1,:)',cs(2,:)',totalmask(:) ) ;
totalmask=reshape(mask2,nrow,ncol);

totalmask(1,1)=1; % no change in DC component

if any(isnan(mask))
  errorlog('Oops nan in mask');
end

fimg=fimg.*totalmask;
img2=abs(ifft2(fimg));

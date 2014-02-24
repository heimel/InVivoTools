function img=cs_gratings(ppd,lowsf,highsf,n_xpixels,n_ypixels)
%CS_GRATINGS shows an image of gratings with a range of contrasts and sf's
%
%   IMG=CS_GRATINGS(PPD,LOWSF,HIGHSF,N_XPIXELS,N_YPIXELS)
%      PPD= pixels per degree
%      LOWSF = lowest spatial frequency (cpd) to show
%      HIGHSF = hight spatial frequency (cpd) to show
%  
% 2003, Alexander Heimel (heimel@brandeis.edu)

if nargin<5
  n_ypixels=800;
end
if nargin<4
  n_xpixels=300;
end
if nargin<3
  highsf=3;
end
if nargin<2
  lowsf=0.05;
end
if nargin<1
  % laptop settings:
  % 1024 pixels in 27 cm at 50 cm viewing distance
  ppd=1024 / 27 * 2 * pi * 50 /360;
end

lowcontrast=10^-4;

x=(1:n_xpixels);
%sfx=logspace(log10(lowsf/ppd) ,log10(highsf/ppd),n_xpixels);
% sf in cycles/pixel
%imx=sin( x .* sfx * 2*pi );
imx=sin( 2*pi*n_xpixels * lowsf/ppd / log(highsf/lowsf) * ...
	 exp( x/n_xpixels*log(highsf/lowsf)));
% correction factor in sine to compensate for the fact that the
% changing sf frequency has an extra effect on the sf of the sine


sfimg=imx(ones(1,n_ypixels),:);
cont=logspace(log10(lowcontrast),0,n_ypixels);
contimg=cont(ones(1,n_xpixels),:)';

img=contimg.*sfimg;

%close all

colormap(gray(2000));
img=floor(2000*(0.5*img+0.5));
image(img)
set(gcf,'Units','pixels');
%set(gcf,'Position',[0 0 n_xpixels n_ypixels]);
pos=get(gcf,'Position');
center=round([pos(1)+pos(3) pos(2)+pos(4)]/2);
set(gcf,'Position',[10 40 ...
		    n_xpixels n_ypixels]);

set(gca,'Units','pixels');
pos=get(gca,'Position');
set(gca,'Position',[0 0 n_xpixels n_ypixels]);
pos=get(gca,'Position');
hold on
axis off


return

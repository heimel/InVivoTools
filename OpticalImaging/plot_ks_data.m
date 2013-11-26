function img=plot_ks_data( data, caption, range)
%PLOT_KS_DATA plots results of Kalatsky-Stryker KS_ANALYSIS function
%
%   PLOT_KS_DATA( DATA, CAPTION )
%
% April 2003, Alexander Heimel, heimel@brandeis.edu
  
if nargin<3
  range=[];
end
  
if nargin<2
  caption='';
else
  caption(find(caption=='_'))='-';
end
  
figure; 

global phases; % debug
phases=angle(data);

subplot(2,2,1)
imagesc(abs(data)');
title('Absolute value (scaled)');
axis off;
subplot(2,2,2)
imagesc(phases');
title('Phase (scaled)');
axis off;


subplot(2,2,3)

if 1 % scaling for visual effect
  disp('Notice: shifting and scaling phase for visual effect');
  centralphase=angle(sum(data(:)));
  %centralphase=angle(data(round(end/2),round(end/2)));
  data=exp(-j*centralphase)*data;
  data=exp(j*0.5)*data;
  data=abs(data).*exp(2*j*angle(data));
end
  
img=angle(data);
imagesc(img');
colormap(hsv(100));
title('Phase (shifted)');
axis off


subplot(2,2,4)
imgt=imagesc_complex(transpose(data),[],'normal',range);
axis off
title('Phase polar plot');
text(-size(data,1)/3,1.2*size(data,2),caption);
hold on

if nargout==1
  img=imgt;
end


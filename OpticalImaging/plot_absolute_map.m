function [c,h]=plot_absolute_map(data1,data2,caption)
%PLOT_ABSOLUTE_MAP combines imaging data from two opposite stimulus directions 
%  
%   PLOT_ABSOLUTE_MAP(DATA1,DATA2,CAPTION)
%       DATA1,DATA2 are output of FOURIER_ANALYSIS function
%       CAPTION is the title for the plot  
%       [C,H] is output of the CONTOUR plot (see HELP CONTOUR)
%  
%  Alexander Heimel, 2003 (heimel@brandeis.edu)
%
  if nargin<3
    caption='';
  else
    caption(find(caption=='_'))='-';
  end

  
  double_phase=1;
  
  if double_phase
    sqrtdata1=data1;
    sqrtdata2=data2;
  else 
    sqrtdata1=sqrt(data1);
    sqrtdata2=sqrt(data2);
  end

  delay=sqrtdata1.*sqrtdata2;
  centerdelay=angle(sum(delay(:)));
  delay=exp(j*centerdelay)*delay;
  
  phase=exp(j*angle(sqrtdata1./sqrtdata2));
  signal=abs(delay);
  phase=phase.*signal;
  
  figure;
  subplot(2,2,1)
  imagesc_complex(transpose(data1));
  axis image off;
  title('Stimulus 1')

  subplot(2,2,2)
  imagesc_complex(transpose(data2));
  axis image off;
  title('Stimulus 2')
  
  subplot(2,2,3)
  if 0
    imagesc(0.5*angle(data1)');
    h=colorbar('horiz');
    set(h,'XTick',[-pi/4,0,pi/4]);
    set(h,'XTickLabel',{'-pi/4 (later)','0','pi/4 (earlier)'});
    hold on; 
  end
  imagesc_complex(transpose(phase));
  axis image off;
  hold on;
  title('Absolute phase');

  
  subplot(2,2,4)
  imagesc_complex(transpose(delay));
  axis image off;
  title('Delay');

  text(-size(data1,1)/3,1.2*size(data1,2),caption);
  hold on

  
  figure % with contourlines
  imagesc_complex(transpose(phase));
  axis image off ;
  hold on;
  title(caption);
  filtersize=[3 3]; % should be odd
  filtersigma=4;
  smoothphase=exp(j*angle(sqrt(data1)./sqrt(data2)));
  smoothphase=conv2( angle(smoothphase)',...
		     gaussian(filtersize,ceil(filtersize/2),filtersigma),...
		     'full');
  [c,h]=contour( smoothphase,8,'k' );
  

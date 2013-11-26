%fit contrast vs spatial frequency from Lu & Roe, Cerebral Cortex, 2007
%
% 2009, Alexander Heimel
%

load('luroe07_fig14.mat')

figure


hold on;
sf=LuRoe07_fig14_c10.x;

for i=1:length(LuRoe07_fig14_contrasts)
  plot(sf,LuRoe07_fig14_all{i}.y);
  
end

  plot(sf,LuRoe07_fig14_all{end}.y*0.49,'r');

  plot(sf,LuRoe07_fig14_all{end}.y*0.25,'r');
  plot(sf,LuRoe07_fig14_all{end}.y*0.15,'r');
set(gca,'Xscale','log');

title('Lu & Roe 2007, fig 14 in blue. Red line is scaled of highest contrast');
bigger_linewidth(3);

xlabel('Spatial frequency (cpd)');
ylabel('Intrinsic signal');
legend(LuRoe07_fig14_contrasts);
disp('At low frequencies, a difference from contrast-invariance is clear');
disp('Not so much at high SF. Perhaps it would have been clearer at an intermediate high SF point');
disp('It could be that the signal is too small at sf=3.36 and what we are seeing is noise');




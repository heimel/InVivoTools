%fit contrast vs spatial frequency from Lu & Roe, Cerebral Cortex, 2007,
%from fig 7c (different from fig14)
%
% 2009, Alexander Heimel
%

load('luroe07_fig7c.mat');
figure;

contrasts=LuRoe07_fig7C.x{1}

hold on
for i=[1 2 4]
  plot(contrasts,LuRoe07_fig7C.y{i});
end
set(gca,'XScale','log');

  plot(contrasts,LuRoe07_fig7C.y{2},'o');

% fitting high
plot(contrasts,LuRoe07_fig7C.y{4}*0.5,'r');
plot([0.01; 0.05; contrasts]*2,[0; 1; LuRoe07_fig7C.y{4}],'g');

%plotting highest sf
plot(contrasts,LuRoe07_fig7C.y{4}*0.25,'r');
plot([0.01; 0.05; contrasts]*4,[0 ;1; LuRoe07_fig7C.y{4}],'g');

title('Lu & Roe, 2007, Fig. 7C');
axis([0.05 1 -1 15]);
xlabel('Contrast');
ylabel('Response');
bigger_linewidth(2);
disp('Based on the data one cannot tell if response scaling or contrast scaling works better');
disp('And the temporal frequency is not fixed between the different spatial freqs as speed was');

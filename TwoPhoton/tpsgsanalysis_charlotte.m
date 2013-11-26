function tpsgsanalysis( resps,data , t, listofcells, listofcellnames, params, process_params, timeint)
%TPSGSANALYSIS analyses twophoton sgs(3d) data
%
%  TPSGSANALYSIS( RESPS )
%
% 2010, Alexander Heimel & Charlotte van Coeverden
%
%

figure;plot (t{1},data{1});
a = find([t{1,:}]>360)
noise=mean(data{1}(a(1),:));
background = resps.spont(1);
screennoise=background-noise;
x = resps.curve(1,:);
y = [resps.indf{1,:}]-noise;

% Create Bar Figure with all data
Fig1 = figure('position',[0 400 600 400]);
bar(x(1:3:end),y(1:3:end),0.3,'r'); hold on;
bar(x(2:3:end),y(2:3:end),0.3,'b');
bar(x(3:3:end),y(3:3:end),0.3,'k');
legend('left','right','both','location','northeast');
z=repmat(screennoise,[1 75]);
plot(z,'c-');

% Make Left,Right and full screen matrix of values obtained and plot in
% scaled colour
LVSM = reshape(y(1:3:end),5,5)-screennoise*0.96;LVSM=LVSM';
RVSM = reshape(y(2:3:end),5,5)-screennoise*0.96;RVSM=RVSM';
FVSM = reshape(y(3:3:end),5,5)-screennoise*0.96;FVSM=FVSM';
mx = max([max(LVSM(:)) max(RVSM(:)) max(FVSM(:))]);
LVSMoptim = LVSM/mx*64;
RVSMoptim = RVSM/mx*64;
FVSMoptim = FVSM/mx*64;
Fig2 = figure('position',[200 200 300 600]);
subplot(3,1,1);
hold on;
image(LVSMoptim);
title('Left stimulus');
axis off;
subplot(3,1,2);
hold on;
image(RVSMoptim);
title('Right stimulus');
axis off;
subplot(3,1,3);
hold on;
image(FVSMoptim);
title('Full stimulus');
axis off;


% Index responses left to right and top to bottom
xa=[-2 -1 0 1 5];
Fig3 = figure('position',[500 200 300 600]);
MeanLeftToRightL = mean(LVSM);
MeanTopToBottomL = mean(LVSM');
MeanLeftToRightR = mean(RVSM);
MeanTopToBottomR = mean(RVSM');
MeanLeftToRightF = mean(FVSM);
MeanTopToBottomF = mean(FVSM');
Fig3LTR = subplot(2,1,1);
axis([-2 2 0 mx]);
hold on;
plot(xa, MeanLeftToRightL,'r',xa,MeanLeftToRightR,'b',xa,MeanLeftToRightF,'k'); 
xlabel('Left to Right');
legend('left','right','both','location','northeast');
Fig3TTB = subplot(2,1,2);
axis([-2 2 0 mx]);
hold on;
plot(xa, MeanTopToBottomL,'r',xa,MeanTopToBottomR,'b',xa,MeanTopToBottomF,'k');
xlabel('Top to Bottom');
legend('left','right','both','location','northeast');

% Make Left,Right and full screen matrix of percentage of total response that is due to the Left or right stimulus plotted in
% scaled colour
PLVSM = LVSM./FVSM*64;
PRVSM = RVSM./FVSM*64;
Fig4 = figure('position',[700 100 800 850]);


F4L = subplot(3,2,1);
image(PLVSM);
axis off;
title('Percentage of total response (left)');
colorbar('ytick',[1 13 26  38 51 64 ],'YTickLabel',{0,20,40,60,80,100});

F4R = subplot(3,2,2);
image(PRVSM);
axis off;
title('Percentage of total response (right)');
colorbar('ytick',[1 13 26  38 51 64 ],'YTickLabel',{0,20,40,60,80,100});


rL=(LVSM-screennoise*0.04)./(LVSM+screennoise*0.04);
rR=(RVSM-screennoise*0.04)./(RVSM+screennoise*0.04);
for i=1:25;
    if rL(i) <= 0;
        rL(i)=0;
    end
    if rR(i) <= 0;
        rR(i)=0;
    end
end
m=1;
rLSc=rL/m*64;
rRSc=rR/m*64;


F4rL = subplot(3,2,3);
image(rLSc);
axis off;
title('Contrast Left (L-bg)/(L+bg) (scaled together)');
colorbar('ytick',[1 9 18 27 37 46 55 64 ],'YTickLabel',{0, (m*1/7), (m*2/7), (m*3/7), (m*4/7), (m*5/7), (m*6/7), (m)});

F4rR = subplot(3,2,4);
image(rRSc);
axis off;
title('Contrast Right (R-bg)/(R+bg) (scaled together)');
colorbar('ytick',[1 9 18 27 37 46 55 64 ],'YTickLabel',{0, (m*1/7), (m*2/7), (m*3/7), (m*4/7), (m*5/7), (m*6/7), (m)}); 

m=max(rL(:));
rLoSc=rL/m*64;
F4scL = subplot(3,2,5);
image(rLoSc);
axis off;
title('Contrast Left (L-bg)/(L+bg) (own scale)');
colorbar('ytick',[1 9 18 27 37 46 55 64 ],'YTickLabel',{0, (m*1/7), (m*2/7), (m*3/7), (m*4/7), (m*5/7), (m*6/7), (m)});

m=max(rR(:));
rRoSc=rR/m*64;
F4scR = subplot(3,2,6);
image(rRoSc);
axis off;
title('Contrast Right (R-bg)/(R+bg)(own scale)');
colorbar('ytick',[1 9 18 27 37 46 55 64 ],'YTickLabel',{0, (m*1/7), (m*2/7), (m*3/7), (m*4/7), (m*5/7), (m*6/7), (m)}); 

% relL=LVSM./RVSM;
% relR=RVSM./LVSM;
% m=max(max(relL(:)), max(relR(:)));
% relL=relL./m*64;
% relR=relR./m*64;
% 
% F4relL = subplot(3,2,5);
% image(relL);
% axis off;
% title('Reliability Left (ratio)');
% colorbar('ytick',[1 9 18 27 37 46 55 64 ],'YTickLabel',{0, round(m*1/7), round(m*2/7), round(m*3/7), round(m*4/7), round(m*5/7), round(m*6/7), round(m)}); 
% 
% F4relR = subplot(3,2,6);
% image(relR);
% axis off;
% title('Reliability Right (ratio)');
% colorbar('ytick',[1 9 18 27 37 46 55 64 ],'YTickLabel',{0, round(m*1/7), round(m*2/7), round(m*3/7), round(m*4/7), round(m*5/7), round(m*6/7), round(m)}); 

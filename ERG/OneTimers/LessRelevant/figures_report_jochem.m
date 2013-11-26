%In this file all plots for my report are constructed. It's in Cell-Mode,
%you can run each block (the stuff that becomes yellow-ish) by pressing
%ctrl-enter. Most can be run in random order but some cells must be
%executed before others. Especially the next one:

%% Loading datapath stuff, run this from OneTimers dir and you're fine
%global ergConfig;
clear;
cd ..;
config_erg;
cd 'OneTimers';
data_erg = [];
%this takes some time but after that you're finee
report_jochem_loadalldata; 
%The scripts output tiff files, insert them in word, crop and set size to 100% in figure properties window
figureoutputdir = 'C:\Documents and Settings\cornelij\Desktop\test\';  
%Figure Constants 
groupnames = {'C57Bl/6J','BALB/c','DBA/2','C3H','GABA'};
dogroups = [1 2 3 4];
colmap = [.5 .5 .5;0 0 0;1 0 1;0 0 0; .2 .2 1; .2 .2 1; 1 0 0; 1 0 0];


%% Methods Fig1 (Blue LED characteristics)
figure(1); subplot1(1,1,'Gap',[0.02 0.02],'FontS',11,'YTickL','Margin','Min',[0.75 0.65],'Max',[1,0.94],'FontS',10); hold off; 
set(gcf,'Position',[100 100 1000 800]);
plot(bx,by,'b','linewidth',3);
ylabel('Relative power','fontsize',10,'VerticalAlign','bottom');
xlabel('Wavelength [nm]','fontsize',10);
title('Blue LED characteristics','fontsize',10);
xlim([410,530]);
print ('-dtiff', '-r300', [figureoutputdir 'figureM1']);
%% Methods Fig2 (equality test)
  figure(1); subplot1(1,1,'Gap',[0.02 0.02],'FontS',11,'YTickL','Margin','Min',[0.65 0.55],'Max',[1,0.94],'FontS',10); hold off; 
  set(gcf,'Position',[100 100 1000 800]);
  tempdata = load([ergConfig.datadir '\20070525 - 07.04.2.02 - Compare - B6\07.04.2.02 - 008 - DATA.mat']) 
  cols = ['b' 'k' 'r'];
  clear p pt;
  p = tempdata.data_saved.results;
  for i = 1:3 pt{i} = (i-1)*30 + [1:30 91:120 181:210]; end
  for i = [2 1 3]
    hold on;
    plot(linspace(-20,120,1401),erg_analysis_avgpulse(-tempdata.data_saved.results(pt{i},800:2200),0),[cols(i)],'linewidth',1) ;
  end
  xlim([-20,120]);
  ylim([-0.1,1.5]);
  ylabel('Response [µv]','fontsize',10,'VerticalAlign','bottom');
  xlabel('Time relative to stimulus onset [ms]','fontsize',10);
  title('Pulse check','fontsize',10);
  print ('-dtiff', '-r300', [figureoutputdir 'figureM2']);

%% Methods Fig2inset (uses data read by previous cell)
  figure(1); subplot1(1,1,'Gap',[0.02 0.02],'FontS',11,'YTickL','Margin','Min',[0.88 0.78],'Max',[1,0.94],'FontS',6); hold off; 
  cols = ['b' 'k' 'r'];
  for i = [2 1 3]
    hold on;
    plot(linspace(-20,120,1401),erg_analysis_avgpulse(-tempdata.data_saved.results(pt{i},800:2200),0),[cols(i)],'linewidth',1) ;
  end
  set(gcf,'Position',[100 100 1000 800]);
  xlim([32.5,38]);
  ylim([1.1,1.41]);
  set(gca,'XTick', [33 34 35 36 37]);
  set(gca,'YTick', [1.2 1.3 1.4]);
  print ('-dtiff', '-r300', [figureoutputdir 'figureM2B']);
%% Methods fig 3
  figure(1); subplot1(1,3,'Gap',[0.05 0.02],'FontS',11,'YTickL','All','XTickL','All','Min',[0.2 0.7],'Max',[1,0.94],'FontS',6); hold off; 
  tempdata1= load([ergConfig.datadir '\20070510 - 07.04.2.01 - Compare - B6\07.04.2.01 - 007 - DATA.mat']);
  tempdata2= load([ergConfig.datadir '\20070510 - 07.04.2.01 - Compare - B6\07.04.2.01 - 005 - DATA.mat']);
  tempdata3= load([ergConfig.datadir '\20070510 - 07.04.2.01 - Compare - B6\07.04.2.01 - 008 - DATA.mat']);
  clear P;
  P{1} = tempdata1.data_saved.results;
  P{2} = tempdata2.data_saved.results;
  P{3} = tempdata3.data_saved.results;
  
  cols = ['k' 'k' 'k']; 
  hold off;
  xl = {'A. Successfully covered','B. Unsuccessfully covered','C. Open'}
  for i = 1:3
    Q = P{i};
    subplot1(i);
    plot(linspace(-20,140,1601),erg_analysis_avgpulse(-Q(1:100,1800:3400),0),cols(i),'linewidth',1); hold on;
    set(gca,'YTick', [-0.2 0 0.2 0.4 0.6 0.8 1]);
    ylim([-0.25,1.1]);
    xlim([-20,140]);
    title(xl{i},'fontsize',10);
  end
  subplot1(1); ylabel('response [µv]','fontsize',10);
  subplot1(2); xlabel('Time from stimulus onset [ms]','fontsize',10);
  print ('-dtiff', '-r300', [figureoutputdir 'figureM3']);
 
%% FIGURE 1 (typical traces for each group)
figure(1); subplot1(1,4,'Gap',[0.02 0.02],'FontS',11,'YTickL','Margin','Min',[0.6 0.4],'Max',[1,0.94],'FontS',10); hold off; 
set(gcf,'Position',[100 100 1000 800]);
plotcounter = 0;
for mouse = [8 3 5 11]
  for exp = 1:1

  plotcounter = plotcounter + 1;  
  plotcounter
  subplot1(plotcounter); 
  
  stims = data_erg(mouse,exp).stims;
  resultset = data_erg(mouse,exp).avgs;
  A = [0 9 10 12 13 16 16 16 14 13]/10;
  for (i = length(A):-1:2)
    A(i) = sum(A(1:i));
  end
    
    i = plot(linspace(-20,130,1501),resultset(:,1800:3300)'-repmat(A,1501,1),'k');
    xlim([-20 130]);
    ylim([-13.2 0.8]);
    title(groupnames{data_erg(mouse,exp).expgroup});
    set(gca,'TickLength',[0 0]);
    
    set(gca,'YTick', []);
    if (plotcounter == 1) 
      set(gca,'YTick', -A(end:-1:1));
      for i = 1:length(stims); st{1+length(stims)-i} = [' ' num2str(stims(i)*ergConfig.convertToCD ,'%6.2g')]; end
      set(gca,'YTickLabel',st); %ergConfig.convertToCD  is coming from CIE_curves
      ylabel('Stimulus intensity [cd*s/m^2]    -    (100µV / div)'); 
    else
      set(gca,'YTick', []);
    end
    if (plotcounter == 1) 
      xlabel('Time relative to stimulus onset [ms]','HorizontalAlignment','left');
    end
   
    %create our own tickmarks on x axis 
    hold on; A = ylim(gca); B=A(1)+(A(2)-A(1))/60; C = get(gca,'XTick'); D = C*0+1;plot([C;C],[D*A(1);D*B],'k'); hold off;
    hold on; A = ylim(gca); B=A(2)-(A(2)-A(1))/60; C = get(gca,'XTick'); D = C*0+1;plot([C;C],[D*A(2);D*B],'k'); hold off;

    %create tickmarks on y axis 
    hold on; A = xlim(gca); B=A(2)-(A(2)-A(1))/20; Q=ylim(gca); C = Q(1)+[1:20]; D = C*0+1;plot([D*A(2);D*B],[C;C],'k'); hold off;
  end
end
print ('-dtiff', '-r300', [figureoutputdir 'figure1']);

%%  figure 2a (a/b wave definition explained)
figure(1); subplot1(1,1,'Gap',[0.02 0.02],'FontS',11,'YTickL','Margin','Min',[0.75 0.45],'Max',[1,0.94],'FontS',10); hold off; 
set(gcf,'Position',[100 100 1000 800]);
mouse = 8;exp=1;run=8;
avgs = data_erg(mouse,exp).avgs*100;
plot(linspace(-20,130,1501),avgs(run,1800:3300),'linewidth',2);
%a = data_erg(mouse,exp).params(3,run)+200;
[ay,ax] = min(avgs(run,1800:3300)); ax = (ax-200)/10;
[by,bx] = max(avgs(run,1800:3300)); bx = (bx-200)/10;
xlim([-20,120]);
XL = xlim(gca);
YL = [-50, 105];
ylim(YL);
hold on;
stimon = 0;
fs = 8;
arrow([ax,ay],[stimon,ay],'ends','both','length',10);
arrow([bx,by],[stimon,by],'ends','both','length',10);
text(stimon+3,ay-1,'a-time','VerticalAlign','top','fontsize',fs);
text(stimon+6,by-1,'b-time','VerticalAlign','top','fontsize',fs);
plot([stimon, stimon],YL,'r');
text(stimon-6,YL(1)+60,'stimulus onset','Rotation',90,'fontsize',fs);
plot(XL,[ay,ay],'k:');
plot(XL,[by,by],'k:');
plot(XL,[0,0],'k:');
arrow([80,0],[80,ay],'ends','both','length',10);
text(80-6,ay+4,'a-amplitude','Rotation',90,'fontsize',fs);
arrow([110,ay],[110,by],'ends','both','length',10);
text(110-6,20,'b-amplitude','Rotation',90,'fontsize',fs);
ylabel('[µv]','fontsize',10,'VerticalAlign','top');
xlabel('Time relative to stimulus onset [ms]','fontsize',10);
title('A. ERG sample trace','fontsize',10);
print ('-dtiff', '-r300', [figureoutputdir 'figure2a']);


%%  figure 2b (a/b bar-graphs inc SEM)
figure(1); subplot1(2,2,'Gap',[0.04 0.1],'FontS',11,'Min',[0.5 0.35],'Max',[1,0.94],'YTickL','All','FontS',8); hold off; 
set(gcf,'Position',[100 100 1000 800]);
titles = {'a-wave amplitude','a-wave implicit time','b-wave amplitude','b-wave implicit time'};
ylabels = {'amplitude [µv]','time [ms]','amplitude [µv]','time [ms]'};
run = 10;
for i = 2:5
  subplot1(i-1);
  count = zeros(10,1);
  temp(1:20,1:20) = NaN;
  for mouse = 1:size(data_erg,1)
    grp = data_erg(mouse,1).expgroup
    if (~isnan(grp))
      count(grp) = count(grp) + 1;
      temp(grp,count(grp)) = 100*(data_erg(mouse,1).params(i,run)+data_erg(mouse,2).params(i,run))/2;
    end
  end
  t{i} = temp;
  if (i == 3 || i == 5) temp(4,:) = 0; end;
  if (i == 3 || i == 5) temp(:,:) = temp(:,:)./1000; end;
  sem = nansem(temp')
  m = abs(nanmean(temp'));
  hs = barweb([dogroups*0; m(dogroups); dogroups*0]',[dogroups*0; sem(dogroups); dogroups*0]',3,{groupnames{dogroups}},titles{i-1},[],ylabels{i-1},colmap);
  h = hs.ca;
  colbars(hs.bars(2), colmap, dogroups);
  set(hs.ylabel,'fontsize',10);
  set(hs.title,'fontsize',10);
  set(h,'fontsize',7);
  set(gca,'XTick',dogroups);
  set(gca,'XTickLabel',{groupnames{dogroups}}); %ergConfig.convertToCD  is coming from CIE_curves
  hold on; A = xlim(gca); B=A(1)+(A(2)-A(1))/60; C = get(gca,'YTick'); D = C*0+1;plot([D*A(1);D*B],[C;C],'k'); hold off;
  if (i==4) ylim(h,[0,99]); end;

  siggroups = {[4], [3], [4], [2]};
  Q = ylim(gca);
  Q = (Q(2)-Q(1))/10;
  hold on; scatter(siggroups{i-1},m(siggroups{i-1})+sem(siggroups{i-1})+Q,20,'k*'); hold off;
  siggroups = {[], [4], [], [4]};
  hold on; scatter(siggroups{i-1},m(siggroups{i-1})+sem(siggroups{i-1})+Q,80,'rx','linewidth',2); hold off;
end
hold off;
gtext('B. Parameter comparison (for response to strongest stimulus)','fontsize',10);
print ('-dtiff', '-r300', [figureoutputdir 'figure2b']);

%% FIGURE 3A (fit plots)
clear log_i50;
figure(1); subplot1(1,4,'Gap',[0.01 0.05],'FontS',11,'Min',[0.2 0.7],'Max',[1,0.94],'YTickL','Margin','XTickL','All','FontS',8); hold off; 
set(gcf,'Position',[-100 -500 1200 1400]);
linestyles = {':' '-' '-.' '--'};
for i = dogroups
  teller = 0;
  subplot1(i); set(gca,'XScale','log'); xlim([0.0020, 30]); ylim([0,200]);
  for mouse = 1:size(data_erg,1)
    for exp = 1:2
      if (data_erg(mouse,exp).expgroup == i)
        if (exp == 1) teller = teller + 1; end
        stims = data_erg(mouse,exp).stims(end-9:end)*ergConfig.convertToCD ;
        bwaveamplitudes = (data_erg(mouse,exp).params(4,end-9:end) - data_erg(mouse,exp).params(2,end-9:end))*100; %a to b wave
        [log_i50(mouse,exp) max_response(mouse,exp) xfit yfit] = erg_analysis_fit(stims, bwaveamplitudes, 500);
        if (max_response(mouse,exp) < 20) log_i50(mouse,exp) = 0; end
        hold on; plot(xfit,yfit,'color',colmap(i*2-1,:),'linestyle',linestyles{teller}); 
        %hold on; scatter(stims,bwaveamplitudes);
      end
    end
  end
  set(gca,'XScale','log'); xlim([0.0020, 30]); ylim([0,220]);
  set(gca,'XTick',[0.0001 0.001 0.01 0.1 1 10 100]);
  title(groupnames{i},'fontsize',10);
  if (i==1) ylabel('b-wave amplitude [µv]','fontsize',10); end
  if (i==1) xlabel('Stimulus intensity [cd*s/m^2]','fontsize',10); end
end
%Since I couldn't decide on a placement method I decided to do manually
gtext('A. Curve fits for b-wave amplitude measurements','fontsize',10,'HorizontalAlign','left');  
print ('-dtiff', '-r300', [figureoutputdir 'figure3a']);

%% FIGURE 3B (fit parameters definition explained)
figure(1); subplot1(1,1,'Gap',[0.04 0.1],'FontS',11,'Min',[0.65 0.55],'Max',[1,0.94],'YTickL','All','FontS',8); hold off; 
set(gcf,'Position',[100 100 800 800]);
mouse = 8;exp=1;
stims = data_erg(mouse,exp).stims*ergConfig.convertToCD ;
bwaveamplitudes = (data_erg(mouse,exp).params(4,:) - data_erg(mouse,exp).params(2,:))*100; %a to b wave
[log_i50 max_response xfit yfit] = erg_analysis_fit(stims, bwaveamplitudes, 500);
semilogx(xfit,yfit,'linewidth',2);
hold on; scatter(stims, bwaveamplitudes,60,'kx','linewidth',2);

index1 = find(xfit>10^log_i50,1);
[dummy,index2] = max(yfit);
xl = xlim(gca);
yl = ylim(gca); %yl(1) = 0; ylim(yl);
arrow([xl(1),yfit(index2)],[xfit(index2),yfit(index2)],'ends','start','length',10,'edgecolor',[1 0 0],'facecolor',[1 0 0]);

fs = 8;
x = xl(1)+(stims(3)-xl(1))/2;
%x = xl(1);xlim(xl);
c = [.5 .5 .5];
arrow([x,yfit(index2)/2],[x,yfit(index2)],'ends','both','length',10,'edgecolor',c,'facecolor',c);
text(x-x/5,3*yfit(index2)/4,'50%','Rotation',90,'fontsize',fs,'HorizontalAlign','center');
plot([xl(1),xfit(index1)],[yfit(index1),yfit(index1)],'k:');
text(xl(1),yfit(index2)+1,'  Maximum Response','VerticalAlign','bottom','fontsize',fs);
arrow([xfit(index1),yl(1)],[xfit(index1),yfit(index1)],'ends','start','length',10,'edgecolor',[1 0 0],'facecolor',[1 0 0]);
text(xfit(index1),yl(1)+5,'  (log)i50%','VerticalAlign','bottom','fontsize',fs,'Rotation',90);
ylabel('b-wave amplitude [µv]','fontsize',10);
xlabel('Stimulus intensity [cd*s/m^2]','fontsize',10);
title('B. Curve fit and parameters','fontsize',10);
print ('-dtiff', '-r300', [figureoutputdir 'figure3b']);
%arrow([x,yl(1)],[x,yfit(index2)/2],'ends','both','length',10,'edgecolor',c,'facecolor',c);
%scatter(xfit(index1),yfit(index1),120,'x','linewidth',3);
%scatter(xfit(index2),yfit(index2),120,'x','linewidth',3);

%% FIGURE 3C
figure(1); subplot1(1,1,'Gap',[0.04 0.1],'FontS',11,'Min',[0.65 0.55],'Max',[1,0.94],'YTickL','All','FontS',8); hold off; 
set(gcf,'Position',[100 100 800 800]);
hold on;
signstyles = {'x' 'o' '*' 'filled'};
for i = dogroups
  teller = 0;
  for mouse = 1:size(data_erg,1)
    for exp = 1:2
      if (data_erg(mouse,exp).expgroup == i)
        if (exp == 1) teller = teller + 1; end
        scatter(log_i50(mouse,exp), max_response(mouse,exp),40,colmap(i*2-1,:),signstyles{teller});
      end
    end
  end
end
xlabel('Log i50','fontsize',10);
ylabel('Max response [µv]','fontsize',10);
title('C. Log-i50 vs Max response','fontsize',10);  
print ('-dtiff', '-r300', [figureoutputdir 'figure3c']);

%% FIGURE 3C - PER MOUSE
figure(1); subplot1(1,1,'Gap',[0.04 0.1],'FontS',11,'Min',[0.65 0.55],'Max',[1,0.94],'YTickL','All','FontS',8); hold off; 
set(gcf,'Position',[100 100 800 800]);
hold on;
mr = ones(20,20)*NaN;
li = ones(20,20)*NaN;
for i = dogroups
  teller = 0;
  for mouse = 1:size(data_erg,1)
    if (data_erg(mouse,exp).expgroup == i)
      teller = teller + 1; 
      mr(i,teller) = (max_response(mouse,1)+max_response(mouse,2))/2;
      li(i,teller) = (log_i50(mouse,1)+log_i50(mouse,2))/2;
      scatter(li(i,teller), mr(i,teller),40,colmap(i*2-1,:),'*');
    end
  end
end
xlabel('Log i50','fontsize',10);
ylabel('Max response [µv]','fontsize',10);
title('C. Log-i50 vs Max response','fontsize',10);  
print ('-dtiff', '-r300', [figureoutputdir 'figure3c']);


%% FIGURE 3D - BAR-plots fit-parameters
figure(1); hold off; subplot1(1,2,'Gap',[0.07 0.05],'FontS',11,'Min',[0.15 0.6],'Max',[1,0.94],'YTickL','All','XTickL','All','FontS',8); hold off; 
hold on;
set(gcf,'Position',[-100 -500 1200 1400]);
togo={mr li};
titles={'Average maximum response','Average log-i50'};
ylabels={'Max response [µv]','Log i50'};

for i=1:2
  subplot1(i);
  mx = togo{i};
  sem = nansem(mx')
  m = abs(nanmean(mx'))
  
  hs = barweb([dogroups*0; m(dogroups); dogroups*0]',[dogroups*0; sem(dogroups); dogroups*0]',3,{groupnames{dogroups}},titles{i},[],ylabels{i},colmap);
  h = hs.ca;
  colbars(hs.bars(2), colmap, dogroups);
  set(hs.ylabel,'fontsize',10);
  set(hs.title,'fontsize',10);
  set(h,'fontsize',7);
  set(gca,'XTick',dogroups);
  set(gca,'XTickLabel',{groupnames{dogroups}}); %ergConfig.convertToCD  is coming from CIE_curves
  hold on; A = xlim(gca); B=A(1)+(A(2)-A(1))/60; C = get(gca,'YTick'); D = C*0+1;plot([D*A(1);D*B],[C;C],'k'); hold off;
  if (i==4) ylim(h,[0,99]); end;

  siggroups = {[3 4], [2]};
  Q = ylim(gca);
  Q = (Q(2)-Q(1))/10;
  hold on; scatter(siggroups{i},m(siggroups{i})+sem(siggroups{i})+Q,20,'k*'); hold off;
  siggroups = {[], [4]};
  hold on; scatter(siggroups{i},m(siggroups{i})+sem(siggroups{i})+Q,80,'rx','linewidth',2); hold off;
end
gtext('D. Maximum response and log-i50 compared between strains','fontsize',10,'HorizontalAlign','left');  
print ('-dtiff', '-r300', [figureoutputdir 'figure3d']);

%% Figure 4A - OPs
figure(1); subplot1(1,4,'Gap',[0.05 0.02],'FontS',11,'YTickL','All','Min',[0.15 0.65],'Max',[1,0.94],'FontS',10); hold off; 
set(gcf,'Position',[100 100 1000 800]);
mouse = 8;exp=1;run=3;
subplot1(1);
plot(data_erg(mouse,exp).OPx{run},data_erg(mouse,exp).OPy{run},'linewidth',2,'color',[0 0 0.7]);
ylim([-0.3 0.3]);
set(gca,'fontsize',7);
xlabel('Time [ms]^ ','fontsize',10);
ylabel('Response [µv]','fontsize',10);
title('A. Example OP','fontsize',10);  

% Figure 4B
subplot1(2);
plot(data_erg(mouse,exp).FFTx{run},data_erg(mouse,exp).FFTy{run},'linewidth',2,'color',[0.7 0 0]);
hold on; plot([75 75], ylim(),'k:');plot([110 110], ylim(),'k:');
plot(data_erg(mouse,exp).FFTx{run},data_erg(mouse,exp).FFTy{run},'linewidth',2,'color',[0.7 0 0]); %yes it's the same, I want it to go over the dotted lines but the first is needed to set ylim
set(gca,'YTick',[]);
set(gca,'fontsize',7);
xlabel('Frequency [Hz]^ ','fontsize',10);
title('B. OP Spectrum','fontsize',10);  

% Figure 4C
%figure(1); subplot1(1,2,'Gap',[0.06 0.02],'FontS',11,'YTickL','Margin','Min',[0.55 0.55],'Max',[1,0.94],'FontS',10); hold off; 
%set(gcf,'Position',[100 100 1000 800]);
%prepare ratioz
for i = dogroups; ratioz{i} = []; end
for run = 1:10
  for i = dogroups
    teller = 0;
    for mouse = 1:size(data_erg,1)
      if (data_erg(mouse,exp).expgroup == i)
        teller = teller + 1; 
        p1 = data_erg(mouse,1).OPparam(run)
        p2 = data_erg(mouse,2).OPparam(run)
        ratio = ratioz{i};
        ratio(teller,run) = (p1.f110/p1.f75+p2.f110/p2.f75)/2;
        if (ratio(teller,run) > 6) ratio(teller,run) = NaN; end %remove outliers (3 in this case)
        ratioz{i} = ratio;
        stimz{i} = data_erg(mouse,2).stims;
      end
    end
  end
end

% Plot ratioz
run = 10;
subplot1(3);
set(gca,'YTickMode','auto');
set(gca,'XScale','log'); xlim([0.0020, 30]); 
set(gca,'XTick',[0.01 0.1 1 10]);
set(gca,'XTickLabel',[0.01 0.1 1 10]);
set(gca,'fontsize',7);

r1 = ones(20,20)*NaN;
for i = dogroups
  r = ratioz{i};
  hold on; plot(stimz{i}*ergConfig.convertToCD ,nanmean(r),'color',colmap(i*2-1,:),'linewidth',2);
  ri = r';  
  r1(i,1:size(ri,2)) = ri(run,:);
end
plot(xlim(),[1 1],'k--');
xlabel('Intensity [cd*s/m^2]','fontsize',10,'verticalalign','top');
ylabel('110 / 75 ratio','fontsize',10);
title('C. All ratios','fontsize',10)
set(gca,'XMinorTick','off');

% bargraphs
% Figure 4D
subplot1(4);
titles = {'D. Max intensity ratio'};
ylabels = {''};%{'110 / 75 ratio'};
for i = 1
  m = nanmean(r1');
  sem = nansem(r1');
  hs = barweb([dogroups*0; m(dogroups); dogroups*0]',[dogroups*0; sem(dogroups); dogroups*0]',3,{groupnames{dogroups}},titles{i},[],ylabels{i},colmap);
  h = hs.ca;
  colbars(hs.bars(2), colmap, dogroups);
  set(hs.ylabel,'fontsize',10);
  set(hs.title,'fontsize',10);
  set(h,'fontsize',6);
  set(gca,'XTick',dogroups);
  set(gca,'XTickLabel',{groupnames{dogroups} }); %ergConfig.convertToCD  is coming from CIE_curves
  hold on; A = xlim(gca); B=A(1)+(A(2)-A(1))/60; C = get(gca,'YTick'); D = C*0+1;plot([D*A(1);D*B],[C;C],'k'); hold off;

  siggroups = {[2]};
  Q = ylim(gca);
  Q = (Q(2)-Q(1))/10;
  hold on; scatter(siggroups{i},m(siggroups{i})+sem(siggroups{i})+Q,20,'k*'); hold off;
  siggroups = {[], [4]};
  hold on; scatter(siggroups{i},m(siggroups{i})+sem(siggroups{i})+Q,80,'rx','linewidth',2); hold off;
  xlabel('Mouse strain^ ','fontsize',10);
end
print ('-dtiff', '-r300', [figureoutputdir 'figure4']);


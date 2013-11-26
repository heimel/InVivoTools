global calib ergconfig;

clear H;
data_erg = []; g = []; new = []; res = [];

group = 'g1'; 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070510 - 07.04.2.01 - Compare - B6\07.04.2.01 - 010 - DATA.mat'; %pulsetrain - B_TR :: Eerste Blue Train (bergvorm)
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070510 - 07.04.2.01 - Compare - B6\07.04.2.01 - 012 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070510 - 07.04.2.01 - Compare - B6\07.04.2.01 - 016 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070510 - 07.04.2.01 - Compare - B6\07.04.2.01 - 023 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070510 - 07.04.2.01 - Compare - B6\07.04.2.01 - 027 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g2'; 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070511 - 07.04.3.01 - Compare - BALBc\07.04.3.01 - 010 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070511 - 07.04.3.01 - Compare - BALBc\07.04.3.01 - 015 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070511 - 07.04.3.01 - Compare - BALBc\07.04.3.01 - 019 - DATA.mat'; %pulsetrain - B_TR :: IPSIEYE; Niet compleet want ik moest dwijlen
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070511 - 07.04.3.01 - Compare - BALBc\07.04.3.01 - 022 - DATA.mat'; %pulsetrain - B_TR :: IPSIEYE
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070511 - 07.04.3.01 - Compare - BALBc\07.04.3.01 - 025 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070511 - 07.04.3.01 - Compare - BALBc\07.04.3.01 - 026 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g3'; 
%try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070514 - 07.04.3.02 - Compare - BALBc\07.04.3.02 - 006 - DATA.mat'; %pulsetrain - B_TR :: Eye Opaque
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070514 - 07.04.3.02 - Compare - BALBc\07.04.3.02 - 007 - DATA.mat'; %pulsetrain - B_TR :: Methocel, Eye rest closed, then this run (terrible noise though)
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070514 - 07.04.3.02 - Compare - BALBc\07.04.3.02 - 008 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070514 - 07.04.3.02 - Compare - BALBc\07.04.3.02 - 012 - DATA.mat'; %pulsetrain - B_TR :: IPSI: Slede stond niet goed!!!
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070514 - 07.04.3.02 - Compare - BALBc\07.04.3.02 - 013 - DATA.mat'; %pulsetrain - B_TR :: IPSI
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070514 - 07.04.3.02 - Compare - BALBc\07.04.3.02 - 014 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070514 - 07.04.3.02 - Compare - BALBc\07.04.3.02 - 015 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g4'; 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070515 - 07.04.3.03 - Compare - BALBc\07.04.3.03 - 003 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070515 - 07.04.3.03 - Compare - BALBc\07.04.3.03 - 004 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070515 - 07.04.3.03 - Compare - BALBc\07.04.3.03 - 005 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070515 - 07.04.3.03 - Compare - BALBc\07.04.3.03 - 008 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070515 - 07.04.3.03 - Compare - BALBc\07.04.3.03 - 009 - DATA.mat'; %pulsetrain - B_TR :: (semiDA)
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070515 - 07.04.3.03 - Compare - BALBc\07.04.3.03 - 010 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070515 - 07.04.3.03 - Compare - BALBc\07.04.3.03 - 011 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070515 - 07.04.3.03 - Compare - BALBc\07.04.3.03 - 012 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g5'; 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070524 - 07.04.3.04 - Compare - DBA2\07.04.3.04 - 009 - DATA.mat'; %pulsetrain - B_TR :: Some ring around the eye
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070524 - 07.04.3.04 - Compare - DBA2\07.04.3.04 - 010 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g6'; 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070525 - 07.04.2.02 - Compare - B6\07.04.2.02 - 009 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070525 - 07.04.2.02 - Compare - B6\07.04.2.02 - 010 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070525 - 07.04.2.02 - Compare - B6\07.04.2.02 - 011 - DATA.mat'; %pulsetrain - B_TR :: GAIN AT x1000
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070525 - 07.04.2.02 - Compare - B6\07.04.2.02 - 013 - DATA.mat'; %pulsetrain - B_TR :: Mouse had some trouble breathing (gedweild afterwards)
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070525 - 07.04.2.02 - Compare - B6\07.04.2.02 - 014 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g7'; 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070529 - 07.04.3.05 - Compare - DBA2\07.04.3.05 - 007 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070529 - 07.04.3.05 - Compare - DBA2\07.04.3.05 - 008 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070529 - 07.04.3.05 - Compare - DBA2\07.04.3.05 - 009 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g8'; 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070530 - 07.04.2.03 - Compare - B6\07.04.2.03 - 007 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070530 - 07.04.2.03 - Compare - B6\07.04.2.03 - 008 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g9'; 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070608 - 07.04.3.06 - Compare - DBA2\07.04.3.06 - 004 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070608 - 07.04.3.06 - Compare - DBA2\07.04.3.06 - 005 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070608 - 07.04.3.06 - Compare - DBA2\07.04.3.06 - 007 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070608 - 07.04.3.06 - Compare - DBA2\07.04.3.06 - 008 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070608 - 07.04.3.06 - Compare - DBA2\07.04.3.06 - 009 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g10'; 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070607 - 07.04.3.07 - Compare - C3H\07.04.3.07 - 004 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070607 - 07.04.3.07 - Compare - C3H\07.04.3.07 - 005 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g11'; 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070611 - 07.04.3.08 - Compare - C3H\07.04.3.08 - 003 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070611 - 07.04.3.08 - Compare - C3H\07.04.3.08 - 004 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070611 - 07.04.3.08 - Compare - C3H\07.04.3.08 - 005 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g12'; 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070622 - 07.04.2.04 - Compare - B6\07.04.2.04 - 007 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070622 - 07.04.2.04 - Compare - B6\07.04.2.04 - 008 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g13'; 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070627 - 07.04.3.09 - Compare - GABA\07.04.3.09 - 007 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070627 - 07.04.3.09 - Compare - GABA\07.04.3.09 - 008 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070627 - 07.04.3.09 - Compare - GABA\07.04.3.09 - 013 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g14'; 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070629 - 06.35.2.23 - Compare - GABA\06.35.2.23 - 014 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070629 - 06.35.2.23 - Compare - GABA\06.35.2.23 - 016 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g15';
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070726 - 07.04.2.06 - Compare - B6\07.04.2.06 - 005 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070726 - 07.04.2.06 - Compare - B6\07.04.2.06 - 006 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 0;

group = 'g16';
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070727 - 07.04.3.10 - Compare - DBA2\07.04.3.10 - 007 - DATA.mat'; %pulsetrain - B_TR :: 
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070727 - 07.04.3.10 - Compare - DBA2\07.04.3.10 - 008 - DATA.mat'; %pulsetrain - B_TR :: 
new.(group) = 1;

group = 'g17';
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070810 - 07.04.3.11 - Compare - GABA\07.04.3.11 - 004 - DATA.mat'; %pulsetrain - B_TR :: 2Analyse
try nr = length(g.(group))+1; catch nr = 1; end; g.(group){nr} = 'C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070810 - 07.04.3.11 - Compare - GABA\07.04.3.11 - 005 - DATA.mat'; %pulsetrain - B_TR :: 2Analyse
new.(group) = 1;

nGroup = 17;

%1 = B6, 2 = BalbC, 3 = DBA2, 4 = C3H, 5 = GABA

exp.g1 = 1;
exp.g2 = 2;
exp.g3 = 2;
exp.g4 = 2;
exp.g5 = 3;
exp.g6 = 1;
exp.g7 = 3;
exp.g8 = 1;
exp.g9 = 3;
exp.g10 = 4;
exp.g11 = 4;
exp.g12 = 1;
exp.g13 = NaN; %Retyped as not GABA (GABA)
exp.g14 = 5;
exp.g15 = NaN; %Done by Alexander (B6)
exp.g16 = 3;
exp.g17 = 5;

for j = 1:nGroup
  group = ['g' num2str(j)];
  if (size(data_erg,1)<j)
    for i = 1:min(2,length(g.(group)))
      g.(group){i} 

      load(g.(group){i},'data_saved');
      [resultset nRemoved baseline awave atime bwave btime prepulse_samples stims] = erg_analysis_basics(data_saved);
      data_erg(j,i).stims = [stims];
      data_erg(j,i).params = [baseline; awave; atime; bwave; btime];
      data_erg(j,i).expgroup = exp.(group);
%      data_erg(j,i).raw = data_saved.results(:,2000:3000);
      data_erg(j,i).avgs = [resultset];
    end
  end
end

%return;

clear saveDf res_time res_ampl numpeaks energy;
colors='bgrcmyk';
j = 0;
for mouse = 1:size(data_erg,1) for exp = 1:2
  i = 0; j=j+1;
  data_erg(mouse,exp).OPx = {};  data_erg(mouse,exp).OPy = {};
  data_erg(mouse,exp).FFTx = {};  data_erg(mouse,exp).FFTy = {};
for s = 1:10
  i = i + 1; 
  fiscalebijtelling = size(data_erg(mouse,exp).avgs,1)-10;
  D = data_erg(mouse,exp).avgs(s+fiscalebijtelling,2000:3000); 
  versch = 20;
 
  totsamples = size(D);
  hsr = 10000/2;
  [B1, B2] = butter(5,[65/hsr,300/hsr]);
  Df = filtfilt(B1, B2,D);

  NFFT = 2^nextpow2(length(D))*16; % Next power of 2 from length of y
  Df_fft = fft(Df,NFFT)/length(Df);
  Fs = 10000;
  f = Fs/2*linspace(0,1,NFFT/2);
  lala = round((NFFT/10000)*300);
  Y =2*abs(Df_fft(1:lala));
  X = f(1:lala);
  
  [dummyY, dummyX] = max(2*abs(Df_fft(1:lala)));
  f110(i) = 2*abs(Df_fft(round((NFFT/10000)*110)));
  f75(i) = 2*abs(Df_fft(round((NFFT/10000)*75)));
  fpow(i) = opp(f,2*abs(Df_fft)); 
  fmax(i) = f(dummyX); 

  data_erg(mouse,exp).OPparam(i).f110 = f110(i);
  data_erg(mouse,exp).OPparam(i).f75 = f75(i);
  data_erg(mouse,exp).OPparam(i).fpow = fpow(i);
  data_erg(mouse,exp).OPparam(i).fmax = fmax(i);
  data_erg(mouse,exp).FFTx{i} = X;
  data_erg(mouse,exp).FFTy{i} = Y;
  data_erg(mouse,exp).OPx{i} = linspace(0,100,length(Df));
  data_erg(mouse,exp).OPy{i} = Df;
  data_erg(mouse,exp).stim = stims(end-9:end);
end 
end
end

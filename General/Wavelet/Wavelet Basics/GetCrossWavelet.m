function [Cross Auto1 Auto2 frq] = GetCrossWavelet(Data1, Data2, Fs)
% Calculates coherence and phase functions using Morlet wavelet between two
% signals
%
% Inputs:
% Data1 and Data2 : Data in (samples x channels x trials)
% Fs : sampling frequency
%
% Outputs:
% AChn in (frequencies x samples x channels)
% frq gives the array of calculated frequencies in Hz
%
%
% see for a plot example at the end

NSa=size(Data1,1);    % number of samples per trial
NCh=size(Data1,2);    % number of channels
NTr=size(Data1,3);    % number of trials

%Subtract ERP and 50Hz artifact
[Data1] = sinefit50(Data1,Fs); 
[Data2] = sinefit50(Data2,Fs); 

%Initiation of parameters, you only have to do this once
Datatemp = rand(NSa, 1);
[~,frq,filter]=gaborspace(Datatemp, [5,floor(NSa/3),50],1,3);
Ffilter=fourier_embed(filter, length(Datatemp));
frq=frq*Fs; %from units in samples to units in Hz

% Calculation of coherence function
[Cross Auto1 Auto2] =  hdfwaveCoh(S, Data1, Data2, Ffilter); 


% %first take the mean before taking the 'abs' or 'angle'
% TCross=mean(Cross,3);
% TAuto1=mean(Auto1,3);
% TAuto2=mean(Auto2,3);
% Coherence=abs(mean(TCross,3)).^2./(mean(TAuto1,3).*mean(TAuto2,3));
% Phase=angle(mean(TCross,3));

% Surface plot of Coherence over time
% bg = round(Fs*0.2);  %from 0.1 - 0.3 after stim oNSaet
% ed = round(Fs*0.9)-1;
% Xas=(bg:ed)/Fs-0.3;
% figure; surf(Xas(:),Fs*frq,mean(Coherence(:,bg:ed,:),3,'EdgeColor','none')
% xlabel('Time from stimulus onset (ms)');
% set(gca, 'yscale', 'log', 'ytick', [5.0 10.0 25.0 50.0 100.0 150.0])
% ylabel('Frequencies (Hz)');
% set(gca,'FontSize',22);
% axis tight; axis square; view(0,90);
% % shading interp

% Line plot of Coherence in modulation period
% bgm = round(Fs*0.6);  %from 0.3 - 0.6 after stim onset
% edm = round(Fs*0.9)-1;
% figure; plot(frq,squeeze(mean(mean(Coherence(:,bgm:edm,:),3),2))')
% xlabel('Frequencies (Hz)');
% set(gca, 'xscale', 'log', 'xtick', [5.0 10.0 25.0 50.0 100.0 150.0])
% ylabel('Coherence');
% set(gca,'FontSize',22);
% axis tight; axis square; box off;
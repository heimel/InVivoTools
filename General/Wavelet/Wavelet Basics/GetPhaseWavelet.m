function [Phase frq] = GetPhaseWavelet(Data, Fs)
% Calculates phase spectral density using Morlet wavelet
%
% Inputs:
% Data : Data in (samples x channels x trials)
% Fs : sampling frequency
%
% Outputs:
% Phase in (frequencies x samples x channels)
% frq gives the array of calculated frequencies in Hz
%
% see for a plot example at the end

NSa=size(Data,1);    % number of samples per trial
NCh=size(Data,2);    % number of channels
NTr=size(Data,3);    % number of trials

[Data] = sinefit50(Data,Fs); %Subtract ERP and 50Hz artifact

%Initiation of parameters, you only have to do this once
Datatemp = rand(NSa, 1);
[~,frq,filter]=gaborspace(Datatemp, [5,floor(NSa/3),50],1,3);
Ffilter=fourier_embed(filter, length(Datatemp));
frq=frq*Fs; %from units in samples to units in Hz

% Calculation of spectral measures using Morlet wavelets
[Phase] =  hdfwavePower(Data, Ffilter); 


% TPhase= mean(Phase,3); %mean over channels

% Surface plot of LFP phase over time
% bg = round(Fs*0.2);  %from 0.1 - 0.3 after stim oNSaet
% ed = round(Fs*0.9)-1;
% Xas=(bg:ed)/Fs-0.3;
% figure; surf(Xas(:),Fs*frq,mean(TPhase(:,bg:ed,:),3,'EdgeColor','none')
% xlabel('Time from stimulus oNSaet (ms)');
% set(gca, 'yscale', 'log', 'ytick', [5.0 10.0 25.0 50.0 100.0 150.0])
% ylabel('Frequencies (Hz)');
% set(gca,'FontSize',22);
% axis tight; axis square; view(0,90);
% % shading interp

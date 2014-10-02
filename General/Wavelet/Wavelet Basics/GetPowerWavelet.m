function [AChn,frq,t] = GetPowerWavelet(Data, Fs, onsettime, verbose)
% Calculates power spectral density using Morlet wavelet
%
% Inputs:
% Data : Data in (samples x channels x trials)
% Fs : sampling frequency
%
% Outputs:
% AChn in (frequencies x samples x channels)
% frq gives the vector of calculated frequencies in Hz
% t gives the vector of sample times
%
% see for a plot example at the end
%
% Timo van Kerkoerle
% 2012-2013, modified by Alexander Heimel
%

persistent persistent_Fs sizeData Ffilter persistent_frq

if nargin<3
    onsettime = [];
end
if isempty(onsettime)
    onsettime = 0;
end

if nargin<4
    verbose = [];
end
if isempty(verbose)
    verbose = false;
end


if ~isempty(persistent_Fs) && persistent_Fs==Fs && all(sizeData==size(Data))
    compute_filters = false;
else
    compute_filters = true;
end


if compute_filters
    params = ecprocessparams;
    
    sizeData = size(Data);
    
    NSa=size(Data,1);    % number of samples per trial
    %NCh=size(Data,2);    % number of channels
    %NTr=size(Data,3);    % number of trials
    
    %Initiation of parameters, you only have to do this once
    F1= max(params.vep_wavelet_freq_low,Fs/NSa*3); % lowest frequency, adhoc limit
    W1=round(Fs/F1);%max wavelength
    
    FF = params.vep_wavelet_freq_high; % Highest frequency
    WF = round(Fs/FF); % min wavelength
    Fr = params.vep_wavelet_freq_res; % Frequency resolution
    
    %[GS,freqs,filter]=gaborspace(S,scls,alpha,beta,req)

    [alaki,frq,filter]=gaborspace(rand(NSa, 1), [WF, W1, Fr],1,3); %#ok<ASGLU> %make filters
    Ffilter=fourier_embed(filter, NSa); %filters in fourier space
    
    persistent_frq = frq*Fs; %from units in samples to units in Hz
    persistent_Fs = Fs;
    
   
end

    % Calculation of spectral measures using Morlet wavelets

[AChn] =  hdfwavePower(Data, Ffilter);
frq = persistent_frq;

TAChn = mean(AChn,3); %mean over channels

t = (1:size(TAChn,2))/Fs - onsettime;

% Surface plot of LFP power over time
if verbose>1
    figure;
    surf(t,frq,mean(TAChn,3),'EdgeColor','none')
    xlabel('Time from stimulus onset (s)');
    set(gca, 'yscale', 'log', 'ytick', [5.0 10.0 25.0 50.0 100.0 150.0])
    ylabel('Frequencies (Hz)');
    set(gca,'FontSize',22);
    axis tight; axis square; view(0,90);
    % shading interp
    
    % Line plot of LFP power in modulation period
    bgm = round(Fs*(onsettime+0.050));  %from 50 ms after stim onset
    edm = round(Fs*(onsettime+1))-1; % to 1s after onset
    figure;
    plot(frq,squeeze(mean(mean(TAChn(:,bgm:edm,:),3),2))')
    xlabel('Frequencies (Hz)');
    set(gca, 'xscale', 'log', 'xtick', [5.0 10.0 25.0 50.0 100.0 150.0])
    ylabel('LFP Power');
    set(gca,'FontSize',22);
    axis tight; axis square; box off;
end


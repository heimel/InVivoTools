function [Data,line2data] = remove_line_noise(Data,Fs,Fl)
%REMOVE_LINE_NOISE: Subtracts line noise artifact
%
%  DATA = REMOVE_LINE_NOISE( DATA, FS, [FL] )
%
% Inputs:
%    DATA : Data in (samples x channels x trials)
%    FS : sampling frequency
%    FL : optional line noise frequency,in Europe 50 Hz, in US 60 Hz
%
% Output:
%    DATA: original with sine fit of line noise removed.
%
% 2012 Alexander Heimel, modified from Timo Kerkoerle

verbose = false;


if nargin<3
    Fl=50; % Hz  
end

if numel(Data)==length(Data)
    Data=Data(:);
end

% % taking only part of the data
% Data = Data(1: fix(0.5 * Fs));

NSa=size(Data,1);
NCh=size(Data,2);
NTr=size(Data,3);



% reference: Local Field Potential in Cortical Area MT: Stimulus Tuning and Behavioral Correlations
%Jing Liu and William T. Newsome 


% subtract DC
if 0
    for ch=1:NCh
        for k=1:NTr
            Data(:,ch,k) = Data(:,ch,k)-mean(Data(:,ch,k));
        end
    end
end

% h = adaptfilt.lms(15,0.00007);


if verbose
    
    figure;
    hold on;
    nsamples = fix(0.5 * Fs); % 0.5 s
    plot( (1:nsamples)/Fs,Data(1:nsamples))
end

% routine could be sped up a lot by calculating complex sin outside loops
omega=[0:NSa-1]/Fs * 2*pi * Fl  ;
for h = 1:3  % number of harmonics to remove
    for ch=1:NCh
        for k=1:NTr
            
           [Ahat,ThetaData] = sinefit2(Data(:,ch,k)',2*pi*Fl*h,0,1/Fs);
            Data(:,ch,k) = Data(:,ch,k)-(Ahat*sin(omega*h+ThetaData))';
            
%             [y,e] = filter(h,Ahat*sin(omega*h+ThetaData),Data(:,ch,k));

        end
    end % ch
end % h

if verbose
%    plot( (1:nsamples)/Fs,Ahat*sin(2*pi*(1:nsamples)/Fs*Fl+ThetaData),'k' )
%    plot( (1:nsamples)/Fs,std(Data(1:nsamples)) *sin(2*pi*(1:nsamples)/Fs*Fl+ThetaData),'k' )
    plot((1:nsamples)/Fs,Data(1:nsamples),'r')
end

line2data = abs(Ahat)./std(Data);

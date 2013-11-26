% erg_getdata_ops: Calculates ops for a given filename, calls
% erg_getdata_avg and erg_getdata_div in order to do this. Saves/loads 
% cache file depending on ergConfig.getdata_cache_load_ops and  
% ergConfig.getdata_cache_save_ops.
%
% This file works on a multi-channel basis: each channel results will be 
% saved in another entry in channel_ops. This is a cell containing a struct
% per channel. The struct contains all parameters.

function [channel_ops] = erg_getdata_ops(filename)

global ergConfig;

%check if a cache version is available..
cache_filename = [filename(1:end-8) 'CACHE_OPS.mat'];
if (ergConfig.getdata_cache_load_ops && exist(cache_filename,'file'))
  load(cache_filename);
  return;
end

[channel_avg stims prepulse_samples] = erg_getdata_avg(filename, 1);
[block duration stimuli] = erg_getdata_div(filename);

for chan = 1:block.numchannels
  i = 0; 
  ops.OPx = {};  ops.OPy = {};
  ops.FFTx = {};  ops.FFTy = {};
  avg = channel_avg{chan};
  
  for s = 1:10
    i = i + 1; 
    D = avg.resultset(s,prepulse_samples:prepulse_samples+1000); 
    versch = 20;

    totsamples = size(D);
    hsr = 10000/2;
    [B1, B2] = butter(5,[65/hsr,300/hsr]);
    Df = filtfilt(B1, B2,D); %or just filter(B1,B2,D)?? 

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

    ops.OPparam(i).f110 = f110(i);
    ops.OPparam(i).f75 = f75(i);
    ops.OPparam(i).fpow = fpow(i);
    ops.OPparam(i).fmax = fmax(i);
    ops.FFTx{i} = X;
    ops.FFTy{i} = Y;
    ops.OPx{i} = linspace(0,100,length(Df));
    ops.OPy{i} = Df;
  end  
  channel_ops{chan} = ops;
end;

%Save cache, depending on config setting
if (ergConfig.getdata_cache_save_ops)
  save(cache_filename,'channel_ops');
end

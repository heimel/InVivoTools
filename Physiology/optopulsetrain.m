function [wave, time] = optopulsetrain(sample_rate,delay_duration,prepulse_duration,pulse_duration,postpulse_duration,pulse_freq,n_repeats,high,low,min_samples )
%OPTOPULSETRAIN returns data to send to analogoutput to send to an optogenetic stimulator
%
%   [wave,time] = optopulsetrain(sample_rate,delay_duration,prepulse_duration,...
%             pulse_duration,postpulse_duration [=0],pulse_freq [=0],...
%             n_repeats [=1],high [=3.3],low [=0],min_samples [=1024] )
%
% 2019, Alexander Heimel

if nargin<10 || isempty(min_samples)
    min_samples = 1024; % required for some NI boards
end
if nargin<9 || isempty(low)
    low = 0; % V
end
if nargin<8 || isempty(high)
    high = 3.3; % V
end
if nargin<7 || isempty(n_repeats)
    n_repeats = 1;
end
if nargin<6 || isempty(pulse_freq)
    pulse_freq = 0;
end
if nargin<5 || isempty(postpulse_duration)
    postpulse_duration = 0; %s
end

if delay_duration * sample_rate ~= round(delay_duration * sample_rate) || ...
        prepulse_duration * sample_rate ~= round(prepulse_duration * sample_rate)   || ...
        pulse_duration * sample_rate ~= round(pulse_duration * sample_rate) || ...
        pulse_duration * pulse_freq ~= round(pulse_duration * pulse_freq) 
    logmsg('Sample rate and pulse parameters are not exactly compatible'); 
end

if sample_rate / pulse_freq ~= round(sample_rate / pulse_freq)
    logmsg('Sample rate and pulse frequency are not exactly compatible');
end
    

delay_pulse = low*ones(round(delay_duration*sample_rate),1);
pre_pulse = low*ones(round(prepulse_duration*sample_rate),1);
if pulse_freq>0
    n_pulses = round(pulse_duration * pulse_freq);
    onepulse = low*ones(round(sample_rate / pulse_freq),1);
    onepulse(1:round(sample_rate / pulse_freq / 2)) = high;
    pulsetrain = repmat(onepulse,n_pulses,1);
else
    pulsetrain = high*ones(round(pulse_duration*sample_rate),1);
end
post_pulse = low*ones(round(postpulse_duration*sample_rate),1);
pulse = [pre_pulse;pulsetrain;post_pulse];
wave = [delay_pulse; repmat(pulse,n_repeats,1); low];

if length(wave)<min_samples % minimally 1024 samples required
    wave(end+1:min_samples) = low; % padding to required length
end

time = (0:length(wave)-1)/sample_rate;

if nargout==0
    figure
    plot(time,wave);
    xlabel('Time (s)');
    ylabel('Pulse (V)');
end



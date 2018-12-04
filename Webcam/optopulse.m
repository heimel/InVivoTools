function optopulse( duration, frequency)
%OPTOPULSE wrapper around calling optopulse.c
%   should become mex file
%
%  OPTOPULSE( DURATION=60, FREQUENCY=20)
%        DURATION in seconds
%        FREQUENCY in Hz
%    Use DURATION = 0 to kill previous optopulse
%   
%   2018, Alexander Heimel
%

if nargin<1 || isempty(duration)
    duration = 60;
end
if nargin<2 || isempty(frequency)
    frequency = 20;
end

if duration==0
    system('pkill optopulse');
end

cmd = '~/Software/InVivoTools/Webcam/optopulse';
cmd = [cmd ' ' num2str(duration) ' ' num2str(frequency)];

system(cmd,false,'async');


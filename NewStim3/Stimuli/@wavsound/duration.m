function t = duration(ws)

% DURATION - duration of wavsound stim
%
%  T = DURATION(MYWAVSOUNDSTIM)
%
%  Returns play duration of MYWAVSOUNDSTIM.
%
%  If the filename cannot be opened then the duration is 0.
%
%  See also:  WAVSOUND
 

p = getparameters(ws);

if exist(p.filename),
	[y,fs] = wavread(p.filename);
	t = length(y)/fs;
else,
	t = 0;  % we don't know
end;


t = t + duration(ws.stimulus);

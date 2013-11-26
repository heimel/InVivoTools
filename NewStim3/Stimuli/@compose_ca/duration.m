function t = duration(cca)

% DURATION - Duration of compose_ca stim
%
%  T = DURATION(MYCOMPOSE_CA)
%
%  Returns the expected duration of the COMPOSE_CA stimulus
%  MYCOMPOSE_CA.
%
%  See also:  COMPOSE_CA, STIMULUS/DURATION


if numStims(cca)>0,
	t = duration(get(cca,1));  % duration is duration of first stimulus
else, t = 0;
end;


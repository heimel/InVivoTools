function [trimmedscript, trimmedmti, inds] = stimscriptmtitrim(thescript, themti, wholetrials)

% STIMSCRIPTMTITRIM - Trim any aborted stim presentations off a stimscript/mti
%
%  [TRIMMEDSCRIPT, TRIMMEDMTI, INDS] = STIMSCRIPTMTITRIM(THESCRIPT,THEMTI,[WHOLE_TRIALS])
%
%  Examines the measured timing information THEMTI, and removes any stimulus
%  presentations that were not shown (that is, they have all zero 'startstoptimes' fields).
%  These presentations are also deleted from THESCRIPT.  The 'trimmed' script is returned
%  in TRIMMEDSCRIPT, and the 'trimmed' MTI is returned in TRIMMEDMTI.
%  INDS is a list of the 'good' index values that should be retained.
%  If WHOLE_TRIALS is specified, then the script is assumed to be divided into 
%  pseudo-randomly generated trials where each stim is presented 1 time each trial, and
%  only whole trials are allowed (that is, partial trials will be trimmed).
%  
%
% See also: DISPLAYTIMING, DISPLAYSTIMSCRIPT

trimmedmti = themti;
trimmedscript = thescript;

if nargin<3, wt = 1; else, wt = wholetrials; end;

good = [];

for i=length(trimmedmti):-1:1,
	if ~eqlen(trimmedmti{i}.startStopTimes,[0 0 0 0]),
		good = i;
		break;
	end;
end;

% now need to consider whole trials
if wt,
	stimspertrial = numStims(thescript);
	good = stimspertrial * floor(good./stimspertrial);
end;

inds = 1:good;

if good==length(trimmedmti), % nothing to do
else,  % need to trim
	do = getDisplayOrder(trimmedscript);
	do = do(inds);
	trimmedscript = setDisplayMethod(trimmedscript,2,do);
	trimmedmti = trimmedmti(inds);
end;


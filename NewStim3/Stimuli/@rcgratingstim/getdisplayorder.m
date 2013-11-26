function do = getdisplayorder(rcgstim)
% GETDISPLAYORDER - Get display sequence for an rcgstim
%  DO = GETDISPLAYORDER(RCGSTIM)
%     Returns the display sequence for an RCGstim.
%

p = getparameters(rcgstim);

numNonBlank = length(p.spatialfrequencies)*length(p.spatialphases)*length(p.orientations);

do = [];
rand('state',p.randState);
for i=1:p.reps,
	if p.order==1,
	        do = [ do randperm(numNonBlank) numNonBlank+1];
	else,
		do = [ do 1:numNonBlank+1];
	end;
end;

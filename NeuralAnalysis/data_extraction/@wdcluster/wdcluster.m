function [wdc] = wdcluster(parameters,arg2)

% WDC = WDCCLUSTER(PARAMETERS)
%
% spikewin                    :   250e-6
% event_type_string           :   The string that will be used as part of the
%                             :     output object's name (e.g. cell)
% output_object (0 or 1)      :   Type of output object to make.  Must be
%                                   cksmultiunit (0) or ckssingleunit (1).

default_p = struct('spikewin',250e-6,'output_object',1);

me = [];
finish = 1;

if ischar(parameters),
	if strcmp(parameters,'graphical'),
		mywdc = wdcluster('default');
		finish = 0;
		wdc = edit_graphical(mywdc);
	elseif strcmp(parameters,'default'),
		parameters = default_p;
	else, error('Unknown string input to wdcluster.');
	end;
else,
	[good,err]=verifywdcluster(parameters);
	if ~good,error(['Could not create wdcluster: ' err]); end;
end;

if finish,
	exop = secondaryextractoperator(5);
	wdc = class(struct('WDCparams',parameters),'wdcluster',exop);
end;

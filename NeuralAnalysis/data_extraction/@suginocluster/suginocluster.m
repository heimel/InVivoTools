function [sc] = suginocluster(parameters,arg2)

% SC = SUGINOCLUSTER(PARAMETERS)
%
% spikewin                    :   250e-6
% event_type_string           :   The string that will be used as part of the
%                             :     output object's name (e.g. cell)
% output_object (0 or 1)      :   Type of output object to make.  Must be
%                                   cksmultiunit (0) or ckssingleunit (1).

default_p = struct('spikewin',250e-6,...
		'maxND',35,'thN1',5,'thN2',3,'stS',2,'edS',1,'rmPts',3,...
		'grS',1.5,'cTh',0.98,'grS2',0.4,'cTh2',0.99,'mrgTh',0.7,...
		'mrgTh2',0.3,'ovlTh',0.3,'ovlMN',15,'engTh',0.8,'numTh',0.01,...
		'numTh2',10,'dth',7,'dth2',chi2inv(0.9999,4),...
		'event_type_string','cell','output_object',1);

me = [];
finish = 1;

if ischar(parameters),
	if strcmp(parameters,'graphical'),
		mysc = suginocluster('default');
		finish = 0;
		me = edit_graphical(mysc);
	elseif strcmp(parameters,'default'),
		parameters = default_p;
	else, error('Unknown string input to suginocluster.');
	end;
else,
	[good,err]=verifysuginocluster(parameters);
	if ~good,error(['Could not create suginocluster: ' err]); end;
end;

if finish,
	exop = secondaryextractoperator(5);
	sc = class(struct('SCparams',parameters),'suginocluster',exop);
end;

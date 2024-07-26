function [ac] = autocluster(parameters,arg2)
% AUTOCLUSTER selects features and uses autoclass to produce clustering
%
%    AUTOCLUSTER(PARAMETERS)
%
% spikewin                    :   250e-6
% event_type_string           :   The string that will be used as part of the
%                             :     output object's name (e.g. cell)
% output_object (0 or 1)      :   Type of output object to make.  Must be
%                                   cksmultiunit (0) or ckssingleunit (1).


default_p = struct('spikewin',250e-6,...
  'usepcas',1,  ...
  'usecumsumpcas',0,  ...
  'usemaxs',0,  ...
  'usemins',0,  ...
  'uselocmaxs',0,  ...
  'uselocmins',0,  ...
  'max_duration',0, 'max_n_tries',50, ...
  'n_save',2, 'n_data',0,  ...
  'rel_delta_range',0.01, 'force_new_search_p','true',...
  'minprob',0.99,...    %minimum probability for use in average spike waveform
  'output_object',1  );

ac=[];
finish = 1;

if ischar(parameters),
	if strcmp(parameters,'graphical'),
		myac = autocluster('default');
		finish = 0;
		ac = edit_graphical(myac);
	elseif strcmp(parameters,'default'),
		parameters = default_p;
	else, error('Unknown string input to autocluster.');
	end;
else,
	[good,err]=verifyautocluster(parameters);
	if ~good,error(['Could not create autocluster: ' err]); end;
end;

if finish,
	exop = secondaryextractoperator(5);
	ac = class(struct('ACparams',parameters),'autocluster',exop);
end;

function [wd] = windowdiscriminator(parameters,arg2)

% WD = WINDOWDISCRIMINATOR(PARAMETERS)
%
% filtermethod (0,1,2)        :   Method of filtering (none, convolution, or
%                             :      Chebyshev type I)
% filterarg                   :   Argument to filter method above.  It is
%                             :      required but ignored in the 'none' case,
%                             :      and it is the stencil with which to
%                             :      convolve the data in the 'convolution'
%                             :      case.  In the Cheby I case, it is the
%                             :      high and low cut-off frequencies in hertz
%                             :      (e.g. [300 5000],[0 5000], [300 Inf],etc.)
% threshmethod (0 or 1)       :   Method of finding threshold.  0=>use N
%                                   standard deviations away.  1=>use actual
%                                   value provided
% thresh1                     :   Value data must exceed to be counted
% thresh2                     :   Value data must not exceed to be counted
% allowborders (0 or 1)       :   If data at borders of files exceeds thresh1,
%                             :     should it be counted?
% scratchfile                 :   String to append to scratch files
%                             :     (use if want to use diff. extractors on
%                             :          same data)
% event_type_string           :   The string that will be used as part of the
%                             :     output object's name (e.g. cell)
% output_object (0 or 1)      :   Type of output object to make.  Must be
%                                   cksmultiunit (0) or ckssingleunit (1).

input_types={'singleEC', 'singleIC', 'unknown', 'field'};
output_types={'cksmultipleunit', 'ckssingleunit'};

default_p = struct('filtermethod',0,'filterarg',[300 5000]/(31439/2),'threshmethod',0,...
		'thresh1',3,'thresh2',8,'allowborders',1,...
		'scratchfile','','event_type_string','cell','output_object',1);

wd = [];
finish = 1;

if ischar(parameters),
	if strcmp(parameters,'graphical'),
		mywd = windowdiscriminator('default');
		finish = 0;
		wd = edit_graphical(mywd);
	elseif strcmp(parameters,'default'),
		parameters = default_p;
	else, error('Unknown string input to windowdiscriminator.');
	end;
else,
	[good,err]=verifywindowdiscriminator(parameters);
	if ~good,error(['Could not create windowdiscriminator: ' err]); end;
end;

if finish,
	exop = extractoperator(5);
	wd = class(struct('WDparams',parameters),'windowdiscriminator',exop);
        wd=set_input_types(wd,input_types);wd=set_output_types(wd,output_types);
end;

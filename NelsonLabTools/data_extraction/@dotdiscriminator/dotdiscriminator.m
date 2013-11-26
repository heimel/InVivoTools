function [dd] = dotdiscriminator(parameters,arg2)

% DD = WINDOWDISCRIMINATOR(PARAMETERS)
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
% dots [Nx3]                  :   The dots to be used for discriminating.
%                             :     The first row is [thresh sign  0],
%                             :      indicating that all events larger than
%                             :      thresh (in direction of sign, +/-1) will
%                             :      be counted.  Each additional row is
%                             :       [thresh sign offset], where offset is
%                             :      the number of samples from the first
%                             :      dot.
% scratchfile                 :   String to append to scratch files
%                             :     (use if want to use diff. extractors on
%                             :          same data)
% event_type_string           :   The string that will be used as part of the
%                             :     output object's name (e.g. cell)
% output_object (0 or 1)      :   Type of output object to make.  Must be
%                                   cksmultiunit (0) or ckssingleunit (1).

input_types={'singleEC', 'singleIC', 'unknown', 'field'};
output_types={'cksmultipleunit', 'ckssingleunit'};

default_p = struct('filtermethod',0,'filterarg',[300 5000]/(31439/2),...
  'dots',[1 1 0],'scratchfile','','event_type_string','cell','output_object',1);

dd = [];
finish = 1;

if ischar(parameters),
	if strcmp(parameters,'graphical'),
		mydd = dotdiscriminator('default');
		finish = 0;
		dd = edit_graphical(mydd);
	elseif strcmp(parameters,'default'),
		parameters = default_p;
	else, error('Unknown string input to dotdiscriminator.');
	end;
else,
	[good,err]=verifydotdiscriminator(parameters);
	if ~good,error(['Could not create dotdiscriminator: ' err]); end;
end;

if finish,
	exop = extractoperator(5);
	dd = class(struct('DDparams',parameters),'dotdiscriminator',exop);
        dd=set_input_types(dd,input_types);dd=set_output_types(dd,output_types);
end;

function [good, errormsg] = verifyautocluster(parameters)
%TO BE UPDATED

% note: parameters must be a struct, NOT an object

proceed = 1;
errormsg = '';

good=1;

return;  % for now

if proceed,
   % check that all arguments are present and appropriately sized
   fieldNames = {'filtermethod','filterarg','threshmethod','thresh1',...
   'thresh2','allowborders','scratchfile','event_type_string','output_object'};
   fieldSizes={[1 1],[1 -1],[1 1],[1 1],[1 1],[1 1],[-1 -1],[-1 -1],[1 1]}; 
   [proceed,errormsg] = hasAllFields(parameters, fieldNames, fieldSizes);
end;

if proceed,
	if parameters.threshmethod~=0&parameters.threshmethod~=1,
		proceed=0;err='threshmethod must be 0 or 1.'; end;
	if parameters.allowborders~=0&parameters.allowborders~=1,
		proceed=0;err='allowborders must be 0 or 1.'; end;
	if parameters.output_object~=0&parameters.output_object~=1,
		proceed=0;err='output_object must be 0 or 1.'; end;
	if parameters.filtermethod<0|parameters.filtermethod>2,
		proceed=0;err='filtermethod must be 0,1,2.';end;
	if parameters.filtermethod==2&size(parameters.filterarg)~=[2 1],
		proceed=0;err='filterarg must be [low high] with Cheby I.';end;
	if parameters.thresh1 == parameters.thresh2,
		proceed=0;err='thresh1 must not equal thresh2.'; end;
end;
good = proceed;

function [good, errormsg] = verifymultiextractor(parameters)

  % note: parameters must be a struct, NOT an object

proceed = 1;
errormsg = '';

if proceed,
   % check that all arguments are present and appropriately sized
   fieldNames = {'filtermethod','filterarg','thresh',...
   'useabs','datadir','thresh3','threshcov','normalize',...
   'thresh2','pre_time','post_time','oversampling','remove_unresolved',...
   'peak_sep','remove_unresolved','overlap_sep','event_sep',...
   'scratchfile','event_type_string','output_object'};
   fieldSizes={[1 1],[1 -1],[1 1],...
               [1 1],[1 1],[1 1],[1 1],[1 1],...
               [1 1],[1 1],[1 1],[1 1],[1 1],...
               [1 1],[1 1],[1 1],[1 1],...
               [-1 -1],[-1 -1],[1 1]}; 
   [proceed,errormsg] = hasAllFields(parameters, fieldNames, fieldSizes);
end;

if proceed,
        fieldNames = {'thresh','thresh2','thresh3','threshcov'};
        for i=1:length(fieldNames),
                eval(['if ~isnumeric(parameters.' fieldNames{i} '),proceed=0;' ...
                   'errormsg=''' fieldNames{i} ' must be 0 or 1.''; end;']);
        end;
        fieldNames = {'pre_time','post_time','event_sep','peak_sep'};
        for i=1:length(fieldNames),
                eval(['if ~ispos(parameters.' fieldNames{i} '),proceed=0;' ...
                   'errormsg=''' fieldNames{i} ' must be 0 or 1.''; end;']);
        end;
        if ~isboolean(parameters.useabs),proceed=0;errormsg='useabs must be boolean.';end;
        if (parameters.normalize~=0)&(parameters.normalize~=1)&(parameters.normalize~=2),
             proceed=0;errormsg='normalize must be 0, 1, or 2.';end;
        if (parameters.datadir~=0)&(parameters.datadir~=1)&(parameters.datadir~=2),
             proceed=0;errormsg='datadir must be 0, 1, or 2.';end;
	if parameters.output_object~=0&parameters.output_object~=1,
		proceed=0;errormsg='output_object must be 0 or 1.'; end;
	if parameters.filtermethod<0|parameters.filtermethod>2,
		proceed=0;errormsg='filtermethod must be 0,1,2.';end;
	if parameters.filtermethod==2&size(parameters.filterarg)~=[1 2],
		proceed=0;errormsg='filterarg must be [low high] with Cheby I.';end;
        if ~(ispos(parameters.oversampling)&isint(parameters.oversampling)),
                proceed=0;errormsg='oversampling must be positive integer.'; end;
        if ~(ispos(parameters.thresh)),
                proceed=0;errormsg='negative threshold not allowed (thresh).'; end;
        if ~(ispos(parameters.thresh2)),
                proceed=0;errormsg='negative threshold not allowed (thresh2).'; end;
        if ~(ispos(parameters.thresh3)),
                proceed=0;errormsg='negative threshold not allowed (thresh3).'; end;
        if ~(ispos(parameters.threshcov)),
                proceed=0;errormsg='negative threshold not allowed (threshcov).'; end;
        
end;
good = proceed;

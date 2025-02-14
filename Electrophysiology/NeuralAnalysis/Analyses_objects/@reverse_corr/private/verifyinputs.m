function [good,errormsg] = verifyinputs(inputs)

proceed = 1;
errormsg = '';

if proceed,
        % check that all arguments are present and appropriately sized
        fieldNames = {'spikes','stimtime','cellnames'};
        fieldSizes = {[1 -1],[1 -1],[1 -1]};
        [proceed,errormsg] = hasAllFields(inputs, fieldNames, fieldSizes);
end;

if proceed,
   if iscell(inputs.spikes),
     for i=1:length(inputs.spikes),
        if ~isa(inputs.spikes{i},'spikedata'),
        proceed=0;errormsg='spikes not spikedata.'; break; end;
     end;
   else, proceed=0; errormsg='spikes must be cell list of spikedata objects.';
   end;
   if isstruct(inputs.stimtime),
     for i=1:length(inputs.stimtime),
        if ~isstimtimestruct(inputs.stimtime(i)),
           proceed=0;errormsg='stimtime must be a struct array of stimtime''s.';
        end;
     end;
   else, proceed=0;errormsg='stimtime must be a struct array of stimtime''s.';
   end;
   if ~(iscellstr(inputs.cellnames)&...
	(length(inputs.spikes)==length(inputs.cellnames))),
	length(inputs.spikes),length(inputs.cellnames),
	proceed=0;errormsg=['cellnames must be a cellstr and be as long as '...
		'spikes.'];
   end;
end;

if proceed,
   foundIt = 0;
   stim = inputs.stimtime.stim(1);
   cl=class(stim); c=methods(cl); 
   foundIt = 1;
   %for i=1:length(c),
   %  if strcmp(c{i},'reverse_corr'), foundIt = 1; break; end;
   %end;
   if foundIt==0,proceed=0;errormsg='stim has no reverse_corr method.';end;
   pars = getparameters(stim);
   if ~isfield(pars,'rect'), proceed=0;errormsg='stim type has no rect field.';
   end;
   for i=1:length(inputs.stimtime),
     if ~strcmp(class(inputs.stimtime(i).stim),cl),
        proceed=0;errormsg='all stims must be of same class.';
     end;
   end;
end;

good = proceed;

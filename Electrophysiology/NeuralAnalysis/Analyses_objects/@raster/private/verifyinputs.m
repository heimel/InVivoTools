function [good,errormsg] = verifyinputs(inputs)

proceed = 1;
errormsg = '';

if proceed,
        % check that all arguments are present and appropriately sized
        fieldNames = {'spikes','triggers','condnames'};
        fieldSizes = {[1 1],[1 -1],[1 -1]};
        [proceed,errormsg] = hasAllFields(inputs, fieldNames, fieldSizes);
end;

if proceed,
%        if ~iscell(inputs.spikes),
%                proceed=0;errormsg='spikes must be a cell.'; end;
%        for i=1:length(inputs.spikes),
%              if ~isa(inputs.spikes{i},'spikedata'),
%                  proceed=0;errormsg='all inputs.spikes must be spikedata objects.';
%                  break;
%              end;
%        end;
        if ~strcmp(class(inputs.triggers),'cell'),
                proceed=0;errormsg='triggers not a cell list.';
        end;
        if length(inputs.condnames)~=length(inputs.triggers),
          proceed=0;errormsg='triggers and condnames must be same length.';
        end;
        if proceed,
          for i=1:length(inputs.triggers),
           if min(size(inputs.triggers{i}))~=1,
              proceed=0; errormsg='all ''triggers'' entries must be 1-d.';break;
           end;
          end;
        end;
end;

good = proceed;

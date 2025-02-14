function [good,errormsg] = verifyinputs(inputs)

proceed = 1;
errormsg = '';

if proceed,
        % check that all arguments are present and appropriately sized
        fieldNames = {'data','triggers','condnames'};
        fieldSizes = {[1 1],[1 -1],[1 -1]};
        [proceed,errormsg] = hasAllFields(inputs, fieldNames, fieldSizes);
end;

if proceed,
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

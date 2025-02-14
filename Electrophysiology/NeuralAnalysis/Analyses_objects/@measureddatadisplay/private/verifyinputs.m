function [good,errormsg] = verifyinputs(inputs)

proceed = 1;
errormsg = '';

if proceed,
        % check that all arguments are present and appropriately sized
        fieldNames = {'measureddata'};
        fieldSizes = {[1 -1]};
        [proceed,errormsg] = hasAllFields(inputs, fieldNames, fieldSizes);
end;

if proceed,
        for i=1:length(inputs.measureddata),
           if ~isa(inputs.measureddata{i},'measureddata'),
             proceed=0;errormsg='all inputs must be measureddata objects.'; break;
           end;
        end;
end;

good = proceed;


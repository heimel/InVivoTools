function [good,errormsg] = verifyinputs(inputs)

proceed = 1;
errormsg = '';

if proceed,
        % check that all arguments are present and appropriately sized
        fieldNames = {'depth','loc','wrt'};
        fieldSizes = {[1 1],[1 3],[1 -1]};
        [proceed,errormsg] = hasAllFields(inputs, fieldNames, fieldSizes);
end;

if proceed,
        if ~strcmp(inputs.wrt,'bregma')&~strcmp(inputs.wrt,'interaural point'),
            proceed=0;
            errormsg='wrt must be ''bregma'' or ''interaural point''.'; end;
        if ~isnumeric(inputs.depth),
            proceed=0; errormsg='depth must be a number.'; end;
        if ~isnumeric(inputs.depth),
            proceed=0; errormsg='depth must be a number.'; end;
end;

good = proceed;

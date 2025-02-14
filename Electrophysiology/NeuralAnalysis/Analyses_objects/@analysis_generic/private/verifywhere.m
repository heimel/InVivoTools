function [good,errormsg] = verifywhere(where)

proceed = 1;
errormsg = '';

if proceed,
        % check that all arguments are present and appropriately sized
        fieldNames = {'figure','rect','units'};
        fieldSizes = {[1 1],[1 4],[1 -1]};
        [proceed,errormsg] = hasAllFields(where, fieldNames, fieldSizes);
end;

if proceed,
	width = where.rect(3); height = where.rect(4);
        if width<0|height<0,
	  proceed=0;   errormsg='width, height of rect must be > 0.';
	end;
	if where.figure<0,proceed=0;errormsg='figure must be > 0.'; end;
	if (~strcmp(where.units,'normalized'))&(~strcmp(where.units,'pixels')),
	  proceed=0; errormsg='units must be ''pixels'' or ''normalized''.';end;
end;

good = proceed;

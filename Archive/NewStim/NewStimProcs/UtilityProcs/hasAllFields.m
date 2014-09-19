function [good, errormsg] = hasAllFields(variable, fieldNames, fieldSizes)

%  Part of the NewStim package
%  [GOOD,ERRORMSG] = HASALLFIELDS(VARIABLE,FIELDNAMES,FIELDSIZES)
%
%  Checks to see if VARIABLE has all of the fieldnames in the cellstr FIELDNAMES
%  and also checks to see if the values of those names match the dimensions
%  given in the cell array FIELDSIZES.  If you don't care to analyze one
%  dimension, pass -1 for that dimension.
%
%  For example,
%      r = struct('test1',5,'test2',[6 1]);
%      s = struct('test1',5,'test3',[6 1]);
%
%      [g,e]=hasAllFields(r,{'test1','test2'},{[1 1],[1 2]})
%               gives g = 1, e=''.
%      [g,e]=hasAllFields(s,{'test1','test2'},{[1 1],[1 2]})
%               gives g = 0, e=['''test2''' not present.']
%  If you didn't care how many columns the test2 field of r was, then you could
%  pass [1 -1] instead of [1 2], or if you didn't care what size it was at all
%  then you could pass [-1 -1].
%
%  Note:  At present, this function does not work on arrays of structs, only
%  structs.  As a work-around, pass the first element of a struct array to see
%  if it is good.

good = 1; errormsg = '';

if nargin == 3, checkSizes = 1; else, checkSizes = 0; end;

	notbad = 1;
	
for i=1:length(fieldNames),
	if good, notbad = 1; end;
	good = good & isfield(variable,fieldNames{i});
	if (notbad& ~good), 
		errormsg = ['''' fieldNames{i} ''' not present.']; notbad = 0;
	end;
    if checkSizes & good,
        sz = []; szg = fieldSizes{i};
        eval(['sz = size(variable.' fieldNames{i} ');']);
        if (szg(1) > -1) good=good&(szg(1)==sz(1)); end;
        if (szg(2) > -1) good=good&(szg(2)==sz(2)); end;
    end;
	if (notbad& ~good),
		if (szg(1)==-1), eT1 = 'N'; else, eT1 = int2str(szg(1)); end;
		if (szg(2)==-1), eT2 = 'N'; else, eT2 = int2str(szg(2)); end;
		errormsg = [fieldNames{i} ' not of expected size ' ...
		'(got ' int2str(sz(1)) 'x' int2str(sz(2)) ' but expected ' eT1 'x' eT2 ').'];
		notbad = 0;
	end;
end;

function descr = sswhatvaries(ss)

% SSWHATVARIES - Identify what varies among stimuli in a stimscript
%
%   DESCR = SSWHATVARIES(STIMSCRIPT)
%
%    Returns a list of parameters that vary across different stimuli
%  in a stimscript.  If the stimuli within the script are of different
%  types or there are no stimuli in the stimscript, then DESCR is NaN.
%
%  Example: if STIMSCRIPT has two stochasticgridstims that differ in
%  their values in the 'rect' parameter, DESCR = {'rect'}.
%
%
%  See also:  STIMSCRIPT

descr = {};
N = numStims(ss);

if N==0, descr = NaN;
elseif N>=1,
	stimclass =class(get(ss,1));
	p1 = getparameters(get(ss,1));
end;

for i=2:N,
    newstim=get(ss,i);
    if ~isfield(getparameters(newstim),'isblank'),
    	if ~strcmp(class(newstim),stimclass),
    		descr = NaN; return;
    	end;
    	p2 = getparameters(newstim);
    	fn2 = fieldnames(p2);
    	for j=1:length(fn2),
            if isfield(p1,fn2{j})&isfield(p2,fn2{j}),
                if ~(eq(getfield(p1,fn2{j}),getfield(p2,fn2{j}))),
                    if isempty(intersect(fn2{j},descr)),
                        descr = cat(2,descr,{fn2{j}});
                    end;
                end;
            end;
    	end;
    end;
end;

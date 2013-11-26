function b = foreachstimdolocal(varlist, func, varargs)
%
%  B = FOREACHSTIMDOLOCAL(VARLIST, FUNC, VARARGS)
%
%  Calls the function FUNC with arguments VARARGS for every stimulus or
%  stimscript in the cellstr VARLIST, where VARLIST is a list of variables
%  in the calling function.  In the case of a stimscript, FUNC is
%  run on every stimulus contained in the stimscript.  FUNC is expected to
%  return a new stimulus which will replace the previous stimulus, or return
%  empty if no replacement is to be made.  The input and output of FUNC should
%  be as follows:
%
%  NEWSTIM = FUNC(STIM, VARARGS)
%
%  VARARGIN should be a cell list of variable names followed by values.
%
%  B is 1 if all of the stimuli and scripts in the list are replaced, or 0
%  otherwise.
%
%  See also:  CELLSTR, STIMULUS, FOREACHSTIMDO

b = 1;
for i=1:length(varlist),
        n = char(varlist(i));
        s = evalin('caller',n);
        if isa(s,'stimulus'),
                eval(['s = ' func '(s,varargs);']);
                if ~isempty(s), % update successful
                        assignin('caller',n,s);
                else, b = 0;
                end;
        elseif isa(s,'stimscript'),
                % loop over stimuli
                for i=1:numStims(s),
                        eval(['g=' func '(get(s,i),varargs);']);
                        if ~isempty(g), s=set(s,g,i); else, b = 0; end;
                end;
                assignin('caller',n,s);
        end;
end;


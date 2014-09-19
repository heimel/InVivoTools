function g = listofvars(classname)

%  Part of the NewStim package
%
%  VARLIST = LISTOFVARS(CLASSNAME)
%
%  Returns a list of variables in the main workspace that are of type CLASSNAME.
%  CLASSNAME should be a string like 'double' or 'stimulus'.  'ans' is never
%  returned in this list.
%  
%  See also:  LIST
%
%                                     Questions to vanhoosr@brandeis.edu

g = {}; g_ = 0;
w = evalin('base','whos');

for i=1:length(w),
        if (strcmp(w(i).name,'ans')==0)&...
             evalin('base',['isa(' w(i).name ',''' classname ''')']),
                g_ = g_ + 1;
                g{g_} = w(i).name;
        end;
end;


function t = duration(stimscript)

%  T = DURATION(STIMSCRIPT)
%
%  Returns the estimated duration of the time it will take to show STIMSCRIPT.
%  Should be acurate to within a few screen refreshes.  Note that this function
%  may require the presence of the StimWindowGlobals, which are available only
%  on the Macintosh.
%                                         Questions?  vanhoosr@brandeis.edu

t = 0;

ord = getDisplayOrder(stimscript);
for i=1:length(ord),
        t = t + duration(stimscript.Stims{ord(i)});
end;


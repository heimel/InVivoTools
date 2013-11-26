function [ci] = get_clock_info(prefix,direction,shift)

%  [CI] = GET_CLOCK_INFO(PREFIX,DIRECTION,SHIFT)
%
%   This function returns information necessary for matching recorded data to
%   a clock. PREFIX contains the directory of the experiment to analyize.  It
%   is assumed that each recording run contains a 'clockt' record, which
%   contains a positive to negative trigger.  It is also assumed at the
%   experiment record contains a variable 'start' which has the time of the
%   trigger in seconds.
%
%   See GET_TRIG for a description of DIRECTION and SHIFT.  If they are not
%   provided, they are assumed to be -1 and 2.
%
%                                      Questions to vanhoosr@brandeis.edu

if nargin>=2,
	d = direction; s = direction;
else,
	s = 2; d = -1;
end;

curr_dir = pwd;

cd(prefix);

ci = [];

g = dir;

for i=3:length(g),
	cd (g(i).name);
	if (exist('raw data')==7), % continue, this is a data directory
		f = dir; j = 3;
		while (j<=length(f))&(isempty(findstr('.mat',f(j).name))),
			j=j+1;
		end;
		if j<=length(f), % we have a stim file
			vars = load(f(j).name);
			t1 = vars.start;
		else,
			t1 = -1;
		end;
		[t2] = 1;
		ci = [ci ; t1 t2];
	end;
	cd(prefix);
end;

cd(curr_dir);

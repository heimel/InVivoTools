function [s_n, s_t, s_fileno, s_sampinfile] = get_trig(prefix, direction, shift)

%  [SAMPLE_NUMBER, SAMPLE_TIME, SAMPLE_FILENUMBER, SAMPLE_IN_FILE] =
%           GET_TRIG(PREFIX, DIRECTION, SHIFT)
%
%     Returns the sample number and sample time of the clock trigger.  If no
%     trigger is found, -1 is returned for both arguments.  The file to use
%     is determined in the ``records'' file in the PREFIX directory.
%     DIRECTION can be either -1 or 1, and determines whether the program
%     looks for a positive to negative transition or a negative to positive
%     transition, respectively.  The trigger signal is assumed to be +/- 5.
%     One can shift the trigger signal by providing the SHIFT argument.
%
%     SAMPLE_FILENUMBER returns which of the files the trigger was found in.
% 
%                                  Questions to vanhoosr@brandeis.edu
%
%     Note I:  The data files are assumed to be in the CKS format, which calls
%     for the data to be stored in several small sequential files.  For
%     simplicity, this function assumes that the transition does not occur
%     _exactly_ at the boundary between two of these files.
%
%     Note II: Prefix is assumed to be BLAH/raw data/.  The path 'raw data'
%     should be included.


curr_dir = pwd;

cd(prefix);

a = loadStructArray('records');
i = 1; while (i<=length(a))&(strcmp(a(i).type,'clockt')==0), i = i + 1; end;
if strcmp(a(i).type,'clockt')==0,
	error('Could not find a ''clockt'' entry in records file.');
end;

gotit = 0; j = 1;
if (prefix(end)=='/'), prefix = prefix(1:end-1); end;

while ((j<=a(i).reps)&(gotit==0)),
	fname = [prefix '/r' sprintf('%.3i',j) '_' a(i).fname ];
	data = loadIgor(fname)+shift;
        filesize = length(data);
        if (direction==-1), I=find(data(11:end-2)>=0&data(13:end)<0) + 10; end;
        if (direction== 1), I=find(data(11:end-2)<=0&data(13:end)>0) + 10; end;
        if ~isempty(I),
		s_n = (j-1)*filesize + I(end);
                s_t = a(i).samp_dt * s_n;
		s_fileno = j;
		s_sampinfile = I(end);
	        gotit = 1;
	end;
	j=j+1;
end;

if (gotit==0),
	s_n = -1;
	s_t = -1;
	s_fileno = -1;
	s_sampinfile = -1;
end;

cd(curr_dir);

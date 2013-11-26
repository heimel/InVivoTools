function saveStructArray(fname,gdi,header,delimiter,delimit_arrays)
%SAVESTRUCTARRAY saves struct array in csv file
%
%  SAVESTRUCTARRAY(FNAME,GDI,HEADER,DELIMITER)
%        Save struct array GDI into file FNAME.
%        if header == 1, write fieldnames
%        if 2 arguments, header = 1
%
% Steve VanHooser?  2013, Alexander Heimel
%

if nargin<5
    delimit_arrays = [];
end
if isempty(delimit_arrays)
    delimit_arrays = false;
end
if nargin < 4
    delimiter = [];
end
if isempty(delimiter)
    delimiter=char(9);
end
if nargin < 3
	header = [];
end
if isempty(header)
    header = 1;
end



[fid,msg] = fopen(fname, 'wt');
if fid == -1
	disp(msg);
	return;
end

if length(gdi)>100
    show_wait = true;
else
    show_wait = false;
end
if show_wait
   h_wait=waitbar(0,'Saving database. Please wait...');
end


if header == 1
    [s,h] = struct2char(gdi(1),delimiter,delimit_arrays,false);
	fprintf(fid,'%s\n',h);
end


for i=1:length(gdi)
	s = struct2char(gdi(i),delimiter,delimit_arrays,false);
    fprintf(fid,'%s\n',s);
    if show_wait && mod(i,10)==0
        waitbar(i/length(gdi),h_wait)
    end
end
if show_wait
    close(h_wait);
end

fclose(fid);

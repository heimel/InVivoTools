function data = loadIgor(filename, start0, stop0)

%  LOADIGOR Load Igor Binary file
%     DATA = LOADIGOR(FILENAME) loads data from an Igor binary data file.  The
%  data is assumed to be one dimentional, and the file is assumed to be from
%  a Macintosh computer (that is, the byte ordering is assumed to be
%  big-endian); this function, however, should work on any computer. 
%
%  One may also use
%     DATA = LOADIGOR(FILENAME,START,STOP)
%  This will only load data between samples START and STOP.  STOP may be Inf
%  to indicate the end of the file.  The first sample is numbered 1.
%  
%  Note:  This program has only been tested with float data.

if nargin==1, start=0; stop=Inf;
elseif nargin==3, start=fix(start0)-1; stop=fix(stop0);
elseif nargin==2, error('LoadIgor needs 1 or 3 arguments.'); end;

fid = fopen(filename, 'r','b');

if (fid>2),   %  successful file open
   s = fseek(fid,17,'bof');
   [a,c] = fread(fid,1,'uchar');
   str = '';
   if (a==2) str = 'float'; sz = 4;
   elseif (a==4) str = 'double'; sz = 2;
   elseif (a==8) str = 'char'; sz = 1;
   elseif (a==32) str= 'long'; sz = 4;
   elseif error('Unknown data type.'); end;
		
   s = fseek(fid,58,'bof');
   [a,c] = fread(fid,1,'int');
   if stop==Inf, r = a-start; else, r = stop-start; end;
   if start>a,
      error(['Start > file length: start = ' int2str(start+1) ...
             ', filelength = ' int2str(a) '.']);
   elseif start+r>a; error(['Requested stopping location ' int2str(start+r) ...
                            ' > length of file ' int2str(a) '.']);
   end;
   s = fseek(fid,126,'bof'); s = fseek(fid,sz*start,'cof');
   [data,c] = fread(fid,r,str);
		
   fclose(fid);
else, error(['Could not open file ' filename '.']);
      data = [];
end;

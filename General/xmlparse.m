function domnode = xmlparse( xml )
%XMLPARSE parses xml text
%
%   DOMNODE = XMLPARSE( XML )
%     wrapper around XMLREAD
%
% 2012, Alexander Heimel
%

tempfile = tempname;
fid = fopen(tempfile,'w');
fwrite(fid,xml);
fclose(fid);

domnode = xmlread(tempfile);

delete(tempfile);
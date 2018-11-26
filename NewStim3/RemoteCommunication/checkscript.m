function txt = checkscript(fname)
txt = '';
refreshnetwork;
if exist(fname,'file')
    fid = fopen(fname,'rt');
    if fid>0
        logmsg(['Opening file ' fname]);
        while 1
           line = fgetl(fid);
           if ~ischar(line)
               break
           end
           txt = [txt sprintf('\n') line]; %#ok<AGROW>
         end
         fclose(fid);
     else
         fclose('all'); % seems unnecessary?
     end
end

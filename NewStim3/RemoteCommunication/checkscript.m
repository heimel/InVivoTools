function txt=checkscript(fname)
refreshnetwork;
fid = fopen(fname,'rt');
if fid>0
    disp(['CHECKSCRIPT: Opening file ' fname]);
    txt = [];
    while 1
        line = fgetl(fid);
        if ~ischar(line)
            break
        end
        txt = [txt sprintf('\n') line]; %#ok<AGROW>
    end
    fclose(fid);
else
    txt = [];
    fclose('all');
end


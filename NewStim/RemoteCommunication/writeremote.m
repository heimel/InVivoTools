function b = writeremote(pathstr,strs)

% Part of the NewStim package
% B = WRITEREMOTE(PATHSTR,STRS)
%
%  Attempts to write the cellstr STRS to the remote machine.  Returns 1 if
%  successful, or 0 otherwise.  If the path does not exist, it gives an
%  error dialog.  (This function presently assumes it is on a unix machine.)
%
%  See also:  REMOTECOMM

b=1;
pathn=fixpath(pathstr);
fname=[pathn 'runit.m'];
if exist(pathn)~=7,
        b = 0;
        errordlg('Remote directory does not exist.','Error');elseif exist(fname),
        b = 0;
        errordlg('Remote server not operating or still processing commands.',...
		'Error');
else,   
        fid = fopen(fname,'wt');
        if fid<0,
                b = 0;
                errordlg(['Could not create ' fname '.']);
        else,
                bigstr = [];
                for i=1:length(strs),
                        bigstr = [bigstr char(strs(i)) 10];
                end;
                fprintf(fid,'%s',bigstr);
                fclose(fid);
                if strcmp(computer,'LNX86') | strcmp(computer,'GLNX86') 
                    eval(['! chmod 770 ' fname ]);
                end 
        end;
end;

function newud=show_protocol( ud )
%SHOW_PROTOCOL shows dec protocol
%
%  NEWUD=SHOW_PROTOCOL( UD )
%
% 2012, Alexander Heimel
%

newud=ud;
record=ud.db(ud.current_record);


decpath = fullfile(expdatabasepath,'..','..','DEC');
protocolpath = dir(fullfile(decpath,[record.protocol(1:5) '*'] ));

if length(protocolpath)>1
    disp(['SHOW_PROTOCOL: More than one matching entry for protocol number ' ...
        record.protocol(1:5) '. Taking first']);
    protocolpath = protocolpath(1);
end
decpath = '\\vs01.herseninstituut.knaw.nl\MVP\Shared\DEC';
filename = fullfile(decpath,protocolpath.name,record.filename);

if ~exist(filename,'file')
    disp(['SHOW_PROTOCOL: Cannot find ' filename ]);
    return
end

if ispc
    winopen(filename)
else
    system(['acroread ''' filename '''']);
end

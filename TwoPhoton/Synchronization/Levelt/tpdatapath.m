function path=tpdatapath( record )
%TPDATAPATH constructs a twophoton data path
%
% PATH = TPDATAPATH( RECORD )
%  by default PATH is the networkpath, unless a local data folder is
%  present
%
% check TP_ORGANIZATION for organization of the files
%
% 2008-2013, Alexander Heimel
%

% set default root
networkroot=fullfile(networkpathbase ,'Twophoton');

switch host
    case 'olympus-0603301' % two-photon computer
        localroot='D:\Data';
    case 'wall-e' % two-photon computer
        localroot='/home/data';
    case 'nin343' % two-photon computer
        localroot='C:\Data';
    case 'nin233' % daan's desktop
        localroot='E:\2PhotonData';
%     case 'nin421' %Ania's desktop
%         localroot='C:\Users\szmuksta\Dropbox\Data_Ania';
    otherwise
        switch computer
            case 'MACI64' % i.e. Daan's home mac
                localroot = fullfile('/Users/daniellevanversendaal/Data');
            case 'MACI' % Daan laptop
                localroot = fullfile('/Users/Dropbox/Data');
            case {'PCWIN','PCWIN64'}
                localroot='C:\Data\InVivo\Twophoton';
            case {'GLNX86','GLNXA64'}
                localroot = '/home/data/InVivo/Twophoton';
        end
end

if nargin==1
    if isempty(record.mouse)
        warning('TPDATAPATH:NO_MOUSE_NUMBER','Record does not contain mouse number, e.g. 08.26.1.06');
        warning('OFF','TPDATAPATH:NO_MOUSE_NUMBER');
    end
    if isempty(record.date)
        warning('TPDATAPATH:NO_EXPERIMENT_DATE','Record does not contain experiment date, e.g. 2010-05-19');
        warning('OFF','TPDATAPATH:NO_EXPERIMENT_DATE');
    end
    
    % first try local root
    path=fullfile(localroot,record.experiment,record.mouse,record.date,record.epoch);
    if ~exist(path,'dir')
        path=fullfile(networkroot,record.experiment,record.mouse,record.date,record.epoch);
        if ~exist(path,'dir')
            % fall back to local path
            path=fullfile(localroot,record.experiment,record.mouse,record.date,record.epoch);
        else
           % disp(['TPDATAPATH: No local data in ' path '. Taking network data.']);
        end       
    end        
else
    path=localroot;
    if ~exist(path,'dir')
        path=networkroot;
        if ~exist(path,'dir')
            path=localroot;
        end
    end
end



function tppath=tpdatapath( record )
%LOHMANN/TPDATAPATH constructs a twophoton data path
%  TPPATH = TPDATAPATH( RECORD )
%
%     RECORD contains experiment description needed to set data path
%     check HELP TP_ORGANIZATION for detailed explanation of record fields
%   
%     TPPATH should contain reference, stimulus, times and drift files
%
%
% 2009-2011, Alexander Heimel
%

if isfield(record,'tpdatapath')
    tppath = record.tpdatapath;
    return
end


switch host
    case 'nin158'
        switch computer % to debug on Alexander's computer
            case 'GLNX86'
                root = '/home/data/InVivo/Twophoton/Friederike';
            otherwise
                root='G:\Bl6_AM Data';
        end
    case {'nin326','lohmann'}
        switch computer % to debug on Alexander's computer
            case 'GLNX86'
                if strcmp(record.experiment(1:4),'AMam')
                    root = '/home/data/InVivo/Twophoton/Friederike';
                else
                    root = '/home/data/InVivo/Twophoton/Juliette';
                end
            otherwise
                root='H:\In vivo - Patching';
        end
    
        
    otherwise
        root = '/home/data/InVivo/Twophoton';
end

if nargin==1
    % change date from 2009-13-31 to 20091231
    if isfield(record,'trackepoch') % i.e. linescan
        tppath = fullfile(root,'Linescans',record.experiment,record.stack);
        
    else
        switch host
            case 'nin158' % friederike
                
                date = record.date([1 2 3 4 6 7 9 10]);
                tppath=fullfile(root,trim([date ' ' record.experiment record.stack]));
            otherwise % juliette
                tppath=fullfile(root, record.experiment, record.mouse);
                
        end
    end
else
    tppath = root;
end


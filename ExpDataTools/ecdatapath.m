function datapath=ecdatapath( record )
%ECDATAPATH constructs the datapath for ec-experiments
%
%
% 2007 Alexander Heimel
%

if nargin<1
	record.date = datestr(now,29);
    record.setup = host;
end

% first check locally
base = fullfile(localpathbase,'Electrophys',capitalize(record.setup));
if ~exist(base,'dir')
    disp(['LOCALPATHBASE: Folder ' base ' does not exist.']);
    base=fullfile(networkpathbase,'Electrophys',capitalize(record.setup));
end

switch record.setup
    case 'antigua'
        datapath=fullfile(base,record.date(1:4),record.date(6:7),record.date(9:10),'Mouse');
%         case 'nin380'
%         datapath=fullfile('V:\InVivo\Electrophys\Nin380',record.date(1:4),record.date(6:7),record.date(9:10)); % temporarily
    otherwise
        datapath=fullfile(base,record.date(1:4),record.date(6:7),record.date(9:10));
end
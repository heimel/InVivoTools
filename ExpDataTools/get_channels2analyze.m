function  channels = get_channels2analyze( record )
%GET_CHANNELS2ANALYZE gets channels from edit in ec database control window
%
% 2014-2019, Alexander Heimel
%

h_db = get_fighandle('Ec database*');
if length(h_db)>1
    warning('ANALYSE_ECTESTRECORD:MULTIPLE_DB','Multiple EC database control windows. Take first for determining channel');
    warning('off','ANALYSE_ECTESTRECORD:MULTIPLE_DB');
    h_db = h_db(1);
end
channels = [];
if isempty(h_db)
    logmsg('Cannot find database control window to find Channels to analyze.');
end
h = ft(h_db,'channels_edit');
if ~isempty(h)
    try
        channels = str2num( get(h,'String')); %#ok<ST2NM>
    end
end

function obj = ft(fig, name)
obj = findobj(fig,'Tag',name);

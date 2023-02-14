function measures = select_measures_by_channel(measures,record,channelfield)
%SELECT_MEASURES_BY_CHANNELS returns only measures for selected channels
%
%  measures = select_measures_by_channel(measures,record,channelfield='channel')
%
% 2014-2023, Alexander Heimel

if nargin<3 || isempty(channelfield)
    channelfield = 'channel';
end

if isfield(measures,channelfield) 
    channels = get_channels2analyze( record );
    if ~isempty(channels) 
        i = 1;
        while i<=length(measures)
            if ~ismember(measures(i).(channelfield),channels)
                measures(i) = [];
            else
                i = i+1;
            end
        end
        if isempty(measures)
            errormsg('None of the requested channels are analyzed.');
        end
    end
end

function measures = select_measures_by_channel(measures,record)
%SELECT_MEASURES_BY_CHANNELS returns only measures for selected channels
%
% 2014, Alexander Heimel

if isfield(measures,'channel') 
    channels = get_channels2analyze( record );
    if ~isempty(channels) && isfield(measures,'channel')
        i = 1;
        while i<=length(measures)
            if ~ismember(measures(i).channel,channels)
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

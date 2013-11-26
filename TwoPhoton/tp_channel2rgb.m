function channel2rgb = tp_channel2rgb(record)
%TP_CHANNEL2RGB maps PMT channels to RGB image
%
% 2011, Alexander Heimel
%

par = tpreadconfig(record);

if ~isfield(record,'channels')
    channels = [];
else
    channels = record.channels;
end

if ~isempty(channels) && length(channels)~=par.NumberOfChannels
    disp('TP_CHANNEL2RGB: Incorrect number of channels specified in channels field. Defaulting.');
    disp('TP_CHANNEL2RGB: For three or less channels, use wavelength in channels field.');
    disp('TP_CHANNEL2RGB: For four or more channels, specify color for each channel, i.e. [2 3 1 1] to choose red,blue,green,green,');
    disp('TP_CHANNEL2RGB: where in case of a double assignment the highest channel that is enable, will use the color.');
    channels = [];
end

green_channel =  1;
red_channel = 2;
blue_channel = 3;

if ~isempty(channels)
    n_channels = length(record.channels);
    
    % mapping from channel to rgb, *only red and green channel*
    switch n_channels
        case 1 % default to green channel
            green_channel =  1;
            red_channel = 2;
            blue_channel = 3;
        case 2 % default to red & green depending on wavelength
            [m, red_channel ] = max(record.channels); %#ok<ASGLU>
            [m, green_channel ] = min(record.channels); %#ok<ASGLU>
            blue_channel = 3;
        case 3 % select based on wavelength
            [m, red_channel ] = max(record.channels); %#ok<ASGLU>
            [m, blue_channel ] = min(record.channels); %#ok<ASGLU>
            green_channel = setdiff([1 2 3],[red_channel blue_channel]);
         otherwise
             green_channel = find(record.channels == 1);
             red_channel = find(record.channels == 2);
             blue_channel = find(record.channels == 3);
    end
end

channel2rgb = 3*ones(1,par.NumberOfChannels); % all mapped to blue
channel2rgb(red_channel) = 1;
channel2rgb(green_channel) = 2;
channel2rgb(blue_channel) = 3; % slightly superfluous

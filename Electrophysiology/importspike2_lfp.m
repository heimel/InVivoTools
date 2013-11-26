function results = importspike2_lfp(smrfilename,stim_type,pre_ttl,post_ttl,only_first_ttl,amplification,verbose)
%IMPORTSPIKE2_LFP
%
%  PRE_TTL is time (s) to return before TTL
%  POST_TTL is time (s) to return after TTL
%
% RESULTS structure containing
%   .WAVES_TIME=-pre_ttl+(0:size(waves,2)-1)*sample_interval;
%   .WAVES contains LFP channel in millivolts
%   .STIM_WAVES contains stimulus channel in voltages from AD-board;
%   .STIM_INTENSITIES=max(stim_waves,[],2)';
%   .SAMPLE_INTERVAL in seconds
%
%
% 2009 - 2012, Alexander Heimel
%
results = [];

persistent persistent_smrfilename
persistent lfpchannel LFPdata lfpdata data_ttl sample_interval stimdata stimchannel markerdata

warning('IMPORTSPIKE2_LFP:TIMING','IMPORTSPIKE2_LFP: Alexander: improve and generalize timing correction, joint for ec and lfp');
warning('off', 'IMPORTSPIKE2_LFP:TIMING');

if nargin<7
    verbose = [];
end
if isempty(verbose)
    verbose = 1;
end

if nargin<6
    amplification = [];
end
if isempty(amplification)
    amplification = 1000;
    warning('IMPORTSPIKE2_LFP:BLANK_AMPLIFICATION',...
        'IMPORTSPIKE2_LFP: Blank amplification field in record. Defaulting to 1000x');
    warning('off','IMPORTSPIKE2_LFP:BLANK_AMPLIFICATION');
end


if nargin<5
    only_first_ttl = false;
end

%disp(['IMPORTSPIKE2_LFP: Requested time ' num2str(post_ttl+pre_ttl) ' s']);

%nn=smrfilename;
%mm=lfpdata;

if isempty(persistent_smrfilename) || ~strcmp(persistent_smrfilename,smrfilename)
    loadsmr = 1;
else
    loadsmr = 0;
    %     disp('IMPORTSPIKE2_LFP: Using SMR file cache');
end

%loadsmr =1;

if nargin<4;post_ttl=[];end
if nargin<3;pre_ttl=[];end

%defaults
if isempty(post_ttl)
    post_ttl=0.2; %s
end
if isempty(pre_ttl)
    pre_ttl=0.1; %s
end

switch stim_type
    case 'io'
        startmarker='I';
    case 'pp'
        startmarker='P';
    case 'ltp'
        startmarker='B';
    case {'fullscreen_white_15s','bars_nase'}
        startmarker=[]; % i.e. no startmarker
    otherwise
        startmarker = []; % i.e. no startmarker
end

memory_limit = 500000000;

if loadsmr
    % open data file
    fid=fopen(smrfilename);
    if fid==-1
        errordlg(['Error: failed to open  ' smrfilename],'Importspike2_lfp');
        return;
    end
    persistent_smrfilename = smrfilename;
    disp(['IMPORTSPIKE2: Opened ' smrfilename ' ...' ]);

    lfpchannelname='LFP';
    stimchannelname='diode';
    markerchannelname='Keyboard';
    ttlchannelname='TTL'; % since 2009-06-03 using second TTL channel

    list_of_channels = SONChanList(fid);

    lfpchannel=findchannel(list_of_channels,lfpchannelname);
    stimchannel=findchannel(list_of_channels,stimchannelname); % could be absent

    ttlchannel=findchannel(list_of_channels,ttlchannelname);
    if length(ttlchannel)>1
        ttlchannel = ttlchannel(strmatch(ttlchannelname,{list_of_channels(ttlchannel).title},'exact'));
    end
    if ttlchannel == -1 % since 2012-07-01
        ttlchannelname='TTL'; % since 2009-06-03 using second TTL channel
        ttlchannel=findchannel(list_of_channels,ttlchannelname);
    end
    if ttlchannel==-1
        warning(['IMPORTSPIKE2_LFP:UNFOUND_' ttlchannelname],...
            ['IMPORTSPIKE2_LFP: Could not find channel named ' ttlchannelname]);
        warning('off',['IMPORTSPIKE2_LFP:UNFOUND_' ttlchannelname]);
    end


    markerchannel=findchannel(list_of_channels,markerchannelname);
    %if lfpchannel==-1 || ttlchannel==-1 || stimchannel==-1 || markerchannel==-1
    if ttlchannel==-1 || markerchannel==-1
        fclose( fid );
        return  % didn't find one of the TTL or Keyboard channels
    end

    if lfpchannel==-1
        fclose( fid );
        return  % didn't find any channels
    end

    % load lfp channels
    requested_sample_interval = 0.001; % 1000 Hz
    lfpnum=1;
    LFPdata = [];
    for lfpch=lfpchannel
        [lfpdata,lfpheader]=SONGetChannel(fid,lfpch);
        if lfpheader.kind~=1
            disp('Warning: lfpchannel',num2str(lfpch),' (or maybe others as well) is of unexpected kind');
        end

        sample_interval=SONGetSampleInterval(fid,lfpch);

        if length(lfpdata)*8>memory_limit
            errr =['Recorded ' smrfilename ...
                ' for too long. Clipping data to ' num2str(round(memory_limit/8*sample_interval/60)) ' minutes.'];
            errordlg(errr,'IMPORTSPIKE2_LFP');
            disp(['IMPORTSPIKE2_LFP: ' errr]);
            lfpdata = lfpdata(1:round(memory_limit/8));
        end

        % convert to voltage:
        lfpdata=SONADCToDouble(lfpdata,lfpheader);


        % removing line noise, now done at level of analyse_veps
        % Check out mouse=11.35.1.30,test=t00002 for an example with line noise;
        if 0
            disp('IMPORTSPIKE2_LFP: Removing line noise in temporal domain');
            [lfpdata,line2data] = remove_line_noise(lfpdata,1/sample_interval);
            disp(['IMPORTSPIKE2_LFP: Ratio of line noise amplitude to signal is ' num2str(line2data) ]);
        end

        % downsampling
        if requested_sample_interval>sample_interval
            down_sample = floor(requested_sample_interval/sample_interval);
            disp(['IMPORTSPIKE2_LFP: Downsampling ' num2str(down_sample) 'x to ' num2str(1/requested_sample_interval) 'Hz']);
            sample_interval = sample_interval*down_sample;
            lfpdata=resample(lfpdata,1,down_sample);
        end

        LFPdata(lfpnum,:)=lfpdata;
        lfpnum=lfpnum+1;
    end

    if stimchannel~=-1 % load stimulus channel
        [stimdata,stimheader]=SONGetChannel(fid,stimchannel);
        if stimheader.kind~=1
            disp('IMPORTSPIKE2_LFP: stimchannel is of unexpected kind');
        end
        % convert to voltage:
        stimdata=SONADCToDouble(stimdata,stimheader);
    else
        stimdata = [];
    end

    if ~isempty(startmarker)
        [markerdata,markerheader]=SONGetChannel(fid,markerchannel);
        if markerheader.kind~=5
            disp('IMPORTSPIKE2_LFP: markerchannel is of unexpected kind');
        end
    end

    ttlinfo=SONChannelInfo(fid,ttlchannel);
    if ttlinfo.firstblock==-1 % apparently empty, check on other ttlchannel
        ttlchannelname='TTL'; % since 2009-06-03 using second TTL channel
        ttlchannel=findchannel(list_of_channels,ttlchannelname);
        if length(ttlchannel)>1
            disp('IMPORTSPIKE2_LFP: Two TTL channels. Taking first');
            ttlchannel = ttlchannel(1);
        end
        ttlinfo=SONChannelInfo(fid,ttlchannel);
        if ttlinfo.firstblock==-1
            disp('IMPORTSPIKE2_LFP: Can not find recorded TTLs');
            fclose( fid );
            return
        end
    end

    [data_ttl,header_ttl]=SONGetChannel(fid,ttlchannel);
    if header_ttl.kind~= 3
        disp('IMPORTSPIKE2_LFP: ttlchannel is of unexpected kind');
    end

    fclose(fid);
end

if ~isempty(startmarker)
    ind=find(markerdata.markers==startmarker,1);
    start_time=markerdata.timings(ind);
else
    ind=[];
    start_time=0;
end

switch stim_type
    case 'ltp'
        if ind<length(markerdata.timings)-2
            stop_time=markerdata.timings(ind+3);% first B, then L, then B
        else
            stop_time=inf; %lfpheader.stop;
        end
    case {'fullscreen_white_15s','bars_nase'}
        stop_time=inf;
    otherwise
        if ~isempty(ind) && ind<length(markerdata.timings)
            stop_time=markerdata.timings(ind+1);
        else
            stop_time=inf; %lfpheader.stop;
        end
end
ttls=data_ttl(data_ttl>start_time & data_ttl<stop_time);

if only_first_ttl && ~isempty(ttls)
    ttls = ttls(1);
end

wavelength_samples= round( (pre_ttl+post_ttl)/sample_interval); % round to 100 samples
for j=1:length(lfpchannel)
    waves=zeros(length(ttls),wavelength_samples);
    stim_waves=waves;
    for i=1:length(ttls)
        startind=round( (ttls(i)-pre_ttl)/sample_interval);
        if startind+size(waves,2)-1>size(LFPdata,2)
            warning('IMPORTSPIKE2_LFP:INCOMPLETE_DATASET',...
                'IMPORTSPIKE2_LFP: Not acquired complete data set');
            waves(i,:) = NaN;
            waves(i,1:size(LFPdata,2)-startind+1)= ...
                LFPdata(j,startind : min(startind+size(waves,2)-1,end));
        else
            waves(i,:)=LFPdata(j,startind :startind+size(waves,2)-1);
        end
        if stimchannel~=-1
            stim_waves(i,:)=stimdata(startind :startind+size(waves,2)-1);
        end
    end
    rstim_intensities{1,j}=max(stim_waves,[],2)';
    rstim_waves{1,j}=stim_waves;
    rwaves_time{1,j} =-pre_ttl+(0:size(waves,2)-1)*sample_interval;
    rwaves{1,j} = waves / amplification * 1000; % to get mV
end
results.stim_intensities=rstim_intensities;
results.stim_waves=rstim_waves;

results.waves_time = rwaves_time;
results.waves = rwaves; % to get mV
results.sample_interval = sample_interval;

%resample waves
%results.waves_resample=resample(results.waves',1,3)';
%results.waves_time_resample=resample(results.waves_time,1,3);

if verbose>1 % plot waves
    figure('Name','Wave');
    hold on
    plot(results.waves_time,results.waves,'k');
    ylabel('Voltage (mV)');
    xlabel('Time (s)');
    xlim([results.waves_time(1) results.waves_time(end)]);
end


return



function channel=findchannel(list_of_channels,channelname)
ch=1;
channel=-1;
% totallength=numel(isletter(channelname));
letterlength=numel(isletter(channelname));
channelX=1;
while ch<=length(list_of_channels)
    %     if totallength-letterlength~=0
    if numel(list_of_channels(ch).title)>=letterlength && strcmp(list_of_channels(ch).title(1:letterlength),channelname)==1
        channel(channelX)=list_of_channels(ch).number;
        channelX=channelX+1;
        ch=ch+1;
        %             break;
    else
        ch=ch+1;
    end
end;
% end;
return


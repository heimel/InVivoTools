function cells = importaxon( record, verbose)
%IMPORTAXON imports data from Axon ABF files
%
%  CELLS = IMPORTAXON( RECORD )
%
% 2015, Alexander Heimel
%
cells = {};

if ~isfield(record,'test')
    record.test = record.epoch;
end

params = ecprocessparams(record );

filename = fullfile( experimentpath(record),params.ec_axon_default_filename );

%machineF    char array,        the 'machineformat' input parameter of the
%              'ieee-le'

[data,sample_interval_us] = abfload(filename,'verbose',0);
%[data,sample_interval_us] = abfload(filename,'machineF','ieee-be');

if 0 % high pass filter
    [z,p] = butter(9,0.009,'high');
    dataf = filter(z,p,data(:,1));
    
    figure;
    plot(data(:,1))
    hold on
    plot(max(data(:,1))*2+dataf);
end

ind_spikes = detect_spikes( data(:,1),sample_interval_us);
spiketimes = ind_spikes * sample_interval_us * 1e-6; % spike times in seconds

ind_ttl = detect_ttl( data(:,2));
ttl = ind_ttl* sample_interval_us * 1e-6; % ttl time in seconds

spiketimes = spiketimes - ttl;


if verbose

    figure('Name',[recordfilter(record) ' - Trace '],'NumberTitle','off');
    t = (0:size(data,1)-1)*sample_interval_us * 1e-6 - ttl;
    plot(t,data(:,2)/max(data(:,2))*median(data(ind_spikes,1)),'g-'); % ttl channel
    hold on
    plot(t,data(:,1),'-k');
    plot(t(ind_spikes),data(ind_spikes,1),'or');

    plot_stimulus_timeline(record);

end

[stims,stimsfilename] = getstimsfile( record );
intervals=[stims.start stims.MTI2{end}.frameTimes(end)+10];

spiketimes = spiketimes * params.secondsmultiplier;
spiketimes = spiketimes + stims.start + params.trial_ttl_delay;


try
    cksds=cksdirstruct(experimentpath(record,false));
catch
    logmsg(['Could not create/open cksdirstruct ' experimentpath(record,false)])
    return
end
px = getexperimentfile(cksds,1);
delete(px);

detector_params = [];
unitchannelname = 'axon';

cl = 1;
cll.name=sprintf('cell_%s_%s_%.4d_%.3d',...
    '',unitchannelname,1,cl);
cll.intervals = intervals;
cll.sample_interval = sample_interval_us *1e-6;
cll.desc_long = [ filename ':' stimsfilename];
cll.desc_brief = filename;
cll.channel = 1;
cll.index = cl-1; % will be used to identify cell
cll.data = spiketimes;
cll.detector_params = detector_params;
cll.trial = record.test;
cll.channel = 1;
cll.wave = []; %mean(spikes,1) ;
cll.std = []; %std(spikes,1);
cll.spikes = [];
cells = cll;




function ind = detect_ttl( d)
low=median(d(d<0)); % find low mode 
high=median(d(d>0));
rangelh = high-low;
ind = find( (d<low+0.05*rangelh ) & (d>low-0.05*rangelh),1);

function ind = detect_spikes( d,sample_interval_us )
d = detrend( d );
minpeakdistance = 500/sample_interval_us; 
minpeakheight = 5 * std(d);
[pks,ind] = findpeaks(d,'minpeakheight',minpeakheight,'minpeakdistance',minpeakdistance);

% figure
% plot(d);

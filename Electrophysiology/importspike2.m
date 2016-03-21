function cells = importspike2(record)
%IMPORTSPIKE2 stores spike2-sorted spikes into Nelsonlab experiment file
%
%   CELLS = IMPORTSPIKE2( RECORD )
%
%       TRIAL, name e.g. 'Data04-01-14e'
%       STIMULUSTRIAL, e.g. 't00001'
%       PATH,  default 'C:\Documents and
%       Settings\Jan-Alexander\Desktop\testdata'
%       UNITCHANNELNAME, default 'units'
%       TTLCHANNELNAME, default 'TTL'
%
% 2004-2015, Alexander Heimel
%

cells = {};

trial = [record.test filesep 'data.smr'];
datapath = experimentpath(record,false);
unitchannelname = 'Spikes'; % was 'units'
ttlchannelname = 'TTL';

params = ecprocessparams( record );
if isfield(params,'secondsmultiplier')
    secondsmultiplier = params.secondsmultiplier;
    ttl_delay = params.trial_ttl_delay;
else
    secondsmultiplier = 1.000032; % daneel 2012-09-18
    ttl_delay = 0.0115;
end

if ~isfield(record,'amplification') || isempty(record.amplification) 
    amplification = 5000;
else
    amplification = record.amplification;
end

try
    cksds=cksdirstruct(datapath);
catch
    logmsg(['Could not create/open cksdirstruct ' datapath])
    return
end

px = getexperimentfile(cksds,1);
delete(px);

smrfilename=fullfile(datapath,trial);

cells=loadcells(cksds,record.test,smrfilename,unitchannelname,ttlchannelname,secondsmultiplier,ttl_delay,amplification);

return


function cells=loadcells(cksds,trial,smrfilename,unitchannelname,ttlchannelname,secondsmultiplier,ttl_delay,amplification)
% LOADCELLS reads spike2-smr file into spikedata object

px = getexperimentfile(cksds,1);

fid=fopen(smrfilename);
if fid==-1
    logmsg(['Failed to open  ' smrfilename]);
    cells=[];
    return;
end

list_of_channels=SONChanList(fid);
unitchannel=findchannel(list_of_channels,unitchannelname);
ttlchannel=findchannel(list_of_channels,ttlchannelname);
if unitchannel==-1 || ttlchannel==-1
    cells=[];
    return  % didn't find one of the channels
end
[data_units,header_units]=SONGetChannel(fid,unitchannel);
if ~isfield(header_units,'kind') || header_units.kind~=6
    cells = [];
    logmsg(['Unitchannel is of unexpected kind for ' smrfilename']);
    return
end
sample_interval=SONGetSampleInterval(fid,unitchannel);
[data_ttl,header_ttl]=SONGetChannel(fid,ttlchannel);
if ~isstruct(header_ttl) || header_ttl.kind~= 3
    logmsg(['TTLchannel is of unexpected kind for ' smrfilename]);
    cells = [];
    return
end

if 0 % to get raw single units
    rawsinglechannel=findchannel(list_of_channels,'singleEC');
    [data_rawsingle,header_rawsingle]=SONGetChannel(fid,rawsinglechannel);
end
fclose(fid);

% apply time correction
data_ttl = data_ttl * secondsmultiplier;
data_units.timings = data_units.timings * secondsmultiplier;

% load acquisitionfile for electrode name
% to get samplerate acqParams_out should be used instead of _in
ff=fullfile(getpathname(cksds),trial,'acqParams_in');
f=fopen(ff,'r');
if f==-1
    logmsg(['Could not open ' ff ]);
    return;
end
fclose(f);  % just to get proper error
acqinfo=loadStructArray(ff);

% creating acqParams_out
ffout=[ff(1:end-2) 'out'];
if ~exist(ffout,'file')
    copyfile(ff,ffout);
end

% load stimulus starttime
stimsfilename=fullfile(getpathname(cksds),trial,'stims.mat');
stimsfile=load(stimsfilename);

desc_long=[smrfilename ':' stimsfilename];
desc_brief=smrfilename;
detector_params=[];
n_classes=max(data_units.markers(:,1))+1;

intervals=[stimsfile.start ...
    stimsfile.MTI2{end}.frameTimes(end)+10];

% shift time to fit with TTL and stimulustimes
timeshift=stimsfile.start-data_ttl(1);
% timeshift=stimsfile.start-data_ttl(1)+1; % just for motion stim for 13.20
% disp('IMPORTSPIKE2: Taking first TTL for time synchronization');

timeshift=timeshift+ ttl_delay; % added on 24-1-2007 to account for delay in ttl


data_units.timings=data_units.timings+timeshift;

cellnamedel=sprintf('cell_%s_%s_%.4d_*',acqinfo(1).name,unitchannelname,acqinfo(1).ref);
deleteexpvar(cksds,cellnamedel); % delete all old representations


%classes = uniq(sort(double(data_units.markers(:,1))));
for cl=1:n_classes
    % cellname needs to start with 'cell' to be recognized
    % by cksds
    clear('cll');
    cll.name=sprintf('cell_%s_%s_%.4d_%.3d',...
        acqinfo(1).name,unitchannelname,acqinfo(1).ref,cl);
    cll.intervals = intervals;
    cll.sample_interval = sample_interval;
    cll.desc_long = desc_long;
    cll.desc_brief = desc_brief;
    cll.channel = 1;
    ind = find( data_units.markers(:,1)==cl-1);
    cll.index = cl-1; % will be used to identify cell
    cll.data=data_units.timings( ind);
    cll.detector_params=detector_params;
    cll.trial=trial;
    cll.channel = 1;
    spikes = double(data_units.adc(ind,:))/10/amplification; % to get mV
    cll.wave = mean(spikes,1) ;
    cll.std = std(spikes,1);
    cll.snr = (max(cll.wave)-min(cll.wave))/mean(cll.std);
    cll.spikes = spikes;
    cll.ind_spike = []; %[1:length(spikes)]';
    if cl==1
        cll.type = 'mu';
    else
        cll.type = 'su';
    end
    cells(cl) = cll;
 end % cl n_classes


 if 0 % merging cells 
     cll = cells(1);
     for c=2:length(cells)
        cll.data = [cll.data; cells(c).data];
        cll.spike_amplitude = [cll.spike_amplitude; cells(c).spike_amplitude];
        cll.spike_trough2peak_time = [cll.spike_trough2peak_time; cells(c).spike_trough2peak_time];
        cll.spike_peak_trough_ratio = [cll.spike_peak_trough_ratio; cells(c).spike_peak_trough_ratio];
        cll.spike_prepeak_trough_ratio = [cll.spike_prepeak_trough_ratio; cells(c).spike_prepeak_trough_ratio];
        cll.spike_lateslope = [cll.spike_lateslope; cells(c).spike_lateslope];
     end
         %    XX=[cll.spike_amplitude,cll.spike_peak_trough_ratio,cll.spike_prepeak_trough_ratio,cll.spike_trough2peak_time,cll.spike_lateslope];
      XX=[cll.spike_amplitude,cll.spike_peak_trough_ratio/range(cll.spike_peak_trough_ratio),cll.spike_prepeak_trough_ratio/range(cll.spike_prepeak_trough_ratio),cll.spike_trough2peak_time/range(cll.spike_trough2peak_time),cll.spike_lateslope/range(cll.spike_lateslope)]; %spikes(:,2:4:end)
         
     if  0 % add replace features by PCs
         
         [pc,score,latent,tsquare] = princomp(XX);
         score = score( randperm(size(score,1)),:);
         
         
         cll.spike_amplitude = score(:,1);
         cll.spike_trough2peak_time = score(:,2); %ms
         cll.spike_peak_trough_ratio = score(:,3);
         cll.spike_prepeak_trough_ratio = score(:,4);
         cll.spike_lateslope=score(:,5);
     end
     cells = cll;
     
     if 0 % kmean clustering
         NumClust  = 10;
         if exist('score','var')
             indx = kmeans(score(:,[1:5]),NumClust);
         else
             indx =clusterdata(XX(:,[1 2 3 4 5]),'linkage','ward','maxclust',5);
%             indx = kmeans(XX(:,[ 1 2 3 4 5]),NumClust);
         end
         for i=1:max(indx)
             ind = find(indx==i);
             cells(i)=cll;
             cells(i).name =[ 'cell_ctx_Spikes_0001_' num2str(i,'%03d')];
             cells(i).data = cll.data(ind);
             
             cells(i).spike_amplitude =cll.spike_amplitude(ind);
             cells(i).spike_trough2peak_time = cll.spike_trough2peak_time(ind); %ms
             cells(i).spike_peak_trough_ratio = cll.spike_peak_trough_ratio(ind);
             cells(i).spike_prepeak_trough_ratio = cll.spike_prepeak_trough_ratio(ind);
             cells(i).spike_lateslope=cll.spike_lateslope(ind);
             
         end
     end
 end



return

%
function channel=findchannel(list_of_channels,channelname)
ch=1;
channel=-1;
while ch<=length(list_of_channels)
    if strcmp(list_of_channels(ch).title,channelname)==1
        channel=list_of_channels(ch).number;
        break;
    else
        ch=ch+1;
    end
end
if channel==-1
    logmsg(['Could not find channel named ' channelname]);
end
return






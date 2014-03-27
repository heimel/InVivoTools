function cells = importspike2(trial,stimulustrial,path,unitchannelname,ttlchannelname,secondsmultiplier,ttl_delay)
%IMPORTSPIKE2 stores spike2-sorted spikes into Nelsonlab experiment file
%
%   CELLS=importspike2(trial,stimulustrial,path,unitchannelname,ttlchannelname)
%
%       TRIAL, name e.g. 'Data04-01-14e' 
%       STIMULUSTRIAL, e.g. 't00001'
%       PATH,  default 'C:\Documents and
%       Settings\Jan-Alexander\Desktop\testdata'
%       UNITCHANNELNAME, default 'units'
%       TTLCHANNELNAME, default 'TTL'
% 
% 2004-2013, Alexander Heimel 
%

cells={};

if nargin<7
    ttl_delay = 0.0115;
end

if nargin<6
%    secondsmultiplier = 1.000018; % nin380 2012-08
warning('IMPORTSPIKE2:TIMING','IMPORTSPIKE2: Alexander: improve and generalize timing correction, joint for ec and lfp');
warning('off', 'IMPORTSPIKE2:TIMING');

secondsmultiplier = 1.000032; % daneel 2012-09-18
end

if nargin<5
    ttlchannelname='TTL';
end 
if nargin<4
    unitchannelname='units';
end
if nargin<3
  warning('IMPORTSPIKE2:nopath','No path given to importspike2.');
  return
end 

try 
  cksds=cksdirstruct(path);
catch
  disp(['IMPORTSPIKE2: Could not create/open cksdirstruct ' path])
  return
end

[px,expf] = getexperimentfile(cksds,1);
delete(px);
%  cksds=cksdirstruct(path);



smrfilename=fullfile(path,trial);

cells=loadcells(cksds,stimulustrial,smrfilename,unitchannelname,ttlchannelname,secondsmultiplier,ttl_delay);

try 
  transfercells(cells,cksds);
catch
  disp('IMPORTSPIKE2: Could not transfer cells to cksdirstruct');
  return
end

n_cells=length(cells);
if n_cells==1
  display(['IMPORTSPIKE2: Imported ' num2str(length(cells)) ' cell from smr-file.']);
else
  display(['IMPORTSPIKE2: Imported ' num2str(length(cells)) ' cells from smr-file.']);
end

return


function cells=loadcells(cksds,trial,smrfilename,unitchannelname,ttlchannelname,secondsmultiplier,ttl_delay)
% LOADCELLS reads spike2-smr file into spikedata object

[px,expf] = getexperimentfile(cksds,1);

fid=fopen(smrfilename);
if fid==-1
    disp(['IMPORTSPIKE2: Failed to open  ' smrfilename]);
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
    disp(['IMPORTSPIKE2: Unitchannel is of unexpected kind for ' smrfilename']);
    return
end
sample_interval=SONGetSampleInterval(fid,unitchannel);
[data_ttl,header_ttl]=SONGetChannel(fid,ttlchannel);
if ~isstruct(header_ttl) || header_ttl.kind~= 3
    disp(['IMPORTSPIKE2: TTLchannel is of unexpected kind for ' smrfilename]);
    cells = [];
    return
end
% if length(data_ttl)>1
%     disp('IMPORTSPIKE2: Expected just one ttl');
% end

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
    disp(['Error: could not open ' ff ]);
    return;
end
fclose(f);  % just to get proper error
acqinfo=loadStructArray(ff);

ffout=[ff(1:end-2) 'out'];
if exist(ffout,'file')~=2
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
  
  spikes = double(data_units.adc(ind,:))/10; % to get mV
  
  cll.wave = mean(spikes,1) ;
  cll.std = std(spikes,1); 
  cll.snr = (max(cll.wave)-min(cll.wave))/mean(cll.std);
  cll = get_spike_features(spikes, cll );
  
cells(cl) = cll;
  if 0 && ~isempty(ind)
	  figure; hold on;
	  t=(0:length(cells(cl).wave)-1)*sample_interval*1000; % ms
	  
	  if length(ind)>100
		  indsel=ind(round(linspace(1,length(ind),100)));
	  else
		  indsel=ind;
	  end
	  for j=indsel
		  plot(t,double(data_units.adc(j,:)));
	  end
	  plot(t, 10*cells(cl).wave ,'k-');
	  plot(t, 10*cells(cl).wave+cells(cl).std,'-','color',[0.7 0.7 0.7]);
	  plot(t, 10*cells(cl).wave-cells(cl).std,'-','color',[0.7 0.7 0.7]);
	  xlabel('Time (ms)');
	  ylabel('Potential (0.1 mV)');
	  bigger_linewidth(3);
	  smaller_font(-12);
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
      disp(['IMPORTSPIKE2: Could not find channel named ' channelname]);
  end   
return
  
  
function transfercells(cells,cksds)
%TRANSFERCELLS Transfers cells from loadcells to the cksdirstruct
%
%    TRANSFERCELLS(CELLS,CKSDS)
%

for cl=1:length(cells)
   acell=cells(cl);
   thecell=cksmultipleunit(acell.intervals,acell.desc_long,...
		acell.desc_brief,acell.data,acell.detector_params);
    saveexpvar(cksds,thecell,acell.name,1);
end

return





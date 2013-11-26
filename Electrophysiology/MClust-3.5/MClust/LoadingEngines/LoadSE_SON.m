function varargout = LoadSE_SON(fn,varargin)
% MClust Loading engine for CED SON files (*.smr).  Requires SON library 
% for Matlab written by Malcolm Lidierth and available as contributed software 
% at http://www.ced.co.uk
% 
% Place LoadSE_SON.m in the MClust "LoadingEngines" directory and install
% SON library in your Matlab path to use.
%
% This version is for use only with single electrode recordings. It uses
% the first wavemark channel encountered, so if you have more than one wavemark 
% channel in your SMR file make sure the channel you want imported is the lowest 
% numbered.  This engine can be easily modified to use up to four channels.
% As is, it zero pads the three unused channels for compatability with
% MClust.  
%
% Tested with SON library version 1.02, Spike2 version 4.19, and MClust 3.3
%
% 17 March 2004, Shane Heiney <shane@vor.wustl.edu>

%%%% First a little error checking %%%%

% Check for SON library

if ~exist('SONgetchannel','file')           % If this function exists, assume library is installed
    error('LoadSE_SON:Cannot find SON library.  Is it in your Matlab path?');
end

% Check for appropriate output arguments

if nargout < 1 
    error('LoadSE_SON:You must specify at least one output argument');
end

if nargout > 2
    error('LoadSE_SON:You may only specify a maximum of 2 output arguments');
end

%%%% Parse input %%%%

switch length(varargin)   
    
    case 0      % No additional arguments
        record_units=-1;      % All records
        
    case 1      % Supplied range, but no units
        error('LoadSE_SON:For range of records you must specify record_units');
        
    case 2      % User specified range of values to get
        records_to_get=varargin{1};
        record_units=varargin{2};
        
    otherwise
        error('LoadSE_SON:Too many input arguments');
end

%%%% Open SMR file %%%%

fid=fopen(fn);

if fid == 0 
    error(['LoadSE_SON:File ' fn ' would not open']);
end

%%%% Check for wavemark channels %%%%

clist=SONchanlist(fid);

% Cycle through chanlist, looking for wavemark channels.  Store first four 
% in wavemarkchans array, so engine can be easily extended for stereotrodes
% and tetrodes.

j=1;
wavemarkchans=zeros(1,4);
for i=1:length(clist)
    if clist(i).kind == 6
        wavemarkchans(j)=clist(i).number;
        j=j+1;
        if j > 4        % Only use first 4 wavemark channels found
            break;
        end
    end
end

% Since only one electrode, only get one wavemark channel

% Could use scheme below to have user select wavemark channel to use, but
% it requires too much user interaction on multiple calls to this function.
% There's probably a workaround for that, but for now use first channel 
% encountered instead.
%
% validchans=find(wavemarkchans>0);
% numchans=length(validchans);
% 
% chan=1;
% 
% if numchans > 1 
%     list=cellstr(int2str(wavemarkchans(validchans)'));
%     [chan,ok]=listdlg('ListString',list,'SelectionMode','single','Name','Channel Selection',...
%         'PromptString',{'Select wavemark channel'; 'to use:'},'OKString','Use selection',...
%         'CancelString','Cancel Import','ListSize',[150 75]);
%     if ok == 0
%         error('You must select a Spike2 wavemark channel to proceed');
%     end
% end
    
[data,header]=SONgetchannel(fid,wavemarkchans(1));

% Extract spike waveforms and timestamps and convert from ADC units to double

spikes=double(data.adc)*header.scale/6553.6+header.offset;
timestamps=data.timings;

%%%% Return desired values %%%%

% Check records_to_get

switch record_units
    
    case -1         % All records
        index=1:length(timestamps);
        t=timestamps(index);
        
    case 1          % Timestamp list
        index=find(intersect(timestamps,records_to_get));
        t=timestamps(index);
        
    case 2          % Record number list
        index=records_to_get;
        t=timestamps(records_to_get);
        
    case 3          % Timestamp range
        index=find(timestamps >= records_to_get(1) & timestamps <= records_to_get(2));
        t=timestamps(index);
        
    case 4          % Record number range
        index=records_to_get(1):1:records_to_get(2);
        t=timestamps(index);
        
    case 5         % return spike count
        t=length(spikes);      % value returned is not timestamp, but rather spike count
        
    otherwise 
        error('LoadSE_SON:Invalid argument for record_units');
        
end

% First output argument is timestamp or spike count
varargout{1}=t;

if nargout == 2          % Return spike waveforms also
    
    if record_units == 5       % User only wants spike count
        error('LoadSE_SON:Too many output arguments for record_units=5');
    end
      
    % Make n x 4 x npoints matrix, where n is number of spikes and npoints is
    % number of samples per spike.
    %
    % In this version of loading engine, only first channel is used, so
    % remaining 3 filled with zeros.
    %
    % This step is only performed if user wants spike waveforms, since
    % it can be somewhat computationally intensive.
    
    [m,n]=size(spikes);
    wv=zeros(length(index),4,n);
    
    for i=1:length(index)
        wv(i,1,:)=spikes(index(i),:);
    end
    
    varargout{2}=wv;
    
end

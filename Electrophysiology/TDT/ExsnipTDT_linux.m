function CSnip = ExsnipTDT_linux(EVENT, Trials)
%
%Called by invivotools to retrieve spikes (only snip data)
%after filtering the trigger array.
%Returns a N by 1 structure format (N is number of channels):
%       each cell contains a struct array with two fields :
%       time (double)
%       data (array of data samples (singles) containing the wave form)

%usage in analyse_ectestrecord m-file:
%define the following variables in EVENT
%Input : EVENT.Triallngth = s; % lenght of trial in seconds
%        EVENT.Start = s;      % start of trial relative to stimulus onset
%        EVENT.type = 'snips';
%        EVENT.Myevent = (string) event;    %snip event
%
%       Trials : (double)stimulus onset time determined in analyse_veps
%
% 2014, Alexander Heimel


CSnip = [];

tank = EVENT.Mytank;
blockname = EVENT.Myblock;

if isempty(tank)
    errormsg('No tank specified');
    return
end
if ~exist(tank,'dir')
    errormsg(['Cannot locate tank at ' tank]);
    return
end
if isempty(blockname)
    errormsg('Not block specified');
    return
end


filebase = fullfile( tank,blockname,['Mouse_' blockname]);
tev_path = [filebase '.tev'];



%check if start and triallength exist
if ~isfield(EVENT, 'Start') || ~isfield(EVENT, 'Triallngth')
    errormsg('No Start or Triallngth defined');
    return
end

%F = figure('Visible', 'off');
%H = actxcontrol('TTANK.X', [20 20 60 60], F);
%H.ConnectServer('local', 'me');

%H.OpenTank(EVENT.Mytank, 'R');
%H.SelectBlock(EVENT.Myblock);
%H.CreateEpocIndexing;

EvCode = EVENT.Myevent; %event code as string
Sampf = EVENT.snips.Snip.sampf; %sample frequency for this event
Evlngth = EVENT.snips.Snip.size;    %number of samples in each event epoch
Evtime = Evlngth/Sampf; %timespan of one event epoch
if iscell(EVENT.snips.Snip.channels)
    ChaNm = length(EVENT.snips.Snip.channels); %channels in block is a cell
else
    ChaNm = EVENT.snips.Snip.channels;
end

if isfield(EVENT, 'CHAN') && length(EVENT.CHAN) <= ChaNm
    Chans = EVENT.CHAN;  %SELECTED CHANNELS
    if size(Chans,2) == 1
        Chans = Chans';  %should be a row vector
    end
else
    Chans = 1:ChaNm;
end

% CSnip = {};
EVNUM = round(double(ChaNm) *(EVENT.Triallngth + 0.5)*Sampf/double(Evlngth)); %more event
%epochs than needed

%    for j = 1:size(Trials,1)
% OnsTrl = Trials(1,1) + EVENT.Start;  %time where trial should start relative to stimulus onset
% EndTrl = OnsTrl + EVENT.Triallngth;  %time where trial should end, based on trial lenght
% %select time window starting one event epoch(Evtime) earlier and ending one
% %event epoch later.
% Recnum = H.ReadEventsV(EVNUM, EvCode, 0, 0, OnsTrl-Evtime, EndTrl+Evtime, 'ALL');
% ChnIdx = H.ParseEvInfoV(0, Recnum, 4);      %channel number corresponding to each epoch
% Times = H.ParseEvInfoV(0, Recnum, 6);       %actual time onset of each epoch
% Data = H.ParseEvV(0, Recnum);                  %event epoch data
%Times = Times - Trials(j,1);

% Nc = 1;
% for i = Chans
%     D2 = 1000*Data(:,ChnIdx == i);
%     T2 = Times(ChnIdx == i);
%     CSnip(Nc,1).time = T2';
%     CSnip(Nc,1).data = D2';
%     Nc = Nc + 1;
% end

%   end

% H.CloseTank;
% H.ReleaseServer;
% close(F)

% save(MatFile, 'CSnip')




% an example of reading A/D samples from tev. You can use the same code to read
% the snip-type data (sorted waveforms). Just replace the store ID.
table = { 'float',  1, 'float';
    'long',   1, 'int32';
    'short',  2, 'short';
    'byte',   4, 'schar';
    'unknown', 4, 'unknown';
    }; % a look-up table

tev = fopen(tev_path);
% typecast Store ID (such as 'Evnt', 'eNeu', and 'LPFs') to number
namecode = 256.^(0:3)*double('Snip')';

% select tsq headers by the Store ID
row = (namecode == data.namecode);

%EVENTCODE = [data.timestamp(row) data.strobe(row)];
%
first_row = find(1==row,1);
format    = data.format(first_row)+1; % from 0-based to 1-based
%
SNIPS.format        = table{format,1};
SNIPS.sampling_rate = data.frequency(first_row);
SNIPS.chan_info     = [data.timestamp(row) data.chan(row)];
% For the snip type, you may want the sortcode additionally.
% SPIKE.chan_info = [data.timestamp(row) data.chan(row) data.sortcode(row)];

fp_loc  = data.fp_loc(row);
nsample = (data.size(row)-10) * table{format,2};
SNIPS.sample_point = NaN(length(fp_loc),max(nsample));
for n=1:length(fp_loc)
    fseek(tev,fp_loc(n),'bof');
    % For the snip type, each row of sample_point corresponds to each waveform.
    SNIPS.sample_point(n,1:nsample(n)) = fread(tev,[1 nsample(n)],table{format,3});
end
fclose(tev);



Nc = 1;
for i = Chans
    D2 = 1000*Data(:,ChnIdx == i);
    T2 = Times(ChnIdx == i);
    CSnip(Nc,1).time = T2';
    CSnip(Nc,1).data = D2';
    Nc = Nc + 1;
end

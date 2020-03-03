function [SIG,TIM] = signalsTDT_linux(EVENT, Trials)
%[SIG,TIM] = signalsTDT_linux(EVENT, Trials)
%
%Called by invivotools to retrieve lfp data (only stream data) after
%filtering the trigger array.
%Returns a cell format (SIG) contains N by 1 cells (N is number of the channels)
%each cell contains samples from onset of a stimulus with the length and
%prestimulus time determined in analyse_veps
%
%
%usage in analyse_veps m-file:
%define the following variables in EVENT
%Input : EVENT.Myevent = (string) event  %must be a stream event
%        EVENT.type = 'strms'   %must be a stream event
%        EVENT.Triallngth =  (double) lenght of trial in seconds
%        EVENT.Start =       (double) start of trial relative to stimulus onset
%        EVENT.CHAN = (string) channel numbers
%       Trials : (double)stimulus onset time determined in analyse_veps
%
% 2014-2020, Alexander Heimel

SIG = {};

if nargin<1
    logmsg('Debugging example')
    EVENT.Mytank = '~/Desktop/TDT_invivotools';
    EVENT.Mytank = '/home/data/InVivo/Electrophys/Antigua/2013/12/18/Mouse';
    EVENT.Myblock = 't-1';
    EVENT.Myevent = 'LFPs';
    EVENT.Start =  -2; % i.e. 2s befor stim onset
    EVENT.Triallngth =  2+3; %i.e. 5s total trial length    
    Trials = [10 ;20];
end

if ~isfield(EVENT,'strms')
    EVENT = load_tdt_linux( EVENT );
end    

Rt = strmatch(EVENT.Myevent, {EVENT.strms(:).name} );
if isempty(Rt)
    errordlg([EVENT.Myevent ' is not a stream type event'])
    return
end

%check if start and triallength exist
if ~isfield(EVENT, 'Start') || ~isfield(EVENT, 'Triallngth')
    errordlg('No Start or Triallngth defined');
    return
end

if isempty(EVENT.Mytank)
    errormsg('No tank specified');
    return
end
if ~exist(EVENT.Mytank,'dir')
    errormsg(['Cannot locate tank at ' EVENT.Mytank]);
    return
end
if isempty(EVENT.Myblock)
    errormsg('No block specified');
    return
end

strm = read_tdt_strm( EVENT );
    
Sampf = EVENT.strms(Rt).sampf; 
ChaNm = EVENT.strms(Rt).channels; % recorded channels
if isfield(EVENT, 'CHAN') && length(EVENT.CHAN) <= ChaNm
    Chans = EVENT.CHAN;  %selected channels
else
    Chans = 1:ChaNm;
end

TrlSz = round(EVENT.Triallngth*Sampf);

SIG = cell(length(Chans), 1);
TIM = cell(length(Chans), 1);
for i = 1:length(Chans)
    SIG{i} = nan(TrlSz, size(Trials,1));
    TIM{i} = nan(TrlSz, size(Trials,1));
end

for j = 1:size(Trials,1)
    Nc = 1;
    OnsTrl = Trials(j,1) + EVENT.Start;  %time where trial should start relative to stimulus onset
    EndTrl = OnsTrl + EVENT.Triallngth;  %time where trial should end, based on trial length
    for ch = Chans
        chanind = find(strm.chan==ch);
        
        first_epoch_ind = find( strm.timestamp(chanind)<OnsTrl, 1, 'last' );
        if isempty(first_epoch_ind)
            logmsg(['Missing start of trial ' num2str(j) ' for channel ' num2str(ch)]);
            continue
        end
        first_epoch_start = strm.timestamp(chanind(first_epoch_ind));
        last_epoch_ind = find( strm.timestamp(chanind)>EndTrl, 1, 'first' )-1;
        if isempty(last_epoch_ind)
            logmsg(['Missing end of trial ' num2str(j) ' is captured for channel ' num2str(ch)]);
            continue
        end
        last_epoch_start = strm.timestamp(chanind(last_epoch_ind));
        
        TDs = OnsTrl - first_epoch_start;    %number of samples between actual onset and requested onset
        Sb = round(TDs*Sampf)+1;  % number of samples to start from at first epoch
        
        TDe = EndTrl - last_epoch_start;
        Se = round(TDe*Sampf);      % number of samples needed from last epoch
        
        SIG{Nc,j}  = [ strm.sample_point(chanind(first_epoch_ind),Sb:end)' ; ...
            flatten(strm.sample_point(chanind(first_epoch_ind+1:last_epoch_ind-1),:)') ; ...
            strm.sample_point(chanind(last_epoch_ind),1:Se)'   ];
        
        TIM{Nc,j} = first_epoch_start + (Sb-1) / Sampf + (0: (length(SIG{Nc,j})-1))/Sampf;
        
        
        Nc = Nc + 1;
    end % channel ch
end % trial j


function strm = read_tdt_strm( EVENT )
persistent strm_pers EVENT_pers

if EVENT_pers == EVENT
    %    logmsg(['Loading ' EVENT.Myevent ' from tank '  EVENT.Mytank ', ' EVENT.Myblock ' from cache.']);
    strm = strm_pers;
    return
end

strm = [];


if ~isempty(EVENT.Mytank) && EVENT.Mytank(end)==filesep
    [~,preamble] = fileparts(EVENT.Mytank(1:end-1));
else
    preamble = '';
end
filebase = fullfile( EVENT.Mytank,EVENT.Myblock,[preamble '_' EVENT.Myblock]);
tev_path = [filebase '.tev'];
if ~exist(tev_path,'file')
    filebase = fullfile( EVENT.Mytank,EVENT.Myblock);
    tev_path = [filebase '.tev'];
    if ~exist(tev_path,'file')
        errormsg(['Cannot find block ' EVENT.Myblock ' in tank ' EVENT.Mytank]);
        return
    end
end
    
tsq_path = [filebase '.tsq'];

tsq = fopen(tsq_path);
fseek(tsq, 0, 'eof');
ntsq = ftell(tsq)/40;

logmsg('TEMP SHORTING NUMBER OF DATA SAMPLES' );
ntsq = 400000;

fseek(tsq, 0, 'bof') ; data.size      = int32(fread(tsq, [ntsq 1], 'int32',  36));
fseek(tsq,  4, 'bof'); data.type      = int32(fread(tsq, [ntsq 1], 'int32',  36));
fseek(tsq,  8, 'bof'); data.name      = uint32(fread(tsq, [ntsq 1], 'uint32', 36)); %4
fseek(tsq, 12, 'bof'); data.chan      = uint16(fread(tsq, [ntsq 1], 'ushort', 38));
fseek(tsq, 14, 'bof'); data.sortcode  = uint16(fread(tsq, [ntsq 1], 'ushort', 38));
fseek(tsq, 16, 'bof'); data.timestamp = double(fread(tsq, [ntsq 1], 'double', 32));
fseek(tsq, 24, 'bof'); data.fp_loc    = int64(fread(tsq, [ntsq 1], 'int64',  32));
fseek(tsq, 24, 'bof'); data.strobe    = double(fread(tsq, [ntsq 1], 'double', 32));
fseek(tsq, 32, 'bof'); data.format    = int32(fread(tsq, [ntsq 1], 'int32',  36));
fseek(tsq, 36, 'bof'); data.frequency = double(fread(tsq, [ntsq 1], 'float',  36));
fclose(tsq);

data.timestamp = data.timestamp - data.timestamp(2);

table = { 'float',  1, 'float';
    'long',   1, 'int32';
    'short',  2, 'short';
    'byte',   4, 'schar'; };
name = 256.^(0:3)*double(EVENT.Myevent)';
row = (name == data.name); % select stream
first_row = find(1==row,1);
format    = data.format(first_row)+1; % from 0-based to 1-based

strm.format = table{format,1};
strm.sampling_rate = data.frequency(first_row);
strm.timestamp = data.timestamp(row);
strm.chan = data.chan(row);
fp_loc  = data.fp_loc(row);
nsample = (data.size(row)-10) * table{format,2};
strm.sample_point = NaN(length(fp_loc),max(nsample));

tev = fopen(tev_path);
for n=1:length(fp_loc)
    fseek(tev,fp_loc(n),'bof');
    strm.sample_point(n,1:nsample(n)) = fread(tev,[1 nsample(n)],table{format,3});
end
fclose(tev);

EVENT_pers = EVENT;
strm_pers = strm; % to store

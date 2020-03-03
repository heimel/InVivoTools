function EVENT = load_tdt(EVENT, use_matlab_tdt, allowchanges)
%LOAD_TDT
%
%   EVENT = LOAD_TDT( EVENT, USE_MATLAB_TDT=isunix, ALLOWCHANGES=true ) 
%
%called by Tdt2ml to retrieve info about events and
%the timing data of strobe events from a TDT Tank
%
%If used in a batch file you must initialize these values:
%input: EVENT.Mytank = full path to the tank you want to read from 
%       EVENT.Myblock = name of the block you want to read from
%
%output: EVENT ;  a structure containing a lot of info
%        Trilist ; an array containing timing info about all the trials
%             1st column contains stimulus onset times
%             4th target onset times
%             7th micro stim times
%
%uses GetEpocsV to retrieve stobe-on epocs; Updated 17/04/2007
%
% 2006, Chris van der Togt, 29/05/2006
% 2019, Alexander Heimel

if nargin<2 || isempty(use_matlab_tdt)
    use_matlab_tdt = isunix;
end
if use_matlab_tdt
    logmsg('Using TDTREAD matlab routines.');
    EVENT = load_tdt_linux(EVENT);
    return
end
if nargin<3 || isempty(allowchanges)
    allowchanges = true;
end


F = figure('WindowStyle','normal','Visible', 'off');
try
    H = actxcontrol('TTANK.X', [20 20 60 60], F);
catch me
    me.identifier
end

E.UNKNOWN = hex2dec('0');  %"Unknown"
E.STRON = hex2dec('101');  % Strobe ON "Strobe+"
E.STROFF = hex2dec('102');  % Strobe OFF "Strobe-"
E.SCALAR = hex2dec('201');  % Scalar "Scalar"
E.STREAM = hex2dec('8101');  % Stream "Stream"
E.SNIP = hex2dec('8201');  % Snip "Snip"
E.MARK = hex2dec('8801');  % "Mark"
E.HASDATA = hex2dec('8000');  % has associated waveform data "HasData"

%event info indexes
I.SIZE   = 1;
I.TYPE   = 2;
I.EVCODE = 3;
I.CHAN   = 4;
I.SORT   = 5;
I.TIME   = 6;
I.SCVAL  = 7;
I.FORMAT  = 8;
I.HZ     = 9;
I.ALL    = 0;

H.ConnectServer('local','me');
H.OpenTank(EVENT.Mytank, 'R');
H.SelectBlock(EVENT.Myblock);


EVENT.timerange = H.GetValidTimeRangesV();
H.CreateEpocIndexing;
%ALL = H.GetEventCodes(0);
%AllCodes = cell(length(ALL),1);
%for i = 1:length(ALL)
%        AllCodes{i} = H.CodeToString(ALL(i));
%  AllCodes{i} = H.GetEpocCode(i-1);
%end
invalidchar = '^[^a-zA-Z]|\W+';

EVS = H.GetEventCodes(E.STREAM); %gets the long codes of event types
STRMS = size(EVS,2);
strms = cell(STRMS,1);
if ~isnan(EVS)
    for i = 1:STRMS
        strms{i} = H.CodeToString(EVS(i));
        %        IxC = find(strcmp(AllCodes, strms(i)));
        %        AllCodes(IxC) = [];
    end
    
    for j = 1:length(strms)
        Epoch = char(strms{j});
        Recnum = H.ReadEventsV(1000, Epoch, 0, 0, 0, 0, 'ALL'); %read in number of events
        %call ReadEventsV before ParseEvInfoV !!!! I don't expct more than a
        %1000 channels per event
        
        T = H.ParseEvV(0, 1);
        
        EVENT.strms(j).name = Epoch;
        EVENT.strms(j).size = size(T,1);    %number of samples in each event epoch
        EVENT.strms(j).sampf = H.ParseEvInfoV(0, 1, I.HZ); %9 = sample frequency
        EVENT.strms(j).channels = max(H.ParseEvInfoV(0, Recnum, I.CHAN)); %4 = number of channels
        EVENT.strms(j).bytes = H.ParseEvInfoV(0, 1, I.SIZE); %1 = number of samples * bytes (4??)
        
    end
end
%get snip events

EVS = H.GetEventCodes(E.SNIP);
SNIPS = size(EVS,2);
snips = cell(SNIPS,1);
if ~isnan(EVS)
    for i = 1:SNIPS
        snips{i} = H.CodeToString(EVS(i));
        %remove this item from allcodes
        %            IxC = find(strcmp(AllCodes, snips(i)));
        %            AllCodes(IxC) = [];
    end
    for j = 1:length(snips)
        Epoch = char(snips{j});
        invc = regexp(Epoch, invalidchar); %check for invalid characters
        Epch = Epoch;
        if ~isempty(invc)
            Epoch(invc) = '_';
            errordlg(['Invalid character(s) in Epoch name; ' Epch 'replaced by underscore: ' Epoch])
        end
        Recnum = H.ReadEventsV(100000, Epch, 0, 0, 0, 0, 'ALL'); %read in number of events
        if Recnum ~= 0
            T = H.ParseEvV(0, 1);
            EVENT.snips.(Epoch).size = size(T,1); %number of samples per epoch event
            EVENT.snips.(Epoch).sampf = H.ParseEvInfoV(0, 1, I.HZ); %9 = sample frequency
            
            Timestamps = H.ParseEvInfoV(0, Recnum, I.TIME); %6 = the time stamp
            Channel =    H.ParseEvInfoV(0, Recnum, I.CHAN);
            Chnm = max(Channel);
            EVENT.snips.(Epoch).channels = Chnm;
            EVENT.snips.(Epoch).bytes = H.ParseEvInfoV(0, 1, I.SIZE);
            
            while Recnum == 100000
                Recnum = H.ReadEventsV(100000, Epoch, 0, 0, 0, 0, 'NEW'); %read in number of events
                Timestamps = [Timestamps H.ParseEvInfoV(0, Recnum, I.TIME)];
                Channel = [Channel H.ParseEvInfoV(0, Recnum, I.CHAN)];
            end
            Times = cell(Chnm,1);
            for k = 1:Chnm
                Times(k) = {Timestamps(Channel == k)};
            end
            
            
            EVENT.snips.(Epoch).name = Epoch;
            EVENT.snips.(Epoch).times = Times;
        else
            EVENT.snips.(Epoch).name = Epoch;
            EVENT.snips.(Epoch).size = nan; %number of samples per epoch event
            EVENT.snips.(Epoch).sampf = nan; %9 = sample frequency
            EVENT.snips.(Epoch).times = [];
        end
    end
end



stron = H.GetEpocCode(0);
i = 0;
strons = {};
while ~isempty(stron)
    i = i + 1;
    strons(i) = {stron};
    stron = H.GetEpocCode(i);
end

for j = 1:length(strons)
    Epoch = char(strons{j});
    Temp = H.GetEpocsV( Epoch, 0, 0, 100000);
    if isnan(Temp)
        logmsg([ Epoch ' Event has been recorded, but cannot be retrieved']);
    else
        TINFO = Temp(2,:);
        
        if (strcmp(Epoch, 'word') || strcmp(Epoch, 'Word'))
            TINFO(2,:) = Temp(1,:);
        end
        EVENT.strons.(Epoch) = TINFO;
    end
end

H.CloseTank;
H.ReleaseServer;
close(F)

if allowchanges
    storepath = fullfile(EVENT.Mytank,EVENT.Myblock);
    if ~exist(storepath,'dir') % temporary addition
        logmsg(['Path ' storepath ' does not exist. Saving on desktop']);
        storepath = getdesktopfolder;
    end
    MatFile = fullfile(storepath,EVENT.Myblock);
    save(MatFile, 'EVENT','-v7')
end

% % % keyboard
% EVENT.Myevent = 'Snip';
% EVENT.type = 'snips';
% G=EVENT.strons.stim;f = find(~isnan(G));
% Trials = G(f);
% Event=signalsTDT(EVENT, Trials);
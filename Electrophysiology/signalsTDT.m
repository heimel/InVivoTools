function SIG = signalsTDT(EVENT, Trials)
%SIG = Exd2(EVENT, Trials)
%
%Called by invivotools to retrieve lfp data (only stream data) after
%filtering the trigger array. 
%Returns a cell format (SIG) contains N by 1 cells (N is number of the channels)
%each cell contains samples from onset of a stimulus with the length and
%prestimulus time determined in analyse_veps

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
%Chris van der Togt, 11/11/2005
%updated 08/04/2008

if isunix
    SIG = signalsTDT_linux(EVENT, Trials);
    return
end

SIG = [];

% matfile = fullfile(EVENT.Mytank,EVENT.Myblock); %name of file used to save lfp structure
% MatFile=fullfile(matfile,'LFP');
% if exist([MatFile '.mat'], 'file')
%     load(MatFile);
%     return
% end

EvCode = EVENT.Myevent;
Rt = strmatch(EvCode, {EVENT.strms(:).name} );
if isempty(Rt)
    errordlg([EvCode ' is not a stream type event'])
    return
end

%check if start and triallength exist
if ~isfield(EVENT, 'Start') || ~isfield(EVENT, 'Triallngth')
    errordlg('No Start or Triallngth defined');
    return
end

F = figure('Visible', 'off');
H = actxcontrol('TTANK.X', [20 20 60 60], F);
H.ConnectServer('local', 'me');

if 0 == H.OpenTank(EVENT.Mytank, 'R')
    errordlg([EVENT.Mytank 'does not exist!!!'])
    H.CloseTank;
    H.ReleaseServer;
    close(F)
    return
end

H.SelectBlock(EVENT.Myblock);
H.CreateEpocIndexing;

Sampf = EVENT.strms(Rt).sampf; %sample frequency for this event
Evlngth = EVENT.strms(Rt).size; %number of samples in each epoch
Evtime = Evlngth/Sampf; %timespan of one event epoch plus one for safety
ChaNm = EVENT.strms(Rt).channels; %channels in block
if isfield(EVENT, 'CHAN') && length(EVENT.CHAN) <= ChaNm
    Chans = EVENT.CHAN;  %SELECTED CHANNELS
else
    Chans = 1:ChaNm;
end

TrlSz = round(EVENT.Triallngth*Sampf);
EVNUM = round(ChaNm *(EVENT.Triallngth + 0.5)*Sampf/Evlngth); %more event epochs than needed

%SIG = single([]);
 SIG = cell(length(Chans), 1);
for i = 1:length(Chans)
   SIG{i} = nan(TrlSz, size(Trials,1));
end

for j = 1:size(Trials,1)
    OnsTrl = Trials(j,1) + EVENT.Start;  %time where trial should start relative to stimulus onset
    EndTrl = OnsTrl + EVENT.Triallngth;  %time where trial should end, based on trial lenght
    %select time window starting one event epoch(Etime) earlier and ending one
    %event epoch later.
    Recnum = H.ReadEventsV(EVNUM, EvCode, 0, 0, OnsTrl-Evtime, EndTrl+Evtime, 'ALL');

    if Recnum > 0
        ChnIdx = H.ParseEvInfoV(0, Recnum, 4);      %channel number corresponding to event epoch
        Times = H.ParseEvInfoV(0, Recnum, 6);
        Data = H.ParseEvV(0, Recnum);   %event epoch data


        MnTime = min(Times);     %actual time onset of first epoch
        TD = OnsTrl - MnTime;    %number of samples between actual onset and requested onset
        if TD < 0
            disp(['warning..Missing data at start of trial: ' num2str(j)])
        else
            Sb = round(TD*Sampf)+1;  % begin sample
            Se = Sb + TrlSz -1;      % end sample
            %try
            if (Se < size(Data(:),1)/ChaNm)
                Nc = 1;
                for i = Chans
                    Ds = Data(:,ChnIdx == i);

                    [Ts, Tdx] = sort(Times(ChnIdx == i));
                    if any(diff(Tdx)-1)
                        Ds = Ds(:,Tdx);
                        disp('Warning, order error !!!!!')
                    end

                    SIG{Nc}(:,j) = Ds(Sb:Se);
                    Nc = Nc + 1;

                end
            else
                disp( ['Warning not enough data in trial: ' num2str(j)])
            end

            %catch
            %        disp Sb Se;
            %end
        end
    else
        disp(['No data for trial ' num2str(j) '. Reading error!!!!'] )
    end
end

H.CloseTank;
H.ReleaseServer;
close(F)

function SNIP = Exsniptimes(EVENT, Trials)
%SNIP = Exsniptimes(EVENT, Trials)
%
%Time stamps for snip data has already been retrieved and stored in the
%EVENT structure. Just retrieve it from EVENT and reorder in trials
%
%Returns a cell matrix (ST) :
%       1st dimension contains channel numbers
%       2nd dimension trial number
%       each element is an array or snip times
%
%usage in batch files:
%define the following variables in EVENT
%Input : EVENT.Triallngth = s; lenght of trial in seconds
%        EVENT.Start = s;      start of trial relative to stimulus onset
%
%       Trials : (double) array of stimulus onset times
%                returned by Exinf3.m
%
%Chris van der Togt, 24/03/2006
%updated 30/06/2006

%check if start and triallength exist
if ~isfield(EVENT, 'Start') || ~isfield(EVENT, 'Triallngth')
    errordlg('No Start or Triallngth defined');
    return
end


EvCode = EVENT.Myevent; %event code as string
Rt = strmatch(EvCode, {EVENT.snips(:).name} );
if isempty(Rt)
    errordlg([EVENT.Myevent ' is not a snip type event'])
    return
end 

if isfield(EVENT, 'CHAN')
    Chans = EVENT.CHAN;  %SELECTED CHANNELS
    [r,c] = size(Chans);
    if r > c
        %Chans has to be a column array
        Chans = Chans';
    end
end

Times = EVENT.snips(Rt).times;

 SNIP = cell(length(Chans), size(Trials,1));
 for j = 1:size(Trials,1)
            OnsTrl = Trials(j,1) + EVENT.Start;  %time where trial should start relative to stimulus onset
            EndTrl = OnsTrl + EVENT.Triallngth;  %time where trial should end, based on trial lenght
          %select time window starting one event epoch(Evtime) earlier and ending one 
          %event epoch later.
        
            Ncx = 1; %new channel index for selected channels
            for i = Chans
                %times reordered and relative to stim onset
                SNIP(i, j) = { Times{i}(Times{i} > OnsTrl & Times{i} < EndTrl) - Trials(j,1) };
                Ncx = Ncx + 1;
            end
        
 end



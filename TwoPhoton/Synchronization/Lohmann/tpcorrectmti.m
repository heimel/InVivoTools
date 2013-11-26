function [mti2,starttime] = tpcorrectmti(mti, filename,globaltime)

% TPCORRECTMTI - Correct NewStim MTI based on recorded times
%
% [MTI2,STARTTIME] = TPCORRECTMTI(MTI, STIMTIMEFILE,[GLOBALTIME])
%
%   Returns a time-corrected MTI timing file given actual timings
% recorded by the Spike2 machine and saved in a file named
% STIMTIMEFILE.
%
% GLOBALTIME is an optional argument.  If it is 1 then time is returned
% relative to the stimulus computer's clock.
%
% From FITZCORRECTMTI by Steve VanHooser
%

if nargin>2, globetime = globaltime; else, globetime = 0; end;

skip_correction=1;
if skip_correction
  warning('Skipping MTI correction');
  P(1)=1;
  P(2)=0;
  reftime = mti{1}.startStopTimes(2);    
else
  fid = fopen(filename);

  if fid<0, error(['Could not open file ' filename ', with error ' lasterr '.']); end;

  % first get multiplier between two timebases and then convert

  sp2_times = [];
  mac_times = [];
  mac_stimid = [];

  if length(mti)>1, % if more than one stim, then use stim start times to calc
    for i=1:length(mti),
      stimline = fgets(fid);
      stimdata = sscanf(stimline,'%f');
      sp2_times(end+1) = stimdata(2);
      mac_times(end+1) = mti{i}.startStopTimes(2);
      mac_stimid(end+1) = mti{i}.stimid;
      %if mac_stimid(end)~=stimdata(1), error(['Stim order from stim computer does not match that recorded in Spike2']); end;
      %disp(['Mac stim ' int2str(mac_stimid(end)) ', spike2 stim: ' int2str(stimdata(1)) '.']);
    end;
  else, % if less than one stim, then use frametimes to calc match
    stimline = fgets(fid);
    stimdata = sscanf(stimline,'%f');
    sp2_times = stimdata(3:end);
    mac_times = mti{1}.frameTimes';
    mac_stimid = mti{1}.stimid;
    if mac_stimid(end)~=stimdata(1), error(['Stim order from stim computer does not match that recorded in Spike2']); end;


    fseek(fid,0,'bof');
    stimline = fgets(fid);
    stimdata = sscanf(stimline,'%f');
    reftime = stimdata(2);  % should be mti{1}.startStopTimes(2)
    fclose(fid);
  end;

  warnstate = warning('query');
  warning off;
  P = polyfit(mac_times,sp2_times,1);
  warning(warnstate);

end


if 0,
  figure;
  plot(mac_times,sp2_times,'o');
  hold on;
  plot(mac_times,P(1)*mac_times+P(2),'g--');
end;

%fprintf(1,'P(1) is %0.15d\n',P(1));

% slope is time_spike2 / time_mac

mti2 = mti;

et = mti2{1}.startStopTimes(1);

% now convert back
for i=1:length(mti),
  mti2{i}.startStopTimes = et+(mti2{i}.startStopTimes-et)*P(1);
  mti2{i}.frameTimes = et+(mti2{i}.frameTimes-et)*P(1);
end;

starttime = mti2{1}.startStopTimes(2) - reftime;

if globetime,
  [pathstr,name]=fileparts(filename);
  g = load([pathstr filesep 'stims']);
  for i=1:length(mti),
    mti2{i}.startStopTimes = mti2{i}.startStopTimes+g.start-starttime;
    mti2{i}.frameTimes = mti2{i}.frameTimes + g.start-starttime;
  end;
end;
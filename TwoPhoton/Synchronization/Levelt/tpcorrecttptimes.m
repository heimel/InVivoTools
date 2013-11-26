function [newtimes,frame2dirnum] = tpcorrecttptimes(records)
% TPCORRECTTPTIMES - Corrects time for prairieview twophoton files
%
%   [FRAMETIMES,FRAME2DIRNUM] = ...
%     TPCORRECTTPTIMES({PARAMSTRUCT}, TIMEFILENAME)
%
%  Corrects the self-reported frame triggers of the PrairieView
%  two-photon to be consistent with the clock on the Spike2 
%  acquisition machine.
%
%  PARAMSTRUCT should be a cell list of parameter structures
%  associated with the PrairieView folder as returned by 
%  'readprairieconfig' function.  Each two-photon data
%  directory (i.e., TPDATA-001, TPDATA-002, etc) will
%  have its own PARAMSTRUCT, and these should passed in
%  a cell list (i.e., {PARAMSTRUCT001,PARAMSTRUCT002}).
%
%  TIMEFILENAME should be the name of a file that contains
%  timestamps of all triggers from the Prairie hardware
%  as measured on the Spike2 machine.
%
%  FRAMETIMES are the beginning times for each two-photon
%  frame, relative to the spike2 machine clock, measured in
%  seconds.
%
%  FRAME2DIRNUM is an array of numbers that indicate
%  which data directory corresponds to each recorded
%  frame.  For example, FRAME2DIRNAME(1) is the
%  data directory number that contains the data
%  for recorded two-photon frame 1.

%disp('TPCORRECTTPTIMES is not (yet) using frame trigger information');

tpsetup(records(1))


%starttime = 0; % if no stimulus file available
for i = 1:length(records)
    % use calibrated frametimes from fluoview tiff file
    params = tpreadconfig(records(i));
    %stims = getstimsfile( records(i) );
    %if isempty(stims)
    %    disp('TPCORRECTTPTIMES: No stimulus file present. Concatening to previous recording');
    %else
    %    starttime = stims.start;
    %end
    newtimes{i} = params.frame_timestamp; %#ok<AGROW> % +starttime ;
    frame2dirnum{i} = ones(size(newtimes{i})); %#ok<AGROW>
    %starttime = newtimes{i}(end) + (newtimes{i}(end)-newtimes{i}(end)); 
end


%if length(records)==1
%    params = tpreadconfig(records);
%    newtimes = params.frame_timestamp;
%    frame2dirnum = ones(size(newtimes));
%else
%    disp('TPCORRECTTPTIMES: arbitrarily making up starting times. should be avoided');
% %   starttime = 0;
%    for i=1:length(records)
%        starttime = str2double(records(i).epoch)*1000; 
%        params = tpreadconfig(records(i));
%        newtimes{i} = starttime + params.frame_timestamp ;
%        frame2dirnum{i} = ones(size(newtimes{i}));
%        starttime = newtimes{i}(end) + 60; % i.e. assume an arbitrary minute between subsequent epochs
%    end
%end

return


frame2dirnum = [];
havefile = 1;





if exist(filename,'file')
	spike2times = load(filename,'-ascii');
else
  havefile = 0; 
  spike2times = []; 
  tptime0 = 0;
  
  warning(['No frame time file ' filename ' available. Not correcting tptimes. ']);
  tpparam_times = [];

  for i=1:length(params),
    tpshifttime=0;
    frame2dirnum = [frame2dirnum repmat(i,1,length(params{i}.Image_TimeStamp__s_))];
    tpparam_times = [ tpparam_times tpshifttime + params{i}.Image_TimeStamp__s_ ];
  end
  newtimes=tpparam_times;
  return
end;

 % determine which signal is being recorded using record in directory
 % triggerSignal == 0 => PCO1 channel from BNC-2090 B
 % triggerSignal == 1 => start of frame trigger from BNC-2090 A

pathname = fileparts(filename);
try
	triggerSignal = load([pathname filesep 'twophotontriggermethod.txt'],'-ascii');
catch
  triggerSignal = 0;
end;

 % If we have triggerSignal == 0, we must see if we have one trigger per cycle or one trigger per frame
 % If we have triggerSignal == 1, we must make sure user recorded enough frames to have valid data and trim
 %                                   the extra trigger if the user is in max speed mode
total_param_frames = 0; nCycles = 0; onetriggerpercycle = 0; tobetrimmed = [];
spike2inc = 0;
totalcycleswmorethanoneframe = 0;

for i=1:length(params),
	total_param_frames = total_param_frames + length(params{i}.Image_TimeStamp__us_);
		% while we're here, make sure enough triggers were recorded for this to work
	totalframespershot = 0;
	nCycles = nCycles + params{i}.Main.Total_cycles;
	for j=1:params{i}.Main.Total_cycles,
		numImagesInCycle = getfield(getfield(params{i},['Cycle_' int2str(j)]),'Number_of_images');
		totalframespershot = totalframespershot + numImagesInCycle - 1;
		if numImagesInCycle>1, totalcycleswmorethanoneframe = totalcycleswmorethanoneframe + 1; end;
	end;
	if triggerSignal==1 && totalframespershot<1,
		error(['When using the Prairie counter triggers, there must be at least one frame that gives good triggers.\n'...
			'Note that the first image in a cycle is not triggered in this mode, ' ...
			'so one cycle must have at least 2 images.']);
	end;
end;

% if number of triggers is total_param_frames+nCycles, then max speed was used 
if (triggerSignal>0)&&(length(spike2times)==total_param_frames+totalcycleswmorethanoneframe),
	triggerSignal=2;  % max speed was used
	%spike2times = spike2times(setdiff(1:length(spike2times),tobetrimmed));
end;
if (triggerSignal==0)&&(length(spike2times)==nCycles), onetriggerpercycle = 1; end;

%triggerSignal, onetriggerpercycle,

 % catch trigger count errors
if (onetriggerpercycle==0&&total_param_frames~=length(spike2times))&&~(triggerSignal==2),
	error(['Number of twophoton times (' int2str(length(spike2times)) ...
			') does not equal number of cycles (' int2str(nCycles) ...
			') or number of frames (' int2str(total_param_frames) ...
			'); probably an extra trigger was recorded before acquisition; please remove any extra triggers from ' filename '.']);
end;


% three possibilities...triggerSignal==0&&onetriggerpercycle==0, triggerSignal==0&onetriggerpercycle==1, triggerSignal==1
%
%  our job is to create a set of ordered pairs with one entry of each pair corresponding to the Prairie computer's record
%    of when a particular frame occured (prairie_reported_trigs), and one entry corresponding to that recorded by the
%    spike 2 machine (spike_reported_trig).
%
%    We can then use these values to fit the clock drift between the two computers and specify the time of each two photon
%    frame relative to the spike 2 machine (including frames for which we have no trigger on the spike 2 machine).

prairie_reported_trig = [];  spike_reported_trig = [];
spike2inc = 0; % position index in spike2times

tpparam_times = [];

for i=1:length(params),
	params{i}.Image_TimeStamp__us_ = params{i}.Image_TimeStamp__us_*1e-6; % change to seconds
	
	% one thing we need to do for each params{i} is to calculate the time shift to global time; this is necessary
        % because every Prairie recording in a shot begins at T=0
        %  the variable to do this is tpshifttime, and is calculated differently for each case
	tpshifttime = Inf;
	if triggerSignal==0,
		tpshifttime = spike2times(spike2inc+1) - params{i}.Image_TimeStamp__us_(1);
	end;
	if triggerSignal==0 && onetriggerpercycle==0,
		prairie_reported_trig = [prairie_reported_trig params{i}.Image_TimeStamp__us_+tpshifttime];
		spike_reported_trig = [spike_reported_trig spike2times(spike2inc+1:spike2inc+length(params{i}.Image_TimeStamp__us_))];
		spike2inc = spike2inc + length(params{i}.Image_TimeStamp__us_);
	elseif triggerSignal==1,
		% the triggers come 300ms early in this mode
		tpshifttime = spike2times(spike2inc+1) + 0.3 - params{i}.Image_TimeStamp__us_(2);
		prairie_reported_trig = [prairie_reported_trig params{i}.Image_TimeStamp__us_(2:end)+tpshifttime];
		spike_reported_trig = [spike_reported_trig 0.3+spike2times(spike2inc+1:spike2inc-1+length(params{i}.Image_TimeStamp__us_))];
		spike2inc = spike2inc + length(params{i}.Image_TimeStamp__us_);
  else  % we have to dive into cycles
		offset = 1;
		for j=1:params{i}.Main.Total_cycles,
			numImagesInCycle = getfield(getfield(params{i},['Cycle_' int2str(j)]),'Number_of_images');
			if onetriggerpercycle, % also triggerSignal==0
				prairie_reported_trig = [prairie_reported_trig tpshifttime+params{i}.Image_TimeStamp__us_(offset)];
				spike_reported_trig = [spike_reported_trig spike2times(spike2inc+1);];
				spike2inc = spike2inc + 1;
      else  % triggerSignal==2
				if numImagesInCycle>1, % then we have triggers here
					if isinf(tpshifttime), % then we haven't found a time shift yet, so do it here
						tpshifttime = spike2times(spike2inc+1) - params{i}.Image_TimeStamp__us_(offset+1);
					end;
					prairie_reported_trig = [prairie_reported_trig ...
						tpshifttime+params{i}.Image_TimeStamp__us_(offset+1:offset+numImagesInCycle-1)];
					spike_reported_trig = [spike_reported_trig spike2times(spike2inc+1:spike2inc+numImagesInCycle-1)];
				end;
				% now snip out extra 2 triggers
				if spike2inc == 0 && numImagesInCycle==1, % catch special case
					start1 = 0; stop1 = -1;
					start2 = spike2inc+1+numImagesInCycle; % snip one trigger off of end of cycle
					stop2 = length(spike2times);
        else
					start1 = 1;
					stop1 = spike2inc+numImagesInCycle-1; % snip two triggers off of end
					start2 = stop1 + 2 + double(numImagesInCycle>1);  % cycles w/ numImages>1 have an extra extra trigger
					spike2inc = stop1;
				end;
				stop2 = length(spike2times); % this will actually not be the right thing for very last cycle, but won't hurt us
				spike2times = spike2times([start1:stop1 start2:stop2]);
			end;
			offset = offset + numImagesInCycle;
		end;
	end;
	frame2dirnum = [frame2dirnum repmat(i,1,length(params{i}.Image_TimeStamp__us_))];
	tpparam_times = [ tpparam_times tpshifttime + params{i}.Image_TimeStamp__us_ ];
end;

if length(spike_reported_trig)<3,
	newtimes = tpparam_times ;  % not enough data to make projection
else
	warnstate = warning('query'); warning off;
	P = polyfit(prairie_reported_trig,spike_reported_trig,1);
	newtimes = P(1)*tpparam_times+P(2);
end;

debugging = 0;

if debugging,
	figure;
	plot(prairie_reported_trig,spike_reported_trig,'-o');
	hold on
	plot(tpparam_times,newtimes,'rx--','linewidth',2);
end;


function [result,indimages] = tpsinglecondition(record, channel, thetrials, timeint, sponttimeint, plotit)

%  TPSINGLECONDITION - Simple image math
%
%  [RESULT,INDIMAGES] = TPSINGLECONDITION(RECORD,CHANNEL,
%        TRIALLIST,[T0 T1], [SP0 SP1], PLOTIT,NAME)
%
%    Computes simple image math for twophoton images.
%
%  RECORD is a record pointing to two-photon data. 
%  CHANNEL is the channel number to read.
%
%  
%  TRIALLIST is the trial numbers to include.  If it is empty, all
%     trials are included.
%
%  [T0 T1] is the time interval to analyze relative to stimulus onset.  If this
%   argument is empty then the stimulus duration is analyzed.
%
%  [SP0 SP1] is the time interval to analyze for computing the resting state
%   relative to stimulus onset. Default if empty is to analyze the
%   interval 2 seconds after the last stimulus until stimulus
%   onset.
%
%  INDIMAGES are individual single condition images in a cell list.
%  They are the same size as the images in RECORD, less 20 pixels
%  on a side that are trimmed.  These pixels are trimmed so that
%  the entire frame can be read even after drift correction.
%  Images that drift by more than 10 pixels will not be included in
%  the images.
%
%  RESULT is a cell list of composites of INDIMAGES, each one
%  containing a 3x3 composite of images in INDIMAGES.
%
%  If PLOTIT is 1, then the data is plotted as an image with title
%  NAME.

interval = []; spinterval = [];

stims = getstimsfile( record );
if isempty(stims) 
    % create stims file
    stiminterview(record);
    stims = getstimsfile( record );
end;

s.stimscript = stims.saveScript; 
s.mti = stims.MTI2;
[s.mti,starttime] = tpcorrectmti(s.mti,record);
do = getDisplayOrder(s.stimscript);

tottrials = length(do)/numStims(s.stimscript);

if isempty(thetrials), do_analyze_i = 1:length(do);
else
        do_analyze_i = [];
        for i=1:length(thetrials),
                do_analyze_i = cat(2,do_analyze_i,...
                fix(1+(thetrials(i)-1)*length(do)/tottrials):fix(thetrials(i)*length(do)/tottrials));
        end;
end;

for i=1:length(do_analyze_i),
        stimind = do_analyze_i(i);
        if ~isempty(timeint),
                interval(i,:) = s.mti{stimind}.frameTimes(1) + timeint;
        else
                interval(i,:) = [ s.mti{stimind}.frameTimes(1) s.mti{stimind}.startStopTimes(3)];
        end;

        dp = struct(getdisplayprefs(get(s.stimscript,do(i))));
        if ~isempty(sponttimeint),
                spinterval(i,:) = s.mti{stimind}.frameTimes(1) + sponttimeint;
        else
            BGpretime = dp.BGpretime;
            if isnan(BGpretime)
                BGpretime = 0;
            end
            BGposttime = dp.BGposttime;
            if isnan(BGposttime)
                BGposttime = 0;
            end

          if BGposttime > 0,  % always analyze before time
                spinterval(i,:)=[s.mti{stimind}.startStopTimes(1)-BGposttime+1 s.mti{stimind}.startStopTimes(1)];
                spinterval(i,:)=[s.mti{stimind}.startStopTimes(1)-BGposttime+1 s.mti{stimind}.startStopTimes(1)];
          elseif BGpretime > 0,
                spinterval(i,:)=[s.mti{stimind}.startStopTimes(1) s.mti{stimind}.frameTimes(1)];
          end;
        end;
end;

im = tppreview(record,2,1,channel); 
im_outline = zeros(size(im,1),size(im,2)); % get size from RGB preview image
im_outline(10:end-10,10:end-10) = 1; % set bulk to 1
pixinds = {find(im_outline==1)}; % find bulk pixels
im_outline = 0*im_outline(10:end-10,10:end-10); % remove sides from im_outline
 % now sort into individual stims

 for i=1:numStims(s.stimscript),
     disp(['Now working on image ' int2str(i) '.']);
     li = find(do(do_analyze_i)==i);
     myintervals = interval(li,:);
     data = tpreaddata(record,myintervals-starttime,pixinds,21,channel);
     indimages{i} = data{1,1} ;
     if ~isempty(spinterval) % if spontaneous data taken
         myspintervals = spinterval(li,:);
         datasp = tpreaddata(record,myspintervals-starttime,pixinds,21,channel);
         indimages{i} = indimages{i} - datasp{1,1}; % remove spontaneous
     end
     indimages{i} = reshape(indimages{i},size(im_outline,1),size(im_outline,2));
     % indimages{i} = conv2(indimages{i},ones(5)/sum(sum(ones(5))),'same'); % spatial smoothing
     indimages{i} = spatialfilter(indimages{i},2); % spatial smoothing
 end;

if 0,
for i=1:numStims(s.stimscript),
	li = find(do(do_analyze_i)==i);
	myim = im_outline;
	if ~isempty(li),
		indimages{i}=nanmean(cat(3,data{li,1}),3)-nanmean(cat(3,data{li+size(interval,1),1}),3);
		indimages{i}=reshape(indimages{i},size(im_outline,1),size(im_outline,2));
		indimages{i}=conv2(indimages{i},ones(5)/sum(sum(ones(5))),'same');
	end;
end;
end;

i = 1; r = 1;
edge = 3 ;
width = size(indimages{1},1) +edge;
height = size(indimages{1},2) + edge;
while i<=numStims(s.stimscript),
	imstart = i;
	im_ = zeros(3*width,3*height);
	ctr = [ ];
	for j=1:3,
		for k=1:3,
			if i<=numStims(s.stimscript),
				im_(1+(j-1)*width:j*width-edge,1+(k-1)*height:k*height-edge)=indimages{i};
				ctr(end+1,1:2)=[median(1+(j-1)*size(indimages{i},1):j*size(indimages{i},1)) median(1+(k-1)*size(indimages{i},2):k*size(indimages{i},2))];
				i=i+1;
			end;
		end;
	end;
	imend = i-1;
	if plotit,
		imagedisplay(im_,'Title',['Single conditions ' int2str(imstart) ' to ' int2str(imend) '.']);
	end;
	result{r} = im_;
	r = r + 1;
end;

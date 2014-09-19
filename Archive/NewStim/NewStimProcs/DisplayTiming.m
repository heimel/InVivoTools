function [MTI] = DisplayTiming(stimScript)

if ~isloaded(stimScript),
	error('DisplayTiming error: stimScript not loaded.');
end;

% l = numStims(stimScript);

MTI = cell(0);

StimWindowGlobals;

dispOrder = getDisplayOrder(stimScript);

for i=1:length(dispOrder)
	df = struct(getdisplayprefs(get(stimScript,dispOrder(i))));
	ds = struct(getdisplaystruct(get(stimScript,dispOrder(i))));
	if (strcmp(ds.displayType,'CLUTanim'))|(strcmp(ds.displayType,'Movie')), %#ok<OR2>
		if max(df.frames) > ds.frames, error(['Error: frames to display in ' ...
		     'displaypref less than actual number of frames in displaystruct.']); end;
		if min(df.frames) < 1, error(['Error: frames to display in ' ...
		     'displaypref out of bounds (less than first frame).']); end;
		% the following line is necessary because SetClut takes 1 refresh
		if strcmp(ds.displayType,'CLUTanim'), sft=1; else, sft=0; end;
		pauseRefresh = zeros(1,length(df.frames));
		if df.roundFrames,
			pauseRefresh(:) = round(StimWindowRefresh / df.fps)-sft;
		else,
			pauseRefresh = diff(fix((1:(length(df.frames)+1)) * StimWindowRefresh / df.fps))-sft;
		end;
		frameTimes = zeros(size(pauseRefresh));
	else,
		if (strcmp(ds.displayType,'custom'))
			eval([ds.displayProc '(-1,[],ds,df);']); % get proc in memory
		end;
		frameTimes = [];
		pauseRefresh = [];
	end;
	startStopTimes = [ 0 0 0 0];
	preBGframes = fix(df.BGpretime * StimWindowRefresh);
	postBGframes = fix(df.BGposttime * StimWindowRefresh);
	MTI{i} = struct('preBGframes', preBGframes, 'postBGframes', postBGframes, ...
	                'pauseRefresh', pauseRefresh, 'frameTimes', frameTimes, ...
					'startStopTimes', startStopTimes, 'ds', ds, 'df', df);
end;

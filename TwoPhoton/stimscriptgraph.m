function [stims, stimlabels] = stimscriptgraph(record, plotit)

%  STIMSCRIPTGRAPH - Graph of stimulus times for Fitzlab data
%
%  [STIMS,STIMLABELS]= STIMSCRIPTGRAPH(RECORD, PLOTIT)
%
%    Prepares the stimulus history for plotting on a graph.  STIMS is a list
%  of ordered pairs; when the first column is plotted against the second,
%  the stimuli appear as step to 1, and interstimulus time appears as 0.
%  STIMLABELS is a struct with labels for each stimulus; it has fields
%  'x','y', and 'label'.
%  
%  If PLOTIT is 1 then the stimulus history is plotted in the current axes.%
%  The axes will be rescaled to show the whole record.
%  
stims = getstimsfile( record );
if isempty(stims)
    stiminterview(record);
    stims = getstimsfile( record );
end
s.stimscript = stims.saveScript; s.mti = stims.MTI2;
[s.mti,starttime]=tpcorrectmti(s.mti,record);
do = getDisplayOrder(s.stimscript);

stims = [ 0 0 ];
stimlabels = struct('x','','y','','label',''); stimlabels = stimlabels([]);

for i=1:length(do),
	stims(end+1,:) = [s.mti{i}.startStopTimes(2)-starttime 0];
	stims(end+1,:) = [s.mti{i}.startStopTimes(2)-starttime 1];
	stims(end+1,:) = [s.mti{i}.startStopTimes(3)-starttime 1];
	stims(end+1,:) = [s.mti{i}.startStopTimes(3)-starttime 0];
	stimlabels(end+1) = ...
		struct('x',mean(s.mti{i}.startStopTimes(2:3)-starttime),...
			'y',2,'label',[int2str(do(i))]); % ',t' int2str(1+floor(i/numStims(s.stimscript)))]);
end;

if plotit,
	hold on;
	plot(stims(:,1),stims(:,2),'g');
	for i=1:length(stimlabels), text(stimlabels(i).x,stimlabels(i).y,stimlabels(i).label,'horizontalalignment','center'); end;
	A = axis; axis([min(stims(:,1)) max(stims(:,1)) 0 3]);
end;

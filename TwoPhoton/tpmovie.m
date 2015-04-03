function M = tpmovie(record, channel, trials, thestims, sorted, diffnc, filename) 
%  TPMOVIE - Movie of two-photon data
%
%  MOVIE=TPMOVIE(RECORD, CHANNEL, TRIALS, STIMS, SORT, DIFF, FILENAME, MOVIETYPE)
%
%    Computes a movie for two-photon data that is linked to the
%  stimulus presentation.  DIRNAME is the name of the directory.
%
%  CHANNEL is the channel to read.
%
% TRIALS is an array list of trial numbers to include.  The stimuli are assumed
%   to have been run in repeating blocks.  If this argument is not present or is
%   empty then all trials are included.
%
% STIMS is an array list of stim numbers to include. If this argument is not
%   present or is empty then all stimuli are included.
%
% SORT is 0/1; if it is 1, then the stimuli are shown in numerical order.
% DIFF is 0/1; if it is 1, then the difference between the first five frames
%        and the remaining frames are shown; otherwise, the raw data is shown.
%
% FILENAME is the name of the output AVI file.
%
%
% 200X-200X Steve Van Hooser, 200X-2014 Alexander Heimel
%

if nargin<7
    filename = '';
end
if nargin<6
    diffnc = [];
end
if isempty(diffnc)
    diffnc = 0;
end
if nargin<5
    sorted = [];
end
if isempty(sorted)
    sorted = 0;
end
if nargin<4
    thestims = [];
end
if nargin<3
    trials = [];
end

logmsg(['Creating movie for ' recordfilter(record)]);
logmsg(['Set movie_sync_factor or movietype']);

params = tpprocessparams(record);
cfg = tpreadconfig( record );

movietype = params.movietype; %'plain';

fps = 1/cfg.frame_period * params.movie_sync_factor;

if isempty(filename)
    fname = [record.date '_' record.epoch '_' movietype];
     fname = fullfile(experimentpath(record),fname);
end


pvfilename = tpscratchfilename( record, 1, 'preview');
load(pvfilename);
mx = [];
mn = [];
gamma = [];
channels = [];
h = figure;
[previewim,mxbg,mnbg,gamma] = tp_image(pvimg,channels,mx,mn,gamma,tp_channel2rgb(record));
bgim = get(previewim,'cdata');
close(h);
clear('pvimg');

stims = getstimsfile( record );
if isempty(stims)
    stiminterview(record);
    stims = getstimsfile( record );
end;
s.stimscript = stims.saveScript; s.mti = stims.MTI2;
[s.mti,starttime]=tpcorrectmti(s.mti,record);
do = getDisplayOrder(s.stimscript);

tottrials = length(do)/numStims(s.stimscript);

if isempty(trials)
    trials = 1:tottrials; 
end
if isempty(thestims)
    thestims = 1:numStims(s.stimscript); 
end
do_analyze_i = [];


for i=1:length(trials),
	thistrial = fix(1+(trials(i)-1)*length(do)/tottrials):fix(trials(i)*length(do)/tottrials);
	[dummy,thesestims] = intersect(do(thistrial),thestims); thesestims = sort(thesestims);
	do_analyze_i = cat(2,do_analyze_i,thistrial(thesestims));
end;

if sorted,
	[dummy,newinds] = sort(do(do_analyze_i));
	do_analyze_i = do_analyze_i(newinds);
end;

notvisited = 1:length(do_analyze_i);

interval = [];

while ~isempty(notvisited),
	di = diff(do_analyze_i(notvisited));
	norun = find(di~=1);
	if isempty(norun),
		rununtil = notvisited(end);
    else
        rununtil = notvisited(norun(1));
	end;
	%notvisited(1), rununtil,
	interval(end+1,:) = [s.mti{do_analyze_i(notvisited(1))}.startStopTimes(2) - 4 ...
				s.mti{do_analyze_i(rununtil)}.startStopTimes(3) + 2 ];
	notvisited = (rununtil+1):length(do_analyze_i);
end;

pv=tppreview(record,5,1,channel);
pv = pv(:,:,channel);
im=zeros(size(pv));
borderwidth = min(10,round(min(size(pv))/2)-10);
im(1+borderwidth:end-borderwidth,1+borderwidth:end-borderwidth)=1;
pixels=find(im==1);
im=im(1+borderwidth:end-borderwidth,1+borderwidth:end-borderwidth);
pv=pv(1+borderwidth:end-borderwidth,1+borderwidth:end-borderwidth);
bgim=bgim(1+borderwidth:end-borderwidth,1+borderwidth:end-borderwidth,:);

[data,t] = tpreaddata(record,interval-starttime,{pixels},0,channel);


show_stim = false;
logmsg('Turned off showing stimulus times. Change show_stim to true in code');

if show_stim
    height_stim = 100;
    figure('position',[100 100 size(im,2) size(im,1)+height_stim],'toolbar','none','menu','none');
    ax1 = axes('units','pixels','position',[0 50 size(im,2) height_stim]); % for stim data
    [stimgraph, stimlabels] = stimscriptgraph(record,1);
    ind_s = find(stimgraph(:,2)==1);
    stimints = reshape(stimgraph(ind_s,1),2,length(stimgraph(ind_s,1))/2)';
    ax2 = axes('units','pixels','position',[0 height_stim size(im,2) size(im,1)]); % for image data
else
    figure('position',[100 100 size(im,2) size(im,1)],'toolbar','none','menu','none');
    ax2 = axes('units','pixels','position',[0 0 size(im,2) size(im,1)]); % for image data
    
end
colormap(gray(256));
H = gcf;



mx=0; mn=10000;
for i=1:size(interval,1),
	frameshere = reshape(data{i,1},size(im,1),size(im,2),length(data{i,1})/(size(im,1)*size(im,2)));
	for k=1:size(frameshere,3),
		myframe = conv2((frameshere(:,:,k)-diffnc*pv),ones(1,1)/(sum(sum(ones(1,1)))),'same');
		mxh=max(max(myframe));
		mnh=min(min(myframe));
		mx=max([mxh mx]);mn=min([mnh mn]);
	end;
end;
 
%if diffnc, mn= 0; end;
M = struct('cdata',[],'colormap',[]); 
M = M([]);

hh = [];

bgmode = mode(flatten(round(bgim(:,:,2)*mxbg(channel))));
template = round(bgim(:,:,2)*mxbg(channel))-bgmode;
template = template/max(template(:));

for i=1:size(interval,1),
	frameshere = reshape(data{i,1},size(im,1),size(im,2),length(data{i,1})/(size(im,1)*size(im,2)));
	timehere = reshape(t{i,1},size(im,1),size(im,2),length(data{i,1})/(size(im,1)*size(im,2)));
	for k=1:size(frameshere,3),
        if show_stim
            tm = sum(sum(timehere(:,:,k)))/(size(im,1)*size(im,2));
            axes(ax1);
            if ishandle(hh), delete(hh); end;
            hold on;
            hh = plot([tm tm],[0 3],'k--');
            axis([tm-3 tm+3 0 4]);
            if ~isempty(find(stimints(:,1)<=tm&stimints(:,2)>=tm)),
                set(ax1,'Color',[1 0 0]);
            else
                set(ax1,'Color',[1 1 1]);
            end;
            ch=get(ax1,'children');set(ax1,'children',[ch(2:end);ch(1)]);
        end
        axes(ax2); cla; 
		myframe = conv2((frameshere(:,:,k)-diffnc*pv),ones(1,1)/(sum(sum(ones(1,1)))),'same');
		%image(rescale(myframe,[mnbg(channel) mxbg(channel)],[0 256]));
		set(ax2,'xtick',[],'ytick',[]);
        
        deltaf = myframe - bgim(:,:,2)*mxbg(channel);
        deltafoverf = deltaf ./  (bgim(:,:,2)*mxbg(channel));
        deltafoverf = (template>0).*deltafoverf;
        deltafoverf = spatialfilter( deltafoverf,4,'pixel');
        deltafoverf = rescale(deltafoverf,[0 0.2],[0 1]);

        switch movietype
            case 'twocolor'
                img = bgim;
                img(:,:,3) = deltafoverf .* (template>0) .* template.^.5;
                img(:,:,2) = img(:,:,2) + 0.3*img(:,:,3); %deltafoverf;
                img(:,:,1) = img(:,:,1) + 0.3*img(:,:,3); %deltafoverf;
                img = rescale(img,[0 1],[0 1]);
            case 'plain'
                img(:,:,3) = deltafoverf;
        end
        
        image(img);
        axis off
		M(end+1) = getframe(H);
	end;
end;

movie2avi(M,filename,'FPS',fps,'compression','none');

[pathname,filenameonly,fileext] = fileparts(filename);
copyfile(filename,fullfile(getdesktopfolder,[filenameonly fileext]));

close(H);
logmsg('On linux, use avconv to convert and avidemux to cut movie');


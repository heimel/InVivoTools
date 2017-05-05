function record = analyse_pupiltestrecord( record, verbose )
%ANALYSE_PUPILTESTRECORD analyses pupil testrecord
%
%  RECORD = ANALYSE_PUPILTESTRECORD( RECORD, VERBOSE=true )
%
% 2017, Alexander Heimel
%

if nargin<2 || isempty(verbose)
    verbose = true;
end

par = pupilprocessparams( record );

% load pupil data
datapath = experimentpath( record );
pupil_xy = load(fullfile(datapath,'pupil_xy.txt'),'-ascii');
pupil_area = load(fullfile(datapath,'pupil_area.txt'),'-ascii');
pupil_t = (pupil_area(:,1)-pupil_area(1,1))/1e9 + par.pupil_timeshift;

sampletime = median(diff(pupil_t)); % s

vars = {'pupil_x','pupil_y','pupil_r','pupil_s','pupil_d'};
n_vars = length(vars);

pupil_xyrs = NaN(size(pupil_xy,1),n_vars);
pupil_xyrs(:,1) = pupil_xy(:,2);
pupil_xyrs(:,2) = pupil_xy(:,3);
pupil_xyrs(:,3) = sqrt(pupil_area(:,2));

% ind_nanstart = find(pupil_xyrs(:,3)==0,1);
% while ~isempty(ind)
%     ind

ind_nan = pupil_xyrs(:,3)==0;
for v = 1:n_vars
    pupil_xyrs(ind_nan,v) = NaN;
end

% set average position to 0,0
pupil_xyrs(:,1) = pupil_xyrs(:,1) - nanmedian(pupil_xyrs(:,1));
pupil_xyrs(:,2) = pupil_xyrs(:,2) - nanmedian(pupil_xyrs(:,2));

% median filtering
span = round(par.averaging_window/sampletime);
pupil_xyrs(:,3) = movmedian( pupil_xyrs(:,3),span,'omitnan','Endpoints','fill');
pupil_xyrs(:,1) = movmedian( pupil_xyrs(:,1),span,'omitnan','Endpoints','fill');
pupil_xyrs(:,2) = movmedian( pupil_xyrs(:,2),span,'omitnan','Endpoints','fill');

% smoothing
for i = 1:3
    pupil_xyrs(:,i) =  smooth(pupil_xyrs(:,i),span,'sgolay');
end

% change to degrees
for i = 1:3
    pupil_xyrs(:,i) =  asin(pupil_xyrs(:,i)/par.eye_radius_pxl)/pi*180;
end

% compute speed
pupil_xyrs(2:end,4) =  sqrt(diff(pupil_xyrs(:,1)).^2 + diff(pupil_xyrs(:,2)).^2) / sampletime; % degrees per second
pupil_xyrs(:,4) =  smooth(pupil_xyrs(:,4),span,'sgolay');

% displacement from average position
pupil_xyrs(:,5) =  sqrt(pupil_xyrs(:,1).^2 + pupil_xyrs(:,2).^2); % pixels 

stims = getstimsfile(record);

% plot raw data
if verbose
    figure
    yyaxis left
    plot(pupil_t,pupil_xyrs(:,3));
    hold on
    plot_stimulus_timeline(stims)
    yyaxis right
    plot(pupil_t,pupil_xyrs(:,4));
    plot(pupil_t,pupil_xyrs(:,1));
    plot(pupil_t,pupil_xyrs(:,2));
end

scriptpars = getparameters(stims.saveScript);
stimuli = get(stims.saveScript);
stimpars = cellfun(@getparameters,stimuli);

% get stimulus parameter
paramname = varied_parameters(stims.saveScript);
if isempty(paramname)
    logmsg('No parameter varied');
    paramname = {'imageType'};
end

ind = find(strcmp(record.stim_type,paramname));
if isempty(ind)
    paramname = paramname{1};
else
    paramname = paramname{ind};
end

binwidth = 1 * sampletime;
stimduration = duration(stimuli{1}); % duration(stims.saveScript)/length(stims.MTI2);
n_bins = ceil(stimduration / binwidth + 1);
dp = struct(getdisplayprefs(stimuli{1}));
t = (0:binwidth:(n_bins-1)*binwidth) - dp.BGpretime;
n_presentations = length(stims.MTI2); % total number of stimuli shown

% get responses from data
xyrs_all = NaN( n_presentations, n_bins, n_vars );
for i = 1:n_presentations
    ind = find(pupil_t > stims.MTI2{i}.startStopTimes(1)-stims.start & pupil_t < stims.MTI2{i}.startStopTimes(4)-stims.start);
    ind = ind(1:min([end,length(t)]));
    xyrs_all(i,1:length(ind),:)  = pupil_xyrs( ind,:);
end

displayorder = getDisplayOrder(stims.saveScript);
range = scriptpars.(paramname);
measures.xyrs_mean = NaN( length(range), n_bins,3);
measures.xyrs_sem = NaN( length(range), n_bins,3);

ind_stimtime = find(t>0);
ind_pretime = (t<0  & t>t(1)+par.separation_from_prev_stim_off );

measures.variable = paramname;
measures.range = range;

% mean response
measures.adaptation_pupil_r = nanmean(xyrs_all(:,ind_stimtime,3),2);
measures.psth_t = t;

for i = 1:length(range)
    if isnumeric(range(i))
        crit = [paramname '=' num2str(range(i))];
    else
        crit  = [paramname '=' range{i}];
    end
    if ~isempty(record.stim_parameters)
        crit = [crit ',' record.stim_parameters]; %#ok<AGROW>
    end
    ind_stims = find_record(stimpars,crit);
    ind = [];
    for j = ind_stims
        ind = [ind find(displayorder==j)]; %#ok<AGROW>
    end
    
    % xyr_response is mean over time post stimulus onset minus
    %      mean over time pre stimulus onset
    % xyr_response(n_stimuli,{x,y,r})
    xyrs_pretime = nanmean(xyrs_all(:,ind_pretime,:),2) ;

    
    xyrs_response = nanmean(xyrs_all(:,ind_stimtime,:),2) - ...
        xyrs_pretime;
    
   
    
    for v = 1:n_vars
        measures.(vars{v})(i) = nanmean(xyrs_response(ind,v)); % mean over stims
        measures.([vars{v} '_sem'])(i) = nanstd(xyrs_response(ind,v))/sqrt(length(ind));
        measures.(['psth_' vars{v}])(i,:) = nanmean(xyrs_all(ind,:,v)); % mean over stims
        measures.(['psth_' vars{v} '_sem'])(i,:) = nanstd(xyrs_all(ind,:,v))/sqrt(length(ind));
        measures.([vars{v} '_baseline'])(i) =  nanmean(xyrs_pretime(ind,v)); % mean over stims
    end % var v
end % range i
for v = 1:n_vars
    measures.([vars{v} '_baseline']) = nanmean(measures.([vars{v} '_baseline']));
end
record.measures = measures;



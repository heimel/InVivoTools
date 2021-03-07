function measures=analyse_ps( inp , record, verbose)
%ANALYSE_PS analyses periodic stimulus ecdata
%   works whenever only one stimulus parameter is varied
%
%  MEASURES = ANALYSE_PS( INP, RECORD, VERBOSE)
%
% 2007-2019, Alexander Heimel
%

if nargin<3 || isempty(verbose)
    verbose = true;
end

processparams = ecprocessparams(record);

measures.usable=1;

paramname = varied_parameters(inp.st.stimscript);
if isempty(paramname)
    logmsg('No parameter varied');
    paramname = {'imageType'}; % or 'angle' or 'duration'
end

ind = find(strcmp(record.stim_type,paramname));  
if isempty(ind)
    paramname = paramname{1};
else
    paramname = paramname{ind};
end

inp.paramname = paramname; % for tuning_curve
inp.paramnames = {paramname}; % for periodic_curve
if isfield(record,'stim_parameters')
    inp.selection = record.stim_parameters; % selection like, 'contrast=0.4,angle=180'
else
    inp.selection = '';
end

[sts,triggers] = split_stimscript_by_trigger( inp.st );
for t = 1:length(sts)
    inps(t)  = inp; %#ok<AGROW>
    inps(t).st = sts(t); %#ok<AGROW>
end

for i = 1:length(triggers) 
    inp = inps(i);
    measures.triggers = triggers;
    
    par = struct('res',processparams.ec_binwidth,'showrast',0,'interp',3,'drawspont',1,...
        'int_meth',0,'interval',[0 0]);
    
%     if processparams.post_window(2)<Inf
%         logmsg('For Koen')
%         par.interval = [0 processparams.post_window(2)];
%         par.int_meth = 1;
%     end
    
    if verbose  % dont show for more than 5 cells
        where.figure = figure;
        where.rect = [0 0 1 1];
        where.units = 'normalized';
    else
        where = []; % turn off extra figure
    end
    tc = tuning_curve(inp,par,where,record);
    out(i) = getoutput(tc); %#ok<AGROW>
    % out.curve contains per responses
    % (1,:) parameter value
    % (2,:) average firing rate
    % (3,:) std firing rate
    % (4,:) sem in firing rate (std/sqrt(trials))
    
    curve = out(i).curve;     
    if isempty(curve)
        return
    end
    
%     if processparams.post_window(2)<Inf
%         logmsg('For Koen')
%         ch = get(where.figure,'children');
%         set(ch(4),'xlim', [processparams.pre_window(1) processparams.post_window(2)]);
%         set(ch(5),'xlim', [processparams.pre_window(1) processparams.post_window(2)]);
%     end

    
    measures.curve{i} = curve;
    measures.rate_spont{i} = out(i).spont(1);
    [measures.rate_max{i}, ind_pref] = max(curve(2,:));
    measures.response_max{i} = measures.rate_max{i} - measures.rate_spont{i};
    if measures.rate_max{i}>0 % i.e.spikes
        measures.preferred_stimulus{i} = curve(1,ind_pref);
    else
        measures.preferred_stimulus{i} = NaN;
    end
    measures.range{i} = curve(1,:);
    
    if processparams.compute_f1f0 && isa(inp.st.stimscript,'periodicscript')
        pc = periodic_curve(inp,'default',[],record);
        pc_out = getoutput(pc);
        mf0 = max(pc_out.f0curve{1}(2,:));
        mf1 = max(pc_out.f1curve{1}(2,:));
        measures.f1f0{i} = mf1/mf0 ;
    end
    
    % RESPONSE is RATE MINUS SPONTANEOUS
    % normalization by max for trigger 1 only
    measures.rate{i} = curve(2,:);
    measures.rate_normalized{i} = measures.rate{i} / measures.rate_max{1};
    measures.rate_max_normalized{i} = measures.rate_max{i} / measures.rate_max{1};
    measures.rate_difference{i} = measures.rate{i} - measures.rate{1};
    measures.response{i} = curve(2,:) - measures.rate_spont{i};
    measures.response_normalized{i} = measures.response{i} / measures.response_max{1};
    measures.response_max_normalized{i} = measures.response_max{i} / measures.response_max{1};
    measures.response_difference{i} = measures.response{i} - measures.response{1};
    
    %  compute peak time for preferred stimulus
    rast=getoutput(out(i).rast);
    binsize = (rast.bins{1}(end)-rast.bins{1}(1))/(length(rast.bins{1})-1);
    maxbins = min(cellfun(@length,rast.counts));
    
    rastcount_max = zeros(1,maxbins);%length decreased because it can fluctuate with one
    ind = find(measures.range{i}==measures.preferred_stimulus{i});
    for j=ind
        rastcount_max = rastcount_max+rast.counts{j}(1:length(rastcount_max))/rast.N(j);
    end
      measures.fano{i} = mean(rast.fano(ind));
    rastcount_max = rastcount_max/length(ind);
    
    rastcount_all = zeros(1,maxbins);
    for j=1:length(rast.counts)
        rastcount_all = rastcount_all+rast.counts{j}(1:length(rastcount_all))/rast.N(j);
    end
    rastcount_all = rastcount_all/length(rast.counts);

    tbins = binsize*((1:maxbins)-0.5);

    % add spontaneous raster
    spontrast =  getoutput(out(i).spontrast);
    tbins_all = [spontrast.bins{1} tbins];
    if length(unique(tbins_all))~=length(tbins_all)
        tbins_all = tbins;
    else
        rastcount_all = [spontrast.counts{1}/spontrast.N rastcount_all]; %#ok<AGROW>
    end
    
    measures.psth_tbins{i} = tbins;
    measures.psth_count{i} = rastcount_max;

    measures.psth_tbins_all{i} = tbins_all;
    measures.psth_count_all{i} = rastcount_all;
    
    measures.psth_count_raw{i} = rast.counts;
    
    filterwidth = 0.05/binsize; % 50 ms width = too broad for onset times!
    rastcount_max = spatialfilter(rastcount_max,filterwidth);
    [ind_max_label,ind_max] = max(rastcount_max); %#ok<ASGLU>
    measures.time_peak{i} = ind_max*binsize;
    
    % peak time all stimuli
    rastcount_allf = spatialfilter(rastcount_all,filterwidth);
    [~,ind_max] = max(rastcount_allf);
    measures.time_peak_all{i} = tbins_all(ind_max);
    
    % onset latency
    filterwidth = 0.02/binsize; % 20 ms width = too broad for onset times!
    rastcount_allf = spatialfilter(rastcount_all,filterwidth);
    %     dcount_all = diff(rastcount_allf);
    %     ddcount_all = diff(dcount_all);
    %     maxpre = max(ddcount_all(1:find(tbins_all>0,1)));
    ind0 = find(tbins_all>0,1);
    meanpre = mean(rastcount_allf(1:ind0));
    stdpre = std(rastcount_allf(1:ind0));
    %     ind_max = find(ddcount_all>maxpre,1);
    ind_latency = ind0-1+find(rastcount_allf(ind0:end)>meanpre+2*stdpre,1);
    measures.time_onsetlatency_all{i} = tbins_all(ind_latency);
    
end % trigger i

if length(inps)==1
    measures.curve = measures.curve{1};
else
    % ugly code to compute friedman test
    count = zeros(length(measures.curve),length(rast.values),size(rast.values{1},2)); % triggers x range x repetitions
    for i=1:length(measures.curve)
        rast = getoutput(out(i).rast);
        for j=1:length(rast.values)
            count(i,j,:) = sum(rast.values{j}) ;
        end
    end
    
    reps = size(count,3);
    x = zeros(size(count,2)*reps,length(measures.curve));
    for i=1:length(measures.curve)
        c = 1;
        for j=1:size(count,2)
            for r=1:reps
                x(c,i) = count(i,j,r);
                c = c+1;
            end
        end
    end
    
    try
        measures.friedman_p = friedman(x,reps,'off');
    catch
        measures.friedman_p = [];
    end
end


spikes=get_data(inp.spikes,[inp.st.mti{1}.startStopTimes(2),inp.st.mti{end}.startStopTimes(3)]);
if processparams.ec_compute_spikerate_adaptation && ~isempty(spikes) && length(spikes)>2 
    isi = spikes(2:end)-spikes(1:end-1);
    isitimes=(spikes(2:end)+spikes(1:end-1))/2;
    isitimes = isitimes - isitimes(1); % to avoid warning in polyfit
    pfit = polyfit(isitimes,isi,1);
    isi_start = pfit(1)*isitimes(1)+pfit(2);
    isi_end = pfit(1)*isitimes(end)+pfit(2);
    mean_rate = 1/mean(isi);
    measures.rate_change_global = (1/isi_end - 1/isi_start)/(isitimes(end)-isitimes(1)) / mean_rate ;
else
    measures.rate_change_global = NaN;
end



measures.variable = paramname;
switch lower(measures.variable)
    case 'contrast'
        measures = compute_contrast_measures(measures);
    case 'angle'
        measures = compute_angle_measures(measures); % also shifts range around preferred
    case 'gnddirection'
        measures = compute_angle_measures(measures);
    case 'size'
        measures = compute_size_measures(measures,inp.st,record);
    case 'location'
        measures = compute_position_measures(measures,inp.st);
    case 'tfrequency'
        measures = compute_tfrequency_measures(measures);
    case 'sfrequency'
        measures = compute_sfrequency_measures(measures);
end
% New postanalyses tests with variable stimnumber are called at the bottom
% of analyse_ectestrecord, and should be given in record.analysis field

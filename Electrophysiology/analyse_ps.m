function measures=analyse_ps( inp , record, verbose)
%ANALYSE_PS analyses periodic stimulus ecdata
%   works whenever only one stimulus parameter is varied
%
%  MEASURES=ANALYSE_SG( INP , RECORD, verbose)
%
%
% 2007-2013 Alexander Heimel
%

if nargin<3
    verbose = [];
end
if isempty(verbose)
    verbose = true;
end

measures.usable=1;

paramname = varied_parameters(inp.st.stimscript);
if isempty(paramname)
    disp(['ANALYSE_PS: No parameter varied']);
    paramname = {'angle'};
    paramname = {'imageType'};
end

ind = strmatch(record.stim_type,paramname);  % notice: changed from record.stim_parameters 2013-03-29!
if isempty(ind)
%     disp(['ANALYSE_PS: Parameter ' record.type ' is not varied, but trying anyway']);
%     if isfield(getparameters(inp.st.stimscript),record.stim_parameters)
%         paramname = record.stim_parameters;
%     else
%         disp(['ANALYSE_PS: Parameter ' record.stim_parameters ' for mouse ' record.mouse ',date ' record. date ' is not a parameter']);
%         paramname = 'angle';
%     end
    paramname = paramname{1};
else
    paramname = paramname{ind};
end


%inp.paramnames=paramname; % for periodic_curve
inp.paramname = paramname; % for tuning_curve
inp.selection = record.stim_parameters; % selection like, 'contrast=0.4,angle=180'
%triggers = uniq(sort(getTrigger(inp.st.stimscript)));

%inp.st = select_stimuli( inp.st, record.stim_parameters);

%if length(triggers)>1 % i.e. more than one type of trigger
[sts,triggers] = split_stimscript_by_trigger( inp.st );
for t = 1:length(sts)
    inps(t)  = inp;
    inps(t).st = sts(t);
end

for i = 1:length(triggers) 
    inp = inps(i);

    measures.triggers = triggers;
    
    %where.figure=figure;where.rect=[0 0 1 1]; where.units='normalized';
    %orient(where.figure,'landscape');
    par = struct('res',0.01,'showrast',0,'interp',3,'drawspont',1,...
        'int_meth',0,'interval',[0 0]);
    
    
    
    if verbose  % dont show for more than 5 cells
        where.figure=figure;
        where.rect=[0 0 1 1];
        where.units='normalized';
    else
        where = []; % turn off extra figure
    end
    tc = tuning_curve(inp,par,where);
    out(i) = getoutput(tc);
    % out.curve contains per responses
    % (1,:) parameter value
    % (2,:) average firing rate
    % (3,:) std firing rate
    % (4,:) sem in firing rate (std/sqrt(trials))
    
    curve = out(i).curve;     
    if isempty(curve)
        return
    end
    measures.curve{i} = curve;
    measures.rate_spont{i} = out(i).spont(1);
    [measures.rate_max{i} ind_pref] = max(curve(2,:));
    measures.response_max{i} = measures.rate_max{i} - measures.rate_spont{i};
    if measures.rate_max{i}>0 % i.e.spikes
        measures.preferred_stimulus{i} = curve(1,ind_pref);
    else
        measures.preferred_stimulus{i} = NaN;
    end
    measures.range{i} = curve(1,:);
    
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
    
    %    tempst = getparameters(inp.st.stimscript);
    %    if isfield(tempst,'tFrequency')
    %       maxbins = ceil(1/tempst.tFrequency/binsize); % one cycle
    %   else
    maxbins = min(cellfun(@length,rast.counts));
    %   end
    
    rastcount_max = zeros(1,maxbins);%length decreased because it can fluctuate with one
    ind = find(measures.range{i}==measures.preferred_stimulus{i});
    for j=ind
        rastcount_max = rastcount_max+rast.counts{j}(1:length(rastcount_max))/rast.N(j);
    end
    rastcount_max = rastcount_max/length(ind);
    
    measures.psth_tbins{i} = binsize*((1:maxbins)-0.5);
    measures.psth_count{i} = rastcount_max;
    
    filterwidth = 0.05/binsize; % 50 ms width = too broad for onset times!
    rastcount_max = spatialfilter(rastcount_max,filterwidth);
    [ind_max_label,ind_max] = max(rastcount_max);
    measures.time_peak{i} = ind_max*binsize;
end % trigger i


if length(inps)==1
    measures.curve = measures.curve{1};
else
    % ugly code to compute friedman test
    for i=1:length(measures.curve)
        rast = getoutput(out(i).rast);
        for j=1:length(rast.values)
            count(i,j,:) = sum(rast.values{j}) ;
        end
    end
    
    reps = size(count,3);
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
    %[stats,h] = manova(x,group,0.05)
end
measures.variable = paramname;


switch measures.variable
    case 'contrast'
        measures = compute_contrast_measures(measures);
    case 'angle'
        measures = compute_angle_measures(measures); % also shifts range around preferred
    case 'gnddirection'
        measures = compute_angle_measures(measures);
end




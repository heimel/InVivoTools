function measures=analyse_ectest_by_typenumber( inp , record)
%ANALYSE_ECTEST_BY_TYPENUMBER analyses hupe stimulus ecdata
%
%  MEASURES=ANALYSE_ECTEST_BY_TYPENUMBER( INP , RECORD)
%
%  DEPRECATED
%
% 2010 Alexander Heimel
%

logmsg('Deprecated. Better to change stim_type in record and use ANALYSE_PS instead');

measures.usable=1;

% figure out which stimulus parameters to know which spikes need to be
% analysed
ss = get(inp.st.stimscript);
p = getparameters(ss{1});

if isfield(p,'duration')
    measures.duration = p.duration;
end
switch record.stim_type
    case {'hupe','lammemotion'}
        if ~isa(ss{1},'hupestim') && ~isa(ss{1},'lammestim')
            errormsg('Stimulus is not a hupestim or lammestim');
        end
        measures.start_stim_difference =  p.movement_onset;
        measures.start_analysis_after_stim_difference = 0.2; % s
    case {'lammetexture'}
        if ~isa(ss{1},'lammestim')
            errormsg('Stimulus is not a lammestim');
        end
        measures.start_stim_difference =  p.figure_onset;
        % 100 ms after figure onset
        measures.start_analysis_after_stim_difference = 0.2; % s
    case 'border'
        if ~isa(ss{1},'borderstim')
            errormsg('Stimulus is not a borderstim');
        end
        measures.start_stim_difference =  0;
        measures.start_analysis_after_stim_difference = 0; % s
    otherwise
        measures.start_stim_difference =  0;
        measures.start_analysis_after_stim_difference = 0; % s
        warning('Unknown stimulus type');
end
int_meth = 0;
interval = [measures.start_stim_difference+measures.start_analysis_after_stim_difference 0];

trigger = getTrigger(inp.st.stimscript);
if any(diff(trigger)) % i.e. more than one type of trigger
    logmsg('Some stimuli give triggers (e.g. for light stimulation)');
    sts = split_stimscript_by_trigger( inp.st );
    for t = 1:length(sts)
        inps(t)  = inp;
        inps(t).st = sts(t);
    end
else
    inps = inp;
end

for i = 1:length(inps) % loop over multiple triggers
    inp = inps(i);

    inp.paramname = 'typenumber';
    if 0
        where.figure = figure;
        where.rect = [0 0 1 1];
        where.units = 'normalized';
        orient(where.figure,'landscape');
    else
        where = [];
    end
    par = struct('res',0.01,'showrast',0,'interp',3,'drawspont',1,...
        'int_meth',int_meth,'interval',interval);
    
    % tuning_curve class is child of analysis_generic
    tc = tuning_curve(inp,par,where);
    out = getoutput(tc);
    % out.curve contains per responses
    % (1,:) parameter value
    % (2,:) average firing rate
    % (3,:) std firing rate
    % (4,:) sem in firing rate (std/sqrt(trials))
    
    if 0 % showrast
        rastfig = figure;
        where.figure = rastfig;
        out.rast = setlocation(out.rast,where);
    end
    
    % to get full psth
    par.int_meth = 0;
    par.interval = [0 0];
    tc_full = tuning_curve(inp,par,where);
    out_full = getoutput(tc_full);
    raster_full = getoutput(out_full.rast);
    
    uniqstim = uniq(sort(out.curve(1,:)));
    curve = zeros(4, length(uniqstim));
    for j = 1:length(uniqstim)
        % check code
        curve(1,j)=uniqstim(j);
        ind = find(out.curve(1,:)==uniqstim(j));
        curve(2,j)=mean(out.curve(2,ind));
        curve(3,j)=mean(out.curve(3,ind));
        curve(4,j)=mean(out.curve(4,ind))/sqrt(2);
        
        % check if ind finds the right rasters
        try
            psth(j).tbins = mean(reshape([raster_full.bins{ind}],length(raster_full.bins{ind(1)}),length(ind))',1) ...  %#ok<UDIM>
                - measures.start_stim_difference;
            psth(j).data = mean(reshape([raster_full.counts{ind}],length(raster_full.counts{ind(1)}),length(ind))',1) ...  %#ok<UDIM>
                / mean(diff(psth(j).tbins)) / raster_full.N(ind(1));
        catch
            logmsg(['Bins sizes unequal in ' record.mouse ', test ' record.test '. Not adding PSTH']);
        end
    end % j
    
    psth_tbins = figgnd_psth_smooth( psth(1).tbins )';
    psth_bg = figgnd_psth_smooth( psth(2).data )';
    psth_hupe_fig = figgnd_psth_smooth( psth(1).data )';
    psth_hupe_bg  = psth_bg;
    psth_hupe_gnd = figgnd_psth_smooth( psth(3).data )';
    
    % check if there is response
    before_ind = (psth_tbins>-0.5 & psth_tbins<0);
    response_ind = (psth_tbins>0.1 & psth_tbins<0.8);
    
    [h_hupe_bg,p_hupe_bg] = ttest2( psth_hupe_bg(before_ind), psth_hupe_bg(response_ind));
    if isnan(h_hupe_bg)
        h_hupe_bg = 0;
    end
    h_hupe_bg = h_hupe_bg & (nanmean(psth_hupe_bg(response_ind)) > nanmean(psth_hupe_bg(before_ind)));
    [h_hupe_fig,p_hupe_fig] = ttest2( psth_hupe_fig(before_ind), psth_hupe_fig(response_ind));
    if isnan(h_hupe_fig)
        h_hupe_fig = 0;
    end
    h_hupe_fig = h_hupe_fig & (nanmean(psth_hupe_fig(response_ind)) > nanmean(psth_hupe_fig(before_ind)));
    [h_hupe_gnd,p_hupe_gnd] = ttest2( psth_hupe_gnd(before_ind), psth_hupe_gnd(response_ind));
    if isnan(h_hupe_gnd)
        h_hupe_gnd = 0;
    end
    h_hupe_gnd = h_hupe_gnd & (nanmean(psth_hupe_gnd(response_ind)) > nanmean(psth_hupe_gnd(before_ind)));
    if ~any([h_hupe_bg h_hupe_fig h_hupe_gnd])
        logmsg('No significant responses on any of figure, background and ground stimulus.');
        measures.usable = 0;
    end
        
    hupe_norm = max(psth_hupe_fig(response_ind));
    psth_hupe_fig_norm = psth_hupe_fig / hupe_norm;
    psth_hupe_bg_norm = psth_hupe_bg / hupe_norm;
    psth_hupe_gnd_norm = psth_hupe_gnd / hupe_norm;
    
    if length(psth)>3 % i.e. all lamme stimuli
        all_lamme_stimuli = true;
        psth_lamme_figs = figgnd_psth_smooth( mean([psth(4).data;psth(5).data],1) )';
        psth_lamme_gnds = figgnd_psth_smooth( mean([psth(3).data;psth(6).data],1) )';
        psth_lamme_bg  = figgnd_psth_smooth( psth(2).data )';
        lamme_norm = max( psth_lamme_figs );
        psth_lamme_figs_norm = psth_lamme_figs / lamme_norm;
        psth_lamme_gnds_norm = psth_lamme_gnds / lamme_norm;
        psth_lamme_bg_norm = psth_lamme_bg / lamme_norm;
    else
        all_lamme_stimuli = false;
    end
    
    % change old numbering of lammemotion stim
    if 0
        if strcmp(record.stim_type,'lammemotion') && ...
                datenumber(record.date) < datenumber('2010-02-30')
            curve_head = curve(1,:);
            new_curve_head = curve_head;
            new_curve_head(curve_head==1) = 7;
            new_curve_head(curve_head==3) = 8;
            curve(1,:) = new_curve_head;
        end
    end
    
    rate_spont = out.spont(1);
    
    [rate_max ind_pref] = max(curve(2,:));
    preferred_stimulus = curve(1,ind_pref);
    
    switch record.stim_type
        case {'hupe','lammemotion'}
            % recalculate spontaneous rate if no BGpretime was added
            tempdp = cell2struct({p.displayprefs{2:2:end}},{p.displayprefs{1:2:end}},2);
            if isfield(tempdp,'BGpretime') && tempdp.BGpretime == 0
                % i.e. no real spontaneous data in stimulus
                % get it from after onset
                par_spont = struct('res',0.01,'showrast',0,'interp',3,'drawspont',1,...
                    'int_meth',1,'interval',[p.figure_onset+1 p.movement_onset]);
                tc_spont = tuning_curve(inp,par_spont,[]);
                out_spont = getoutput(tc_spont);
                rate_spont = mean(out_spont.curve(2,:));
            end
            
            % calculate figure ground modulation
            hupe_modulation = (curve(2,1)-curve(2,3)) / curve(2,3);
            hupe_modulation2 = (curve(2,1)-curve(2,3)) / ...
                (curve(2,1) + curve(2,3));
            
            if all_lamme_stimuli
                lamme_figresponse = curve(2,4) + curve(2,5) - 2*rate_spont;
                lamme_gndresponse = curve(2,3) + curve(2,6) - 2*rate_spont;
                lamme_modulation = ...
                    (curve(2,4)+curve(2,5)) / ...
                    (curve(2,3)+curve(2,6));
                figgnd_modulation = ...
                    (lamme_figresponse - lamme_gndresponse)/...\
                    (lamme_figresponse + lamme_gndresponse);
            else
                lamme_modulation = NaN;
                figgnd_modulation = NaN;
            end
        case {'lammetexture'}
            disp('LAMMETEXTURE ANALYSIS OUTDATED');
            % calculate figure ground modulation
            figresponse = measures.curve(2,1) - measures.rate_spont;
            bothresponse = measures.curve(2,2) - measures.rate_spont;
            
            % Figure ground modulation is same as Hupe 'background induced response
            % suppresion'
            %  measures.figgnd_modulation = (figresponse-bothresponse)/bothresponse;
            hupe_modulation = (figresponse-bothresponse)/bothresponse;
            % i.e. 0 is figresponse is identical to both response
            lamme_modulation = ...
                (curve(2,4)+curve(2,5)-2*rate_spont)/ ...
                (curve(2,3)+curve(2,6)-2*rate_spont);
        case 'border'
            borderpolarity_modulation = ...
                (curve(2,2) + curve(2,4)) / ...
                (curve(2,1) + curve(2,3));
        otherwise
    end
            
    % assign measures
    measures.parameter = inp.paramname;
    measures.curve{i} = curve;
    measures.rate_spont(i) = rate_spont;
    measures.rate_max(i) = rate_max;
    measures.preferred_stimulus(i) = preferred_stimulus;
    measures.psth{i} = psth;
    measures.psth_tbins{i} = psth_tbins;
    measures.psth_bg{i} = psth_bg;
    
    % hupe stuff
    if exist('psth_hupe_fig','var')
        measures.psth_hupe_fig{i} = psth_hupe_fig;
        measures.psth_hupe_bg{i} = psth_hupe_bg;
        measures.psth_hupe_gnd{i} = psth_hupe_gnd;
        measures.psth_hupe_fig_norm{i} = psth_hupe_fig_norm;
        measures.psth_hupe_bg_norm{i} = psth_hupe_bg_norm;
        measures.psth_hupe_gnd_norm{i} = psth_hupe_gnd_norm;
        measures.hupe_modulation(i) = hupe_modulation;
        measures.hupe_modulation2(i) = hupe_modulation2;
    end
    
    % lamme stuff
    measures.all_lamme_stimuli = all_lamme_stimuli; % should be identical for all i
    if all_lamme_stimuli
        measures.lamme_figresponse(i) = lamme_figresponse;
        measures.lamme_gndresponse(i) = lamme_gndresponse;
        measures.psth_lamme_figs{i} = psth_lamme_figs;
        measures.psth_lamme_gnds{i} = psth_lamme_gnds;
        measures.psth_lamme_bg{i}  = psth_lamme_bg;
        measures.psth_lamme_figs_norm{i} = psth_lamme_figs_norm;
        measures.psth_lamme_gnds_norm{i} = psth_lamme_gnds_norm;
        measures.psth_lamme_bg_norm{i} = psth_lamme_bg_norm;
        measures.lamme_modulation(i) = lamme_modulation; 
        measures.figgnd_modulation(i) = figgnd_modulation;
    end
    
    % border stuff
    if exist('borderpolarity_modulation','var')
            measures.borderpolarity_modulation(i) = borderpolarity_modulation;
    end    
end %i


function record = ec_analyse_zeta( record, verbose)
%EC_ANALYSE_ZETA computes ZETA for units and stores in measures
%
%  RECORD = EC_ANALYSE_ZETA( RECORD, VERBOSE )
%
%  zetatest from Jorrit Montijn needs to be in the path
%
% 2022, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = false;
end

measures = record.measures;

stims = getstimsfile( record );
if isempty(stims)
    return
end


stim_onsets = cellfun( @(x) x.startStopTimes(2),stims.MTI2);
if length(stim_onsets)<5
    logmsg('Too few stimuli to compute Zeta');
    return
end


datapath = experimentpath(record);
spikesfile = fullfile(datapath, '_spikes.mat');

compute_real_zeta = true;

if ~exist(spikesfile,'file')
    logmsg(['Cannot find spikesfile ' spikesfile ]);
    compute_real_zeta = false;
    logmsg(['Only computing Zeta based on PSTH for ' recordfilter(record)]);
end
load(spikesfile,'cells');


if length([cells.index]) ~= length(unique([cells.index]))
    logmsg(['Spikesfile ' spikesfile ' contains multiple sortings in ' recordfilter(record)]);
    logmsg('Reimporting from raw data. Make sure that sorting parameters in processparams_local.m are identical to previous time!');
    processparams = ecprocessparams;
    switch processparams.spike_sorting_routine
        case 'klustakwik'
            cells = import_spikes(record,[],true,false);
            cells = import_klustakwik( record, cells );
            if isempty(cells)
                logmsg(['Cannot import klustakwik clusters for ' recordfilter(record)]);
                return
            end
            cells = ec_assign_cell_info( cells, record ); % sort cells by descending amplitude

        otherwise
            cells = import_spikes(record,[],true,false);
    end
end

if length(cells)~=length(measures) || ~all([cells.index]==[measures.index])
    logmsg(['Imported cells are not consisent with measures in ' recordfilter(record)]);
    compute_real_zeta = false;
    logmsg(['Only computing Zeta based on PSTH for ' recordfilter(record)]);
end
    
for i = 1:length(measures)
    if verbose
        logmsg(['Computing ZETA for ' num2str(i) ' of ' num2str(length(measures))]);
    end
    
    if compute_real_zeta
        duration = [];
        spiketimes = cells(i).data;
        measures(i).zetap = zetatest(spiketimes,stim_onsets,duration);
                
        if false
            figure('Name','Real Zeta'); %#ok<UNRCH>
            subplot(2,1,1);
            n_spikes_shown = rastergram(spiketimes,stim_onsets,[0 3]);
            disp(['Real zeta, spikes shown = ' num2str(n_spikes_shown)]);
            subplot(2,1,2);
            n_events = length(stims.MTI2);
            counts =round(measures(i).psth_count_all{1} * n_events);
            bar( measures(i).psth_tbins_all{1},counts);
        end
    end
    
    % compute Zeta based on psth (which is only limited)
    n_events = length(stims.MTI2);
    
    
    ind_begin = find(measures(i).psth_tbins_all{1}>0,1);
    ind_end = length(measures(i).psth_tbins_all{1});
    counts =round(measures(i).psth_count_all{1}(ind_begin:ind_end) * n_events);
    measures(i).zetap_on_psth = zetatest_on_psth(counts,n_events,verbose);
end

record.measures = measures;

if verbose && compute_real_zeta
    figure('Name','ZETA comparison','NumberTitle','off');
    plot([record.measures.zetap],[record.measures.zetap_on_psth],'o');
    hold on
    set(gca,'xscale','log');
    set(gca,'yscale','log');
    axis square;
    xyline
    xl = xlim;
    yl = ylim;
    lim = [min([xl(1) yl(1)]) max([xl(2) yl(2)])];
    xlim(lim);
    ylim(lim);
    plot(lim,[0.05 0.05],'--');
    plot([0.05 0.05],lim,'--');
    
    xlabel('True ZETA p');
    ylabel('PSTH ZETA p');
    
    cc = corrcoef([record.measures.zetap],[record.measures.zetap_on_psth]);
    logmsg(['Corr. coefficient true Zeta and PSTH Zeta =  ' num2str(cc(1,2),2)]);
end

function record = ec_analyse_biphasic_index( record, verbose)
%EC_ANALYSE_BIPHASIC_INDEX computes transience index
%
%  RECORD = EC_ANALYSE_BIPHASIC_INDEX( RECORD, VERBOSE = FALSE )
%
%  Based on Piscopo et al. J Neurosci
%  biphasic index is computed as the difference of the spike
%  triggered average of the projected stimulus feature value
%  to the mean feature value divided by the
%  maximum difference in the opposite direction, preceding the
%  maximum difference (Sommeijer et al. 2017. This follows the
%  biphasic index to measure how biphasic the response is (Piscopo
%  et al. J Neurosci 2013) which shows a difference between tOFF and
%  sOFF cells in mouse dLGN (Piscopo et al. J Neurosci 2013)
%
%  The calculation is based on the spike-triggered average based on PSTH
%  for this it is necessary to include the entire BGpretime and BGposttime in
%  analysis.
%  Use e.g. params.post_window = [0 6]; %  in processparams_local
%
%  The calculation selects the On or Off response, depending on which is
%  largest. It does thus not compute a normal Spike Triggered Average!
%
%  Note, for reverse correlation this is called transience
%
%  Made for analysis of data of Yi Qin
%
% 2021, Alexander Heimel
%

if nargin<2 || isempty(verbose)
    verbose = false;
end

measures = record.measures;

params = ecprocessparams(record);

stimsfile = getstimsfile(record);
if ~isempty(stimsfile)
    stimparams = getparameters(stimsfile.saveScript);
    dp = struct(displayprefs(stimparams.dispprefs));
end

for i = 1:length(measures)
    for trig = 1:length(measures(i).psth_tbins_all)
        binwidth = mode(diff(measures(i).psth_tbins_all{trig}));
        
        stims_t = measures(i).psth_tbins_all{trig};
        count = measures(i).psth_count_all{trig};
        
        % test psth
        % disp('Test');
        %     count = 0.1*ones(size(count));
        %     count(stims_t>0.050 & stims_t<0.1) = 0.5;
        
        % remove spontaneous rate
        count_spont = mean(count(stims_t> (-dp.BGpretime+0.5) &  stims_t< 0));
        count = count - count_spont;
        
        % test psth
        %count(stims_t>0.20 ) = 0;
        %count(stims_t<0.0 ) = 0;
        
        % recreate stimulus
        stims_f = stimparams.backdrop*ones(size(stims_t));
        stims_f(stims_t>0 & stims_t<stimparams.fixedDur) = stimparams.background;
        stims_f(stims_t<-dp.BGpretime) = stimparams.background;
        stims_f(stims_t> (dp.BGposttime + stimparams.fixedDur + dp.BGpretime)) = stimparams.background;

        if isempty(find(stims_t> (dp.BGposttime + stimparams.fixedDur + dp.BGpretime),1))
            logmsg('OFF-responses not included. Make sure to set params.post_window = [0 XXX] in processparams_local long enough to include off-response');
        end
            
        % subtract mean over time
        stims_f = stims_f - ( max(stims_f)+min(stims_f))/2;
        % normalize by maximum difference from mean
        stims_f = stims_f/max(abs(stims_f));
        
        
        response_time = 0.5; % s period to check on versus of response
        
        % check on or off
        count_on = sum(count(stims_t>0 & stims_t<response_time));
        count_off = sum(count(stims_t>(stimparams.fixedDur+dp.BGposttime) & stims_t<(stimparams.fixedDur+dp.BGposttime+response_time)));
        
        onoff = (count_on>count_off);  % onoff 1 = oncell, 0 = offcell
        if onoff % on  
            ind = (stims_t>-params.ec_biphasic_period ...
                & stims_t<params.ec_biphasic_period );
        else % off
            ind = (stims_t>stimparams.fixedDur+dp.BGposttime-params.ec_biphasic_period ...
                & stims_t<stimparams.fixedDur+dp.BGposttime+params.ec_biphasic_period );
        end
        count = count(ind);
        stims_t = stims_t(ind);
        stims_f = stims_f(ind);
        
        
        maxlags = 200;
        [cc,lags] = xcorr(stims_f,count,maxlags);
        lags = lags*binwidth;
        cc = cc / (max(stims_t)-min(stims_t)) / sum(count) * 2; % STA
        ind = find(lags>-0.5 & lags<0);
        cc = cc(ind);
        lags = lags(ind);
        
        [m,peakind] = max( (-1+2*onoff)*(cc)); % location of peak
        
        n_shuffles = 40;
        m_shuffle = zeros(n_shuffles,1);
        for s = 1:n_shuffles
            cc_shuffle = xcorr(stims_f,count(randperm(length(count))),maxlags);
            cc_shuffle = cc_shuffle / (max(stims_t)-min(stims_t)) / sum(count) * 2; % STA
            m_shuffle(s) = max(cc_shuffle(ind));
        end
        
        if abs(m)<2*std(m_shuffle) % no clear peak, thus not computing transience, different from reverse_corr
            biphasic_index  = NaN;
            logmsg(['Cell ' num2str(measures(i).index) ' has no clear STA peak.']);
        else
            [~,prepeakind] = max( (1-2*onoff)*cc(1:peakind-1)); % find peak before peak
            
            biphasic_index = -cc(prepeakind)/cc(peakind);
            
            if verbose
                if onoff
                    logmsg(['Cell ' num2str(measures(i).index) ' has larger on-response. Biphasic index = ' num2str(biphasic_index,2)]);
                else
                    logmsg(['Cell ' num2str(measures(i).index) ' has larger off-response. Biphasic index = ' num2str(biphasic_index,2)]);
                end
            end
        end
        
        measures(i).biphasic_index{trig} = biphasic_index;
        measures(i).onoff{trig} = onoff;
        
        if verbose
            figure
            subplot(2,1,1);
            hold on;
            title(['Cell ' num2str(measures(i).index)]);
            plot(stims_t,stims_f);
            plot(stims_t,count);
            xlabel('Time from stim onset (s)');
            ylabel('Spike count');
            
            subplot(2,1,2);
            plot( lags,cc,'.-')
            xlim([-0.5 0.1]);
            xlabel('Time from spike (s)');
            ylabel('STA');
        end
    end
end

record.measures = measures;

function record=analyse_lfptestrecord( record, verbose)
%ANALYSE_LFPTESTRECORD
%
%   RECORD=ANALYSE_LFPTESTRECORD( RECORD, VERBOSE)
%      if VERBOSE is 0, no graphical output, 1 progress bar, 2 many figures
%
%
% 2007-2014, Alexander Heimel
%

if nargin<2
    verbose = [];
end
if isempty(verbose)
    verbose = 1;
end

datapath = experimentpath(record,false);
smrfile=fullfile(experimentpath(record),'data.smr');

measures = record.measures;

switch record.stim_type
    case 'io'
        logmsg('io analysis is out of date.');
        pre_ttl=0.02; % s
        post_ttl=0.04; % s
        results = importspike2_lfp(smrfile,record.stim_type,pre_ttl,post_ttl);
        
        if ~isempty(results)
            
            % to get original signal in millivolt
            waves=results.waves/ record.amplification *1000;
            waves_time=results.waves_time;
            measures.stim_intensities_measured=results.stim_intensities;
            measures.stim_intensity=mean(results.stim_intensities);
            
            % remove stimulus artefact
            % by NaN-ing 1 ms from the start of the stimulus
            ind_stim=(waves_time>0 & waves_time<=0.001);
            for i=1:size(waves,1)
                waves(i,ind_stim)=nan;
            end
            
            % match stim_intensities in data to record
            round_stim_intensities=round(measures.stim_intensities_measured*10)/10; % round to neareast decivolt
            
            if ischar(record.stim_parameters)
                stim_parameters=eval(record.stim_parameters);
            else
                stim_parameters=record.stim_parameters;
            end
            org_stim_intensities=...
                repmat( stim_parameters,...
                length(measures.stim_intensities_measured)/...
                length(record.stim_parameters),1);
            
            org_stim_intensities=org_stim_intensities(:)';
            if prod(double(org_stim_intensities==round_stim_intensities))~=1
                logmsg('Stimulus intensities in data and on record do not match');
                logmsg(['data   = ' mat2str(measures.stim_intensities)]);
                logmsg(['record = ' mat2str(record.stim_parameters)]);
                return
            end
            measures.stim_intensities=round_stim_intensities;
            
            
            % calculate response amplitudes from post-stim
            indpoststim=findclosest(results.waves_time,0.003); % 3ms post stim
            
            uniq_stim_intensities=uniq(measures.stim_intensities);
            r=zeros(4,length(uniq_stim_intensities)); % rows: stim, mean resp, std, sem
            
            % compute curves
            r(1,:)=uniq_stim_intensities * record.stim_mA_per_V;
            for i=1:length(uniq_stim_intensities)
                ind=find(measures.stim_intensities==uniq_stim_intensities(i));
                
                % for curves use the negative minimum response
                r(2,i)=-mean(min(results.waves(ind,indpoststim:end),[],2));
                r(3,i)=std(min(results.waves(ind,indpoststim:end),[],2));
                r(4,i)=sem(min(results.waves(ind,indpoststim:end),[],2));
                
                % peak2peak(i)=mean(max(results.waves(ind,indpoststim:end),[],2))-...
                %     mean(min(results.waves(ind,indpoststim:end),[],2));
            end
            measures.curve=r;
            if ~isempty(waves) % save waves
                wavefile=fullfile(datapath,record.test,'saved_data.mat');
                save(wavefile,'waves','waves_time','powerm','-v7');
            end
        end
        if ~isempty(measures)
            record.measures = measures;
            record.analysed=datestr(now);
        end
    case 'pp' % paired pulse
        logmsg('pp analysis is out of date.');
        pre_ttl = 0.03; % in s
        post_ttl = 0.3; % in s
        results = importspike2_lfp(smrfile,record.stim_type,pre_ttl,post_ttl);
        
        if isempty(results) || isempty(results.waves{1})
            errormsg( ['No waves returned for ' recordfilter(record)]);
            wavefile=fullfile(datapath,record.test,'saved_data.mat');
            delete(wavefile);
            return
        end
        % all written for no trigger
        
        % to get original signal in millivolt
        waves=results.waves{1}/ record.amplification *1000;
        waves_time=results.waves_time{1};
        measures.stim_intensities_measured=results.stim_intensities{1};
        measures.stim_intensity=mean(results.stim_intensities{1});
        
        % get pulse frequency, number and width, only from first train
        high_ind=find(results.stim_waves{1}(1,:)>max(results.stim_intensities{1}(1,:))/2);
        dif_seq=high_ind(2:end)-high_ind(1:end-1);
        ind_start_pulses=high_ind([1 find(dif_seq>1)+1]);
        
        % remove stimulus artefact
        start_pulse_times=waves_time(ind_start_pulses);
        ind_stim=[];
        for j=1:length(start_pulse_times)
            ind_stim=[ind_stim find(waves_time>start_pulse_times(j) & ...
                waves_time<start_pulse_times(j)+0.001)];
        end
        for i=1:size(waves,1)
            waves(i,ind_stim)=nan;
        end
        
        measures.interval=mean(dif_seq(dif_seq>1)-1)*results.sample_interval; % in s
        measures.frequency=1/measures.interval; % in Hz
        measures.n_pulses=length(find(dif_seq>1))+1;
        measures.pulse_width=length(dif_seq)/measures.n_pulses*results.sample_interval; % in s
        measures.repetitions=size(results.stim_waves{1},1);
        
        % calculate responses for all trains
        responses=zeros(measures.repetitions,measures.n_pulses);
        norm_responses=responses; % normalized to every first pulse in the train
        for i=1:measures.repetitions
            for j=1:measures.n_pulses
                % take trough to peak hight
                % start 1 ms after pulse
                % stay 1 ms away from next pulse
                
                ind_single_response=(ind_start_pulses(j)+ ...
                    floor( (0.001)/results.sample_interval): ...
                    ind_start_pulses(j)+ ...
                    floor( (measures.interval-0.001) / results.sample_interval));
                responses(i,j)=...
                    max( results.waves{1}(i,ind_single_response)) - ...
                    min( results.waves{1}(i,ind_single_response))  ;
                norm_responses(i,j)=responses(i,j)/responses(i,1);
            end
        end
        
        measures.curve(1,1:measures.n_pulses)=1:measures.n_pulses;
        measures.curve(2,:)=mean(responses,1);
        measures.curve(3,:)=std(responses,1);
        measures.curve(4,:)=sem(responses,1);
        
        measures.norm_curve(1,1:measures.n_pulses)=1:measures.n_pulses;
        measures.norm_curve(2,:)=mean(norm_responses,1);
        measures.norm_curve(3,:)=std(norm_responses,1);
        measures.norm_curve(4,:)=sem(norm_responses,1);
        
        measures.paired_pulse_ratio=measures.norm_curve(2,2);
        measures.last_pulse_ratio=measures.norm_curve(2,end);
        if ~isempty(waves) % save waves
            waves{1,1}{1,1} = waves;
            wavefile=fullfile(datapath,record.test,'saved_data.mat');
            save(wavefile,'waves','waves_time','powerm','-v7');
        end
        if ~isempty(measures)
            record.measures = measures;
            record.analysed=datestr(now);
        end
    otherwise % visual stimuli
        record = analyse_veps(record,verbose);
end





logmsg(['Analysed mouse=' record.mouse ...
    ', date=' record.date ', test=' record.test]);

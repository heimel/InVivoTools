function record = ec_analyse_adaptation( record )
%EC_ANALYSE_ADAPTATION compute some specific adaptation measures
%
%  RECORD = EC_ANALYSE_ADAPTATION( RECORD )
%
%
% 2021, Alexander Heimel
%

stimsfile = getstimsfile(record);
if ~isempty(stimsfile)
    stimparams = getparameters(stimsfile.saveScript);
else
    logmsg('TEMPORARILY FILLING IN MISSING STIMS DETAILS');
    stimparams.tFrequency = 2;
    stimparams.nCycles = 6;
end
period = 1 / stimparams.tFrequency;
binwidth = min([0.25 period]); % averaging period
stimduration = period * stimparams.nCycles;

measures = record.measures;

for i=1:length(measures)
    m = measures(i);
    n_triggers = length(m.rate);
    measures(i).adaptation_peak2 = {};
    measures(i).adaptation_peak3 = {};
    measures(i).adaptation_peak4 = {};
    measures(i).adaptation_peak5 = {};
    for t=1:n_triggers
        
        [~,ind_max] = max(m.psth_count{t});
        peak_time = m.psth_tbins{t}(ind_max);
        binstart = peak_time - binwidth/2;
        while binstart>period % go to first bin
            binstart = binstart - period;
        end
        binstarts = binstart:period:(stimduration-binwidth); % only full bins
        binends = binstarts + binwidth;
        
        peakrates = zeros(length(binstarts),1);
        for j = 1:length(binstarts)
            ind = (m.psth_tbins{t}>binstarts(j) & m.psth_tbins{t}<binends(j));
            peakrates(j) = mean(m.psth_count{t}(ind));
        end % j
        peakrates_normalized = peakrates / peakrates(1); % normalize to first peak

        % peaktimes = (binstarts+binends) / 2;
        
        %    figure
        %    plot(m.psth_tbins{1},m.psth_count{1}/max(m.psth_count{1}));
        %    hold on
        %    plot(peaktimes,peakrates_normalized,'v');
        %    hold off
        
        
        measures(i).adaptation_peak2{t} = peakrates_normalized(2);
        measures(i).adaptation_peak3{t} = peakrates_normalized(3);
        measures(i).adaptation_peak4{t} = peakrates_normalized(4);
        measures(i).adaptation_peak5{t} = peakrates_normalized(5);
    end % t
end

record.measures = measures;

function record = ec_analyse_f1f0( record )
%EC_ANALYSE_F1F0 compute F1/F0 based on psth.count
%
%  RECORD = EC_ANALYSE_F1F0( RECORD )
%
%
% 2021, Alexander Heimel
%


measures = record.measures;

stimsfile = getstimsfile(record);
if ~isempty(stimsfile)
    stimparams = getparameters(stimsfile.saveScript);
else
    logmsg('TEMPORARILY FILLING IN MISSING STIMS DETAILS');
    stimparams.tFrequency = 2;
    stimparams.nCycles = 6;
end
period = 1 / stimparams.tFrequency;


for i=1:length(measures)
    m = measures(i);
    n_triggers = length(m.rate);
    for t = 1:n_triggers
        tbins = m.psth_tbins{t};
        count = m.psth_count{t};
        f = exp(2*pi*1i*tbins/period)';
        f1 = 2*norm(count*f)/length(tbins);
        f0 = sum(count)/length(tbins);
        f1f0 = f1/f0;
        
        measures(i).f1f0{t} = f1f0;
    end % t
end % measure i

record.measures = measures;
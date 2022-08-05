function record = ec_analyse_zeta( record, verbose)
%EC_ANALYSE_ZETA computes ZETA for units and stores in measures
%
%  RECORD = EC_ANALYSE_ZETA( RECORD, VERBOSE )
%
% 2022, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true;
end

measures = record.measures;

stims = getstimsfile( record );

stim_onsets = cellfun( @(x) x.startStopTimes(2),stims.MTI2);

datapath = experimentpath(record);
spikesfile = fullfile(experimentpath(record), '_spikes.mat');

if ~exist(spikesfile,'file')
    logmsg(['Cannot find spikesfile ' spikesfile ]);
    return
end
load(spikesfile,'cells');

if ~all([cells.index]==[measures.index])
    logmsg(['Spikesfile ' spikefile ' is not consisent with measures in ' recordfilter(record)]);
    return
end
    

for i = 1:length(measures)
    if verbose
        logmsg(['Computing ZETA for ' num2str(i) ' of ' num2str(length(measures))]);
    end
    spiketimes = cells(i).data;
    measures(i).zetap = zetatest(spiketimes,stim_onsets);   
end

record.measures = measures;

function results_oxyrecord(record)
%RESULTS_OXYRECORD shows results from oxymeter analysis
%
% 2019, Alexander Heimel


global measures global_record

global_record = record;
measures = record.measures;

evalin('base','global global_record');
evalin('base','global measures');


figure('Name','Trial median');

% Heart rate
subplot(2,1,1)
hold on
plot(record.measures.beattime_trialaverage,record.measures.heartrate_trialmedian+record.measures.heartrate_trialsem,'Color',0.7*[1 1 1]);
plot(record.measures.beattime_trialaverage,record.measures.heartrate_trialmedian-record.measures.heartrate_trialsem,'Color',0.7*[1 1 1]);
plot(record.measures.beattime_trialaverage,record.measures.heartrate_trialmedian,'b');
ylim([0 20]);
plot([0 0],ylim,'y-');
xlabel('Time from stimulus onset (s)');
ylabel('Heart rate (Hz)');
logmsg(['Median heart rate = ' num2str(record.measures.heartrate_median)]);
logmsg(['Stddev heart rate = ' num2str(record.measures.heartrate_std)]);

% Breathing rate
subplot(2,1,2)
hold on
plot(record.measures.breathtime_trialaverage,record.measures.breathrate_trialmedian+record.measures.breathrate_trialsem,'Color',0.7*[1 1 1]);
plot(record.measures.breathtime_trialaverage,record.measures.breathrate_trialmedian-record.measures.breathrate_trialsem,'Color',0.7*[1 1 1]);
plot(record.measures.breathtime_trialaverage,record.measures.breathrate_trialmedian,'b');
ylim([0 20]);
plot([0 0],ylim,'y-');
xlabel('Time from stimulus onset (s)');
ylabel('Breath rate (Hz)');
logmsg(['Median breath rate = ' num2str(record.measures.breathrate_median)]);
logmsg(['Stddev breath rate = ' num2str(record.measures.breathrate_std)]);


logmsg('Measures available in workspace as ''measures'', stimulus as ''analysed_script'', record as ''global_record''.');

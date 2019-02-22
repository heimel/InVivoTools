function results_pupiltestrecord( record )
%RESULTS_PUPILTESTRECORD
%
%  RESULTS_PUPILTESTRECORD( record )
%
%  2017, Alexander Heimel
%

global measures analysed_script global_record

global_record = record;

evalin('base','global measures');
evalin('base','global analysed_script');
evalin('base','global global_record');
analysed_stimulus = getstimsfile(record);
if ~isempty(analysed_stimulus) && isfield(analysed_stimulus,'saveScript')
    analysed_script = analysed_stimulus.saveScript;
else
    logmsg('No savedscript');
end

measures = merge_measures_from_disk( record );

if isempty(measures)
	logmsg('Measures are empty. Perhaps no analysis done yet?');
	return
end

par = pupilprocessparams( record );

vars = {'pupil_x','pupil_y','pupil_r','pupil_s','pupil_d'};
labels = {'pupil x (deg)','pupil y (deg)','pupil radius (deg)','pupil speed (deg/s)','pupil displacement (deg)'};
n_vars = length(vars);

tit = recordfilter(record);

figure('Name',tit,'NumberTitle','off')
for v = 1:n_vars
    subplot(2,n_vars,v)
    hold on
    for i = 1:length(measures.range)
        try
            errorbar(measures.psth_t,measures.(['psth_' vars{v}])(i,:),measures.(['psth_' vars{v} '_sem'])(i,:));
        catch
            logmsg('Unable to plot PSTH');
        end
    end
    xlabel('Time (s)');
    ylabel(capitalize(labels{v}));
    xlim([min(measures.psth_t)+par.separation_from_prev_stim_off max(measures.psth_t)]);
    
    subplot(2,n_vars,n_vars+v)
    hold on
    bar(measures.(vars{v}));
    errorbar(measures.(vars{v}),measures.([vars{v} '_sem']),'.');
    xlabel('Condition');
    ylabel(['Change ' labels{v}]);
end % var v

figure('Name',['Scatter-' tit] ,'NumberTitle','off')
 for i = 1:length(measures.range)
     subplot(2,ceil(length(measures.range)/2),i);
     co = get(gca,'colororder');
     plot(measures.pupil_x_stim(i,:),measures.pupil_y_stim(i,:),'.',...
         'MarkerEdgeColor',co(i,:))
     xlim([-30 30]);
     ylim([-30 30]);
 end
 

logmsg('Measures available in workspace as ''measures'', stimulus as ''analysed_script'', record as ''global_record''.');


% works in 2016a
close all
mice = {
    '14.13.2.01', '14.13.2.02'...
    '14.13.2.03', '14.13.2.04'};
n_mice = length(mice);

mean_dur = NaN(1, 30, 2, n_mice);

for i = 1:n_mice
    if exist ('man_frz_dur_14.13.2.01.mat', 'file')~= 0
        load(['man_frz_dur_14.13.2.0' num2str(i) '.mat'])
    else
        errormsg('File does not exist. Get data from manualfrzdata.m');
    end
    in_trials =  man_frz_dur((1:20),:,:);
    mean_dur(:,:,:,(i)) = nanmean(in_trials);
    for j = 1:numel(in_trials)
        if ~isnan(in_trials(j)) && in_trials(j)> 0
            in_trials(j) = 1;
        end
    end
    perf = nanmean(in_trials);
    perf_col = reshape(perf,[30,2]);
    ses_num = sum(~isnan(perf_col));
    figure(i);
    if any(~isnan(perf_col(:,2)))
    bhand_perf = bar(perf_col);
    set(bhand_perf(1),'FaceColor',[0.4 0.0 0.4], 'edgecolor', 'none');
    set(bhand_perf(2),'FaceColor',[0.2 0.6 0.4], 'edgecolor', 'none');
    else
        bhand_perf = bar(perf_col(:,1));
        set(bhand_perf,'FaceColor',[0.4 0.0 0.4], 'edgecolor', 'none');
    end
    ylim([0, 1])
    xlim([0 max(ses_num)+1])
    title(['Response profile of mouse 2.0' num2str(i)])
    ylabel('Propotion freezing')
    xlabel('Time(sessions)')
    hold on
    yyaxis 'right';
    phand_dur = plot(mean_dur(:,:,1,i), '-.h', 'color',[0.6 0.0 0.6], 'linewidth', 1.2);
    ax = gca;
    ax.YColor = 'k';
    ylim(ax,[0 1.08])
    ylabel('freezing duration(s)')
    legend([bhand_perf(1),phand_dur],'hab', 'mean dur hab') 
    legend('boxoff')
    if any(~isnan(mean_dur(:,:,2,i)))
        plot(mean_dur(:,:,2,i), '-.*', 'color',[0.4 0.8 0.6], 'linewidth', 1.2)
        legend('hab','novel', 'mean dur hab', 'mean dur nov')
        legend('boxoff')
    end
end


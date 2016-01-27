function results_ecmovie(record)
%RESULTS_ECMOVIE shows the rastergrams of multiple movie repetitions
%
% 2016, Alexander Heimel

% experiment(14.14)
% ecdb = load_testdb('ec','nin380');
% record = ecdb(find_record(ecdb,'mouse=11.35.1.65,test=t-7'));

% movie info
n_repeats = 10;
duration = 20.501; % s

% read stimsfile 
[stim,stimsfilename]=getstimsfile(record);
if isempty(stim) % copy movie stim file
    % get movie file
    curexp = experiment;
    experiment(14.14);
    ecdb = load_testdb('ec','nin380');
    experiment(curexp);
    ind = find_record(ecdb,'mouse=11.35.1.65,test=t-7');
    orgrec = ecdb(ind);
    [~,orgstimsfilename] = getstimsfile(orgrec);
    copyfile(orgstimsfilename,stimsfilename,'f');
    record = analyse_testrecord(record);
end

spikesfile = fullfile(experimentpath(record),'_spikes.mat');
s = load(spikesfile);
cells = s.cells;

for c=1:length(cells)
    figure('Name',['Rastergram cell ' num2str(cells(c).index)],'NumberTitle','off');
    subplot('position',[0.1 0.1 0.8 0.5]);
    hold on;
    spikes = cells(c).data - stim.start;
    n_spikes = length(spikes);
    for r = 1:(n_repeats-1) % removing first = 0th repeat
        start = r*duration;
        stop = (r+1)*duration;
        ind = find(spikes>start & spikes<stop);
        spikes_shifted{r} = spikes(ind)-r*duration; %#ok<AGROW>

        % plot raster
        plot([spikes(ind) spikes(ind)]'-r*duration,...
            [(r+0.55)*ones(size(spikes(ind))) (r+1.45)*ones(size(spikes(ind)))]','k');
    end
    set(gca,'ydir','reverse');
    ylim([1-0.5,n_repeats+0.5]);
    
    [counts,centers] = hist(flatten(spikes_shifted),[0:0.032:duration]);

    rangetype = 'aroundpeak';    
    switch rangetype
        case 'aroundpeak'
            xrange = min(duration, duration/n_spikes*500);
            [~,ind]=max(counts);
            xmin = max(0,centers(ind)-xrange/2);
            xmin = min(duration-xrange,xmin);
            xmax = xmin + xrange;
        case 'fixed'
            xmin = 0 ;
            xmax = 10;
    end
    xlim([xmin xmax]);
    
    
    subplot('position',[0.1 0.6 0.8 0.3]); % PSTH
    bar(centers,counts);
    xlim([xmin xmax]);
    set(gca,'xtick',[]);
end
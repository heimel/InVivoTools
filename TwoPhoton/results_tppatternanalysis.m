function results_tppatternanalysis( result, process_params )
%RESULTS_TPPATTERNANALYSIS
%
% RESULTS_TPPATTERNANALYSIS( RESULT, PROCESS_PARAMS)
%
% 2010-2011, Alexander Heimel
%

results_cellular_events( result, process_params);
results_event_types( result, process_params);
results_waves_summary( result, process_params);
return

function results_waves_summary( result, process_params)
retinal_waves = result.retinal_waves;
cortical_waves = result.cortical_waves;

 fprintf(['Median velocity retinal waves = ' num2str(median(result.velocity(retinal_waves)),3) ' (um/s)\n']);
 fprintf(['Median velocity cortical waves = ' num2str(median(result.velocity(cortical_waves)),3) ' (um/s)\n']);
 p_kw = kruskal_wallis_test(result.velocity(retinal_waves),result.velocity(cortical_waves));
 disp(['Velocities of retinal vs cortical waves: kruskal-wallis (non-parametric), p = ' num2str(p_kw,2)]);

 
fprintf(['# retinal waves   = ' num2str(sum(retinal_waves),'%03.f') ', ']);
fprintf(['# cortical waves  = ' num2str(sum(cortical_waves),'%03.f' ) '\n']);
fprintf(['# total waves = ' num2str(sum(result.waves),'%03.f' ) ', ']);
fprintf(['likely true # waves = ' num2str(sum(result.waves) - (1+erf(process_params.wave_criterium))*size(result.participating_fraction,1) ,'%03.f' ) '\n']);

edges = ( (-pi):2*pi/20:(pi));

disp(['Preferred retinal wave direction present: chi2 test, p = ' num2str(result.network_retinal_wave_direction_chi2_p,2)]);

%if any(cortical_waves)
%    x = histc( result.wave_direction( cortical_waves) ,edges );
%    y = histc( result.shuffled_wave_direction( result.shuffled_cortical_events) ,edges );
%    if size(x,1) < size(x,2), x = x';  end
%    if size(y,1) < size(y,2), y = y';  end
%    x = x(1:end-1);
%    y = y(1:end-1);
%    p = chi2class( [x y]);
%    disp(['Preferred cortical wave direction present: chi2 test, p = ' num2str(p,2)]);
%end
disp(['Preferred cortical wave direction present: chi2 test, p = ' num2str(result.network_cortical_wave_direction_chi2_p,2)]);

if any(result.waves)
    x = histc( result.direction( result.waves) ,edges );
    y = histc( result.shuffled_direction  ,edges);
    if size(x,1) < size(x,2), x = x';  end
    if size(y,1) < size(y,2), y = y';  end
    x = x(1:end-1);
    y = y(1:end-1);
    p = chi2class( [x y]);
    disp(['Preferred wave direction present: chi2 test, p = ' num2str(p,2)]);

    if 0 && process_params.output_show_figures
        title(['Preferred wave direction present: chi2 test, p = ' num2str(p,2)]);
        figure('name','Wave preference','NumberTitle','off');
        plot((edges(1:end-1)+edges(2:end))/2,x/mean(x));
        hold on;
        plot((edges(1:end-1)+edges(2:end))/2,y/mean(y),'r');ylim([0 2.5])
        xlabel('Direction (rad)');
        ylabel('Fraction');
        bigger_linewidth(2);
        smaller_font(-6);
        legend('Data','Shuffled');
    end
end

disp(['Preferred retinal wave direction per cell compared to detect shuffled waves: minimum p-value (chi2test) = ' ...
    num2str(min(result.retinal_wave_direction_chi2_p),2)]);
disp(['Preferred retinal wave direction per cell compared to detect shuffled waves: minimum p-value (chi2test) Bonferroni corrected = ' ...
    num2str(min(result.retinal_wave_direction_chi2_p_bonf),2)]);
if min(result.retinal_wave_direction_chi2_p_bonf)<0.05
    disp(['Number of cells with p-value Bonferroni corrected below 0.05 = ' ...
        num2str( length(find(result.retinal_wave_direction_chi2_p_bonf<0.05))) ]);
end

wave_figure( result, process_params );
return


function results_event_types( result, process_params)
fprintf(['# retinal events  = ' num2str(sum(result.retinal_events),'%03.f') ', ']);
fprintf(['# cortical events = ' num2str(sum(result.cortical_events),'%03.f') '\n']);


if process_params.output_show_figures
    plot_event_types(result, process_params);
end
return


function results_cellular_events( result, process_params)
n_events = size( result.participating_fraction,1);
n_cells = size( result.event_amplitude_ratios,2);
fprintf(['# total events  = ' num2str(n_events,'%03.f') ', ']);
fprintf(['# cells = ' num2str(n_cells) '\n']);
if 0
    [dip,p_value] = HartigansDipSignifTest( result.event_amplitude_ratios(~isnan(result.event_amplitude_ratios)) );
    disp(['Bimodal retinal vs cortical event amplitudes: Hartigans'' DIP test,  p = ' num2str(p_value,2) ])
end
if process_params.output_show_figures
    plot_cellular_events( result);
end
return

function plot_cellular_events( result )
h=figure('name','Cellular results','numbertitle','off'); % per cell amplitude versus participating fraction

figcol = 3;
figrow = 2;
fignum = 1;

subplot(figrow,figcol,fignum); fignum = fignum + 1;
hold on
hist(result.event_amplitude_ratios,max(10,ceil(length(result.retinal_participations)/10)));
xlabel('Ratio of retinal over cortical event amplitude');
ylabel('N');

figure(h);
subplot(figrow,figcol,fignum); fignum = fignum + 1;
hold on
hist(result.retinal_participations,max(10,ceil(length(result.retinal_participations)/10)));
xlabel('Participations in retinal events');
ylabel('Number');

subplot(figrow,figcol,fignum); fignum = fignum + 1; %#ok<NASGU>
hold on
plot(result.retinal_participations,result.event_amplitude_ratios,'o');
xlabel('Participations in retinal events');
ylabel('Ratio of retinal over cortical event amplitude');
return


function plot_event_types(result, process_params)
figure('name','Event types','numbertitle','off');
figrow = 2;
figcol = 2;
fignum = 1;

subplot(figrow,figcol,fignum); fignum = fignum + 1;hold on;
plot(result.participating_fraction,result.amplitude_participating_cells,'.');
plot(result.participating_fraction(result.waves),result.amplitude_participating_cells(result.waves),'.k');
xlabel('Participating fraction');
ylabel('Amplitude of participating cells');

subplot(figrow,figcol,fignum); fignum = fignum + 1;
hold on;
plot(result.participating_fraction,result.timestd,'.');
plot(result.participating_fraction(result.waves),result.timestd(result.waves),'.k');
xlabel('Participating fraction');
ylabel('Time std (s)');

subplot(figrow,figcol,fignum); fignum = fignum + 1; %#ok<NASGU>
hold on;
n = histc( result.participating_fraction, (0:0.1:1));
n(end-1) = n(end-1) + n(end); % combine right edge points with last bin
n = n(1:end-1);
bar((0.15:0.1:0.95),n(2:end),1);
xlabel('Participating fraction');
ylabel('Number');
ax=axis;
plot([process_params.retinal_event_threshold process_params.retinal_event_threshold],[ax(3) ax(4)],'y');
plot([process_params.cortical_event_threshold process_params.cortical_event_threshold],[ax(3) ax(4)],'y');


function fignum = wave_figure_sub(result,events,shuffled_events,figrow,figcol,fignum)
% polar plot direction and speed
subplot(figrow,figcol,fignum); fignum = fignum + 1;
polar( result.direction(events),result.velocity(events),'o');
set(gca,'ydir','reverse')
title('rostral');
ylabel('lateral');

% rose plot of directions
min_plot_velocity = -inf;  %velocity in pixels per cm
subplot(figrow,figcol,fignum); fignum = fignum + 1;
rose( result.direction(events & result.velocity>min_plot_velocity ));
set(gca,'ydir','reverse')
hold on
[ts,rs]=rose( result.shuffled_direction(shuffled_events & result.shuffled_velocity>min_plot_velocity ));
h=polar(ts,rs*sum(events)/sum(shuffled_events));
set(h,'color',0.7*[1 1 1]);
[t,r]=rose( result.direction(events & result.velocity>min_plot_velocity ));
h=polar(t,r);

p = chi2class( [rs(2:4:end);r(2:4:end)]);
fprintf(['Preferred wave direction present: chi2 test, p = ' num2str(p,2) '\n']);
xlabel(['\chi ^2-test, p = ' num2str(p,2)]);

hold on;
title('rostral');
ylabel('lateral');

% histogram of speeds
subplot(figrow,figcol,fignum); fignum = fignum + 1;
[n,x]=hist( log10(result.shuffled_velocity(shuffled_events)) ,30);
n=n/sum(n);
h=bar(x,n,1);
set(h,'facecolor',0.7*[1 1 1]);
hold on
[n,x]=hist( log10(result.velocity(events)),x);
n=n/sum(n);
bar(x,n,0.6);
xlim([0 5]);
xlabel('Log10 velocity (log10 pixels/s)');
ylabel('Fraction');
box off
legend('Shuffled waves','Data');
legend boxoff
return


function wave_figure( result, process_params )
figure('name','Waves','numbertitle','off'); % event properties versus participating fraction
figcol = 3; figrow = 3; fignum = 1;

fprintf('Retinal:');
fignum = wave_figure_sub(result,result.retinal_waves,result.shuffled_retinal_events,figrow,figcol,fignum);
fprintf('Cortical:');
fignum = wave_figure_sub(result,result.cortical_waves,result.shuffled_cortical_events,figrow,figcol,fignum);

subplot('position',[0 0 0.1 1]);text(0.5,0.8,'Retinal','Rotation',90,'HorizontalAlignment','center');axis off
subplot('position',[0 0 0.1 1]);text(0.5,0.5,'Cortical','Rotation',90,'HorizontalAlignment','center');axis off

subplot(figrow,figcol,fignum); fignum = fignum + 1; 
hold on;
hist(result.frac_shuffled_below_fiterror,10);
ax=axis;
%figure;hist(result.rand_frac_shuffled_below_fiterror,10);

%plot( [ax(1) ax(2)],[process_params.wave_criterium process_params.wave_criterium ],'y');
%ax([3 4]) = [-10 4];
%axis(ax);
title('Wave fitting errors');
xlabel('Fraction of shuffles below fiterror');
ylabel('Number of events');

subplot(figrow,figcol,fignum); fignum = fignum + 1; 
hold on;
%figure;plot([result.neuron.wave_direction_mean]);title('Mean wave direction per cell');
hist(result.retinal_wave_direction_chi2_p,(0.025:0.025:1-0.025));
xlabel(['p-value (\chi^2), \newline ' ...
    num2str(fix(length(find(result.retinal_wave_direction_chi2_p<0.05))/length(result.retinal_wave_direction_chi2_p)*100)) '%, p<0.05']);
ylabel('Number');
xlim([0 1]);
title('Preferred retinal direction per cell?');

subplot(figrow,figcol,fignum); fignum = fignum + 1; %#ok<NASGU>
hold on;
%figure;plot([result.neuron.wave_direction_mean]);title('Mean wave direction per cell');
hist(result.retinal_wave_direction_chi2_p_bonf,(0.025:0.025:1-0.025));
xlabel('p-value (\chi^2, bonf. corr.)');
ylabel('Number');
xlim([0 1]);
title('Preferred retinal direction per cell?');


return


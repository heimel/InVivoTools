% x=[5.9 15 12 11 13 9.5 5.7 13]; 
% min(x),mean(x),max(x)
% ans =    5.7000
% ans =   10.6375
% ans =    15


figure;
hold on;
y = [];
y(1,:)=[784/3 180/2 nan nan]/(13312/3);   
y(2,:)=[2507/4 467/3 58/2 nan]/(16734/4);  
y(3,:)=[13670/4 2998/3 717/2 nan]/(117707/4);  
y(4,:)=[10481/4 764/3 60/2 nan]/(96273/4);  
%y(5,:)=[13065/6 4030/5 2456/4 1393/3]/(99068/6);
y(5,:)=[13065/6 4030/5 2456/4 nan]/(99068/6);
y(6,:)=[5614/4 1001/3 85/2 nan]/(59030/4);
y(7,:)=[1059/4 380/3 61/2 nan]/(18640/4);
y(8,:)=[14033/4 2793/3 772/2 nan]/(106497/4);
x = repmat(50*(1:4),8,1);
plot(x',y');

figure;
hold on
plot(mean(x,1),nanmean(y,1)*100)
errorbar(mean(x,1),nanmean(y,1)*100,nanstd(y,1)*100);
ylim([0 14])
xlim([40 160]);
xlabel('Distance (micron)');
ylabel('Spikes within 1 ms (%)'); 
smaller_font(-12);
bigger_linewidth(2);
%saveas(gcf,fullfile(getdesktopfolder,'spikes_within_1ms.png'),'png');
save_figure('spikes_within_1ms.png',getdesktopfolder,gcf);
% 
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Area = ssc, Channels = [4 5 6]
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Total spikes = 13312
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Spikes within 0.001 s on same channel = 0
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on neighboring channels = 784
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next neighboring channels = 180
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next neighboring channels = 0
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next next neighboring channels = 0
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Percentage counted possibly twice: 5.9 %
% RESULTS_ECTESTRECORD: Measures available in workspace as 'measures', stimulus as 'analysed_script'.
% 
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Area = ssc, Channels = [9 10 11 12]
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Total spikes = 16734
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Spikes within 0.001 s on same channel = 0
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on neighboring channels = 2507
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next neighboring channels = 467
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next neighboring channels = 58
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next next neighboring channels = 0
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Percentage counted possibly twice: 15 %
% 
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Area = ssc, Channels = [6 7 8 9]
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Total spikes = 117707
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Spikes within 0.001 s on same channel = 11
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on neighboring channels = 13670
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next neighboring channels = 2998
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next neighboring channels = 717
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next next neighboring channels = 0
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Percentage counted possibly twice: 12 %
% 
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Area = ssc, Channels = [8 9 10 11]
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Total spikes = 96273
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Spikes within 0.001 s on same channel = 7
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on neighboring channels = 10481
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next neighboring channels = 764
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next neighboring channels = 60
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next next neighboring channels = 0
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Percentage counted possibly twice: 11 %
% 
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Area = ssc, Channels = [6 7 8 9 10 11]
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Total spikes = 99068
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Spikes within 0.001 s on same channel = 2
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on neighboring channels = 13065
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next neighboring channels = 4030
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next neighboring channels = 2456
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next next neighboring channels = 1393
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Percentage counted possibly twice: 13 %
% 
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Area = ssc, Channels = [5 6 7 8]
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Total spikes = 59030
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Spikes within 0.001 s on same channel = 2
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on neighboring channels = 5614
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next neighboring channels = 1001
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next neighboring channels = 85
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next next neighboring channels = 0
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Percentage counted possibly twice: 9.5 %
% 
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Area = ssc, Channels = [4 5 6 7]
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Total spikes = 18640
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Spikes within 0.001 s on same channel = 0
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on neighboring channels = 1059
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next neighboring channels = 380
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next neighboring channels = 61
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next next neighboring channels = 0
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Percentage counted possibly twice: 5.7 %
% 
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Area = ssc, Channels = [4 5 6 7]
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Total spikes = 106497
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Spikes within 0.001 s on same channel = 1
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on neighboring channels = 14033
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next neighboring channels = 2793
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next neighboring channels = 772
% COMPUTE_FRACTION_OVERLAPPING_SPIKES:  on next next next neighboring channels = 0
% COMPUTE_FRACTION_OVERLAPPING_SPIKES: Percentage counted possibly twice: 13 %

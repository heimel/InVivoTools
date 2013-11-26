%% Random representation of some some spikes

InitNumTemps=25;
chan=11;
NumSpikes=size(WaveTime_Spikes(chan,1).data);
f_rand=randperm(NumSpikes);
subp1=floor(sqrt(InitNumTemps+1));
subp2=ceil((InitNumTemps)/sqrt(InitNumTemps));
figure;
for i=1:InitNumTemps
    A=wavelet_decompose(WaveTime_Spikes(chan,1).data(f_rand(i),:),3,'db4');
    subplot(subp1,subp2,i);plot(A(:,1));ylim([-.1,.1]);xlim([0,20])
%     subplot(subp1,subp2,i);plot(smooth(WaveTime_Spikes(chan,1).data(f_rand(i),:)));ylim([-.1,.1]);xlim([0,20])
end;

%% Threshold Sectioning
X=zeros(length(WaveTime_Spikes(chan,1).data),20);
for i=1:length(WaveTime_Spikes(chan,1).data)
X(i,1:20)=smooth(WaveTime_Spikes(chan,1).data(i,1:20));
end;
figure;plot(X(cells(1,11).spike_amplitude>0.15,1:20)')
hold on;
plot(smooth(WaveTime_Spikes(chan,1).data(cells(1,11).spike_amplitude<0.09 & cells(1,11).spike_amplitude>0.05 ,:)),'r')
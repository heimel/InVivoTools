% InitNumTemps=25;
chan=1;
% NumSpikes=size(WaveTime_Spikes(chan,1).data);
% f_rand=randperm(NumSpikes);
% subp1=floor(sqrt(InitNumTemps+1));
% subp2=ceil((InitNumTemps)/sqrt(InitNumTemps));
% figure;
% for i=1:InitNumTemps
%     A=wavelet_decompose(WaveTime_Spikes(chan,1).data(f_rand(i),:),3,'db4');
%     subplot(subp1,subp2,i);plot(A(:,3));ylim([-.1,.1]);xlim([0,30])
% %     subplot(subp1,subp2,i);plot(smooth(WaveTime_Spikes(chan,1).data(f_rand(i),:)));ylim([-.1,.1]);xlim([0,30])
% end;
% X=zeros(30,size(WaveTime_Spikes(chan,1).data,1));
% for i=1:length(WaveTime_Spikes(chan,1).data)
%     A=wavelet_decompose(WaveTime_Spikes(chan,1).data(i,:),3,'db4');
% X(:,i)=A(:,3);
% end;

spikes1=zeros(30,size(WaveTime_Spikes(chan,1).data,1));
% spikes3=zeros(30,size(WaveTime_Spikes(chan,1).data,1));
for i=1:length(WaveTime_Spikes(chan,1).data)
    A=wavelet_decompose(WaveTime_Spikes(chan,1).data(i,:),3,'db4');
    spikes1(:,i)=A(1:30,3);
%     spikes3(:,i)=A(1:30,3);
end;
Spikes1=spikes1';
spikes1=Spikes1(:,1:20);
% spikes=X(1:30,:)';
cll1.sample_interval=1/2.4414e+004;
cll1.wave = mean(spikes1,1);
cll1.std = std(spikes1,1);
cll1.snr = (max(cll1.wave)-min(cll1.wave))/mean(cll1.std);
cll1 = get_spike_features(spikes1, cll1);
% Spikes3=spikes3';
% spikes3=Spikes3(:,1:20);
% % spikes=X(1:30,:)';
% cll3.sample_interval=1/2.4414e+004;
% cll3.wave = mean(spikes3,1);
% cll3.std = std(spikes3,1);
% cll3.snr = (max(cll3.wave)-min(cll3.wave))/mean(cll3.std);
% cll3 = get_spike_features(spikes3, cll3);
XX=[cll1.spike_amplitude,cll1.spike_peak_trough_ratio/range(cll1.spike_peak_trough_ratio),cll1.spike_prepeak_trough_ratio/range(cll1.spike_prepeak_trough_ratio),cll1.spike_trough2peak_time/range(cll1.spike_trough2peak_time),spikes1(:,2:4:end)];
% XX=[cll1.spike_amplitude,cll1.spike_peak_trough_ratio/range(cll1.spike_peak_trough_ratio),cll1.spike_prepeak_trough_ratio/range(cll1.spike_prepeak_trough_ratio),...
%     cll1.spike_trough2peak_time/range(cll1.spike_trough2peak_time),cll3.spike_amplitude,cll3.spike_peak_trough_ratio/range(cll3.spike_peak_trough_ratio),...
%     cll3.spike_prepeak_trough_ratio/range(cll3.spike_prepeak_trough_ratio),cll3.spike_trough2peak_time/range(cll3.spike_trough2peak_time)];
[pc,score,latent,tsquare]=princomp(XX);
figure;
subplot(2,2,1);plot(score(:,2),score(:,3),'.')
subplot(2,2,2);plot(score(:,1),score(:,3),'.')
subplot(2,2,3);plot(score(:,1),score(:,4),'.')
subplot(2,2,4);plot(score(:,2),score(:,4),'.')
% subplot(2,2,4);plot3(score(:,2),score(:,3),score(:,5),'.')

NumClust=5;
[IDX,f1,f2,D] = kmeans(score(:,[1:4]),NumClust);
subp1=floor(sqrt(NumClust+1));
subp2=ceil(sqrt(NumClust));
figure;
Col3=rand(1,NumClust);
for i=1:NumClust
%     D=spikes(IDX==i,:);subplot(subp1,subp2,i);plot(D','Color',[i/NumClust (NumClust-i)/NumClust Col3(i)]);ylim([-.12,.12]);xlim([0,20]);hold on;plot(mean(D,1),'Color',[0 0 0],'LineWidth',3)
    D=WaveTime_Spikes(chan,1).data(IDX==i,1:20);subplot(subp1,subp2,i);plot(D','Color',[i/NumClust (NumClust-i)/NumClust Col3(i)]);ylim([-.12,.12]);xlim([0,30]);hold on;plot(mean(D,1),'Color',[0 0 0],'LineWidth',3)
end;
figure;hold on;
for i=1:NumClust
%     D=spikes(IDX==i,:);plot(D','Color',[i/NumClust (NumClust-i)/NumClust Col3(i)]);ylim([-.12,.12]);xlim([0,20]);hold on;plot(mean(D,1),'Color',[0 0 0],'LineWidth',3)
D=WaveTime_Spikes(chan,1).data(IDX==i,1:20);plot(D','Color',[i/NumClust (NumClust-i)/NumClust Col3(i)]);ylim([-.12,.12]);xlim([0,30]);hold on;plot(mean(D,1),'Color',[0 0 0],'LineWidth',3)
end;
figure;hold on;
for i=1:NumClust
%     D=spikes(IDX==i,:);plot(D','Color',[i/NumClust (NumClust-i)/NumClust Col3(i)]);ylim([-.12,.12]);xlim([0,20]);hold on;plot(mean(D,1),'Color',[0 0 0],'LineWidth',3)
D=WaveTime_Spikes(chan,1).data(IDX==i,1:20);plot(mean(D,1),'Color',[i/NumClust (NumClust-i)/NumClust Col3(i)],'LineWidth',3);ylim([-.12,.12]);xlim([0,20]);
end;

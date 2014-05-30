function [SPs,NumClust] = spike_sort_wpca(SPIKESdata,cll1,verbose)
%
%
% 2013, Mehran Ahmadlou
%

if nargin<3
    verbose = [];
end
if isempty(verbose)
    verbose = 0;
end

if size(SPIKESdata,1)<10 % cant sort with less than 10 spikes
    logmsg('Fewer than 10 spikes. Not sorting channel');
    SPs.data=SPIKESdata;
    SPs.time=cll1.data;
    NumClust = 1;
    return
end

    
    
spikes1=zeros(30,size(SPIKESdata,1));
for i=1:size(SPIKESdata,1)
    A=wavelet_decompose(SPIKESdata(i,:),3,'db4');
    spikes1(:,i)=A(1:30,3);
end;
Spikes1=spikes1';
spikes1=Spikes1(:,1:20);
cll1 = get_spike_features(spikes1, cll1);
XX=[cll1.spike_amplitude,cll1.spike_peak_trough_ratio/range(cll1.spike_peak_trough_ratio),cll1.spike_prepeak_trough_ratio/range(cll1.spike_prepeak_trough_ratio),cll1.spike_trough2peak_time/range(cll1.spike_trough2peak_time),spikes1(:,1:5:20)];
[pc,score,latent,tsquare]=princomp(XX);
% figure;
% subplot(2,2,1);plot(score(:,2),score(:,3),'.')
% subplot(2,2,2);plot(score(:,1),score(:,3),'.')
% subplot(2,2,3);plot(score(:,1),score(:,4),'.')
% subplot(2,2,4);plot(score(:,2),score(:,4),'.')
NumClust=3; %11

[IDX,f1,f2,D] = kmeans(score(:,[1:4]),NumClust);
SPs=struct([]);
for i=1:NumClust
    sps.time=cll1.data(IDX==i);
    sps.data=SPIKESdata(IDX==i,:);
    SPs=[SPs;sps];
end

if verbose
    subp1=floor(sqrt(NumClust+1));
    subp2=ceil(sqrt(NumClust));
    figure;
    Col3=rand(1,NumClust);
    for i=1:NumClust
        D=SPs(i,1).data(:,1:20);
        subplot(subp1,subp2,i);
        plot(D','Color',[i/NumClust (NumClust-i)/NumClust Col3(i)]);
        ylim([-.12,.12]);
        xlim([0,20]);
        hold on;
        plot(mean(D,1),'Color',[0 0 0],'LineWidth',3)
    end
end

return
% figure;hold on;
% for i=1:NumClust
% %     D=spikes(IDX==i,:);plot(D','Color',[i/NumClust (NumClust-i)/NumClust Col3(i)]);ylim([-.12,.12]);xlim([0,20]);hold on;plot(mean(D,1),'Color',[0 0 0],'LineWidth',3)
% D=SPIKESdata(IDX==i,1:20);plot(D','Color',[i/NumClust (NumClust-i)/NumClust Col3(i)]);ylim([-.12,.12]);xlim([0,30]);hold on;plot(mean(D,1),'Color',[0 0 0],'LineWidth',3)
% end;
% figure;hold on;
% for i=1:NumClust
% %     D=spikes(IDX==i,:);plot(D','Color',[i/NumClust (NumClust-i)/NumClust Col3(i)]);ylim([-.12,.12]);xlim([0,20]);hold on;plot(mean(D,1),'Color',[0 0 0],'LineWidth',3)
% D=SPIKESdata(IDX==i,1:20);plot(mean(D,1),'Color',[i/NumClust (NumClust-i)/NumClust Col3(i)],'LineWidth',3);ylim([-.12,.12]);xlim([0,20]);
% end;

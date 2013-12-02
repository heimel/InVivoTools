% seriesname={'AO' 'BMI'};
% d1=load('jao.txt');
% d2=load('jbaltic.txt');
% figure;plot((d2(:,2)));d2(:,2)=boxpdf(d2(:,2));figure;plot((d2(:,2)),'r');
% tlim=[min(d1(1,1),d2(1,1)) max(d1(end,1),d2(end,1))];
% subplot(2,1,1);
% wt(d1);
% title(seriesname{1});
% set(gca,'xlim',tlim);
% subplot(2,1,2)
% wt(d2)
% title(seriesname{2})
% set(gca,'xlim',tlim)
% clf
% xwt(d1,d2)
% title(['XWT: ' seriesname{1} '-' seriesname{2} ] )
% clc
% clf
% wtc(d1,d2)
% title(['WTC: ' seriesname{1} '-' seriesname{2} ] )
% 

load waves_31_6
waves_timeSC=waves_timeVC;waves_SC=waves_VC;
load waves_31_12
RSQ=0;
for i=1:80
    d1=[waves_timeSC(i,:);waves_SC(i,:)]';
    d2=[waves_timeVC(i,:);waves_VC(i,:)]';
    [Rsq,period,scale,coi,sig95]=wtc(d1,d2,'mcc',0);
    RSQ=RSQ+Rsq;
end
% figure;imagesc(RSQ/80)
figure;
subplot(5,1,1)
surf(waves_timeVC(1,:),1./period(10:97),RSQ(10:97,:)/80,'EdgeColor','none');
axis xy; axis tight; view(0,90);

load waves_32_6
waves_timeSC=waves_timeVC;waves_SC=waves_VC;
load waves_32_12
RSQ=0;
for i=1:80
    d1=[waves_timeSC(i,:);waves_SC(i,:)]';
    d2=[waves_timeVC(i,:);waves_VC(i,:)]';
    [Rsq,period,scale,coi,sig95]=wtc(d1,d2,'mcc',0);
    RSQ=RSQ+Rsq;
end
% figure;imagesc(RSQ/80)
subplot(5,1,2)
surf(waves_timeVC(1,:),1./period(10:97),RSQ(10:97,:)/80,'EdgeColor','none');
axis xy; axis tight; view(0,90);

load waves_33_6
waves_timeSC=waves_timeVC;waves_SC=waves_VC;
load waves_33_12
RSQ=0;
for i=1:80
    d1=[waves_timeSC(i,:);waves_SC(i,:)]';
    d2=[waves_timeVC(i,:);waves_VC(i,:)]';
    [Rsq,period,scale,coi,sig95]=wtc(d1,d2,'mcc',0);
    RSQ=RSQ+Rsq;
end
% figure;imagesc(RSQ/80)
subplot(5,1,3)
surf(waves_timeVC(1,:),1./period(10:97),RSQ(10:97,:)/80,'EdgeColor','none');
axis xy; axis tight; view(0,90);

load waves_34_6
waves_timeSC=waves_timeVC;waves_SC=waves_VC;
load waves_34_12
RSQ=0;
for i=1:80
    d1=[waves_timeSC(i,:);waves_SC(i,:)]';
    d2=[waves_timeVC(i,:);waves_VC(i,:)]';
    [Rsq,period,scale,coi,sig95]=wtc(d1,d2,'mcc',0);
    RSQ=RSQ+Rsq;
end
% figure;imagesc(RSQ/80)
subplot(5,1,4)
surf(waves_timeVC(1,:),1./period(10:97),RSQ(10:97,:)/80,'EdgeColor','none');
axis xy; axis tight; view(0,90);

load waves_35_6
waves_timeSC=waves_timeVC;waves_SC=waves_VC;
load waves_35_12
RSQ=0;
for i=1:80
    d1=[waves_timeSC(i,:);waves_SC(i,:)]';
    d2=[waves_timeVC(i,:);waves_VC(i,:)]';
    [Rsq,period,scale,coi,sig95]=wtc(d1,d2,'mcc',0);
    RSQ=RSQ+Rsq;
end
% figure;imagesc(RSQ/80)
subplot(5,1,5)
surf(waves_timeVC(1,:),1./period(10:97),RSQ(10:97,:)/80,'EdgeColor','none');
axis xy; axis tight; view(0,90);


% figure;wtc(d1,d2,'mcc',0);
% load waves_sf_0_33_6
% load waves_sf_0_33_12
% RSQ=0;
% for i=1:30
%     d1=[waves_timeSC(i,:);waves_SC(i,:)]';
%     d2=[waves_timeVC(i,:);waves_VC(i,:)]';
%     [Rsq,period,scale,coi,sig95]=wtc(d1,d2);
%     RSQ=RSQ+Rsq;
% end
% figure;imagesc(RSQ/30)
% load waves_sf_0_35_6
% load waves_sf_0_35_12
% RSQ=0;
% for i=1:30
%     d1=[waves_timeSC(i,:);waves_SC(i,:)]';
%     d2=[waves_timeVC(i,:);waves_VC(i,:)]';
%     [Rsq,period,scale,coi,sig95]=wtc(d1,d2);
%     RSQ=RSQ+Rsq;
% end
% figure;imagesc(RSQ/30)
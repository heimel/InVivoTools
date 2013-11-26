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

load waves_sf_0_31_6
load waves_sf_0_31_12
RSQ=0;
for i=1:60
    d1=[waves_timeSC(i,:);waves_SC(i,:)]';
    d2=[waves_timeVC(i,:);waves_VC(i,:)]';
    [Rsq,period,scale,coi,sig95]=wtc(d1,d2);
    RSQ=RSQ+Rsq;
end
figure;imagesc(RSQ/60)
load waves_sf_0_33_6
load waves_sf_0_33_12
RSQ=0;
for i=1:60
    d1=[waves_timeSC(i,:);waves_SC(i,:)]';
    d2=[waves_timeVC(i,:);waves_VC(i,:)]';
    [Rsq,period,scale,coi,sig95]=wtc(d1,d2);
    RSQ=RSQ+Rsq;
end
figure;imagesc(RSQ/60)
load waves_sf_0_35_6
load waves_sf_0_35_12
RSQ=0;
for i=1:60
    d1=[waves_timeSC(i,:);waves_SC(i,:)]';
    d2=[waves_timeVC(i,:);waves_VC(i,:)]';
    [Rsq,period,scale,coi,sig95]=wtc(d1,d2);
    RSQ=RSQ+Rsq;
end
figure;imagesc(RSQ/60)
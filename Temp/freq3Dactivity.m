% close all
% clear
% clc
% imshow(retinotopyfig);
% hpos = impoly;
% pos = getPosition(hpos);
%%
% 
% load ffrr
% load MFRDnew
% % load MFRDnew_phase
sm=length(ffrr);
m=[size(ffrr{1,1}(1:end,1:end),1),size(ffrr{1,1}(1:end,1:end),2)];
MFRDnew=zeros(m(1),m(2),sm);
% sm=size(MFRDnew,3);
% denspat = fspecial('gaussian',3,3);
for i=1:sm
    MFRDnew(:,:,i)=ffrr{1,i}(1:end,1:end);
%     GausI=imfilter(MFRDnew(:,:,i),denspat,'conv');
%     MFRDnew(:,:,i)=GausI;
    i
end;
blk_num=1;
Tnum=sm/blk_num;
StimNum=1;
TS=Tnum/StimNum;
clear ffrr

M_index=[];
for f=0:StimNum-1
    M_ind=[];
    for k=0:blk_num-1
        M_ind=[M_ind,Tnum*k+TS*f+1:Tnum*k+TS*(f+1)];
    end
    M_index=[M_index;M_ind];
end

w=80;
fs=12.4;
nfft=4*w;
FREQpoint=floor(nfft/2)+1;
FreqFrame=zeros(m(1),m(2),StimNum,FREQpoint);
for f=1:StimNum
for i=1:m(1)
    for j=1:m(2)
        FreqFrame(i,j,f,:)=pwelch(squeeze(MFRDnew(i,j,M_index(f,:))),w,floor(w/2),nfft,fs);
    end
end
f
end
clear MFRDnew
save('FreqFrame_1314_E19_0617_0to120.mat','FreqFrame')
% MFRDnew2=[];
% for i=1:sm
%     MFRDnew2(:,:,i)=MFRDnew([80:110,70:120],[20:60,90:160],i);
%     i
% end;
% MFRDnew=MFRDnew2;
% % % 

% for t0=1:FREQpoint
%     frameX=FreqFrame(1:3:end,1:3:end,:,t0)./squeeze(sum(FreqFrame(1:3:end,1:3:end,:,:),4));
% end

figure;
cmap1=colormap('prism');

%%%%%%%%%%%%%%%%%%%%%%%
lev1=1/FREQpoint;
lev2=6/FREQpoint;
labelStr='tv';
btnPos1=[70 70 18 700];
tv=uicontrol( ...
    'Style','slider', ...
    'Position',btnPos1, ...
    'String',labelStr, ...
    'max',FREQpoint,...
    'min',1,...
    'Value',1,...
    'SliderStep',[lev1 lev2]);

labelStr='OK';
callbackStr='good=1;';
pH=uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',[0.93 0.05 0.05  0.05], ...
    'String',labelStr, ...
    'Interruptible','on', ...
    'Callback',callbackStr);
Fac1=ceil(sqrt(StimNum));Fac2=ceil(StimNum/Fac1);
good=0;
% sumFX=squeeze(sum(FreqFrame(1:10:end,1:10:end,:,:),4));
% sumFX=squeeze(mean(FreqFrame(1:10:end,1:10:end,:,:),4));
% Mrange=[min(sumFX(:)) max(sumFX(:))];
% Mrange=[-.5*std(MFRDmean(:))+.5*std(MFRDmean(:))];
while good ==0
    t0=get(tv,'Value');
    t0=floor(t0);
    aa=(t0/FREQpoint)*fs;
    frameX=FreqFrame(1:10:end,1:10:end,:,t0)./sumFX;
    for i=1:StimNum
%         frameX=FreqFrame(:,:,:,t0);
        subplot(Fac1,Fac2,i)
%         Mrange=[min(frameX(:)) max(frameX(:))];
%         imshow(squeeze(FreqFrame(1:2:end,1:2:end,i,t0))'./squeeze(sum(FreqFrame(1:2:end,1:2:end,i,:),4))',Mrange,'Colormap',cmap1)
        imshow(squeeze(FreqFrame(1:2:end,1:2:end,i,t0))',Mrange,'Colormap',cmap1)
        colormap jet % prism
        %         aa2=num2str(ffdd);
        posi2 = [70 840 40 15];
        hh = uicontrol('Style','text',...
            'String',aa,...
            'Position',posi2);
%         hpos = impoly(gca, floor(pos/2));
        drawnow;
    end
end;

% figure; Mrange=[0.5 1];for i=1:StimNum
% subplot(Fac1,Fac2,i);FD=mean(squeeze(MFRDnew(:,:,M_index(i,:))),3)'-MFRDmean';
% imshow((FD-min(FD(:))/max(FD(:))),Mrange,'Colormap',cmap1);
% end;colormap jet

%% for TF stim
% 
% x1=151;y1=115;
% N1=3;
% T1=5;
% L=1395;
% F1=floor(L/T1);
% F2=floor(L/(T1*N1));
% TMS={};
% for nm=0:N1-1
% TM=[];
%     for ts=0:T1-1
% TM=[TM;squeeze(MFRDnew(x1,y1,F1*ts+F2*nm+1:F1*ts+F2*(nm+1)))-squeeze(mean(MFRDnew(x1,y1,F1*ts+F2*nm+10:F1*ts+F2*nm+25),3))];
% 
% end;
% TMS=[TMS,TM];
% end;
% figure;plot(TMS{1})
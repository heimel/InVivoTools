% close all
% clear
% clc

%%
% 
% % load ffrr
% % load MFRDnew
% % % load MFRDnew_phase
% blk_num=20;
% sm=length(ffrr);
% Tnum=sm/blk_num;
% StimNum=2;
% TS=Tnum/StimNum;
% m=[size(ffrr{1,1}(1:end,1:end),1),size(ffrr{1,1}(1:end,1:end),2)];
% MFRDnew=zeros(m(1),m(2),sm);
% denspat = fspecial('gaussian',5,5);
% for i=1:sm
%     MFRDnew(:,:,i)=ffrr{1,i}(1:end,1:end);
%     GausI=imfilter(MFRDnew(:,:,i),denspat,'conv');
%     MFRDnew(:,:,i)=GausI;
%     i
% end;
MFRDnew1=[];
MFRDnew2=[];
for i=1:sm
    MFRDnew1(:,:,i)=MFRDnew(165:175,87:97,i);
    MFRDnew2(:,:,i)=MFRDnew(148:158,116:126,i);
    i
end;
% MFRDnew=MFRDnew2;
% % % 
% % %%
% % 
% 
% % MFRDmean=(MFRDmean-min(MFRDmean(:)))/max(MFRDmean(:));
% 
M_index=[];
M_ind_pre=[];
M_ind_new1={};
M_ind_new2={};
M_ind_stim=[];
for f=0:StimNum-1
    M_ind=[];
    M_ind_st=[];
    for k=0:blk_num-1
        M_ind=[M_ind,Tnum*k+TS*f+1:Tnum*k+TS*(f+1)];
        M_ind_pre=[M_ind_pre,Tnum*k+TS*f+1:Tnum*k+TS*f+16];
        M_ind_st=[M_ind_st,Tnum*k+TS*f+50:Tnum*k+TS*f+70];
        M_ind_new1{f+1,k+1}=squeeze(mean(shiftdim(MFRDnew1(:,:,Tnum*k+TS*f+50:Tnum*k+TS*f+70),2)));
        M_ind_new2{f+1,k+1}=squeeze(mean(shiftdim(MFRDnew2(:,:,Tnum*k+TS*f+50:Tnum*k+TS*f+70),2)));
    end
    M_index=[M_index;M_ind];
    M_ind_stim=[M_ind_stim;M_ind_st];
end
% % 
% MFRDmean=squeeze(mean(shiftdim(MFRDnew(:,:,1:3:end),2)));
MFRDmean=squeeze(mean(shiftdim(MFRDnew(:,:,M_ind_pre),2)));

pretimeStim=sm/blk_num/StimNum;

for t0=1:sm/StimNum
    for i=1:StimNum
        PMP1(i,t0)=mean(mean((squeeze(MFRDnew1(:,:,M_index(i,t0)))-M_ind_new1{i,ceil(t0/pretimeStim)})));
        PMP2(i,t0)=mean(mean((squeeze(MFRDnew2(:,:,M_index(i,t0)))-M_ind_new2{i,ceil(t0/pretimeStim)})));
    end
end
% CORRPMPcircle=0;
% CORRPMPsquare=0;
% M_ind_stim=[];
% for k=0:blk_num-1
%     f_ind=k*pretimeStim+54:k*pretimeStim+62;
%     M_ind_stim=[M_ind_stim,f_ind];
%     PMPC(k+1)=mean(PMP1(1,f_ind)-PMP2(1,f_ind));
%     PMPS(k+1)=mean(PMP1(2,f_ind)-PMP2(2,f_ind));
%     am1=corrcoef(PMP1(1,f_ind),PMP2(1,f_ind));
%     am2=corrcoef(PMP1(2,f_ind),PMP2(2,f_ind));
%     CORRPMPcircle(k+1)=am1(1,2);
%     CORRPMPsquare(k+1)=am2(1,2);
% end

% CORRPMP11=[];
% CORRPMP12=[];
% CORRPMP22=[];
% M_ind_stim=[];
% for j=1:StimNum
% for k=0:blk_num-1
%     f_ind=k*pretimeStim+50:k*pretimeStim+70;
%     M_ind_stim=[M_ind_stim,f_ind];
%     am11=corrcoef(PMP1(j,f_ind),PMP1(j,f_ind));
%     am12=corrcoef(PMP1(j,f_ind),PMP2(j,f_ind));
%     am22=corrcoef(PMP2(j,f_ind),PMP2(j,f_ind));
%     CORRPMP11(j,k+1)=am11(1,2);
%     CORRPMP12(j,k+1)=am12(1,2);
%     CORRPMP22(j,k+1)=am22(1,2);
% end
% end


CORRPMP11=[];
CORRPMP12=[];
CORRPMP22=[];
M_ind_st=[];
for j=1:StimNum
    f_ind=k*pretimeStim+45:k*pretimeStim+80;
    M_ind_st=[M_ind_st,f_ind];
end
for j=1:StimNum
    f_ind=k*pretimeStim+50:k*pretimeStim+70;
    M_ind_stim=[M_ind_stim,f_ind];
    am11=corrcoef(PMP1(j,M_ind_st),PMP1(j,M_ind_st));
    am12=corrcoef(PMP1(j,M_ind_st),PMP2(j,M_ind_st));
    am22=corrcoef(PMP2(j,M_ind_st),PMP2(j,M_ind_st));
    CORRPMP11(j,k+1)=am11(1,2);
    CORRPMP12(j,k+1)=am12(1,2);
    CORRPMP22(j,k+1)=am22(1,2);
end

figure;plot(CORRPMPcircle);hold on;plot(CORRPMPsquare,'r')

PMPcircle=PMP1(1,M_ind_stim)-PMP2(1,M_ind_stim);
PMPsquare=PMP1(2,M_ind_stim)-PMP2(2,M_ind_stim);
figure;plot(PMPcircle);hold on;plot(PMPsquare,'r')


PMPnew=[PMPC,PMPS]';
ind_anova={};
for i=1:20
    ind_anova=[ind_anova,'C'];
end
for i=21:40
    ind_anova=[ind_anova,'S'];
end
p=anova1(PMPnew,ind_anova);


% errorbar(mean())
% 
% 
% F=[];
% 
% figure;
% 
% % subplot(2,2,1)
% cmap1=colormap('prism');
% % imshow(MFRDmean,[min(MFRDmean(:)) max(MFRDmean(:))],'Colormap',cmap1)
% % colormap prism
% % MFRDmean_phase=squeeze(mean(shiftdim(MFRDnew_phase,2)));
% % subplot(2,2,2)
% % cmap2=colormap('hsv');
% % imshow(MFRDmean_phase,[-pi pi],'Colormap',cmap2)
% % colormap prism
% 
% % subplot(2,2,4)
% % imshow(MFRDnew(:,:,1),[min(MFRDmean(:)) max(MFRDmean(:))],'Colormap',cmap1)
% % colormap prism
% % subplot(2,2,5)
% % imshow(MFRDnew_phase(:,:,1),[-pi pi],'Colormap',cmap2)
% % colormap prism
% 
% %%%%%%%%%%%%%%%%%%%%%%%
% lev1=StimNum/sm;
% lev2=1/blk_num;
% labelStr='tv';
% btnPos1=[70 70 18 700];
% tv=uicontrol( ...
%     'Style','slider', ...
%     'Position',btnPos1, ...
%     'String',labelStr, ...
%     'max',floor(sm/StimNum),...
%     'min',1,...
%     'Value',1,...
%     'SliderStep',[lev1 lev2]);
% 
% % labelStr='sv';
% % btnPos2=[200 50 8 100];
% % sv=uicontrol( ...
% %     'Style','slider', ...
% %     'Position',btnPos2, ...
% %     'String',labelStr, ...
% %     'max',sm,...
% %     'min',1,...
% %     'Value',5);
% 
% labelStr='OK';
% callbackStr='good=1;';
% pH=uicontrol( ...
%     'Style','pushbutton', ...
%     'Units','normalized', ...
%     'Position',[0.93 0.05 0.05  0.05], ...
%     'String',labelStr, ...
%     'Interruptible','on', ...
%     'Callback',callbackStr);
% Fac1=floor(sqrt(StimNum));Fac2=floor(StimNum/Fac1);
% good=0;
% Mrange=[-0.25*std(MFRDmean(:)) +.25*std(MFRDmean(:))];
% while good ==0
%     t0=get(tv,'Value');
% %     s0=get(sv,'Value');
%     t0=floor(t0);
% %     s0=floor(s0);
% for i=1:StimNum
% subplot(Fac1,Fac2,i)
% % imshow(squeeze(MFRDnew(:,:,M_index(i,t0)))'-MFRDmean',Mrange,'Colormap',cmap1)
% imshow(squeeze(MFRDnew(:,:,M_index(i,t0)))'-M_ind_new{i,ceil(t0/pretimeStim)}',Mrange,'Colormap',cmap1)
% 
% colormap jet % prism
% % subplot(2,2,2)
% % imshow(squeeze(MFRDnew(:,:,M_index(2,t0)))'-MFRDmean',Mrange,'Colormap',cmap1)
% % colormap jet
% % subplot(2,2,3)
% % imshow(squeeze(MFRDnew(:,:,M_index(3,t0)))'-MFRDmean',Mrange,'Colormap',cmap1)
% % colormap jet
% % subplot(2,2,4)
% % imshow(squeeze(MFRDnew(:,:,M_index(4,t0)))'-MFRDmean',Mrange,'Colormap',cmap1)
% % colormap jet
% % subplot(2,2,5)
% % imshow(MFRDnew_phase(:,:,s0),[-pi pi],'Colormap',cmap2)
% % colormap prism
%     drawnow;
% end
% end;




% MFRDnew1=[];
% MFRDnew2=[];
% for i=1:sm
%     MFRDnew1(:,:,i)=MFRDnew(105:150,45:85,i);
%     MFRDnew2(:,:,i)=MFRDnew(130:150,150:190,i);
% %     MFRDnew2(:,:,i)=MFRDnew(160:180,105:125,i);
%     i
% end;

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
        M_ind_pre=[M_ind_pre,Tnum*k+TS*f+2:Tnum*k+TS*f+30];
        M_ind_st=[M_ind_st,Tnum*k+TS*f+1:Tnum*k+TS*f+80];
        M_ind_new1{f+1,k+1}=squeeze(mean(shiftdim(MFRDnew1(:,:,Tnum*k+TS*f+2:Tnum*k+TS*f+30),2)));
        M_ind_new2{f+1,k+1}=squeeze(mean(shiftdim(MFRDnew2(:,:,Tnum*k+TS*f+2:Tnum*k+TS*f+30),2)));
    end
    M_index=[M_index;M_ind];
    M_ind_stim=[M_ind_stim;M_ind_st];
end
% % 
% MFRDmean=squeeze(mean(shiftdim(MFRDnew(:,:,1:3:end),2)));
MFRDmean=squeeze(mean(shiftdim(MFRDnew(:,:,M_ind_pre),2)));

pretimeStim=sm/blk_num/StimNum;
PMP1=[];
for t0=1:sm/StimNum
    for i=1:StimNum
        PMP1(i,t0)=mean(mean((squeeze(MFRDnew1(:,:,M_index(i,t0)))-M_ind_new1{i,ceil(t0/pretimeStim)})));
        PMP2(i,t0)=mean(mean((squeeze(MFRDnew2(:,:,M_index(i,t0)))-M_ind_new2{i,ceil(t0/pretimeStim)})));
    end
end
CORRPMPcircle=0;
CORRPMPsquare=0;
M_ind_stim=[];
for k=0:blk_num-1
    f_ind=k*pretimeStim+68:k*pretimeStim+80;
    M_ind_stim=[M_ind_stim,f_ind];
    PMPC(k+1)=mean(PMP1(1,f_ind)-PMP2(1,f_ind));
    PMPS(k+1)=mean(PMP1(2,f_ind)-PMP2(2,f_ind));
    PMPS45(k+1)=mean(PMP1(3,f_ind)-PMP2(3,f_ind));
%     [PMPC(k+1),PMPCtime(k+1)]=max(PMP1(1,f_ind)-PMP2(1,f_ind));
%     [PMPS(k+1),PMPStime(k+1)]=max(PMP1(2,f_ind)-PMP2(2,f_ind));
%     [PMPS45(k+1),PMPS45time(k+1)]=max(PMP1(3,f_ind)-PMP2(3,f_ind));
%     PMPC(k+1)=mean(angle(hilbert(PMP1(1,f_ind)-PMP2(1,f_ind))));
%     PMPS(k+1)=mean(angle(hilbert(PMP1(2,f_ind)-PMP2(2,f_ind))));
%     PMPS45(k+1)=mean(angle(hilbert(PMP1(3,f_ind)-PMP2(3,f_ind))));
    am1=corrcoef(PMP1(1,f_ind),PMP2(1,f_ind));
    am2=corrcoef(PMP1(2,f_ind),PMP2(2,f_ind));
    CORRPMPcircle(k+1)=am1(1,2);
    CORRPMPsquare(k+1)=am2(1,2);
end

% figure;plot(CORRPMPcircle);hold on;plot(CORRPMPsquare,'r')
PMPcircle=[];
phasePMPcircle=[];
PMPmean=0;
PMPstd=0;
for i=1:StimNum
PMPcircle(i,:)=PMP2(i,M_ind_stim);
hp=hilbert(PMPcircle(i,:));
phasePMPcircle(i,:)=angle(hp);
PMPmean(i)=mean(PMP1(i,M_ind_stim));
PMPstd(i)=std(PMP1(i,M_ind_stim));
end;
% figure;plot(PMPcircle');
% figure;plot(PMPcircle(1,:));hold on;plot(PMPcircle(2,:),'r');
%  figure;plot(PMPCtime,'r');hold on;plot(PMPStime,'g');plot(PMPS45time,'b')
figure;plot(PMPC,'r');hold on;plot(PMPS,'g');plot(PMPS45,'b');
figure;plot(phasePMPcircle(1,:));hold on;plot(phasePMPcircle(2,:),'r');
% figure;plot(PMPmean)
% figure;errorbar(PMPmean,PMPstd)
% PMPnew=[PMPCtime,PMPS45time]';
PMPnew=[PMPC,PMPS]';
ind_anova={};
for i=1:24
    ind_anova=[ind_anova,'C'];
end
for i=25:48
    ind_anova=[ind_anova,'S'];
end
p=anova1(PMPnew,ind_anova);


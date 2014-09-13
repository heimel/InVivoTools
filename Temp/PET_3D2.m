% close all
% clear
% clc
% imshow(retinotopyfig);
% hpos = impoly;
% pos = getPosition(hpos);
%%
% 
% % load ffrr
% % load MFRDnew
% % % load MFRDnew_phase
% blk_num=1;
% sm=length(ffrr);
Tnum=sm/blk_num;
StimNum=4;
TS=Tnum/StimNum;
% m=[size(ffrr{1,1}(1:end,1:end),1),size(ffrr{1,1}(1:end,1:end),2)];
% MFRDnew=zeros(m(1),m(2),sm);
% % denspat = fspecial('gaussian',3,3);
% for i=1:sm
%     MFRDnew(:,:,i)=ffrr{1,i}(1:end,1:end);
% %     GausI=imfilter(MFRDnew(:,:,i),denspat,'conv');
% %     MFRDnew(:,:,i)=GausI;
%     i
% end;
% clear ffrr
% 
% % for i=1:m(1)
% %     for j=1:m(2)
% %         MFRDnew(i,j,:)= angle(hilbert(MFRDnew(i,j,:)));
% %     end
% % end
% 
% 
% % MFRDnew2=[];
% % for i=1:sm
% %     MFRDnew2(:,:,i)=MFRDnew([80:110,70:120],[20:60,90:160],i);
% %     i
% % end;
% % MFRDnew=MFRDnew2;
% % % % 
% % % %%
% % % 
% % 
% % % MFRDmean=(MFRDmean-min(MFRDmean(:)))/max(MFRDmean(:));
% % 

MFRDnew=data;
M_index=[];
% M_ind_pre=[];
% M_ind_new={};
for f=0:StimNum-1
    M_ind=[];
    for k=0:blk_num-1
        M_ind=[M_ind,Tnum*k+TS*f+1:Tnum*k+TS*(f+1)];
%         M_ind_pre=[M_ind_pre,Tnum*k+TS*f+1:Tnum*k+TS*f+100];
%         M_ind_new{f+1,k+1}=squeeze(mean(shiftdim(MFRDnew(:,:,Tnum*k+TS*f+1:Tnum*k+TS*f+100),2)));
    end
    M_index=[M_index;M_ind];
end
% % % 
% % MFRDmean=squeeze(mean(shiftdim(MFRDnew(:,:,1:3:end),2)));
% MFRDmean=squeeze(mean(shiftdim(MFRDnew(:,:,M_ind_pre),2)));
% 
% pretimeStim=sm/blk_num/StimNum;
% data=reshape(data,222,186,140);



F=[];

figure;

% subplot(2,2,1)
cmap1=colormap('prism');
% imshow(MFRDmean,[min(MFRDmean(:)) max(MFRDmean(:))],'Colormap',cmap1)
% colormap prism
% MFRDmean_phase=squeeze(mean(shiftdim(MFRDnew_phase,2)));
% subplot(2,2,2)
% cmap2=colormap('hsv');
% imshow(MFRDmean_phase,[-pi pi],'Colormap',cmap2)
% colormap prism

% subplot(2,2,4)
% imshow(MFRDnew(:,:,1),[min(MFRDmean(:)) max(MFRDmean(:))],'Colormap',cmap1)
% colormap prism
% subplot(2,2,5)
% imshow(MFRDnew_phase(:,:,1),[-pi pi],'Colormap',cmap2)
% colormap prism
blk_num=7;
StimNum=4;
sm=140;
%%%%%%%%%%%%%%%%%%%%%%%
lev1=StimNum/sm;
lev2=1/blk_num;
labelStr='tv';
btnPos1=[70 70 18 700];
tv=uicontrol( ...
    'Style','slider', ...
    'Position',btnPos1, ...
    'String',labelStr, ...
    'max',floor(sm/StimNum),...
    'min',1,...
    'Value',1,...
    'SliderStep',[lev1 lev2]);

% labelStr='sv';
% btnPos2=[200 50 8 100];
% sv=uicontrol( ...
%     'Style','slider', ...
%     'Position',btnPos2, ...
%     'String',labelStr, ...
%     'max',sm,...
%     'min',1,...
%     'Value',5);

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
Mrange=[-pi pi];
% Mrange=[-.5*std(MFRDmean(:)) +.5*std(MFRDmean(:))];
while good ==0
    t0=get(tv,'Value');
    %     s0=get(sv,'Value');
    t0=floor(t0);
    %     s0=floor(s0);
    for i=1:StimNum
        subplot(Fac1,Fac2,i)
%         imshow(squeeze(MFRDnew(:,:,floor(t0/5)))',Mrange,'Colormap',cmap1)
%         imshow(im2bw(squeeze(MFRDnew(:,:,M_index(i,t0)))'-MFRDmean',0.99))

        imshow(squeeze(MFRDnew(:,:,M_index(i,t0)))',Mrange,'Colormap',cmap1)
%         imshow(squeeze(MFRDnew(:,:,M_index(i,t0)))'-M_ind_new{i,ceil(t0/pretimeStim)}',Mrange,'Colormap',cmap1)
%         aa1=num2str(mod(t0,pretimeStim));
%         posi1 = [70 800 40 15];
%         hh = uicontrol('Style','text',...
%             'String',aa1,...
%             'Position',posi1);
%         ffdd=ceil(t0/pretimeStim);
%         aa2=num2str(ffdd);
%         posi2 = [70 840 40 15];
%         hh = uicontrol('Style','text',...
%             'String',aa2,...
%             'Position',posi2);
%         hpos = impoly(gca, pos);
%         colormap jet % prism
        % subplot(2,2,2)
        % imshow(squeeze(MFRDnew(:,:,M_index(2,t0)))'-MFRDmean',Mrange,'Colormap',cmap1)
        % colormap jet
        % subplot(2,2,3)
        % imshow(squeeze(MFRDnew(:,:,M_index(3,t0)))'-MFRDmean',Mrange,'Colormap',cmap1)
        % colormap jet
        % subplot(2,2,4)
        % imshow(squeeze(MFRDnew(:,:,M_index(4,t0)))'-MFRDmean',Mrange,'Colormap',cmap1)
        % colormap jet
        % subplot(2,2,5)
        % imshow(MFRDnew_phase(:,:,s0),[-pi pi],'Colormap',cmap2)
        colormap gray
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
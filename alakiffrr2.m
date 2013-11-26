load ffrr3
% figure;

for i=1:length(ffrr)
    ffrr{1,i}=ffrr{1,i}(40:140,20:120);
end;

m=[size(ffrr{1,1},1),size(ffrr{1,1},2)];
% FR=zeros(length(ffrr),m-26000+1);
MFRD=zeros(m(1),m(2),length(ffrr));
MFRD_phase=zeros(m(1),m(2),length(ffrr));
denspat = fspecial('gaussian',5,5);
for i=1:length(ffrr)
    GausI=imfilter(ffrr{1,i},denspat,'conv');
    MFRD(:,:,i)=GausI;
    MFRD_phase(:,:,i)=angle(hilbert(GausI));
%     MFRD(:,:,i)=ffrr{1,i};
end;
maxS=35;
MFRDnew=zeros(m(1),m(2),length(ffrr));
MFRDnew_phase=zeros(m(1),m(2),length(ffrr));
for i=1:m(1)
    TD=squeeze(MFRD(i,:,:));
    [U,S,V] = svd(TD);
    SS=[S(1:maxS,:);zeros(m(2)-maxS,length(ffrr))];
    TDnew=U*SS*V';
    MFRDnew(i,:,:)=TDnew;
    MFRDnew_phase(i,:,:)= angle(hilbert(TDnew));
end;
% gausian
% A=0;
% for i=1:length(ffrr)
% %     GausI=imfilter(ffrr{1,i},denspat,'conv');
% %     GausI=imfilter(MFRDnew(:,:,i),denspat,'conv');
% GausI=imfilter(MFRDnew_phase(:,:,i),denspat,'conv');
%     imshow(GausI,[]);
% %     imshow(MFRDnew_phase(:,:,i),[]);
%     A=A+MFRD_phase(:,:,i);
%     colormap prism;
%     pause(0.1)
% end


save('MFRDnew.mat','MFRDnew')
save('MFRDnew_phase.mat','MFRDnew_phase')

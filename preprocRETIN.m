
LF=length(ffrr);
m=[size(ffrr{1,1},1),size(ffrr{1,1},2)];
% FR=zeros(length(ffrr),m-26000+1);
MFRD=zeros(m(1),m(2),LF);
% MFRD_phase=zeros(m(1),m(2),LF-1000);
% denspat = fspecial('gaussian',5,5);
% MF=0;
% for i=1:LF-1000
%     MF=MF+ffrr{1,i};
% end;
% MFRD_rajeev=zeros(m(1),m(2),LF-1000);
% MF=MF/(LF-1000);
for i=1:LF
%     GausI=imfilter((ffrr{1,i}-MF)./MF,denspat,'conv');
%     MFRD(:,:,i)=GausI;
    MFRD(:,:,i)=ffrr{1,i};i
%         MFRD_phase(:,:,i)=angle(hilbert(GausI));
%         MFRD_phase(:,:,i)=angle(hilbert((ffrr{1,i}-ffrr{1,1})./ffrr{1,1}));
%     MFRD_phase(:,:,i)=angle(hilbert(ffrr{1,i}));
    %         MFRD(:,:,i)=ffrr{1,i};
end;
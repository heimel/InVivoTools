GGG=zeros(m(2),m(1));
s1=26;s2=65;p1=12;p2=20;

% MFRD2=zeros(m(1),m(2),4960);
% [a1,a2] = butter(3,1/12.4,'low');
% for i=1:m(1)
%     for j=1:m(2)
%         MFRD2(i,j,:)=filter(a1,a2,MFRD(i,j,:));
%     end
% end

for x=1:m(1)
    for y=1:m(2)
        g=0;
        for k=0:10
            for f=0:3
                g(k+1,f+1)=(mean(squeeze(MFRD(x,y,496*k+124*f+s1:496*k+124*f+s2)))-mean(squeeze(MFRD(x,y,496*k+124*f+p1:496*k+124*f+p2))))/mean(squeeze(MFRD(x,y,496*k+124*f+p1:496*k+124*f+p2)));
            end
        end
        [G,GG]=max(g');
        GGG(y,x)=mode(GG(2:end));
    end
    x
end

% figure;plot(squeeze(MFRD(x,y,496*k+124*f+1:496*k+124*(f+1)))-mean(squeeze(MFRD(x,y,496*k+124*f+1:496*k+124*f+20))),'g');
% hold on;plot(squeeze(MFRD(x,y,496*k+124*f+1:496*k+124*(f+1))-mean(squeeze(MFRD(x,y,496*k+124*f+1:496*k+124*f+20)))),'r')
% hold on;plot(squeeze(MFRD(x,y,496*k+124*f+1:496*k+124*(f+1)))-mean(squeeze(MFRD(x,y,496*k+124*f+1:496*k+124*f+20))),'y')
% hold on;plot(squeeze(MFRD(x,y,496*k+124*f+1:496*k+124*(f+1)))-mean(squeeze(MFRD(x,y,496*k+124*f+1:496*k+124*f+20))),'b')

for f=0:3
    
    M_XY1=[];
    M_XY2=[];
    for k=0:5
        M_ind=k*496+f*124+1:k*496+(f+1)*124;
        M_XY1=[M_XY1;squeeze(MFRD(130,46,M_ind(26:90)))-mean(squeeze(MFRD(98,59,M_ind(1:20))))];
        M_XY2=[M_XY2;squeeze(MFRD(131,36,M_ind(26:90)))-mean(squeeze(MFRD(108,72,M_ind(1:20))))];
    end
    
    [Cxy,F] = mscohere(M_XY1,M_XY2,60,30,60,12.4);
    [Dxy,~] = corrcoef(M_XY1,M_XY2);
    CxyCond(f+1)=mean(Cxy(1:6));
    DxyCond(f+1)=Dxy(1,2);
end

figure;plot(Cxy)

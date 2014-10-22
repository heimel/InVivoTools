clear
clc
close all
load Ic
% X=Ic(:,:,62);
% X=X(31:158,1:128);
X=Ic(41:168,1:128,42:82);
M=3;
% C = fdct_usfft(X,1,M);

Tw=5.00*(10^12);
eps=0.01;
W=2*Tw;

while W > Tw
    
    eps = eps+0.02
    
    C = fdct3d_forward(X);
    for lev=1:M
        for j=1:length(C{lev,1})
            A = C{lev,1}{j,1}> eps*max(max(max(C{lev,1}{j,1})));
            C{lev,1}{j,1}=A.*C{lev,1}{j,1};
        end;
    end;
    
    % % CC=[];
    % % for i=1:32
    % %     CS = max(max(C{1,2}{1,i}));
    % %     CC=[CC,CS];
    % % end;
    % % for i=1:32
    % %     A = C{1,2}{1,i}> 0.01*max(max(C{1,2}{1,i}));
    % %     C{1,2}{1,i}=A.*C{1,2}{1,i};
    % % end;
    % % A = C{1,3}{1,1}> 0.01*max(max(C{1,3}{1,1}));
    % % C{1,3}{1,1}=A.*C{1,3}{1,1};
    
    % XX = ifdct_usfft(C,1);
    XX = fdct3d_inverse(C);
    
    W=abs(wentropy(abs(XX),'shannon'))
    
end;

% II=zeros(128,128,1);
% for i=1:41
% II = (1/41)*XX(:,:,i)+II;
% end;
% imshow(II(128:-1:1,1:128,1),[])
% 
% II=zeros(128,128,1);
% for i=1:41
% II = (1/41)*X(:,:,i)+II;
% end;
% figure;
% imshow(II(128:-1:1,1:128,1),[])


% % R=rand(100,100);R(40:52,30:35)=R(41,29)+.5*rand(13,6);

while 
    
for i=SEQ1
    
    R=squeeze(XX(:,:,i));
    
    R=mat2gray(R);
    S3=false(size(R));
    S3(77,82)=1; % this point is selected by the user
    S2 = false(size(R));S2(10)=1;S2(100)=1;
    seed = S3;
    T=.25;
    while numel(nonzeros(S3-S2))>2
        S2=S3;
        [g,NR,SI,TI] = reggrow(R,S2,T,seed);
        S3=g==1;
    end
%     imshow(X,[])
%     figure;imshow(R)
%     figure;imshow(S3)
    SEQ=S3()
end;

for i=SEQ2
    
    R=squeeze(XX(:,i,:));
    
    R=mat2gray(R);
    S3=false(size(R));
    for j=SEQ1
        S3(77,j)=1;
    end;
    S2 = false(size(R));S2(10)=1;S2(100)=1;
    seed = S3;
    T=.25;
    while numel(nonzeros(S3-S2))>2
        S2=S3;
        [g,NR,SI,TI] = reggrow(R,S2,T,seed);
        S3=g==1;
    end
    imshow(X,[])
    figure;imshow(R)
    figure;imshow(S3)
    
end;
end;
% % R=X;
% % % R=RR(1:300,1:300,1);
% % R=mat2gray(R);
% % S3=false(size(R));
% % S3(89,55)=1; % this point is selected by the user
% % S2 = false(size(R));S2(10)=1;S2(100)=1;
% % seed = S3;
% % T=.25;
% % while numel(nonzeros(S3-S2))>2
% %     S2=S3;
% %     [g,NR,SI,TI] = reggrow(R,S2,T,seed);
% %     S3=g==1;
% % end
% % imshow(X,[])
% % figure;imshow(R)
% % figure;imshow(S3)
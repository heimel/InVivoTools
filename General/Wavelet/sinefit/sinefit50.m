function [Data] = sinefit50(Data,Fs)
%Subtract ERP and 50Hz artifact
%
% Inputs:
% Data : Data in (samples x channels x trials)
% Fs : sampling frequency

NSa=size(Data,1);
NCh=size(Data,2);
NTr=size(Data,3);

f50=2*pi*50; %frequency in rad/sec.
f100=2*pi*100; %frequency in rad/sec.
f150=2*pi*150; %frequency in rad/sec.
t=[0:NSa-1]/Fs;
for h=1:NCh
    EMF=mean(Data(:,h,:),3); %mean over trials
    for k=1:NTr
        Data(:,h,k)=Data(:,h,k)-EMF; %subtract the mean over trials/ partialize to the stimulus
        
        [Ahat,ThetaData,~]=sinefit2(Data(:,h,k)',f50,0,1/Fs);
        Data(:,h,k)=Data(:,h,k)-(Ahat*sin(f50*t+ThetaData))';
        [Ahat,ThetaData,~]=sinefit2(Data(:,h,k)',f100,0,1/Fs);
        Data(:,h,k)=Data(:,h,k)-(Ahat*sin(f100*t+ThetaData))';
        [Ahat,ThetaData,~]=sinefit2(Data(:,h,k)',f150,0,1/Fs);
        Data(:,h,k)=Data(:,h,k)-(Ahat*sin(f150*t+ThetaData))';
    end
end
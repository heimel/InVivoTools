function [] = extraplots_measures_Mehran(measures,selectedpar)
%% ONE
% some extra plots
ori=1:16; % ori
% %% ONE
% % some extra plots
% ori=1:12; % ori
%
% l1=1; % from channel l1
% l2=4; % to channel l2
% a1=ceil(sqrt(l2-l1+1));
% a2=ceil((l2-l1+1)/sqrt(l2-l1+1));
%
% b=selectedpar; % certain ori
% cc=1;
% figure;
% for i=l1:l2
% subplot(a1,a2,cc);plot(measures(1,i).curve(1,b:length(ori):end),mean(measures(1,i).curve(2:end,b:length(ori):end),1));title(num2str(i));
% cc=cc+1;
% end

%% TWO
ori=1; % ori

l1=1; % from channel l1
l2=5; % to channel l2

a1=ceil(sqrt(l2-l1+1));
a2=ceil((l2-l1+1)/sqrt(l2-l1+1));
for b=1:16
    % b=1; % certain ori
    cc=1;
    figure;
    for i=l1:l2
        subplot(a1,a2,cc);
        %         plot(measures(1,i).curve(1,b:length(ori):end),measures(1,i).curve(2,b:length(ori):end));title(num2str(i));
        errorbar(measures(1,i).curve(1,b:length(ori):end),measures(1,i).curve(2,b:length(ori):end),measures(1,i).curve(3,b:length(ori):end));title(num2str(i));
        
        
        cc=cc+1;
    end
    pause
    % b=print('b =     ')
    close
end

b=selectedpar; % certain ori
cc=1;
figure;
for i=l1:l2
    subplot(a1,a2,cc);plot(30*[0:11],mean(measures(1,i).curve(2:end,b:length(ori):b+11),1));title(num2str(i));
    cc=cc+1;
end

%% TWO
% ori=1; % ori
%
% l1=1; % from channel l1
% l2=4; % to channel l2
% a1=ceil(sqrt(l2-l1+1));
% a2=ceil((l2-l1+1)/sqrt(l2-l1+1));
%
% b=selectedpar; % certain ori
% cc=1;
% figure;
% for i=l1:l2
% subplot(a1,a2,cc);plot(30*[0:11],mean(measures(1,i).curve{1,1}(2:end,b:length(ori):b+11),1));title(num2str(i));
% cc=cc+1;
% end
% figure;hold on;
% for i=1:3
%     plot(measures1(1,3).curve(2,1+(i-1)*16:i*16),'color',[rand(1,2),1-rand(1)])
% end;
% figure;hold on;
% for i=1:16
%     plot(measures1(1,3).curve(2,1+(i-1)*16:i*16),'color',[rand(1,2),1-rand(1)])
% end;

x=[0.2 0.4 0.6 0.8 0.95];
for i=1:5
    for k=1:9
        A0(k)=mean(measures0(1,k).curve{1,1}(2,1+(i-1)*16:i*16));
        A1(k)=mean(measures1(1,k).curve{1,1}(2,1+(i-1)*16:i*16));
        A3(k)=mean(measures3(1,k).curve{1,1}(2,1+(i-1)*16:i*16));
        A5(k)=mean(measures5(1,k).curve{1,1}(2,1+(i-1)*16:i*16));
        A2(k)=mean(measures2(1,k).curve{1,1}(2,1+(i-1)*16:i*16));
        A4(k)=mean(measures4(1,k).curve{1,1}(2,1+(i-1)*16:i*16));
    end
    a0(i)=mean(A0);
    a1(i)=mean(A1);
    a2(i)=mean(A2);
    a3(i)=mean(A3);
    a4(i)=mean(A4);
    a5(i)=mean(A5);
end

% x=[0.2 0.4 0.6 0.8 0.95];
% for i=1:5
%         a0(i)=mean(measures0(1,1).curve{1,1}(2,1+(i-1)*16:i*16));
%         a1(i)=mean(measures1(1,1).curve{1,1}(2,1+(i-1)*16:i*16));
%         a3(i)=mean(measures3(1,1).curve{1,1}(2,1+(i-1)*16:i*16));
% %         A5(k)=mean(measures5(1,k).curve{1,1}(2,1+(i-1)*16:i*16));
%         a2(i)=mean(measures2(1,1).curve{1,1}(2,1+(i-1)*16:i*16));
%         a4(i)=mean(measures4(1,1).curve{1,1}(2,1+(i-1)*16:i*16));
% %     a5(i)=mean(A5);
% end

figure;plot(x,a0,'m');hold on;plot(x,a1,'b');plot(x,a2,'color',[0.5 0.1 0.5]);plot(x,a3,'r');plot(x,a4,'color',[0.1 0.5 0.5]);plot(x,a5,'g')

A=[a0;a1;a2;a3;a4;a5];%
% x=[0.05 0.10 0.2 0.30 0.4 0.50];
x=[0.5 1 1.5 4 10 20];
figure;plot(x,A([1 6 2 3 4 5],1),'m');hold on;plot(x,A([1 6 2 3 4 5],2),'b');plot(x,A([1 6 2 3 4 5],3),'r');plot(x,A([1 6 2 3 4 5],4),'g');plot(x,A([1 6 2 3 4 5],5),'y');

l1=1; % from channel l1
l2=5; % to channel l2
a1=ceil(sqrt(l2-l1+1));
a2=ceil((l2-l1+1)/sqrt(l2-l1+1));
figure;
for i=1:5
    % subplot(a1,a2,i);plot(30*[0:11],measures(1,i).curve{1,1}(2,98:2:120))
    subplot(a1,a2,i);plot(30*[0:11],measures(1,i).curve{1,1}(2,1:15:end),'g');hold on;
    subplot(a1,a2,i);plot(30*[0:11],measures(1,i).curve{1,1}(2,4:15:end),'b');hold on;
    subplot(a1,a2,i);plot(30*[0:11],measures(1,i).curve{1,1}(2,7:15:end),'r');hold on;
end

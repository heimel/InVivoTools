function [] = extraplots_measures_Mehran(measures,selectedpar)

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

b=selectedpar; % certain ori
cc=1;
figure;
for i=l1:l2
subplot(a1,a2,cc);plot(30*[0:11],mean(measures(1,i).curve(2:end,b:length(ori):b+11),1));title(num2str(i));
cc=cc+1;
end


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
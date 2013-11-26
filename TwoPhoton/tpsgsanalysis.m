function resps = tpsgsanalysis(record,data,t)
resps = []

stims = getstimsfile( record );
if isempty(stims)
    % create stims file
    stiminterview(record);
    stims = getstimsfile( record );
end;

s.stimscript = stims.saveScript;
s.mti = stims.MTI2;
[s.mti,starttime] = tpcorrectmti(s.mti,record);
do = getDisplayOrder(s.stimscript);

ss = get(s.stimscript);

stimframetimes = s.mti{1}.frameTimes-starttime;

disp('TPSGSANALYSIS: ONLY TAKING FIRST STIMULUS OR REPETITION');
disp('TPSGSANALYSIS: NOT REALLY COMPUTING CORRELATION YET');

stim = ss{1};
[x,y,rect]=getgrid(stim);
v = getgridvalues(stim); % v = X*Y x N
p.feature = 0; % check reverse_corr/setparameters
f = getstimfeatures(v,stim,p,x,y,rect)/255; % features f = Y x X x N x 3


disp('TPSGSANALYSIS: ONLY TAKING FIRST CELL AND INTERVAL');


maxtime = min( max(t{1,1}),max(stimframetimes));
mintime = max( min(t{1,1}),min(stimframetimes));
ind = find(t{1,1}>=mintime & t{1,1}<=maxtime);
t{1,1} = t{1,1}(ind);
data{1,1} = data{1,1}(ind);
ind = find(stimframetimes>=mintime & stimframetimes<=maxtime);
stimframetimes = stimframetimes(ind);

% next lines are ugly. replace
nf = zeros(size(f,1),size(f,2),length(ind));
for r=1:size(f,1)
    for c=1:size(f,2)
        nf(r,c,:) = f(r,c,ind);
    end
end
f=nf;

resample_dt = 0.01;

rt = mintime:resample_dt:maxtime  ; % times are shifted!
tpframe_dt = mean(diff(t{1,1}));
rdata = data{1,1}(floor( (rt-mintime)/tpframe_dt)+1);
stimframe_dt = mean(diff(stimframetimes));

taus =(0:0.1:1); % shift in time (s)
% for i = 1:length(taus)
%     tau = taus(i);
%     tau_samples = round( tau/resample_dt);
    for r = 1:y
        for c= 1:x            
            rf = squeeze(f(r,c,floor((rt-mintime)/stimframe_dt)+1,1));
            
%            revcor(r,c,i) = rdata(1+tau_samples:end)' * rf(1:end-tau_samples);
[revcor(r,c,:),taus,bounds] = crosscorr(rdata,rf,50);
        end
    end
    taus = taus*stimframe_dt
    
    % figure;
    % hold on;
    % plot(stimframetimes,squeeze(f(r,c,:,1)));
    % plot(rt,rf,'k');
    % plot(t{1,1},data{1,1},'r');
    % plot(rt,rdata,'k');
    
    %subplot(1,length(taus),i);
% end

max_revcor = max(revcor(:));
% for i =1:length(taus)
%    
%     figure;
%     imagesc(squeeze(revcor(:,:,i)),[0 max_revcor]);
%     axis image;
%     colorbar;
%     colormap gray;
% 
% end
meanrevcor = mean(revcor,3);
figure;imagesc(meanrevcor); axis image;colormap gray

figure;imagesc(revcor(:,:,1))

figure;
[~,r] = max(max(meanrevcor,[],2),[],1)
[~,c] = max(max(meanrevcor,[],1),[],2)
plot(taus,squeeze(revcor(r,c,:)));
ylim([0 1]);
xlabel('Time lag of signal to stimulus (s)');
ylabel('Correlation');


figure;
hold on;
plot(stimframetimes,squeeze(f(r,c,:,1)));
rf = squeeze(f(r,c,floor((rt-mintime)/stimframe_dt)+1,1));
plot(rt,rf,'k');
plot(t{1,1},data{1,1},'r');
plot(rt,rdata,'k');
xlabel('Time (s)');
ylabel('Response and Intensity');

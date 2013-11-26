%Stuff I needed at that time but I reckon it's useless now

%% Voor RPesentatie 2
  tempdata = load('C:\Documents and Settings\cornelij\My Documents\matlab\workables\DATA\20070525 - 07.04.2.02 - Compare - B6\07.04.2.02 - 010 - DATA.mat')
  data_saved = tempdata.data_saved;
  [resultset nRemoved baseline awave atime bwave btime prepulse_samples stims] = erg_analysis_basics(data_saved);


%%
figure(1); subplot1(4,10,'Gap',[0.01 0.01],'FontS',11,'YTickL','Margin','Min',[0 0],'Max',[1,1],'FontS',10); hold off; 
for run = 1:10
for mouse = 1:size(data_erg,1)
  for exp = 1:2
     if (data_erg(mouse,exp).expgroup < 5)
       subplot1(data_erg(mouse,exp).expgroup*10-10+run);
       plot(data_erg(mouse,exp).FFTx{run},data_erg(mouse,exp).FFTy{run},'linewidth',1,'color',colmap(data_erg(mouse,exp).expgroup*2-1,:));
%      plot(data_erg(mouse,exp).OPx{run},data_erg(mouse,exp).OPy{run},'linewidth',1,'color',colmap(data_erg(mouse,exp).expgroup*2-1,:));
%       ylim([-0.6,0.6]);
       ylim([0,0.1]);
     end
  end
end
end
for i = 1:40
  subplot1(i);
  plot([75 75],[0,0.1],'r');
  plot([110 110],[0,0.1],'r');
end
%%
figure(1); subplot1(2,8,'Gap',[0.01 0.01],'FontS',11,'YTickL','Margin','Min',[0 0],'Max',[1,1],'FontS',10); hold off; 
run = 8;
teller = 0;
for mouse = 1:size(data_erg,1)
  for exp = 1:2
     if (data_erg(mouse,exp).expgroup == 1)
       teller = teller + 1;
       subplot1(teller);
       plot(data_erg(mouse,exp).FFTx{run},data_erg(mouse,exp).FFTy{run},'linewidth',1,'color',colmap(data_erg(mouse,exp).expgroup*2-1,:));
       hold on; plot([75 75],[0,0.1],'r');
       hold on; plot([110 110],[0,0.1],'r');
       ylim([0,0.1]);
       p1 = data_erg(mouse,exp).OPparam(run);
       p2 = (p1.f110/p1.f75);
       subplot1(teller+8);
       hold on; 
       scatter(1,p2,exp*60); 
       ylim([0,50]);
%      plot(data_erg(mouse,exp).OPx{run},data_erg(mouse,exp).OPy{run},'linewidth',1,'color',colmap(data_erg(mouse,exp).expgroup*2-1,:));
%      ylim([-0.6,0.6]);
     end
  end
end
%%


%%
  figure
  plot(linspace(-50,100,1501),resultset(8,1500:3000)*100,'k','linewidth',2);
  hold on; plot([-50,100],[155,155],'b'); hold on; plot([-50,100],[-47,-47],'r');
  ylim([-60,160]);
  xlabel('Stimulus intensity [cd]'); ylabel('Response [uV]');
  legend('Stimulus intensity of 3.2 cds/m^2 (B6)','b-wave peak','a-wave through');
%%
  figure
  semilogx(stims/140000*25, 100*(bwave-awave));
  xlabel('blaat')
  xlim([2.5/1000,25])

%%
global qd
  data_saved = qd

  d = data_saved.block.data4type.pulsetrain;
  Srt = sortrows([data_saved.stimuli; data_saved.results']')';
  dataset = -1.*Srt(4:size(Srt,1),:)';
  graphs_avg = 0;

  sweeps_size  = str2num(d.numrepeats);
  sweeps_start = 1;
  sweeps_end   = str2num(d.pulse_steps);
  sweeps_effective = sweeps_end-sweeps_start+1;
  
  totsamples = size(data_saved.results,2);
  prepulse_samples = min([totsamples, str2num(d.prepulse)*(totsamples/data_saved.msecs)]);
  awave_find_start = prepulse_samples;
  awave_find_end   = min([totsamples, prepulse_samples+30*(totsamples/data_saved.msecs)])
  bwave_find_start = min([totsamples, prepulse_samples+15*(totsamples/data_saved.msecs)]) 
  bwave_find_end   = min([totsamples, prepulse_samples+100*(totsamples/data_saved.msecs)]) 
  
  resultset = ones(10,size(dataset(1,:),2));
  for (i = 1:sweeps_effective)
    [resultset(i,:), nRemoved(i)] = erg_analysis_avgpulse(dataset((i+sweeps_start-2)*sweeps_size+1:(i+sweeps_start-1)*sweeps_size,:),graphs_avg);
    baseline(i) = mean(resultset(i,1:prepulse_samples));
    [awave(i),atime(i)] = min(resultset(i,awave_find_start:awave_find_end));
    [bwave(i),btime(i)] = max(resultset(i,bwave_find_start:bwave_find_end));
  end

%%
res2 = []; a = 0; for i = 1:sweeps_size:sweeps_size*sweeps_effective; a = a + 1; [n1,n2,n3] = erg_io_convertCalib('constant',data_saved.stimuli(:,i)); res2(a) = n2(2); end;
res2
%%
s1 = 1000;
s = 100;
s3 = 8000;
res1 = []; a = 0; for i = s1:s:s3 a = a + 1; if (a > 1) x = res1(:,a-1); else x = 0; end; res1(:,a) = mean(resultset(:,i:i+s),2)+x; end
%for i = 1:10; res1(i,:) = res1(i,:) - mean(res1(1:3,:),1); end
figure(1); subplot(2,3,5); hold off; plot(res1')
[A,B] = max(res1(1:str2num(d.pulse_steps),10:25)');
X=[1:str2num(d.pulse_steps)]; subplot(2,3,4); hold off; plot(X(res2<99),B(res2<99));
%%
hidden
figure(2); hold off; mesh(resultset(:,1000:1:4000))

%% 1e vs 2e helft & sliding window
  global qd
  data_saved = qd;

  
  d = data_saved.block.data4type.pulsetrain;
  Srt = sortrows([data_saved.stimuli; data_saved.results']')';
  dataset = -1.*Srt(4:size(Srt,1),:)';
  graphs_avg = 0;

  reps  = str2num(d.numrepeats);
  steps  = str2num(d.pulse_steps);
  
  totsamples = size(data_saved.results,2);
  prepulse_samples = min([totsamples, str2num(d.prepulse)*(totsamples/data_saved.msecs)]);
  awave_find_start = prepulse_samples;
  awave_find_end   = min([totsamples, prepulse_samples+30*(totsamples/data_saved.msecs)]);
  bwave_find_start = min([totsamples, prepulse_samples+15*(totsamples/data_saved.msecs)]) ;
  bwave_find_end   = min([totsamples, prepulse_samples+100*(totsamples/data_saved.msecs)]) ;
  
  reps_half = round(reps/2);
  resultset1 = ones(steps,size(dataset(1,:),2));
  resultset2 = ones(steps,size(dataset(1,:),2));
  awave = []; bwave = []; atime=[]; btime=[]; baseline = []; 
  window_size = round(sweeps_size/2);
  for (i = 1:sweeps_effective)
    for (j = 1:sweeps_size-window_size)
    [res, rem] = erg_analysis_avgpulse(dataset((i-1)*reps+1+j:(i-1)*reps+window_size+j,:),graphs_avg);
    baseline(i,j) = mean(res(1:prepulse_samples));
    [awave(i,j),atime(i,j)] = min(res(awave_find_start:awave_find_end));
    [bwave(i,j),btime(i,j)] = max(res(bwave_find_start:bwave_find_end));
  end
end

% LinePlots For sliding window and 1st-vs-2nd half test
res2 = []; a = 0; for i = 1:sweeps_size:sweeps_size*sweeps_effective; a = a + 1; [n1,n2,n3] = erg_io_convertCalib('constant',data_saved.stimuli(:,i)); res2(a) = n2(2); end;
figure(1); subplot1(4,4,'Gap',[0.02 0.02]); hold off; 
subplot1(7); hold off; plot((awave(res2<99,:)-baseline(res2<99,:))',':'); 
subplot1(7); hold on; plot((bwave(res2<99,:)-awave(res2<99,:))','-'); 
subplot1(7); hold on; xl=xlim; yl=ylim; text(xl(1)+1,yl(end)-0.2,'(sliding window, dots=awave)')
subplot1(8); hold off; plot(atime(res2<99,:)'/10,':'); hold on;
subplot1(8); hold on; plot(btime(res2<99,:)'/10+30,'-'); hold off; 
subplot1(8); hold on; xl=xlim; yl=ylim; text(xl(1)+3,yl(end)-10,'(sliding window, dots=atime)')

X = sweeps_start:sweeps_end
X = X(res2<99)'
subplot1(5); hold off; plot(X,awave(res2<99,1)-baseline(res2<99,1),'b',X,bwave(res2<99,1)-awave(res2<99,1),'r'); 
subplot1(5); hold on; plot(X,awave(res2<99,end)-baseline(res2<99,end),'b:',X,bwave(res2<99, end)-awave(res2<99, end),'r:');
subplot1(5); hold on; xl=xlim; yl=ylim; text(xl(1)+1,yl(end)-0.2,'(red=b, blue=a, dotted = 2nd half)')
subplot1(6); hold off; plot(X,atime(res2<99,1)/10,'b',X,btime(res2<99,1)/10+30,'r'); 
subplot1(6); hold on;  plot(X,atime(res2<99,end)/10,'b:',X,btime(res2<99,end)/10+30,'r:'); 
subplot1(6); hold on; xl=xlim; yl=ylim; text(xl(1)+1,yl(end)-10,'(red=b, blue=a, dotted = 2nd half)')

%% 1e vs 2e helft, PLOT RAW
figure(2); hold off; plot([1:length(resultset1)],resultset1','r',[1:length(resultset2)],resultset2','b'); 
figure(3); hold off; plot([1:length(resultset1)],resultset1'-resultset2'); 

%%
global qd;
data_saved = qd;
totsamples = size(data_saved.results,2);
hsr = totsamples/data_saved.msecs*1000/2
in = resultset(8,:);
[B1, B2] = butter(2,[60/hsr,235/hsr]);
out = filter(B1, B2,in);
hold off; plot(out(2000:3000));

%%  
  Y2 = resultset(:,dstart:dend)';
  plot(X,Y2-Y);   
%%
global qd;
data_saved = qd;
d = data_saved.block.data4type.pulsetrain;
Srt = sortrows([data_saved.stimuli; data_saved.results']')';
dataset = -1.*Srt(4:size(Srt,1),:)';
sweeps_size  = str2num(d.numrepeats);
sweeps_start = 1;
sweeps_end   = str2num(d.pulse_steps);
sweeps_effective = sweeps_end-sweeps_start+1;

totsamples = size(data_saved.results,2);
prepulse_samples = min([totsamples, str2num(d.prepulse)*(totsamples/data_saved.msecs)]);
hsr = totsamples/data_saved.msecs*1000/2
[B1, B2] = butter(2,[60/hsr,235/hsr]);%235
ds = filter(B1,B2,dataset,[],2);
resultset_op2 = []; resultset = []; resultset_op = []; clear op;
for (i = sweeps_effective:-1:1)
  [resultset_op(i,:), nRemoved_op(i)] = erg_analysis_avgpulse(ds((i+sweeps_start-2)*sweeps_size+1:(i+sweeps_start-1)*sweeps_size,:),0);
  resultset = ones(10,size(dataset(1,:),2));
  [resultset(i,:), nRemoved(i)] = erg_analysis_avgpulse(dataset((i+sweeps_start-2)*sweeps_size+1:(i+sweeps_start-1)*sweeps_size,:),graphs_avg);

  if (i == sweeps_effective)
    [op1wave(i),op1time(i)] = max(resultset_op(i,:));
  else
    op1time(i+1)
    [op1wave(i),op1time(i)] = max(resultset_op(i,op1time(i+1)-50:op1time(i+1)+50));
    op1time(i) = op1time(i)+(op1time(i+1)-50);
  end
  
  t = 30;
  nMin = 0;
  nMax = 0;
  op.amp.downs(i,:) = zeros(1,10);
  op.amp.ups(i,:) = zeros(1,10);
  for (j = 1:t:size(resultset_op,2)-500)
%   resultset_op2(i,:) = sign(resultset_op(i,2:end-1001)-resultset_op(i,1:end-1002))./sign(resultset_op(i,3+t:end-1000+t)-resultset_op(i,2+t:end-1001+t));
    s1 = sign(resultset_op(i,j)-resultset_op(i,j+1));
    s2 = sign(resultset_op(i,j+t)-resultset_op(i,j+t+1));
    if (s1>s2) 
       [MY, MX] = min(resultset_op(i,j:j+t+1));
       MX = MX - 1;
       if (abs(MY) > 0.03 && nMin < 10); 
           nMin = nMin + 1;
           op.amp.downs(i,nMin) = MY;
           op.time.downs(i,nMin) = MX+j;
           resultset_op2(i,MX+j) = MY; 
       end;
    elseif (s1<s2)
       [MY, MX] = max(resultset_op(i,j:j+t+1));
       MX = MX - 1;
       if (abs(MY) > 0.03 && nMax < 10); 
           if nMin == 0
             nMin = nMin + 1;
             op.amp.downs(i,nMin) = 0;
             op.time.downs(i,nMin) = 0;
           end;   
           nMax = nMax + 1;
           op.amp.ups(i,nMax) = MY;
           op.time.ups(i,nMax) = MX+j;
           resultset_op2(i,MX+j) = MY; 
       end;
    end
  end
end

[dummy, col] = max(data_saved.stimuli(:,end));
res2 = []; a = 0; for i = 1:sweeps_size:sweeps_size*sweeps_effective; a = a + 1; [n1,n2,n3] = erg_io_convertCalib('constant',data_saved.stimuli(:,i)); res2(a) = n2(col); end;
%%
figure(2); hold off;
dstart = prepulse_samples-100;
dend = prepulse_samples+900;
X = repmat((dstart-round(prepulse_samples):dend-round(prepulse_samples))/(totsamples/data_saved.msecs),[sweeps_effective,1])';
Y1 = resultset_op(:,dstart:dend)';
Y2 = resultset_op2(:,dstart:dend)';
plot(X,Y1,X,Y2,':');


%%
figure(1); subplot1(10); hold off;
X = repmat(1:length(res2),[10,1])';
M = max(op.amp.ups)>0;
X = X(res2<99,M);
figure(1); subplot1(10); hold off;
plot(X,op.amp.ups(res2<99,M) - op.amp.downs(res2<99,M))

figure(1); subplot1(11); hold off;
plot(X,op.time.ups(res2<99,M));

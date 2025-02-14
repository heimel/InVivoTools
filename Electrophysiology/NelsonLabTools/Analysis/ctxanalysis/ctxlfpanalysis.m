function [latency,meanwaves,sampletimes,stdwaves]=ctxlfpanalysis(cksds, ...
						  test,name,ref,display, ...
						  threshold,sampmult)
%CTXLFPANALYSIS general local field potential analyzer
%
%[LATENCY,MEANWAVES,SAMPLETIMES,STDWAVES]=CTXLFPANALYSIS(CKSDS, ...
%						  TEST,NAME,REF)
%
%[LATENCY,MEANWAVES,SAMPLETIMES,STDWAVES]=CTXLFPANALYSIS(CKSDS, ...
%						  TEST,NAME,REF,DISPLAY, ...
%						  THRESHOLD,SAMPMULT)
%     CKSDS cksdirstruct
%     TEST testname, e.g. 't00023'
%     NAME recordname, e.g. 'ctx'
%     REF reference number
%     DISPLAY, 1 to display (default), 0 for no display
%
%    for output values see HELP TRIGGERED_AVERAGE_RAWDATA
%  2003, Alexander Heimel
%

% setting defaults
if nargin<7
  sampmult=5;
end
if nargin<6
  threshold=5; % times std.dev
end
if nargin<5
  display=1;
end


if display,
  where.figure=figure;
  where.rect=[0 0 1 1];
  where.units='normalized';
  orient(where.figure,'landscape');
else, 
  where = []; 
end;
    

trigs=[];
sts=getstimscripttimestruct(cksds,test);
get(sts.stimscript);
disp( ['Stimuli triggers:  ' num2str(length(sts.mti)) ]);
for i=1:length(sts.mti)
  trigs=[trigs sts.mti{i}.frameTimes(1)];
end


thedir = getpathname(cksds);

cksmeasobj = cksmeasureddata(thedir,name,ref,[],[]);
if isempty(get_intervals(cksmeasobj))
  disp(['No data taken for ' name ' ref ' num2str(ref) ]);
  return;
end


t0=-0.1; %seconds before trigger
t1=0.3;  %seconds after trigger

[meanwaves,sampletimes,stdwaves]=triggered_average_rawdata( ...
    cksmeasobj,trigs,t0,t1,sampmult);


%refresh_rate=119.69; %Hz
%% calculate monitor artefact
%dt=(sampletimes(end)-sampletimes(1))/(length(sampletimes)-1);
%cyclelength=1/dt/refresh_rate;
%artifact=zeros(1,ceil(cyclelength) );
%n_cycles=floor( (sampletimes(end)-sampletimes(1))*refresh_rate  );
%for i=0:n_cycles-1
%  ind=1+round(i*cyclelength);
%  artifact=artifact+ meanwaves(ind:ind+length(artifact)-1);
%end
%artifact=artifact/n_cycles;
%noartmw=meanwaves;
%for i=0:n_cycles-1
%  ind=1+round(i*cyclelength);
%  noartmw(ind:ind+length(artifact)-1)=...
%      noartmw(ind:ind+length(artifact)-1)-artifact;
%end



% low pass filter data:
%[b,a] = cheby1(1,0.4,[400/sampmult/(30000/sampmult/2)],'low');   
[b,a] = cheby1(2,0.4,[300/(30000/sampmult/2)],'low');   
filtmw=filtfilt(b,a,meanwaves);  
% get derivative
diffmw=diff(filtmw);
%get std of this before trigger
ind_time_before=find(sampletimes<0);
std_before=nanstd(diffmw(ind_time_before));
mean_before=nanmean(diffmw(ind_time_before));

ind_above_threshold=find(abs(diffmw)>abs(mean_before)+threshold*std_before);
if isempty(ind_above_threshold)
  disp('Never crossed threshold!');
  above_threshold=nan;
else
  above_threshold=sampletimes(ind_above_threshold(1));
end


disp(['Threshold (' num2str(5) ' x std) crossing: ' ...
      num2str(round(above_threshold*10000)/10) ' ms']);

latency=above_threshold;

if display
  figure(where.figure);
  
  
  subplot(2,1,1);
  plot(sampletimes,meanwaves);
  hold on;
  plot(sampletimes,filtmw,'g');
  %plot(sampletimes,noartmw,'r');
  %plot(sampletimes,meanwaves+stdwaves,'r');
  %plot(sampletimes,meanwaves-stdwaves,'r');
  plot(sampletimes,stdwaves,'k:');
  xlabel('time (s)')
  title(test);

    % plot vertical bar at trigger
  ax=axis;
  plot([0 0],[ax(3) ax(4)],'y');
  
  % plot vertical bar at threshold crossing
  ax=axis;
  plot([above_threshold above_threshold],[ax(3) ax(4)]);

  text( above_threshold-0.02, ax(3)+(ax(4)-ax(3))/20, ...
	[num2str((round(above_threshold*10000)/10)) ' ms']);

  

  subplot(2,1,2);
  plot(sampletimes(1:end-1),diffmw,'k');
  title([ test ' derivative' ]);
  xlabel('time (s)');
  hold on
  plot(sampletimes(1:end-1),mean_before+threshold*std_before,'k:');
  plot(sampletimes(1:end-1),mean_before-threshold*std_before,'k:');

  

  % plot vertical bar at trigger
  ax=axis;
  plot([0 0],[ax(3) ax(4)],'y');

  % plot vertical bar at threshold crossing
  ax=axis;
  plot([above_threshold above_threshold],[ax(3) ax(4)]);
  

    text( above_threshold-0.02, ax(3)+(ax(4)-ax(3))/20, ...
	[num2str(round(above_threshold*10000)/10) ' ms']);

  
end



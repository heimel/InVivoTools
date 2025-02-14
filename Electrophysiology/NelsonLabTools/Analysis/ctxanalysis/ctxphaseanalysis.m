function [newcell,outstr,assoc,pc]=ctxphaseanalysis(cksds,cell,cellname,display)

%  CTXPHASEANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=CTXPHASEANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the temporal frequency test.  CKSDS is a valid CKSDIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the phase test (associate name in quotes):
%  'PhasePeak'                    |      Peak rate at phase w. max resp.
%  'PhaseSust'                    |      Sustained rate at phase w. max resp
%  'PhaseLatency'                 |      Latency of resp at phase w. max res
%  'PhaseAdapt'                   |      Adaptationindex at phase w. max res
%  'PhaseLinearity'               |      Linearity index

newcell = cell;

assoclist = ctxassociatelist('Phase Test');

for I=1:length(assoclist),
  [as,i] = findassociate(newcell,assoclist{I},'protocol_CTX',[]);
  if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

if display,
  where.figure=figure;
  where.rect=[0 0 1 1];
  where.units='normalized';
  orient(where.figure,'landscape');
else, 
  where = []; 
end;
  
assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

peak = []; 
sust = [];
latency = [];
adapt = [];
linearity = [];
pc = [];

phasetest = findassociate(newcell,'Phase Test','protocol_CTX',[]);
if ~isempty(phasetest),
  s=getstimscripttimestruct(cksds,phasetest(end).data);
  if ~isempty(s),

    inp.st = s; 
    inp.spikes = newcell; 
    inp.title=['Phase shift ' cellname];
    inp.paramnames = {'sPhaseShift'};

    stimpara=getparameters(get(inp.st.stimscript,1));
    yloc=(stimpara.rect(4)-stimpara.rect(2))/2;   % y location for latency shift
    
%    pc = periodic_curve(inp,'default',where);
%    p = getparameters(pc);

    inp.paramname = 'sPhaseShift';
    tc=tuning_curve(inp,'default',where);
    para=getparameters(tc);
    %para.res=0.004;   % default is 4ms
    %                  % for testing use 0.5ms
    para.res=0.001;		      
		      
    tc=setparameters(tc,para);
    co = getoutput(tc);
    cr = getoutput(co.rast);

    
    for I=1:length(cr.bins)
      i1=findclosest(cr.bins{I},0 );  % start directly after trigger
      i2=findclosest(cr.bins{I},1); % end 1s after trigger
      activ(I)=sum(cr.counts{I}(i1:i2))*diff(cr.bins{I}(1:2));
      % i don't understand why not divided by last factor
    end
    [m,i] = max(activ); % condition with maximum #spikes
    [mm,ii]=max(cr.counts{i}); % mm is peak response

    peaklatency=cr.bins{i}(ii);

    
    [halfmm_ii,halfmm]=findclosest( cr.counts{i}(1:ii), ceil(mm/2) );
    % to find A half height. 
    if halfmm<mm/2  % then probably instantaneous rise to peak
      halfmm=mm;
      halfmm_ii=ii;
    end

    
    latency=cr.bins{i}(halfmm_ii); % time to peak response
    if latency<0.015 %  correct for latencies smaller than 15ms
      latency=peaklatency;
    end
    

    
    % VERY UGLY TO DO HERE
    if strcmp(cellname,'cell_ctx_0011_001_2003_08_14')
      peaklatency=0.031; 
      latency=0.0295;
    elseif strcmp(cellname,'cell_ctx_0009_001_2003_09_22')
      peaklatency=0.046;
      latency=0.0365;
    elseif strcmp(cellname,'cell_ctx_0008_001_2003_04_24')
      peaklatency=0.026;
      latency=0.026;
    elseif strcmp(cellname,'cell_ctx_0001_001_2003_09_15')
      latency=0.030;
    elseif strcmp(cellname,'cell_ctx_0012_001_2003_09_15')
      peaklatency=0.026;
      latency=0.024;
    elseif strcmp(cellname,'cell_ctx_0020_001_2003_09_22')
      peaklatency=0.134;
      latency=0.084;
    elseif strcmp(cellname,'cell_ctx_0015_001_2003_03_12')
      peaklatency=0.020;
      latency=0.020;
    elseif strcmp(cellname,'cell_ctx_0012_001_2003_08_14')
      peaklatency=0.044;
      latency=0.044;
    elseif strcmp(cellname,'cell_ctx_0010_001_2003_09_08')
      peaklatency=0.028;
      latency=0.028;
    elseif strcmp(cellname,'cell_ctx_0007_001_2003_08_14')
      peaklatency=0.030;
      latency=0.028;
    elseif strcmp(cellname,'cell_ctx_0006_001_2003_09_15')
      peaklatency=0.040;
      latency=0.036;
    end
    
    

    
    ear = latency + [0   0.050];   % first 50ms after half peak time
    lat = latency + [0.3 0.4];     % 300ms to 400 ms after half peak time  
    
    if max(lat)>0.5, 
      lat = 0.45+[0 0.050]; 
      latewind = lat; 
    end;

    e1 = findclosest(cr.bins{i},ear(1));
    e2 = findclosest(cr.bins{i},ear(2));
    l1 = findclosest(cr.bins{i},lat(1));
    l2 = findclosest(cr.bins{i},lat(2));
    bt = diff(cr.bins{i}(1:2)); % time of 1 bin

    spont = co.spont(1); % spontraneous rate from all bgpretimes in Hz

    

    l = size(cr.values{1},2);  % number of trials
    x=sum(cr.counts{i}(e1:e2))/(bt*l*(e2-e1+1))  - spont;
    y=sum(cr.counts{i}(l1:l2))/(bt*l*(l2-l1+1))  - spont;

    trans = (x-y)/x;

    
    
    
    replyear = []; 
    replylat = [];
    for I=1:l,
      replyear(end+1) = sum(cr.values{i}(e1:e2,I))/(bt*(e2-e1+1));
      replylat(end+1) = sum(cr.values{i}(l1:l2,I))/(bt*(l2-l1+1));
    end;

%    [hsustained,sigsustained]=ttest(replylat,spont,0.05,1);
%    if max(replylat)==min(replylat)
%      hsustained=0; % no response at all
%      disp('No sustained spikes in best condition');
%    else
%      [hsustained,sigsustained]=ttest(replylat,spont,0.1,1);
%    end

    hsustained=( y > 2*co.spont(2) ); 
    % sustained if late rate higher than the mean spontaneous rate by two
    % standard deviations of this rate
    % not as accurate as T-test


    % HISTOGRAM OF COMBINED RESPONSES TO ALL CONDITIONS
    conrast=[];
    for con=1:length(cr.bins)
      if ~isempty( cr.rast{con} )
	conrast=[ conrast cr.rast{con}(1,:)];
      end
    end
    edges=(-0.2:0.002:0.5);
    histogram_all=histc(conrast,edges);
    ind=find( histogram_all>0 );
    histogram=[ edges(ind); histogram_all(ind) ];
    
    %figure;
    %plot( histogram(1,:),histogram(2,:),'x');
    
    % LINEARITY
    if co.curve(1,end)<pi
      linearity=NaN; % early test were only done for 0:pi-pi/6
    else
      resp=co.curve(2,:)-co.spont(1);  % subtract spontaneous rate
      spatial_f0=sum(resp)/length(resp );
      spatial_f1=abs( exp(j*co.curve(1,:)) * resp' ) / (length(resp)/2);
      linearity= spatial_f1/spatial_f0;
      % with this scaling of the Fourier transform, 
      % a response of R = 1 + Sin( phi) gives linearity=1
      % if base line becomes bigger w.r.t. modulation the linearity drops
      % below 1. 
      
    end
    
    % ADAPTATION
    % count all spikes after first presentation for each condition and
    % divide this by the count of all spikes after the last presentation
    % of each condition
    n_spikes_first=0;
    n_spikes_last=0;
    n_reps=max(cr.rast{1}(2,:));
    for con=1:length(cr.rast);
      if ~isempty(cr.rast{con})
	n_spikes_first=n_spikes_first+sum(cr.rast{con}(2,:)==1 & cr.rast{con}(1,:)>0);
	n_spikes_last=n_spikes_last+sum(cr.rast{con}(2,:)==n_reps & ...
					cr.rast{con}(1,:)>0);
      end
    end
    adapt=n_spikes_first/n_spikes_last;

    
    % correct latency for position of stimulus on the screen
    %  tested on 2003-05-28 with gerbil and g4 stimulus computer
    %  t00014: phase test, photodiode at top of screen, 16Hz 2 reps: 
    %    with raster 0.5 ms -> -0.2 +- 0.2 ms latency of first spikes
    %   
    %  t00015: phase test, photodiode at bottom of screen, 16Hz, 2 reps:
    %    with raster 0.5 ms -> 6.7 +- 0.2 ms latency of first spikes


   disp(['Raw Latency: ' num2str(latency,3)]);

   latency = latency + (0.2e-3) - (6.7e-3)*yloc/480; 
   peaklatency = peaklatency + (0.2e-3) - (6.7e-3)*yloc/480; 
   % 480 is now monitor depended, but so are the latencies
   
   
   disp(['Corrected Latency: ' num2str(latency,3)]);

   
   if x<co.spont(2)  
     % if early rate smaller than 1 std
     % then probably peak is random fluctuation and numbers are meaningless     
     disp('Peakrate too small to be sure');
     latency=nan;
     peaklatency=nan;
     trans=nan;
     hsustained=nan;
   end



   
   
   assoc(end+1)=ctxnewassociate('Phase Test',...
				 phasetest(end).data,...
				'Phase Test');
   assoc(end+1)=ctxnewassociate('Phase Early rate',x,...
				 'Early rate at phase with maximum response');
    assoc(end+1)=ctxnewassociate('Phase Transience',trans,...
				 'Phasse Transient/Sustained response');

    assoc(end+1)=ctxnewassociate('Phase Late rate',y,['Late rate at'...
		    ' phase with maximum response']);
    assoc(end+1)=ctxnewassociate('Phase Sustained?',hsustained,...
				 ['1 if response is significant in' ...
		    ' late time window']);
    
    assoc(end+1)=ctxnewassociate('Phase Latency',latency,...
		    'Latency of half peak response at phase with maximum response');
    assoc(end+1)=ctxnewassociate('Phase Peak latency',peaklatency,...
		    'Latency of peak response at phase with maximum response');
    assoc(end+1)=ctxnewassociate('Phase Adapt',adapt,['Adaptation rate at'...
		    ' phase with maximum response']);
    assoc(end+1)=ctxnewassociate('Phase Linearity',linearity,...
				 'Linearity index');
    assoc(end+1)=ctxnewassociate('Phase Response curve',co.curve,...
				 'Phase Response curve');
    assoc(end+1)=ctxnewassociate('Phase Spontaneous rate',spont,...
				 'Spontaneous rate');
    assoc(end+1)=ctxnewassociate('Phase Histogram',histogram,...
				 'Phase Peristimulus histogram');

    
  end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr.peak=peak;  %not used

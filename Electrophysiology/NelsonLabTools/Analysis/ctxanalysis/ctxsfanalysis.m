function [newcell,outstr,assoc,pc]=ctxsfanalysis(cksds,cell,cellname,display,stimulusname)

%  CTXSFANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=CTXSFANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY,STIMULUSNAME)
%
%  Analyzes the spatial frequency test.  CKSDS is a valid CKSDIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%  STIMULUSNAME is appended before the associate names
%
%  Measures gathered from the SF test (associate name in quotes):
%  stimulusname is attached to the front of the following
%  'SF Response Curve F0'         |   F0 response
%  'SF Pref'                      |   SF w/ max firing
%  'SF Low'                       |   low SF with half of max response 
%  'SF High'                      |   high SF with half of max response 
%  'Max drifting grating firing'  |   Max firing during drifting gratings
%                                 |      (at optimal TF, SF, angle)

newcell = cell;

assoclist = ctxassociatelist([stimulusname ' Test']);

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

f1curve = []; maxgrating = []; tfpref = []; pc = [];

sftest = findassociate(newcell,[stimulusname ' Test'],'protocol_CTX',[]);
if ~isempty(sftest),
  s=getstimscripttimestruct(cksds,sftest(end).data);
  if ~isempty(s),

    inp.paramnames = {'sFrequency'};
    inp.title=[stimulusname cellname];
    inp.spikes = newcell;
    inp.st = s;
    
    pc = periodic_curve(inp,'default',where);
    
    error('');
    
    p = getparameters(pc);
    p.graphParams(4).whattoplot = 6;
    pc = setparameters(pc,p);
    co = getoutput(pc);

    [mf0,if0]=max(co.f0curve{1}(2,:)); 
    [mf1,if1]=max(co.f1curve{1}(2,:)); 
    f1f0=mf1/(mf0+0.00001);
    
    f0curve = co.f0curve{1}(1:4,:);
    f1curve = co.f1curve{1}(1:4,:);
    
    [f0low, f0max, f0high] = ...
	compute_halfwidth(co.f0curve{1}(1,:),co.f0curve{1}(2,:));

    [f1low, f1max, f1high] = ...
	compute_halfwidth(co.f1curve{1}(1,:),co.f1curve{1}(2,:));

    
    if(1) 
      % fit with difference of gaussian
      % also refit halfwidths and maxima if fit is good enough

      if display
	figure;
      end
      for cmsmp=1:2
	if cmsmp==2 % simple
	  r0=0;
	  re=mf1; ri=mf1;
	  se=f1max; si=0.1;
	  rcurve=f1curve;
	  ylab='F1 (Hz)';
	else
	  r0=co.spont(1);
	  re=mf0; ri=mf0;
	  se=f1max; si=0.1;
	  rcurve=f0curve;
	  ylab='F0 (Hz)';
	end
	
	search_options=optimset('fminsearch');
	search_options.TolFun=1e-3;
	search_options.TolX=1e-3;
	search_options.MaxFunEvals='300*numberOfVariables';
	search_options.Display='off';
	dog_par(:,cmsmp)=fminsearch('dog_error',[r0 re se ri si],search_options,...
				    [rcurve(1,:) 64],[rcurve(2,:) r0], ...
				    [rcurve(4,:) co.spont(2)] 	    )';
	%				   [0 rcurve(1,:) 64],[r0
	%				   rcurve(2,:) r0])'
	% don't include [0 r0] as extra point, because 0 spatial
        % frequency is not really a clear limit, dog_error punishes
        % negative rates at zero sf. 

	dog_par
	norm_error=dog_error(dog_par(:,cmsmp), [rcurve(1,:) 64],[rcurve(2,:) r0]);
	norm_error=sqrt(norm_error/  (rcurve(2,:)*rcurve(2,:)') );
	disp(['Normalized fitting error: ' num2str(norm_error,3)]);
	
	
	sfrange_interp=logspace( log10(min( min(rcurve(1,:)),0.01)) ...
				 ,log10(2),50);
	response=dog(dog_par(:,cmsmp)',sfrange_interp);
	
	[lowr, pref, highr] = ...
	    compute_halfwidth(sfrange_interp,response);

	if display
	  subplot(2,1,cmsmp)
	  errorbar( rcurve(1,:),rcurve(2,:),rcurve(4,:),'o'); 
	  set(gca,'XScale','log');
	  hold on
	  plot( sfrange_interp, response,'r' );
	  xlabel('Spatial frequency')
	  ylabel(ylab);
	  line( [pref pref], [0 dog(dog_par(:,cmsmp)',pref)],...
		'LineStyle','--','Color',[0  0 0]);
	  line( [lowr lowr], [0 dog(dog_par(:,cmsmp)',lowr)],...
		'LineStyle',':','Color',[0  0 0]);
	  line( [highr highr], [0 dog(dog_par(:,cmsmp)',highr)],...
		'LineStyle',':','Color',[0  0 0]);
	end
	
	if norm_error>0.75
	  disp(['Fitting error is larger than 0.75. Not using fit to' ...
		' calculate cut-off frequencies.']);
	else
	  if cmsmp==2 % simple
	    f1low=lowr;
	    f1max=pref;
	    f1high=highr;
	  else
	    f0low=lowr;
	    f0max=pref;
	    f0high=highr;
	  end
	end
      end
      
    end  % fitting DOG
    
    
    % fourier transform
    n=50;  % number of interpolation points
    para=getparameters(s.stimscript);
    nx=200;
    if display
      figure;
    end
    for rep=1:size(co.f1vals{1},1)  % do it for each repetition separately
      freqint=linspace(para.sFrequency(1),para.sFrequency(end),n);
      f1=co.f1vals{1}(rep,:);
      f1int=interp1(para.sFrequency,f1,freqint,'linear');
      x=linspace(-12,12,nx);
      fourier=exp(-pi*2.i * freqint'*x);
      rf(rep,:)=real(trapz(freqint,fourier.*f1int(linspace(1,1,nx),:)'));
      if display 
	plot(x,rf(rep,:));
	hold on;
      end
    end;
    phase(1,:)=co.f1curve{1}(1,:);
    phase(2,:)=angle(mean(co.f1vals{1}));
    phase(3,:)=std(angle(co.f1vals{1}));
    
    if display
      plot(x,mean(rf),'r');
      ylabel('Kernel');
      xlabel('Spatial location (degrees)');
      %    errorbar(x,mean(rf),std(rf));
    end
    
    assoc(end+1)=ctxnewassociate([stimulusname ' Test'],...
				 sftest(end).data,...
				 [stimulusname ' Test']);
    
    assoc(end+1)=ctxnewassociate([stimulusname ' Response Curve F0'],...
				 f0curve,...
				 [stimulusname ' Response Curve (F0)']);
    assoc(end+1)=ctxnewassociate([stimulusname ' Response Curve F1'],...
				 f1curve,...
				 [stimulusname ' Response Curve (F1)']);
    assoc(end+1)=ctxnewassociate([stimulusname ' F1 Phase'],...
				 phase,...
				 [stimulusname ' F1 Phase (mean, std)']);
    assoc(end+1)=ctxnewassociate([stimulusname ' F1/F0'],...
				 f1f0,...
				 [stimulusname ' F1/F0']);
    
    assoc(end+1)=...
	ctxnewassociate([stimulusname ...
		    ' Max drifting grating firing'],...
			[mf0 mf1],...
			[stimulusname ...
		    'Max firing to a drifting grating [F0 F1]']);
    assoc(end+1)=ctxnewassociate([stimulusname ' Pref'],[f0max f1max],...
			[stimulusname ' preference']);
    assoc(end+1)=ctxnewassociate([stimulusname ' Low'],[f0low f1low],...
			[stimulusname ' low half response point']);
    assoc(end+1)=ctxnewassociate([stimulusname ' High'],[f0high f1high],...
			[stimulusname ' high half response point']);  
    
    
    assoc(end+1)=ctxnewassociate([stimulusname ' DOG'],dog_par,...
			[stimulusname ' difference of gaussian parameters ' ...
		    'r0 re se ri si']);    

    
  
    
  end;
else
  error(['Cannot find associate: <' stimulusname ' Test>'] );
end;

for i=1:length(assoc), 
  newcell=associate(newcell,assoc(i)); 
end;




outstr.f0curve = f0curve; %shouldn't be used

  

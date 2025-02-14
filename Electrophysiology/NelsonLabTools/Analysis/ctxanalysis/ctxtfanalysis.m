function [newcell,outstr,assoc,pc]=ctxtfanalysis(cksds,cell,cellname,display)

%  CTXTFANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=CTXTFANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the temporal frequency test.  CKSDS is a valid CKSDIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the TF test (associate name in quotes):
%  'TF Response Curve F0'         |   F0 response
%  'TF Pref'                      |   TF w/ max firing
%  'TF Low'                       |   low TF with half of max response 
%  'TF High'                      |   high TF with half of max response 
%  'Max drifting grating firing'  |   Max firing during drifting gratings
%                                 |      (at optimal TF, SF, angle)

newcell = cell;

assoclist = ctxassociatelist('TF Test');

for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'protocol_CTX',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

if display,
	where.figure=figure;
	where.rect=[0 0 1 1];
	where.units='normalized';
	orient(where.figure,'landscape');
else, where = []; end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

f0curve = []; maxgrating = []; tfpref = []; pc = [];

tftest = findassociate(newcell,'TF Test','protocol_CTX',[]);
if ~isempty(tftest),
  s=getstimscripttimestruct(cksds,tftest(end).data);
  if ~isempty(s),
    inp.paramnames = {'tFrequency'};
    inp.title=['Temporal frequency ' cellname];
    inp.spikes = newcell;
    inp.st = s;
    pc = periodic_curve(inp,'default',where);
    p = getparameters(pc);
    p.graphParams(4).whattoplot = 6;
    pc = setparameters(pc,p);
    co = getoutput(pc);
    
    f0curve = co.f0curve{1}(1:4,:);
    f1curve = co.f1curve{1}(1:4,:);
    [mf0,if0]=max(f0curve(2,:)); 
    [mf1,if1]=max(f1curve(2,:)); 
    maxfiring = [mf0 mf1];
    f1f0=mf1/mf0;
    
    
    [lowf0, maxf0, highf0] = compute_halfwidth(f0curve(1,:),f0curve(2,:));
    [lowf1, maxf1, highf1] = compute_halfwidth(f1curve(1,:),f1curve(2,:));
    

    
    
       
    if(1)   % don't fit
      
      % fit with cascaded low-pass exponential, high pass RC filter
      % also refit halfwidths and maxima if fit is good enough

      if display
	figure;
      end
      for cmsmp=1:2
	if cmsmp==2 % simple
	  r0=0; rmax=mf1; flow=highf1; fhigh=lowf1;
	  rcurve=f1curve;
	  ylab='F1 (Hz)';
	else
	  r0=co.spont(1); rmax=mf0; flow=highf0; fhigh=lowf0;
	  %rmax=mf0*5;flow=5; fhigh=10; 
	  rcurve=f0curve;
	  ylab='F0 (Hz)';
	end
	if isnan(flow)
	  flow=64;
	end
	if isnan(fhigh)
	  fhigh=4;
	end
	
	explow=2;
	
	search_options=optimset('fminsearch');
	search_options.TolFun=1e-7;
	search_options.TolX=1e-6;
	search_options.MaxFunEvals='600*numberOfVariables';
	search_options.MaxIter='600*numberOfVariables';
	%search_options.MaxFunEvals=1000;
	%search_options.Display='off';
	exprc_par(:,cmsmp)=...
	    fminsearch('exprc_error',[r0 rmax flow fhigh explow],...
		       search_options,...
		       [rcurve(1,:)  0 150 200 250 ],...
		       [rcurve(2,:)  r0 r0 r0 r0 ]  ,... % )'; %, ...
		       [rcurve(4,:)  max(min(0.1,co.spont(2)),0.01) max(co.spont(2),0.01) ...
			max(co.spont(2),0.01)  ...
		        0.01 ] )';
	

	
	%				   [0 rcurve(1,:) 64],[r0
	%				   rcurve(2,:) r0])'
	% don't include [0 r0] as extra point, because 0 temporal
        % frequency is not really a clear limit, exprc_error punishes
        % negative rates at zero sf. 

	exprc_par
	
	if ~isnan(prod(exprc_par(:,cmsmp)))
	  norm_error=exprc_error(exprc_par(:,cmsmp), ...
				 [rcurve(1,:) 64 100 120 ],...
				 [rcurve(2,:) r0 r0 r0]);
	  norm_error=sqrt(norm_error/  (rcurve(2,:)*rcurve(2,:)') );
	else
	  norm_error=inf;
	  
	end
	  disp(['Normalized fitting error: ' num2str(norm_error,3)]);
	
	
	tfrange_interp=logspace( log10(min( min(rcurve(1,:)),0.01)) ...
				 ,log10(64),100);
	response=exprc(exprc_par(:,cmsmp)',tfrange_interp);
	
	[lowr, pref, highr] = ...
	    compute_halfwidth(tfrange_interp,response);


	
	if display
	  subplot(2,1,cmsmp)
	  errorbar( rcurve(1,:),rcurve(2,:),rcurve(4,:),'o'); 
	  set(gca,'XScale','log');
	  hold on
	  plot( tfrange_interp, response,'r' );
	  plot( [min(tfrange_interp) max(tfrange_interp)],[r0 r0],'k:');
	  xlabel('Temporal frequency')
	  ylabel(ylab);
	  line( [pref pref], [0 exprc(exprc_par(:,cmsmp)',pref)],...
		'LineStyle','--','Color',[0  0 0]);
	  line( [lowr lowr], [0 exprc(exprc_par(:,cmsmp)',lowr)],...
		'LineStyle',':','Color',[0  0 0]);
	  line( [highr highr], [0 exprc(exprc_par(:,cmsmp)',highr)],...
		'LineStyle',':','Color',[0  0 0]);
	end
	
	if norm_error>0.75
	  exprc_par(:,cmsmp)=nan;
	  disp(['Fitting error is larger than 0.75. Not using fit to' ...
		' calculate cut-off frequencies.']);
	else
	  if cmsmp==2 % simple
	    lowf1=lowr;
	    maxf1=pref;
	    highf1=highr;
	  else
	    lowf0=lowr;
	    maxf0=pref;
	    highf0=highr;
	  end
	end
      end
      
    end  % fitting EXPRC
    
    
    
    
    
    assoc(end+1)=ctxnewassociate('TF Test',...
				 tftest(end).data,...
				 'TF Test');
    assoc(end+1)=ctxnewassociate('TF Response Curve F0',...
			f0curve,'TF Response Curve F1');
    assoc(end+1)=ctxnewassociate('TF Response Curve F1',...
			f1curve,'TF Response Curve F1');
    assoc(end+1)=ctxnewassociate('TF Max drifting grating firing',...
			maxfiring,'Max firing to a drifting grating [F0 F1]');
    assoc(end+1)=ctxnewassociate('TF Pref',[maxf0 maxf1],...
			'Temporal frequency preference [F0 F1]');
    assoc(end+1)=ctxnewassociate('TF Low',[lowf0 lowf1],...
			'Temporal frequency low half response point [F0 F1]');
    assoc(end+1)=ctxnewassociate('TF High',[highf0 highf1],...
			'Temporal frequency high half response point [F0 F1]');
    assoc(end+1)=ctxnewassociate('TF F1/F0',f1f0,...
			'TF F1/F0');
    
    assoc(end+1)=ctxnewassociate(['TF Fitparameters'],exprc_par,...
			['TF Fitparameters' ...
		    'r0 re se ri si']);    

  end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr.f0curve = f0curve; % no longer used

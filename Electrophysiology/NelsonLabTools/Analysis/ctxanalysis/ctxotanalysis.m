function [newcell,outstr,assoc,pc]=ctxotanalysis(cksds,cell,cellname,display)

%  CTXOTANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=CTXOTANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the orientation tuning tests.  CKSDS is a valid CKSDIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the OT Test (associate name in quotes):
%  'OT Response Curve F1'         |   F1 response
%  'OT Pref'                      |   Direction w/ max firing
%  'Max drifting grating firing'  |   Max firing during drifting gratings
%                                 |      (at optimal TF, SF)
%  'Circular variance'            |   Circular variance
%  'Tuning width'                 |   Tuning width (half width at half height)
%  'Direction index'              |   Directionality index
%  'Spontaneous rate'             /  Spontaneous rate and std dev.



newcell = cell;

assoclist = ctxassociatelist('OT Test');

for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'protocol_CTX',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

f0curve = [];
f1curve = []; 
maxgrating = []; 
fdtpref = []; 
circularvariance = [];
tuningwidth = [];
directionindex = [];
pc = [];

if display,
  where.figure=figure;
  where.rect=[0 0 1 1];
  where.units='normalized';
  orient(where.figure,'landscape');
else, 
  where = []; 
end;
    

ottest = findassociate(newcell,'OT Test','protocol_CTX',[]);
if ~isempty(ottest),
  s=getstimscripttimestruct(cksds,ottest(end).data);
  if ~isempty(s),
    inp.paramnames = {'angle'};
    inp.title=['Orientation Tuning' cellname];
    inp.spikes = newcell;
    inp.st = s;

    
    %temp:   
    %inp.paramname = 'angle';
    %tc=tuning_curve(inp,'default',where);
    % para=getparameters(tc);
    %%para.res=0.004;   % default is 4ms
    %%                  % for testing use 0.5ms
    %para.res=0.0125;		      
    %%para.drawspont=1;
    %tc=setparameters(tc,para);
    %co = getoutput(tc);
    %cr = getoutput(co.rast);
    %return
    %temp
     
    
    pc = periodic_curve(inp,'default',where);
    p = getparameters(pc);
%    p.graphParams(4).whattoplot = 2; % show f1/f0 response in last graph
%    p.graphParams(4).whichdata = [1];
    p.graphParams(4).whattoplot = 6; % show f1/f0 response in last graph
    pc = setparameters(pc,p);
    co = getoutput(pc); 
    
    [mf0,if0]=max(co.f0curve{1}(2,:)); 
    [mf1,if1]=max(co.f1curve{1}(2,:)); 
    maxgrating = [mf0 mf1];
    f1f0=mf1/(mf0+0.00001);  
    otpref = [co.f0curve{1}(1,if0) co.f1curve{1}(1,if1)];
    

     
    
    f0curve = [f0curve; co.f0curve{1}];
    f1curve = [f1curve; co.f1curve{1}];
    
    circularvariance = ...
	[compute_circularvariance(co.f0curve{1}(1,:),co.f0curve{1}(2,:)-co.spont(1)) ...
	 compute_circularvariance(co.f1curve{1}(1,:),co.f1curve{1}(2,:))];
    tuningwidth = ...
	[compute_tuningwidth(co.f0curve{1}(1,:),co.f0curve{1}(2,:)-co.spont(1)) ...
	 compute_tuningwidth(co.f1curve{1}(1,:),co.f1curve{1}(2,:))];
    directionindex = ...
	[compute_directionindex(co.f0curve{1}(1,:),...
				co.f0curve{1}(2,:)-co.spont(1)) ...
	 compute_directionindex(co.f1curve{1}(1,:),co.f1curve{1}(2,:))];

    orientationindex = ...
	[compute_orientationindex(co.f0curve{1}(1,:),...
				  co.f0curve{1}(2,:)-co.spont(1)) ...
	 compute_orientationindex(co.f1curve{1}(1,:),co.f1curve{1}(2,:))];

    
    
    if(1)  % fit with Von Misen function
      if display
	figure;
      end
      for cmsmp=1:2
	if cmsmp==2 % simple
	  curve=f1curve;
	  spont_hint=0;
	  ylab='F1 (Hz)';
	else
	  curve=f0curve;
	  spont_hint=co.spont(1);
	  ylab='F0 (Hz)';
	end
	[rcurve,n_otpref(cmsmp),tuningwidth(cmsmp)]=fit_otcurve(curve,otpref(cmsmp),90,...
						    maxgrating(cmsmp),spont_hint );
	% tuning_width is not calculated with spontaneous rate subtracted
						 
						 
	if display
	  subplot(2,1,cmsmp)
	  errorbar( curve(1,:),curve(2,:),curve(4,:),'o'); 
	  hold on
	  plot(rcurve(1,:),rcurve(2,:),'r');
	  
	  xlabel('Orientation')
	  ylabel(ylab);
	end % display
      end % loop over F0, F1
    end  % function fitting

    
    
    
    assoc(end+1)=ctxnewassociate('OT Test',...
				 ottest(end).data,...
				 'OT Test');
    assoc(end+1)=ctxnewassociate('OT F1 Response Curve',...
			f1curve,'OT F1 Response Curve');
    assoc(end+1)=ctxnewassociate('OT F0 Response Curve',...
			f0curve,'OT F0 Response Curve');
    assoc(end+1)=ctxnewassociate('OT F1/F0',...
			f1f0,'OT max F1/max F0');
    assoc(end+1)=ctxnewassociate('OT Max drifting grating firing',...
				 maxgrating,...
				 'OT Max firing to a drifting grating [F0 F1]');
    assoc(end+1)=ctxnewassociate('OT Pref',...
			n_otpref,'OT Direction with max. response [F0 F1]');
    assoc(end+1)=ctxnewassociate('OT Circular variance',...
			circularvariance,'OT Circular variance [F0 F1]');
    assoc(end+1)=ctxnewassociate('OT Tuning width',...
				 tuningwidth,'OT Tuning width [F0 F1]');
    assoc(end+1)=ctxnewassociate('OT Orientation index',...
				 orientationindex,...
				 'OT Orientation index [F0 F1]');
    assoc(end+1)=ctxnewassociate('OT Direction index',...
				 directionindex,'OT Direction index [F0 F1]');
    assoc(end+1)=ctxnewassociate('OT Spontaneous rate',...
				 co.spont','OT Spontaneous rate [mean std]');
       % transpose of co.spont in order not to confuse with F0 F1
  end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr.f1curve = f1curve; % no longer used

function [newcell,outstr,assoc,pc]=ctxlengthanalysis(cksds,cell,cellname,display)

%  CTXLENGTHANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=CTXLENGTHANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the orientation tuning tests.  CKSDS is a valid CKSDIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the LENGTH Test (associate name in quotes):
%  'Length Response Curve F0'         |   F0 response
%  'Length Response Curve F1'         |   F1 response
%  'Length Pixels Pref'                |   Direction w/ max firing
%  'Max drifting grating firing'   |   Max firing during drifting gratings
%  'Length F1/F0'                     / 


newcell = cell;

assoclist = ctxassociatelist('Length Test');

for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'protocol_CTX',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;


assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

maxgrating = []; 
lengthpref = []; 

if display,
  where.figure=figure;
  where.rect=[0 0 1 1];
  where.units='normalized';
  orient(where.figure,'landscape');
else, 
  where = []; 
end;
    
lengthtest = findassociate(newcell,'Length Test','protocol_CTX',[]);

if ~isempty(lengthtest),
   s=getstimscripttimestruct(cksds,lengthtest(end).data);
  if ~isempty(s),
    
    
    
    inp.paramnames = {'sPhaseShift'};   
    % dirty trick using phaseshift to keep different lengths apart
    % and use periodic_curve
    inp.title=['Length ' cellname ];
    inp.spikes = newcell;
    inp.st = s;
    
    pc = periodic_curve(inp,'default',where);
    p = getparameters(pc);
    p.graphParams(4).whattoplot = 6; % show f1/f0 response in last graph
    pc = setparameters(pc,p);
    co = getoutput(pc); 
    
    [mf0,if0]=max(co.f0curve{1}(2,:)); 
    [mf1,if1]=max(co.f1curve{1}(2,:)); 
    maxgrating = [mf0 mf1];
    f1f0=mf1/(mf0+0.00001);  

    % to convert stimulus number to length
    periodicstimuli = get(s.stimscript);
    
    f0curve = co.f0curve{1}(1:4,:);
    f1curve = co.f1curve{1}(1:4,:);
    f0curve(1,:)=get_length( f0curve(1,:), periodicstimuli);
    f1curve(1,:)=get_length( f1curve(1,:), periodicstimuli);
    
    % get stimulus numbers of low halfmax response, max response and high
    % max response
    [f0low, f0max, f0high] = ...
	compute_halfwidth(co.f0curve{1}(1,:),co.f0curve{1}(2,:));
    
    [f1low, f1max, f1high] = ...
	compute_halfwidth(co.f1curve{1}(1,:),co.f1curve{1}(2,:));

    


    f0low=get_length(f0low,periodicstimuli);
    f0max=get_length(f0max,periodicstimuli);
    f0high=get_length(f0high,periodicstimuli);

    f1low=get_length(f1low,periodicstimuli);
    f1max=get_length(f1max,periodicstimuli);
    f1high=get_length(f1high,periodicstimuli);

   
    
    assoc(end+1)=ctxnewassociate('Length Test',...
				 lengthtest(end).data,...
				 'Length Test');
    assoc(end+1)=ctxnewassociate('Length F1 Response Curve',...
			f1curve,'Length F1 Response Curve');
    assoc(end+1)=ctxnewassociate('Length F0 Response Curve',...
			f0curve,'Length F0 Response Curve');
    assoc(end+1)=ctxnewassociate('Length F1/F0',...
			f1f0,'Length max F1/max F0');
    assoc(end+1)=ctxnewassociate('Length Max drifting grating firing',...
				 maxgrating,...
				 'Length Max firing to a drifting grating [F0 F1]');
    assoc(end+1)=ctxnewassociate('Length Pixels Low',[f0low f1low],...
				 'Length with low half max. response [F0 F1]');
    assoc(end+1)=ctxnewassociate('Length Pixels Pref',[f0max f1max],...
				 'Length with max. response [F0 F1]');
    assoc(end+1)=ctxnewassociate('Length Pixels High',[f0high f1high],...
				 'Length with high half max. response [F0 F1]');
  
  
    as=findassociate(newcell,'Monitor','protocol_CTX',[]);
    if ~isempty(as)
      monitor=as.data;
      as=findassociate(newcell,'Position on monitor','protocol_CTX',[]);
      position_on_monitor=as.data;
      pars=getparameters(periodicstimuli{1});
      angle=pars.angle;

      f0low_deg=length_pixels2degrees(f0low, angle ,monitor, ...
					  position_on_monitor);
      f1low_deg=length_pixels2degrees(f1low, angle ,monitor, ...
					  position_on_monitor);
      f0max_deg=length_pixels2degrees(f0max, angle ,monitor, ...
					  position_on_monitor);
      f1max_deg=length_pixels2degrees(f1max, angle ,monitor, ...
					  position_on_monitor);
      f0high_deg=length_pixels2degrees(f0high, angle ,monitor, ...
					   position_on_monitor);
      f1high_deg=length_pixels2degrees(f1high, angle ,monitor, ...
					   position_on_monitor);
      
      assoc(end+1)=ctxnewassociate('Length Degrees Low',[f0low_deg f1low_deg],...
				   'Length with low half max. response [F0 F1]');
      assoc(end+1)=ctxnewassociate('Length Degrees Pref',[f0max_deg f1max_deg],...
				   'Length with low half max. response [F0 F1]');
      assoc(end+1)=ctxnewassociate('Length Degrees High',[f0high_deg f1high_deg],...
				   'Length with low half max. response [F0 F1]');

      
      disp('Associated degrees for length test');
    end
    

  
  end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr=[];

return


function l=get_length( stimnum, periodicstimuli )
  stimnum=round(stimnum);    % in case interpolation yielded something non int.
  for i=1:length(stimnum)
    if ~isnan(stimnum(i))
      pp=getparameters(periodicstimuli{stimnum(i)});
      l(i)=pp.rect(3)-pp.rect(1);
    else
      l(i)=nan;
    end
  end

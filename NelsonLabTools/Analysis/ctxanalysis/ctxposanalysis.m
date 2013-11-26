function [newcell,outstr,assoc,pc]=ctxposanalysis(cksds,cell,cellname,display)

%  CTXPOSANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=CTXPOSANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the orientation tuning tests.  CKSDS is a valid CKSDIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the POS Test (associate name in quotes):
%  'Pos Response Curve F0'         |   F0 response
%  'Pos Response Curve F1'         |   F1 response
%  'Pos Pixels Pref'                |   Direction w/ max firing
%  'Max drifting grating firing'   |   Max firing during drifting gratings
%  'Pos F1/F0'                     / 



newcell = cell;

assoclist = ctxassociatelist('Pos Test');

for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'protocol_CTX',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

maxgrating = []; 
pospref = []; 

if display,
  where.figure=figure;
  where.rect=[0 0 1 1];
  where.units='normalized';
  orient(where.figure,'landscape');
else, 
  where = []; 
end;
    
postest = findassociate(newcell,'Pos Test','protocol_CTX',[])

if ~isempty(postest),
   s=getstimscripttimestruct(cksds,postest(end).data);
  if ~isempty(s),
    
    
    
    inp.paramnames = {'sPhaseShift'};   % dirty trick
    inp.title=['Position ' cellname '(nrs like matlab)'];
    inp.spikes = newcell;
    inp.st = s;
    
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
    prefnum = [co.f0curve{1}(1,if0) co.f1curve{1}(1,if1)]; %stim number

    % to get rectangle parameters
    periodicstimuli = get(s.stimscript);
    pp=getparameters(periodicstimuli{prefnum(1)});
    f0rect=pp.rect;
    pospref(1,1)=round((f0rect(1)+f0rect(3) )/2);
    pospref(2,1)=round((f0rect(2)+f0rect(4) )/2);
    pp=getparameters(periodicstimuli{prefnum(2)});
    f1rect=pp.rect;
    pospref(1,2)=round((f1rect(1)+f1rect(3) )/2);
    pospref(2,2)=round((f1rect(2)+f1rect(4) )/2);
    
    
    f0curve = co.f0curve{1}(1:4,:);
    f1curve = co.f1curve{1}(1:4,:);

    assoc(end+1)=ctxnewassociate('Pos Test',...
				 postest(end).data,...
				 'Pos Test');
    assoc(end+1)=ctxnewassociate('Pos F1 Response Curve',...
			f1curve,'Pos F1 Response Curve');
    assoc(end+1)=ctxnewassociate('Pos F0 Response Curve',...
			f0curve,'Pos F0 Response Curve');
    assoc(end+1)=ctxnewassociate('Pos F1/F0',...
			f1f0,'Pos max F1/max F0');
    assoc(end+1)=ctxnewassociate('Pos Max drifting grating firing',...
				 maxgrating,...
				 'Pos Max firing to a drifting grating [F0 F1]');
    assoc(end+1)=ctxnewassociate('Pos Pixels Pref',...
			pospref,'Position with max. response [F0 F1]');
  end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr=[];

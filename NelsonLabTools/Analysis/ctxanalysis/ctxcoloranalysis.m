function [newcell,outstr,assoc,pc]=ctxcoloranalysis(cksds,cell,cellname,display)

%  CTXCOLORANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=CTXCOLORANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the orientation tuning tests.  CKSDS is a valid CKSDIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the Color Test (associate name in quotes):
%  'Color Response Curve F0'         |   F0 response
%  'Color Response Curve F1'         |   F1 response
%  'Color F1/F0'                     / 
%  'Color Max rate'
%  'Color Min rate'
%  'Color Balance'
  

newcell = cell;

assoclist = ctxassociatelist('Color Test');

for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'protocol_CTX',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

if display,
  where.figure=figure;
  where.rect=[0 0 1 1];
  where.units='normalized';
  orient(where.figure,'landscape');
else, 
  where = []; 
end;
    
colortest = findassociate(newcell,'Color Test','protocol_CTX',[])

if ~isempty(colortest),
   s=getstimscripttimestruct(cksds,colortest(end).data);
  if ~isempty(s),
    
    
    
    inp.paramnames = {'sPhaseShift'};   
    % dirty trick using phaseshift to keep different lambdas apart
    % and use periodic_curve
    inp.title=['Color ' cellname ];
    inp.spikes = newcell;
    inp.st = s;
    
    pc = periodic_curve(inp,'default',where);
    p = getparameters(pc);
    p.graphParams(4).whattoplot = 6; % show f1/f0 response in last graph
    pc = setparameters(pc,p);
    co = getoutput(pc); 
    
    % to convert stimulus number to lambda (from sPhaseShift)
    periodicstimuli = get(s.stimscript);    
    
    f0curve = co.f0curve{1}(1:4,:); % includes std and ste
    f1curve = co.f1curve{1}(1:4,:); % includes std and ste

    [max_f0,i_max_f0]=max(f0curve(2,:)); 
    [max_f1,i_max_f1]=max(f1curve(2,:)); 
    maxrate = [max_f0 max_f1];
    [min_f0,i_min_f0]=min(f0curve(2,:)); 
    [min_f1,i_min_f1]=min(f1curve(2,:)); 
    minrate = [min_f0 min_f1];
    f1f0=max_f1/(max_f0+0.00001);  
    balance=[ f0curve(1,i_min_f0) ...
	      f1curve(1,i_min_f1) ];

    % fit abs(straight line)
    
    for cmsmp=1:2
      if cmsmp==2 % simple
	rcurve=f1curve(:,1:end-2);
      else
	rcurve=f0curve(:,1:end-2);
      end
      
      search_options=optimset('fminsearch');
      search_options.TolFun=1e-3;
      search_options.TolX=1e-3;
      search_options.MaxFunEvals='300*numberOfVariables';
      search_options.Display='off';
      fitabs_par(:,cmsmp)=...
	  fminsearch('absline_error',...
		     [-rcurve(2,end)-rcurve(2,1) rcurve(2,1)],...
		     search_options,...
		     [rcurve(1,:) ],[rcurve(2,:) ], ...
		     [rcurve(4,:) ] 	    )';
    
      fitabs_error=absline_error(fitabs_par(:,cmsmp), [rcurve(1,:) ],...
				 [rcurve(2,:)],rcurve(4,:));
      disp([' fitabs_error: ' num2str(fitabs_error,4)]);

      fittheta_par(:,cmsmp)=...
	  fminsearch('thetaline_error',...
		     [0  rcurve(2,1)],...
		     search_options,...
		     [rcurve(1,:) ],[rcurve(2,:) ],...
      		     [rcurve(4,:) ] 	    )';
    
      fittheta_error=thetaline_error(fittheta_par(:,cmsmp),...
				     [rcurve(1,:) ],...
				     [rcurve(2,:) ],rcurve(4,:));

      
      disp([' fittheta_error: ' num2str(fittheta_error,4)]);



      if(fitabs_error<fittheta_error)
	fitpar=fitabs_par;
	fitfunction=1;
      else
	fitpar=fittheta_par;
	fitfunction=2;
      end
      
      figure;
      errorbar( rcurve(1,:),rcurve(2,:),rcurve(4,:),'k.')
      hold on;
      x=linspace(0,1,100);
      if fitabs_error<fittheta_error
	h=plot( x, abs(x*fitabs_par(1,cmsmp)+fitabs_par(2,cmsmp)),'k');
      else
	h=plot( x, theta(x*fittheta_par(1,cmsmp)+fittheta_par(2,cmsmp)),'k');
      end
      ax=axis;ax(3)=0;axis(ax);
      
    end
      
    

    
    assoc(end+1)=ctxnewassociate('Color Test',...
				 colortest(end).data,...
				 'Color Test');
    assoc(end+1)=ctxnewassociate('Color F1 Response Curve',...
			f1curve,'Color F1 Response Curve');
    assoc(end+1)=ctxnewassociate('Color F0 Response Curve',...
			f0curve,'Color F0 Response Curve');
    assoc(end+1)=ctxnewassociate('Color F1/F0',...
				 f1f0,'Color max F1/max F0');
    assoc(end+1)=ctxnewassociate('Color Max rate',...
				 maxrate,'Color Max rate [F0 F1]');
    assoc(end+1)=ctxnewassociate('Color Min rate',...
				 minrate,'Color Min rate [F0 F1]');
    assoc(end+1)=ctxnewassociate('Color Balance',...
				 balance,'Color Balance [F0 F1]');

    
    assoc(end+1)=ctxnewassociate('Color Fitparameters ',...
				 fitpar,'Color Fitparameters [a b]');
    assoc(end+1)=ctxnewassociate('Color Fitfunction ',...
				 fitfunction,'Color Fitfunction');
    
    assoc(end+1)=ctxnewassociate('Color Spontaneous rate',...
				 co.spont,'Color Spontaneous rate [rate std]');
  end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr=[];

return



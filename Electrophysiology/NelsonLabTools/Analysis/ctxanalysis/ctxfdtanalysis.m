function [newcell,outstr,assoc,pc]=ctxfdtanalysis(cksds,cell,cellname,display)

%  CTXFDTANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=CTXFDTANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the fine direction tuning tests.  CKSDS is a valid CKSDIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the FDT test (associate name in quotes):
%  'FDT Response Curve F1'        |   F1 response
%  'FDT Pref'                     |   Direction w/ max firing
%  'Max drifting grating firing'  |   Max firing during drifting gratings
%                                 |      (at optimal TF, SF)
%  'Circular variance'            |   Circular variance
%  'Tuning width'                 |   Tuning width
%  'Direction index'              |   Directionality index
%



newcell = cell;

assoclist = ctxassociatelist('FDT Test');



for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'protocol_CTX',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

f0curve = [];
f1curve = []; 
maxfiring = []; 
fdtpref = []; 
circularvariance = [];
tuningwidth = [];
directionindex = [];
orientationindex = [];
pc = [];
f1f0 = [];
spont=[];


fdttest = findassociate(newcell,'FDT Test','protocol_CTX',[]);
if ~isempty(fdttest),
  s=getstimscripttimestruct(cksds,fdttest(end).data);
  if ~isempty(s),
    % split data in different contrasts
    p=getparameters(s.stimscript);
    angle=p.angle;
    contrast=p.contrast;
    remainder=s;

    for c=1:length(contrast)
      %	    stims=get(remainder.stimscript);
      stims=get(s.stimscript);
      
      % thiscontrast=[];
      % for j=1:length(stims)
      %   p=getparameters(stims{j});
      %	  if p.contrast==contrast(c)
      %	    thiscontrast(end+1)=j;
      %   end
      % end
      % if line below works, that above stuff can be deleted
      
      thiscontrast = getpsstiminds(s.stimscript,{'contrast'},{contrast(c)});
      
      %	[current.stimscript,remainder.stimscript,current.mti,remainder.mti]=...
      %	   DecomposeScriptMTI(remainder.stimscript,remainder.mti,thiscontrast)
      
      if length(contrast)>1
	[current.stimscript,remainder.stimscript,current.mti,remainder.mti]=...
	    DecomposeScriptMTI(s.stimscript,s.mti,thiscontrast);
      else
	current=s;
      end
	
      inp.paramnames = {'angle'};
      inp.title=['Direction Tuning' cellname];
      inp.spikes = newcell;
      inp.st = current;
      
      if display,
	where.figure=figure;
	where.rect=[0 0 1 1];
	where.units='normalized';
	orient(where.figure,'landscape');
      else, 
	where = []; 
      end;
	
      pc = periodic_curve(inp,'default',where);
      p = getparameters(pc);
      p.graphParams(4).whattoplot = 6; % show f1/f0 response in last graph
      pc = setparameters(pc,p);
      co = getoutput(pc); 
      
      
      [mf0,if0]=max(co.f0curve{1}(2,:)); 
      [mf1,if1]=max(co.f1curve{1}(2,:)); 
      
      f1f0 = [f1f0 ; mf1/mf0 ];
      fdtpref = [fdtpref; co.f0curve{1}(1,if0) co.f1curve{1}(1,if1)];
      f0curve(end+1,:) = co.f0curve{1}(1,:);
      f0curve(end+1,:) = co.f0curve{1}(2,:);
      f0curve(end+1,:) = co.f0curve{1}(3,:);
      f0curve(end+1,:) = co.f0curve{1}(4,:);
      f1curve(end+1,:) = co.f1curve{1}(1,:);
      f1curve(end+1,:) = co.f1curve{1}(2,:);
      f1curve(end+1,:) = co.f1curve{1}(3,:);
      f1curve(end+1,:) = co.f1curve{1}(4,:);
      spont(end+1)=co.spont(1);
      maxfiring = [maxfiring; mf0 mf1];



      
      circularvariance = ...
	  [circularvariance; ...
	   compute_circularvariance(co.f0curve{1}(1,:),co.f0curve{1}(2,:)-co.spont(1)) ...
	   compute_circularvariance(co.f1curve{1}(1,:),co.f1curve{1}(2,:))];
      tuningwidth = ...
	  [tuningwidth; ...
	   compute_tuningwidth(co.f0curve{1}(1,:),co.f0curve{1}(2,:)-co.spont(1)) ...
	   compute_tuningwidth(co.f1curve{1}(1,:),co.f1curve{1}(2,:))];
      directionindex = ...
	  [directionindex;...
	   compute_directionindex(co.f0curve{1}(1,:),co.f0curve{1}(2,:)-co.spont(1)) ...
	   compute_directionindex(co.f1curve{1}(1,:),co.f1curve{1}(2,:))];
      orientationindex = ...
	  [orientationindex;...
	   compute_orientationindex(co.f0curve{1}(1,:),co.f0curve{1}(2,:)-co.spont(1)) ...
	   compute_orientationindex(co.f1curve{1}(1,:),co.f1curve{1}(2,:))];
	
      for cmsmp=1:2
	if cmsmp==2 % simple
	  curve=co.f1curve{1};
	  spont_hint=0;
	else
	  curve=co.f0curve{1};
	  spont_hint=co.spont(1);
	end
	[rcurve{c,cmsmp},fdtpref(end,cmsmp),tuningwidth(end,cmsmp)]=...
	    fit_otcurve(curve,fdtpref(end,cmsmp),90,...
			maxfiring(end,cmsmp),spont_hint );
%			4*tuningwidth(end,cmsmp), ...
      end % loop over F0/F1
      
      
    end; % loop over contrasts
      
    if display,
      % for aligning curves in the center
      [m,irow]=max(maxfiring);
      [m,icol]=max(m);
      optangle=fdtpref(irow(icol),icol);
      [i,v]=findclosest(f0curve(1,:),mod(optangle-90,360));
      n_angles=size(f0curve,2);
      lowhalfsize=floor(n_angles/2);
      angles=f0curve(1,:);
      if i>lowhalfsize 
	% i lays past midpoint
	start1=i-lowhalfsize+1;
	end1=n_angles;
	start2=1;
	end2=i-lowhalfsize;
	angles(start2:end2)=angles(start2:end2)+360;
      else
  	% i lays before midpoint
	start1=i+lowhalfsize;
	end1=n_angles;
	start2=1;
	end2=i+lowhalfsize-1;
	angles(start1:end1)=angles(start1:end1)-360;
      end
      sequence=[(start1:end1) (start2:end2)];
      
      
      colors='kbrymcgw';
      figure;
      
      for i=1:length(contrast)
	subplot(2,1,1),plot(f0curve(1,:),...
			    f0curve(4*(i-1)+2,:), ...
			    [colors(i) 'o']);
	hold on
	plot(rcurve{i,1}(1,:),rcurve{i,1}(2,:),...
			      [colors(i)]);
	xlabel('Angle (degrees)')
	ylabel('Rate (Hz)')
	xt=get(gca,'XTick');
	set(gca,'XTickLabel',num2str(mod(xt,360)'));
	hold on;
	  subplot(2,1,2),plot(f1curve(1,:),...
			      f1curve(4*(i-1)+2,:), ...
			    [colors(i) 'o'])
	  hold on
	  plot(rcurve{i,2}(1,:),rcurve{i,2}(2,:),...
			      colors(i));
	xlabel('Angle (degrees)')
	ylabel('F1 (Hz)')
	xt=get(gca,'XTick');
	set(gca,'XTickLabel',num2str(mod(xt,360)'));
	hold on;
      end
    end
	

    spont=[mean(spont) std(spont) ];
      
    
    assoc(end+1)=ctxnewassociate('FDT Test',...
				 fdttest(end).data,...
				 'FDT Test');
    assoc(end+1)=ctxnewassociate('FDT Response Curve F1',f1curve,...
			'FDT Response Curve (F1)');
    assoc(end+1)=ctxnewassociate('FDT Response Curve F0',f0curve,...
			'FDT Response Curve (F0)');
    assoc(end+1)=ctxnewassociate('FDT Max firing rate',maxfiring,...
			'FDT Max firing rate [F0 F1]');
    assoc(end+1)=ctxnewassociate('FDT Pref',fdtpref,...
			'FDT Direction with max response [F0 F1]');
    assoc(end+1)=ctxnewassociate('FDT Circular variance',circularvariance,...
			'FDT Circular variance [F0 F1]');
    assoc(end+1)=ctxnewassociate('FDT Tuning width',tuningwidth,...
			'FDT Tuning width [F0 F1]');
    assoc(end+1)=ctxnewassociate('FDT Direction index',directionindex,...
			'FDT Direction index [F0 F1]');
    assoc(end+1)=ctxnewassociate('FDT Orientation index',orientationindex,...
			'FDT Orientation index [F0 F1]');
    assoc(end+1)=ctxnewassociate('FDT F1/F0',f1f0,...
			'FDT F1/F0');
    assoc(end+1)=ctxnewassociate('FDT Spontaneous rate',spont,...
			'FDT Spontaneous rate ([mean std])');
  end;
end;

for i=1:length(assoc), 
  newcell=associate(newcell,assoc(i)); 
end;

outstr.f1curve = f1curve; %shouldn't be used


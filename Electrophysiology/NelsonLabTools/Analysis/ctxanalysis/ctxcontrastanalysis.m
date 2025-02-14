function [newcell,outstr,assoc,pc]=ctxcontrastanalysis(cksds,cell,...
		cellname,display)

%  CTXCONTRASTANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=CTXCONTRASTANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the contrast test.  CKSDS is a valid CKSDIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the Contrast test (associate name in quotes):
%  'C50'                          |   Contrast that gives 50% of maximum
%                                 |      for each TF presented
%  'Contrast Max rate'            |   Max firing rate for each TF presented
%  'Cgain0-16'                    |   Gain between 0 and 16% contrast, each TF
%  'Cgain16-100'                  |   Gain between 16 and 100% contrast, ea. TF
%  'Cgain0-32'                    |   Gain between 0 and 32% contrast, each TF
%  'Cgain32-100'                  |   Gain between 0 and 100% contrast, each TF

disp(' Analyzing contrast');

newcell = cell;

assoclist = ctxassociatelist('Contrast Test');

for I=1:length(assoclist),
  [as,i] = findassociate(newcell,assoclist{I},'protocol_CTX',[]);
  if ~isempty(as), 
    newcell = disassociate(newcell,i); 
  end;
end;

if display,
	where1.figure=figure;
	where1.rect=[0 0 1 1];
	where1.units='normalized';
	orient(where1.figure,'landscape');
	where2=where1;
	where3=where1;
else, where1 = []; where2=[]; where3=[];  end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

NRgain = []; NRmax = []; NR50 = []; C50 = []; CMax = []; pc = []; tfs=[];
Cgain0_16 = []; Cgain16_100=[]; Cgain0_32 = []; Cgain32_100=[];
Cgain0_32_maxtf = []; Cgain32_100_maxtf = []; C50_maxtf = []; CMax_tf=[];
Cgain0_16_maxtf = []; Cgain16_100_maxtf = []; themaxtf = [];
Cgain32MaxTFRatios = [];


cntest = findassociate(newcell,'Contrast Test','protocol_CTX',[]);


if ~isempty(cntest),
  s=getstimscripttimestruct(cksds,cntest(end).data);
  if ~isempty(s),
    inp.paramnames = {'contrast'}; inp.title=['Contrast ' cellname];
    inp.spikes = newcell; inp.st = s;
    pp=getparameters(get(inp.st.stimscript,1));
    pc = periodic_curve(inp,'default',where1);
    p = getparameters(pc);
    p.graphParams(4).whattoplot = 6;
    pc = setparameters(pc,p);
    co = getoutput(pc);
    
    f0curve = co.f0curve{1}(1:4,:);
    f1curve = co.f1curve{1}(1:4,:);

    
    % notice: subtracting spontaneous rate before fitting!
    co_f0=struct('curve',co.f0curve{1});
    co_f0.vals=co.f0vals{1}-co.spont(1);
    co_f0.curve(2,:)=co_f0.curve(2,:)-co.spont(1);
    
    [c50_f0,cMax_f0,cgain0_16_f0,cgain16_100_f0,cgain0_32_f0,cgain32_100_f0,...
     nrg_f0,nr50_f0,nrmax_f0,nrexp_f0]=contraststuff(co_f0);
    
    co_f1=struct('curve',co.f1curve{1});
    co_f1.vals=abs(co.f1vals{1}); % to avoid warnings. should not really
                                  % be necessary
				  
    
    
    [c50_f1,cMax_f1,cgain0_16_f1,cgain16_100_f1,cgain0_32_f1,cgain32_100_f1,...
     nrg_f1,nr50_f1,nrmax_f1,nrexp_f1]=contraststuff(co_f1);

    NRgain = [ nrg_f0 nrg_f1 ]; 
    NR50 = [nr50_f0 nr50_f1 ]; 
    NRmax = [nrmax_f0 nrmax_f1];
    NRexp = [nrexp_f0 nrexp_f1];
    
    C50 = [ c50_f0 c50_f1]; 
    % necessary to add spontaneous rate again to max firing rate
    CMax =[ cMax_f0+co.spont(1) cMax_f1];
    Cgain0_16 = [ cgain0_16_f0 cgain0_16_f1]; 
    Cgain16_100=[ cgain16_100_f0 cgain16_100_f1];
    Cgain0_32 = [ cgain0_32_f0 cgain0_32_f1]; 
    Cgain32_100=[ cgain32_100_f0 cgain32_100_f1];

    if display
      % plot F0 Naka-Rushton fit
      graphs=get(gcf,'Children');
      subplot(graphs(4));
      hold on
      x=linspace(0,1,50);
      xn=x.^NRexp(1);
      y=co.spont(1)+NRmax(1)*xn./(xn+NR50(1)^NRexp(1)    );
      plot(x,y,'k--');
      
      
      % plot F1 Naka-Rushton fit
      graphs=get(gcf,'Children');
      subplot(graphs(3));
      hold on
      x=linspace(0,1,50);
      xn=x.^NRexp(2);
      y=NRmax(2)*xn./(xn+NR50(2)^NRexp(2));
      plot(x,y,'k--');
    end
       
    assoc(end+1)=ctxnewassociate('Contrast Test',...
				 cntest(end).data,...
				 'Contrast Test');
    assoc(end+1)=struct('type','Contrast Response Curve F0',...
			'owner','protocol_CTX','data',f0curve,'desc',...
			'Contrast Response Curve F0');
    assoc(end+1)=struct('type','Contrast Response Curve F1',...
			'owner','protocol_CTX','data',f1curve,'desc',...
			'Contrast Response Curve F1');
    assoc(end+1)=struct('type','C50',...
			'owner','protocol_CTX','data',C50,'desc',...
			'Contrast at 50% max firing');
    assoc(end+1)=struct('type','Contrast Max rate',...
			'owner','protocol_CTX','data',CMax,'desc',...
			'Max firing');
    assoc(end+1)=struct('type','Cgain 0-16','owner','protocol_CTX',...
			'data',Cgain0_16,...
			'desc','Contrast gain from 0..16% at each TF');
    assoc(end+1)=struct('type','Cgain 16-100','owner','protocol_CTX',...
			'data',Cgain16_100,...
			'desc','Contrast gain from 16..100% at each TF');
    assoc(end+1)=struct('type','Cgain 0-32','owner','protocol_CTX',...
			'data',Cgain0_32,...
			'desc','Contrast gain from 0..32% at each TF');
    assoc(end+1)=struct('type','Cgain 32-100','owner','protocol_CTX',...
			'data',Cgain32_100,...
			'desc','Contrast gain from 32..100');
    assoc(end+1)=struct('type','Naka-Rushton gain','owner','protocol_CTX',...
			'data',NRgain,'desc','Naka-Rushton gain');
    assoc(end+1)=struct('type','Naka-Rushton max','owner','protocol_CTX',...
			'data',NRmax,'desc','Naka-Rushton max');
    assoc(end+1)=struct('type','Naka-Rushton 50','owner','protocol_CTX',...
			'data',NR50,'desc','Naka-Rushton 50 point');
    assoc(end+1)=struct('type','Naka-Rushton exponent',...
			'owner','protocol_CTX',...
			'data',NRexp,'desc','Naka-Rushton exponent');
    assoc(end+1)=struct('type','Contrast Spontaneous rate',...
			'owner','protocol_CTX',...
			'data',[co.spont(1) 0],...
			'desc','Contrast spontaneous rate');
  end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i));end;

outstr.C50= C50; outstr.CMax = CMax; outstr.Cgain0_16= Cgain0_16;
outstr.Cgain16_100 = Cgain16_100; outstr.NRgain=NRgain;outstr.NR50=NR50;outstr.NRmax=NRmax;




  
function [c50,Cmax,cgain0_16,cgain16_100,cgain0_32,cgain32_100,...
	  nrg,nr50,nrmax,nrexp,nrgain]=contraststuff(c)
  [nrmax,nr50,nrexp]=naka_rushton(c.curve(1,:),c.vals);

  cmax=( (nrexp-1)/(nrexp+1) )^(1/nrexp) * nr50;
  
  if cmax>1 % only influences four cells
    cmax=1;
    nrg=nrmax*nrexp*nr50^nrexp/(nr50^nrexp+1)^2;
  else
    nrg=nrmax/(nr50*100) * nrexp*( (nrexp-1)/(nrexp+1) )^( (nrexp-1)/nrexp)*...
	( (nrexp+1)/(2*nrexp))^2;
  end
     
  
  xx=0:0.01:1;
  yy=interp1(c.curve(1,:),c.curve(2,:),xx,'linear');
  [Cmax,i] = max(yy);
  [c50,j] = findclosest(yy,Cmax/2); c50 = c50/100;
  x=c.curve(1,:);y=c.vals;x_=x;x=repmat(x,size(y,1),1);
  e16 = findclosest(x_,0.16);
  x16 = reshape(x(:,1:e16),1,prod(size(x(:,1:e16))))';
  y16 = reshape(y(:,1:e16),1,prod(size(y(:,1:e16))))';
  cgain0_16 = regress(y16+0.0001,x16+0.0001);
  mean16=c.curve(2,e16);
  e32 = findclosest(x_,0.32);
  x32 = reshape(x(:,1:e32),1,prod(size(x(:,1:e32))))';
  y32 = reshape(y(:,1:e32),1,prod(size(y(:,1:e32))))';
  cgain0_32 = regress(y32,x32+0.00001);
  mean32=c.curve(2,e32);
  e100 = findclosest(x_,1);
  x100_16 = reshape(x(:,e16:e100),1,prod(size(x(:,e16:e100))))' - 0.16;
  y100_16 = reshape(y(:,e16:e100),1,prod(size(y(:,e16:e100))))' - mean16;
  cgain16_100 = regress(y100_16,x100_16);
  x100_32 = reshape(x(:,e32:e100),1,prod(size(x(:,e32:e100))))' - 0.32;
  y100_32 = reshape(y(:,e32:e100),1,prod(size(y(:,e32:e100))))' - mean32;
  cgain32_100 = regress(y100_32,x100_32);

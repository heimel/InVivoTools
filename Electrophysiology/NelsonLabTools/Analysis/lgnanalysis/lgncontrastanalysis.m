function [newcell,outstr,assoc,pc]=lgncontrastanalysis(cksds,cell,...
		cellname,display)

%  LGNCONTRASTANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=LGNCONTRASTANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
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

newcell = cell;

phases = [];
assoclist = lgnassociatelist('Contrast test');

for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'protocol_LGN',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
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

f1curve_1Hz = [];
f1curve_4Hz = [];
f1curve_8Hz = [];

cntest = findassociate(newcell,'Contrast test','protocol_LGN',[]);
if ~isempty(cntest),
	s=getstimscripttimestruct(cksds,cntest(end).data);
	if ~isempty(s),
		if numStims(s.stimscript)>7,
			if display,
				where2.figure=figure;where3.figure=figure;
				orient(where2.figure,'landscape');
				orient(where3.figure,'landscape');
			end;
			thes1Hz.stimscript = []; thes1Hz.mti = [];
			thes4Hz.stimscript = []; thes4Hz.mti = [];
			thes8Hz.stimscript = []; thes8Hz.mti = [];
			inds1 = getpsstiminds(s.stimscript,{'tFrequency'},{1});
			[thes1Hz.stimscript,contrest,thes1Hz.mti,mtir]=...
				DecomposeScriptMTI(s.stimscript,s.mti,inds1);
			inds4 = getpsstiminds(contrest,{'tFrequency'},{4});
			[thes4Hz.stimscript,thes8Hz.stimscript,thes4Hz.mti,thes8Hz.mti]=...
				DecomposeScriptMTI(contrest,mtir,inds4);
			inp1.paramnames={'contrast'}; inp2.paramnames={'contrast'};
			inp3.paramnames={'contrast'}; inp1.title=['Contrast 1Hz ' cellname];
			inp2.title=['Contrast 4Hz ' cellname];
			inp3.title=['Contrast 8Hz ' cellname];
			inp1.spikes=newcell;inp2.spikes=newcell;inp3.spikes=newcell;
			inp1.st=thes1Hz;inp2.st=thes4Hz;inp3.st=thes8Hz;
			pc1=periodic_curve(inp1,'default',where1);
			pc2=periodic_curve(inp2,'default',where2);
			pc3=periodic_curve(inp3,'default',where3);
			tfs = [1 4 8]';
			o1=getoutput(pc1); o2=getoutput(pc2); o3=getoutput(pc3);
			[c501,Cmax1,cgain0_161,cgain16_1001,cgain0_321,cgain32_1001,nrg1,nr501,nrmax1]=...
					contraststuff(o1);
			[c504,Cmax4,cgain0_164,cgain16_1004,cgain0_324,cgain32_1004,nrg4,nr504,nrmax4]=...
					contraststuff(o2);
			[c508,Cmax8,cgain0_168,cgain16_1008,cgain0_328,cgain32_1008,nrg8,nr508,nrmax8]=...
					contraststuff(o3);
			f1curve_1Hz = o1.f1curve; f1curve_4Hz = o2.f1curve; f1curve_8Hz = o3.f1curve;
			NRgain = [ tfs [ nrg1; nrg4 ; nrg8 ] ];
			NRmax = [ tfs [ nrmax1 ; nrmax4; nrmax8] ];
			NR50 = [ tfs [ nr501 ; nr504; nr508;]];
			C50 = [ tfs [ c501; c504; c508]];
			CMax= [ tfs [Cmax1;Cmax4;Cmax8]];
			Cgain0_16 = [ tfs [ cgain0_161; cgain0_164; cgain0_168]];
			Cgain16_100 = [ tfs [ cgain16_1001; cgain16_1004; cgain16_1008]];
			Cgain0_32 = [ tfs [ cgain0_321; cgain0_324; cgain0_328]];
			Cgain32_100 = [ tfs [ cgain32_1001; cgain32_1004; cgain32_1008]];
			asc2=findassociate(cell,'TF Pref','protocol_LGN',[]);
			if ~isempty(asc2),
				[ii]=findclosest(tfs,asc2.data);
				C50_maxtf = C50(ii,2);
				CMax_tf = CMax(ii,2);
				Cgain0_16_maxtf = Cgain0_16(ii,2);
				Cgain16_100_maxtf = Cgain16_100(ii,2);
				Cgain0_32_maxtf = Cgain0_32(ii,2);
				Cgain32_100_maxtf = Cgain32_100(ii,2);
				themaxtf = tfs(ii);
				Cgain32MaxTFRatios = Cgain32_100_maxtf/Cgain0_32_maxtf;
				if ii==1, phases=angle(mean(o1.f1vals{1}));
				elseif ii==2, phases=angle(mean(o2.f1vals{1}));
				elseif ii==3, phases=angle(mean(o3.f1vals{1}));
				end;
			end;
		else,
			inp.paramnames = {'contrast'}; inp.title=['Contrast ' cellname];
			inp.spikes = newcell; inp.st = s;
			pp=getparameters(get(inp.st.stimscript,1));
			pc = periodic_curve(inp,'default',where1);
			p = getparameters(pc);
			p.graphParams(4).whattoplot = 6;
			pc = setparameters(pc,p);
			co = getoutput(pc);
			tfs = [ pp.tFrequency ];
			[c50,cMax,cgain0_16,cgain16_100,cgain0_32,cgain32_100,nrg,nr50,nrmax]=...
					contraststuff(getoutput(pc));
			NRgain = [ tfs nrg ]; NR50 = [tfs nr50 ]; NRmax = [tfs nrmax];
			C50 = [ tfs c50]; CMax =[ tfs cMax];
			Cgain0_16 = [ tfs cgain0_16]; Cgain16_100=[ tfs cgain16_100];
			Cgain0_32 = [ tfs cgain0_32]; Cgain32_100=[ tfs cgain32_100];
			disp(['just one contrast shown']);
            Cgain0_32_maxtf=cgain0_32;Cgain32_100_maxtf=cgain32_100;
			C50_maxtf=C50;CMax_tf=CMax;Cgain0_16_maxtf=cgain0_16;
			Cgain16_100_maxtf=cgain16_100;
			Cgain32MaxTFRatios = Cgain32_100_maxtf/Cgain0_32_maxtf;
			themaxtf = pp.tFrequency;
			phases=angle(mean(co.f1vals{1}));
		end;
		assoc(end+1)=struct('type','C50',...
				'owner','protocol_LGN','data',C50,'desc',...
				'Contrast at 50% max firing for each TF');
		assoc(end+1)=struct('type','Contrast Max rate',...
				'owner','protocol_LGN','data',CMax,'desc',...
				'Max firing for each TF');
		assoc(end+1)=struct('type','Cgain 0-16','owner','protocol_LGN',...
				'data',Cgain0_16,...
				'desc','Contrast gain from 0..16% at each TF');
		assoc(end+1)=struct('type','Cgain 16-100','owner','protocol_LGN',...
				'data',Cgain16_100,...
				'desc','Contrast gain from 16..100% at each TF');
		assoc(end+1)=struct('type','Cgain 0-32','owner','protocol_LGN',...
				'data',Cgain0_32,...
				'desc','Contrast gain from 0..32% at each TF');
		assoc(end+1)=struct('type','Cgain 32-100','owner','protocol_LGN',...
				'data',Cgain32_100,...
				'desc','Contrast gain from 32..100% at each TF');
		assoc(end+1)=struct('type','Contrast at Max TF',...
				'owner','protocol_LGN','data',...
				[C50_maxtf CMax_tf Cgain0_16_maxtf Cgain16_100_maxtf ...
				 Cgain0_32_maxtf  Cgain32_100_maxtf themaxtf],...
				 'desc','Contrast parameters at Max TF');
		assoc(end+1)=struct('type','CGain32Ratio','owner','protocol_LGN',...
			'data',Cgain32MaxTFRatios,'desc',...
			'Ratio of 32-100% gain at max tf to 0-32 gain');
		assoc(end+1)=struct('type','Naka-Rushton gain','owner','protocol_LGN',...
			'data',NRgain,'desc','Naka-Rushton gain, Rm/b');
		assoc(end+1)=struct('type','Naka-Rushton max','owner','protocol_LGN',...
			'data',NRmax,'desc','Naka-Rushton max');
		assoc(end+1)=struct('type','Naka-Rushton 50','owner','protocol_LGN',...
			'data',NR50,'desc','Naka-Rushton 50% point');
		assoc(end+1)=struct('type','Contrast F1 1Hz','owner','protocol_LGN',...
			'data',f1curve_1Hz,'desc','Contrast F1 1Hz');
		assoc(end+1)=struct('type','Contrast F1 4Hz','owner','protocol_LGN',...
			'data',f1curve_4Hz,'desc','Contrast F1 4Hz');
		assoc(end+1)=struct('type','Contrast F1 8Hz','owner','protocol_LGN',...
			'data',f1curve_8Hz,'desc','Contrast F1 8Hz');
		assoc(end+1)=struct('type','Contrast phases','owner','protocol_LGN',...
			'data',phases,'desc','Phases at best contrast');
	end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i));end;

outstr.C50= C50; outstr.CMax = CMax; outstr.Cgain0_16= Cgain0_16;
outstr.Cgain16_100 = Cgain16_100; outstr.NRgain=NRgain;outstr.NR50=NR50;outstr.NRmax=NRmax;

function [c50,Cmax,cgain0_16,cgain16_100,cgain0_32,cgain32_100,nrg,nr50,nrmax]=contraststuff(c)
[nrmax,nr50]=naka_rushton(c.f1curve{1}(1,:),abs(c.f1vals{1}));
nrg=nrmax/(nr50*100);
xx=0:0.01:1;
yy=interp1(c.f1curve{1}(1,:),c.f1curve{1}(2,:),xx,'linear');
[Cmax,i] = max(yy);
[c50,j] = findclosest(yy,Cmax/2); c50 = c50/100;
x=c.f1curve{1}(1,:);y=abs(c.f1vals{1});x_=x;x=repmat(x,size(y,1),1);
e16 = findclosest(x_,0.16);
x16 = reshape(x(:,1:e16),1,prod(size(x(:,1:e16))))';
y16 = reshape(y(:,1:e16),1,prod(size(y(:,1:e16))))';
cgain0_16 = regress(y16,x16);
mean16=c.f1curve{1}(2,e16);
e32 = findclosest(x_,0.32);
x32 = reshape(x(:,1:e32),1,prod(size(x(:,1:e32))))';
y32 = reshape(y(:,1:e32),1,prod(size(y(:,1:e32))))';
cgain0_32 = regress(y32,x32);
mean32=c.f1curve{1}(2,e32);
e100 = findclosest(x_,1);
x100_16 = reshape(x(:,e16:e100),1,prod(size(x(:,e16:e100))))' - 0.16;
y100_16 = reshape(y(:,e16:e100),1,prod(size(y(:,e16:e100))))' - mean16;
cgain16_100 = regress(y100_16,x100_16);
x100_32 = reshape(x(:,e32:e100),1,prod(size(x(:,e32:e100))))' - 0.32;
y100_32 = reshape(y(:,e32:e100),1,prod(size(y(:,e32:e100))))' - mean32;
cgain32_100 = regress(y100_32,x100_32);

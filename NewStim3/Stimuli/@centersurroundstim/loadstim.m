function [outstim] = loadstim(CSSstim)

disp(['got here in centersurroundstim']);

CSSstim = unloadstim(CSSstim);
outstim = CSSstim;

if haspsychtbox,

   StimWindowGlobals;
   NewStimGlobals;

   CSSparams = CSSstim.CSSparams; 
   dfs = struct(getdisplayprefs(CSSstim));
   tRes = (1/StimWindowRefresh);
   fps = StimWindowRefresh;
   biggestrad = max([CSSparams.radius CSSparams.surrradius]);
   hasSurround = CSSparams.surrradius>=0;
   bigRad = biggestrad; if bigRad==0,bigRad=1; end;
   if NS_PTBv<3,
	   offscreen = Screen(-1,'OpenOffscreenWindow',255,2*bigRad*[0 0 1 1]);
   else,
	   offscreen = Screen('MakeTexture',StimWindow,0*ones(2*bigRad));
   end;
   if hasSurround,
     Screen(offscreen,'FillOval',2,biggestrad+CSSparams.surrradius*[-1 -1 1 1]);
   end;
   if CSSparams.radius>0,
     Screen(offscreen,'FillOval',1,biggestrad+CSSparams.radius*[-1 -1 1 1]);
   end;
   middle=mean([CSSparams.FGc;CSSparams.FGs])/255;
   fgc=round(255*(middle+CSSparams.contrast*(CSSparams.FGc/255-middle)));
   fgs=round(255*(middle+CSSparams.contrast*(CSSparams.FGs/255-middle)));

   ctab{1} = repmat(CSSparams.BG,256,1);
   ctab{2} = [CSSparams.BG; fgc; repmat(CSSparams.BG,254,1)];
   ctab{3} = [CSSparams.BG; fgs; fgs;  repmat(CSSparams.BG,253,1)];
   ctab{4} = [CSSparams.BG; fgc; fgs; repmat(CSSparams.BG,253,1)];
   frames=ones(1,ceil(CSSparams.stimduration/tRes));
   start = max([1 1+round(CSSparams.lagon/tRes)]);
   if CSSparams.lagoff>0, stop=min([length(frames) 1+round(CSSparams.lagoff/tRes)]);
   else, stop = length(frames); end;
   sstart = max([1 1+round(CSSparams.surrlagon/tRes)]);
   if CSSparams.surrlagoff>0,
      sstop=min([length(frames) 1+round(CSSparmas.surrlagoff/tRes)]);
   else, sstop = length(frames); end;
   frames(start:stop)=2; frames(sstart:sstop)=3;
   frames(intersect(start:stop,sstart:sstop))=4;

   rect = [ CSSparams.center-biggestrad CSSparams.center+biggestrad ];
   dP = cat(2,{'fps',fps,'rect',dfs.rect,'frames',frames},CSSparams.dispprefs);
   dS = { 'displayType', 'CLUTanim', 'displayProc', 'standard', ...
         'offscreen', offscreen, 'frames', size(ctab,2), ...
		 'clut_usage', repmat(1,256), 'depth', 8, ...
		 'clut_bg', ctab{1}, 'clut', ctab, 'clipRect', [], ...
		 'makeClip', 0,'userfield',[] }; 
		 
  outstim.stimulus = setdisplaystruct(outstim.stimulus,displaystruct(dS));
  outstim.stimulus = setdisplayprefs(outstim.stimulus,displayprefs(dP));
end;

outstim.stimulus = loadstim(outstim.stimulus);

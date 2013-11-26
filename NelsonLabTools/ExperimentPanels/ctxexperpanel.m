function ctxexperpanel(cbo, fig)
% written by Alexander Heimel
% based on lgnexperpanel by Stephen Van Hooser
% Nelson lab, Brandeis
%
% if cbo is text, then is command; else, the tag is used as command
% if fig is given, it is used; otherwise, callback figure is used
%
% STILL TO DO/ADD/CHANGE/THINK ABOUT
% STIMULI
% - introduce pause in SGS
% - color sgs
% - line response instead of phase
% - check colors of cone isolating stimuli
% ANALYSIS/PANEL
% - copy monitor and optic disk from previous
% - calculate cone opponency
% - save REPS, ISI
% - set feature mean in SGS analysis to 64 (or appropriate value)
% - put receptive field graph in periodic curve
% - add receptive field to associations
% - show picture with receptive field
% - remark when starting OT and parameters are not base parameters
%  
% BUGS
% - divide by zero in ctxphaseanalysis  (line 116)
  
% MADE CHANGES
% 2003-02-25: avoided divide by zero in ctxsfanalysis 
% 2003-02-25: implemented choice between cone- and photoreceptor isolating stimuli 
% 2003-04-13: implemented position,length,width stimuli
% 2003-04-14: add 1.2 cpd to default SF tests and changed 0.05 to 0.04 to
%             break scaling symmetry
% 2003-05-01: enlarged width and length tuning range
% 2003-05-06: fixed saving of TFResp properties
% 2003-05-28: changed phasetest range to 2 pi
% 2003-05-28: extended SF range to include 0.015 and 0.15
% 2003-06-19: added spontaneous rate caption for Phase Test
% 2003-06-23: added color stimulus to determine cone balance
% 2003-07-03: added DOG interpolations to SF compare function
% 2003-07-07: fitted Von Misen to orientation tuning curves
% 2003-09-08: added VEP test for depth determination
% 2003-09-14: display 'VEP Test'
% 2003-09-15: changed asc.data to asc(end).data in display_associate
% 2003-10-06: moved 0.5 s of pretime to posttime in color balance test
  
squirrelcolor;

global ctx_databaseNLT;

if nargin==0, % open new figure and draw it
  z = geteditor('RunExperiment');
  if isempty(z)
    errordlg('Needs an experiment to run tests.');
    return;
  end;
  z2= geteditor('screentool');
  if isempty(z2),
    %errordlg('Needs screentool to run tests.');
    %return;
    z2=figure;
    screentool(z2);
  end;
  [cr] = getscreentoolparams;
  if isempty(cr),
    %errordlg('Needs good current rect in screentool.');
    %return;
    udz = get(z2,'userdata');
    set(udz.currrect,'String',mat2str(round(20*[-1 -1 1 1]+...
					    [320 240 320 240] )));
    screentool('plotcurr',z2);
  end;
  cksds = getcksds;
  if isempty(cksds), errordlg(['No existing data---make sure you hit '...
		    'return after directory in RunExperiment window']);
    return;
  end; % now we're sure we've got it or returned
  answ = questdlg('Use an existing record or one that is to be acquired?',...
                  'Existing or acquired',...
                  'Existing record','To be acquired','Cancel');
  if strcmp(answ,'Existing record'),
    nrs = getallnamerefs(cksds);
    str = {};
    for i=1:length(nrs),
      str = cat(2,str,{[ nrs(i).name ' | ' int2str(nrs(i).ref)]});
    end;
    [s,v] = listdlg('PromptString','Select a name | ref',...
		    'SelectionMode','single','ListString',str);
    if v==0, return;
    else, nameref = nrs(s); end;
  elseif strcmp(answ,'To be acquired'), % new record
    udre = get(z,'userdata');
    udre2 = get(udre.list_aq,'userdata');
    if isempty(udre2),
      errordlg('Needs an aquisition record to run tests.'); return;
    else,
      str = {};
      for i=1:length(udre2),
	str = cat(2,str,{[ udre2(i).name ' | ' int2str(udre2(i).ref)]});
      end;
      [s,v] = listdlg('PromptString','Select a name | ref',...
		      'SelectionMode','single','ListString',str);
      if v==0, return;
      else, nameref = struct('name',udre2(s).name,'ref',udre2(s).ref); end;
    end;
  end;
  h1 = drawfig;
  [tef,expf] = getexperimentfile(cksds);
  filldefaults(h1,nameref,expf);
else,  % respond to command
  if nargin==2, thefig = fig; else, thefig = gcbf; end;
  if isa(cbo,'char'), thetag=cbo; else, thetag = get(cbo,'Tag'); end;
  ud = get(thefig,'userdata');
  cksds = getcksds;
  if isempty(cksds),
    errordlg('Cannot find directory structure in RunExperiment.');
  end;
  switch thetag,
   case 'AddDB',
    try,
      ctxexperpanel('SaveBt');
      cksds = getcksds(1);
      c = getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat');
      eval([c{1} '=getfield(data,c{1});']);
      if exist(ctx_databaseNLT)==2,
	save(ctx_databaseNLT,c{1},'-append','-mat');
      else, save(ctx_databaseNLT,c{1},'-mat'); end;
	disp([c{1} ' added to database']);
    catch, errordlg(['Could not export:' lasterr]); end;
   case 'SaveBt', % formerly ExportNameRefBt
    bts = {'DetailCB','RCCB','RC1CB','RC2CB','RCRespCB','CentSizeCB',...
	   'CentSizeRespCB',...
	   'ConeCB','ConeRespCB','OTCB',...
	   'bw SFCB','equilum SFCB','green SFCB','blue SFCB',...
	   'TFCB','ContrastCB','PhaseCB',...
	   'ConeRespCB',...
	   'PosCB','LengthCB','WidthCB','ColorCB','VEPCB'};
    good = 1;
    try, 
      for i=1:length(bts), ctxexperpanel(bts{i},thefig); end;
    catch, errordlg(['Cannot export - ' bts{i} ' not ready.']); good=0;
    end;
    try, c=getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat');
      data = getfield(data,c{1});
    catch, 
      errordlg(['Could not load cell data.']); good = 0; 
    end;
    if good,
      ctxexperpanel('OldSaveBt',thefig);
      ud = get(thefig,'userdata'); cksds=getcksds;
      mods = {'Details','RCResp','CentSizeResp','ConeResp','OTResp',...
	      'bw SFResp','equilum SFResp','green SFResp','blue SFResp',...
	      'TFResp','ContrastResp',...
	      'FDTResp','PhaseResp','Misc',...
	      'PosResp','LengthResp','WidthResp','ColorResp',...
	     'VEPResp'};
      
      for i=1:length(mods),
	g = findinfoinlist(thefig,mods{i});
	if ~isempty(g),
	  disp(['Saving ' mods{i}]);
	  info = ud.infolist{g};
	  if isfield(info,'associate'),
	    for j=1:length(info.associate),
	      % delete any earlier associate of same type
	      [a,I]=findassociate(data,info.associate(j).type,...
				  'protocol_CTX',[]);
	      if ~isempty(I), data=disassociate(data,I); end;
	      data=associate(data,info.associate(j));
	    end;
	  end;
	end;
      end;
      % now save changes
      saveexpvar(cksds,data,c{1},0);
    end;
   case 'OldSaveBt',
    bts = {'DetailCB','RCCB','RC1CB','RC2CB','RCRespCB','CentSizeCB',...
	   'CentSizeRespCB',...
	   'ConeCB','ConeRespCB','OTCB',...
	   'bw SFCB','equilum SFCB','green SFCB','blue SFCB',...
	   'TFCB','ContrastCB','PhaseCB','ConeRespCB',...
	   'PosCB','LengthCB','WidthCB','ColorCB','VEPCB'};
    numbuts = 0;
    try,
      for i=1:length(bts),
	ctxexperpanel(bts{i},thefig);
	if get(ft(thefig,bts{i}),'value'),numbuts=numbuts+1; end;
      end;
    catch, 
      errordlg(['Cannot save - ' bts{i} ' not ready.']); 
      return;
    end;
    if numbuts==0,
      btname=questdlg('Nothing is checked--save anyway?',...
		      'Really save','Yes','No','Cancel');
      if strcmp(btname,'No')|strcmp(btname,'Cancel'), return; end;
    end;
    ud = get(thefig,'userdata');
    g = findinfoinlist(thefig,'Misc'); % remove old data
    ud.infolist = ud.infolist(setxor(1:length(ud.infolist),g));
    sn = get(ft(thefig,'VarNameEdit'),'String');
    newinfo.sn=sn;
    newinfo.onegoodtest = get(ft(thefig,'GoodCB'),'value');
    newinfo.CTXlayer = get(ft(thefig,'CTXLayerPopup'),'value');
    newinfo.isolation = get(ft(thefig,'IsolationPopup'),'value');
    newinfo.comments = get(ft(thefig,'CommentsEdit'),'String');
    newinfo.css = ud.css; newinfo.SGS = ud.SGS; newinfo.PS = ud.PS;
    newinfo.SGS2 = ud.SGS2;
    newinfo.nameref = ud.nameref;
    newinfo.name = 'Misc';
    newinfo.associate = [];
    v   = get(ft(thefig,'CTXLayerPopup'),'value');
    vls = get(ft(thefig,'CTXLayerPopup'),'String');
    vls3= get(ft(thefig,'IsolationPopup'),'String');
      if newinfo.CTXlayer~=1,
	newinfo.associate(end+1)=...
	    struct('type','CTX Layer',...
		   'owner','protocol_CTX',...
		   'data',vls{v},'desc',...
		   'CTX layer as identified by histology');
      end;
      if newinfo.isolation~=1,
	newinfo.associate(end+1)=...
	    struct('type','Unit isolation',...
		   'owner','protocol_CTX',...
		   'data',vls3{newinfo.isolation},'desc',...
		   'Quality of unit isolation as determined by experimenter');
      end;
      if ~isempty(newinfo.comments),
	newinfo.associate(end+1)=...
	    struct('type','Comments',...
		   'owner','protocol_CTX',...
		   'data',newinfo.comments,'desc','Comments');
      end;
      ud.infolist(end+1) = {newinfo};
      set(thefig,'userdata',ud);
      infolist = ud.infolist;
      try,
	%          eval([sn '=infolist;']);
	%          ef=getexperimentfile(cksds,1);
	saveexpvar(cksds,infolist,sn);
	disp('saved exp variable');
	%          try, eval(['save ' ef ' ' sn ' -append -mat']);
	%          catch,  eval(['save ' ef ' ' sn ' -mat']); end;
      catch, errordlg(['Error in saving: ' lasterr ]);
      end;
      disp('Saved');
   case 'RestoreMisc',
    g = findinfoinlist(thefig,'Misc');
    if ~isempty(g),
      info = ud.infolist{g};
      ud.SGS = info.SGS; ud.css = info.css; ud.PS = info.PS;
      if isfield(info,'SGS2'),ud.SGS2 = info.SGS2; end;
      set(thefig,'userdata',ud);
      set(ft(thefig,'GoodCB'),'value',info.onegoodtest);
      set(ft(thefig,'CTXLayerPopup'),'value',info.CTXlayer);
      if isfield(info,'isolation'),
	  set(ft(thefig,'IsolationPopup'),'value',info.isolation);
      end;
      set(ft(thefig,'CommentsEdit'),'String',info.comments);
      set(ft(thefig,'NameRefText'),'String',...
			[info.nameref.name ' | ' int2str(info.nameref.ref) ]);
      set(ft(thefig,'VarNameEdit'),'String',info.sn);
    end;
   case 'SG1EditBt',
    SGS = ud.SGS;
    newSG = stochasticgridstim('graphical',SGS);
    if ~isempty(newSG),
      [cr,dist,sr]=getscreentoolparams;
      newSG = recenterstim(newSG,{'rect',cr,'screenrect',sr,'params',1});
      ud.SGS = newSG;
      set(thefig,'userdata',ud);
    end;
   case 'SG2EditBt',
    SGS2 = ud.SGS2;
    newSG2 = stochasticgridstim('graphical',SGS2);
    if ~isempty(newSG2),
      [cr,dist,sr]=getscreentoolparams;
      newSG2 = recenterstim(newSG2,{'rect',cr,'screenrect',sr,'params',1});
      ud.SGS2 = newSG2;
      set(thefig,'userdata',ud);
    end;
   case 'CentSizeEditBt',
    css = ud.css;
    newcss = centersurroundstim('graphical',css);
    ud.css = newcss;
    set(thefig,'userdata',ud);
   case 'GratingEditBaseBt',
    PS = ud.PS;
    newPS = periodicscript('graphical',PS);
    if ~isempty(newPS),
      [cr,dist,sr]=getscreentoolparams;
      newPS = recenterstim(newPS,{'rect',cr,'screenrect',sr,'params',1});
      ud.PS = newPS;
      set(thefig,'userdata',ud);
    end;

   case 'UseConeIsolatingBt'
    set_cone_isolating(thefig);
   case 'UsePRIsolatingBt'
    set_PR_isolating(thefig);
    
    
   case 'GratingResetBaseBt',
     btn=questdlg('Are you sure?','Resetting stimulus','Yes','No', ...
		  'No');
     if strcmp(btn,'Yes')
       ud=get(thefig,'userdata');
       PS = baseperiodicscript;
       ud.PS = PS;
       set(thefig,'userdata',ud);
     end
     
   case 'DetailCB',
    g = findinfoinlist(thefig,'Details');
    ud.infolist=ud.infolist(setxor(1:length(ud.infolist),g));
    set(thefig,'userdata',ud);
    val = get(ft(thefig,'DetailCB'),'value');
    if val==1, % a change from 0 to 1
      notgood = 0;
      taglist={'RightVertEdit','LeftVertEdit',...
	       'LeftHortEdit',...
	       'RightHortEdit','DepthEdit','MonXEdit','MonYEdit',...
	       'MonZEdit','PosEdit','DiameterEdit'};
      varlist={'RightVert','LeftVert','LeftHort','RightHort','Depth',...
	       'MonX (cm)','MonY (cm)','MonZ (cm)','Position','Diameter'};
      szlist={[1 1],[1 1],[1 1],[1 1],[1 1],[1 1],[1 1],[1 1],[1 2],[1 2]};
      if islistfilledin(thefig,taglist),
	[b,vals] = checksyntaxsize(thefig,taglist,szlist,1,varlist);
	if b,
	  v = get(ft(thefig,'EyePopup'),'value');
	  if v==1,
	    errordlg('Eye popup must be filled in.'); notgood = 1;
	  else,  % we're good, add
	    
	    % calc RF location
	    % translate to monitor 0,0
	    NewStimGlobals; % for NewStimPixelsPerCm
	    
	    cent=vals{9};
	    x=vals{6}-18.0975+cent(1)/NewStimPixelsPerCm;
	    y=vals{7}; 
	    z=vals{8}+32.0675-cent(2)/NewStimPixelsPerCm;
	    rf = [atan(x/y) atan(z/y)]*180/pi;
	    % FAULTY CALCULATION SHOULD BE sqrt(y^2+z^2) instead of y
	    set(ft(thefig,'RFpos'),'String',mat2str(rf,3),...
			      'userdata',rf);
	    diameter = vals{10};
	    lefttoright=(atan( (x+diameter(2)/2/NewStimPixelsPerCm)/y) ...
		- atan( (x-diameter(2)/2/NewStimPixelsPerCm)/y))*180/pi;
	    toptobottom=(atan( (z+diameter(1)/2/NewStimPixelsPerCm)/y) ...
		- atan( (z-diameter(1)/2/NewStimPixelsPerCm)/y))*180/pi;
	    diadeg = [lefttoright toptobottom];
	    
	    set(ft(thefig,'RFdiameter'),'String',mat2str(diadeg,3),...
			      'userdata',diadeg);

	    
	    newinfolist = cell2struct(vals,taglist,2);
	    newinfolist.eye = v;
	    newinfolist.name = 'Details';
	    newinfolist.rfpos=rf;
	    newinfolist.rfdiameter=diadeg;
	    % prepare associations
	    opticDisk.RightVert = newinfolist.RightVertEdit;
	    opticDisk.LeftVert = newinfolist.LeftVertEdit;
	    opticDisk.RightHort = newinfolist.RightHortEdit;
	    opticDisk.LeftHort = newinfolist.LeftHortEdit;
	    newinfolist.associate =...
		struct('type','optic disk location',...
		       'owner','protocol_CTX','data',opticDisk,...
		       'desc','Optic disk locations (in degrees).');
	    vls = get(ft(thefig,'EyePopup'),'String');
	    v=get(ft(thefig,'EyePopup'),'value');
	    newinfolist.associate(2) = ...
		struct('type','Dominant eye',...
		       'owner','protocol_CTX',...
		       'data',vls{v},'desc','Dominant eye');
	    newinfolist.associate(3) = ...
		struct('type','Electrode depth',...
		       'owner','protocol_CTX',...
		       'data',newinfolist.DepthEdit','desc',['Electrode' ...
		    ' depth']);
	    newinfolist.associate(4) =...
		struct('type','RF position','owner','protocol_CTX',...
		       'data',rf,'desc','RF position in degrees');
	    newinfolist.associate(5) =...
		struct('type','RF diameter','owner','protocol_CTX',...
		       'data',diadeg,'desc','RF diameter in degrees');
	    
	    
	    ud.infolist(end+1) = {newinfolist};
	    set(thefig,'userdata',ud);
	  end;
	else, notgood = 1;
	end;
      else, notgood = 1;
      end;
      if notgood, set(ft(thefig,'DetailCB'),'value',0); end;
    elseif val==0,  % a change from 1 to 0
    end;
   case 'RestoreDetails',
    g = findinfoinlist(thefig,'Details');
    if ~isempty(g),
      info = ud.infolist{g};
      taglist={'RightVertEdit','LeftVertEdit',...
	       'LeftHortEdit',...
	       'RightHortEdit','DepthEdit','MonXEdit','MonYEdit',...
	       'MonZEdit','PosEdit','DiameterEdit'};
      varlist={'RightVert','LeftVert','LeftHort','RightHort','Depth',...
	       'MonX (cm)','MonY (cm)','MonZ (cm)','Position','Diameter'};
      for i=1:length(taglist),
	try
	  set(ft(thefig,taglist{i}),...
	      'String',mat2str(getfield(info,taglist{i})));
	catch
	  errordlg(['Could not restore:' taglist{i}]);
	end
      end;
      set(ft(thefig,'EyePopup'),'value',info.eye);
      set(ft(thefig,'DetailCB'),'value',1);
      try
	set(ft(thefig,'RFpos'),'string',mat2str(info.rfpos,3));
	set(ft(thefig,'RFdiameter'),'string',mat2str(info.rfdiameter,3));
      catch
	errordlg(['Could not restore receptive field location']);
      end
    end;
   case 'RCRespCB',
    val = get(ft(thefig,'RCRespCB'),'value');
    g = findinfoinlist(thefig,'RCResp'); % remove old data
    ud.infolist = ud.infolist(setxor(1:length(ud.infolist),g));
    set(thefig,'userdata',ud);
    if val==1, % a change from 0 to 1
      notgood = 0;
      taglist = {'RCCenterLocEdit','MonXEdit','MonYEdit','MonZEdit'};
      varlist={'CenterLocation','MonX (cm)','MonY (cm)','MonZ (cm)'};
      [b,vals]=checksyntaxsize(thefig,taglist,{[1 2],[1 1],[1 1],[1 1]},...
			       1,varlist);
      if b,
	v = get(ft(thefig,'CenterPopup'),'value');
	if v==1, errordlg('CenterPopup must be filled in.'); notgood=1;
	else, % we're good
	  NewStimGlobals;
	  cent = vals{1};
	  % calc RF location
	  % translate to monitor 0,0
	  x=vals{2}-18.0975+cent(1)/NewStimPixelsPerCm;
	  y=vals{3}; z=vals{4}+32.0675-cent(2)/NewStimPixelsPerCm;
	  rf = [atan(x/y) atan(z/y)]*180/pi;
	  set(ft(thefig,'RFText'),'String',['RF: ' mat2str(rf,4)],...
			    'userdata',rf);
	  try,
	    % update css
	    p = getparameters(ud.css);
	    p.center = cent;
	    switch v,
	     case {3,4}, % white or neither, use white on black,
	      p.FGc = squirrel_white'; p.FGs = [ 0 0 0 ];
	      p.BG  = [ 0 0 0 ]; p.surrradius = -1;
	     case 2, % black on white
	      p.FGc = [0 0 0]; p.FGs = squirrel_white';
	      p.BG  = squirrel_white'; p.surrradius = -1;
	    end;
	    css = centersurroundstim(p);
	    ud.css = css;
	    
	    % add info to list
	    newinfolist = cell2struct(vals(1),varlist(1));
	    vls = get(ft(thefig,'CenterPopup'),'String');
	    newinfolist.centerval  = vls{v};
	    newinfolist.rf = rf;
	    newinfolist.name = 'RCResp';
	    newinfolist.rclatency = get(ft(thefig,'RCLatencyText'),'userdata');
	    newinfolist.rctransience= get(ft(thefig,'RCTransienceText'),...
					  'userdata');
	    % prepare associations
	    newinfolist.associate = [];
	    if get(ft(thefig,'RC1CB'),'value'),
	      newinfolist.associate(end+1)=...
		  struct('type','RC coarse test',...
			 'owner','protocol_CTX',...
			 'data',get(ft(thefig,'RC1TestEdit'),'String'),...
			 'desc','Test number string for RC coarse test');
	    end;
	    if get(ft(thefig,'RC2CB'),'value'),
	      newinfolist.associate(end+1)=...
		  struct('type','RC fine test',...
			 'owner','protocol_CTX',...
			 'data',get(ft(thefig,'RC2TestEdit'),'String'),...
			 'desc','Test number string for RC fine test');
	    end;
	    if ~isempty(newinfolist.rclatency),
               newinfolist.associate(end+1)=...
		   struct('type','reverse correlation latency test',...
			  'owner','protocol_CTX',...
			  'data',get(ft(thefig,'RCLatencyText'),'userdata'),...
			  'desc',...
			  ['Latency as determined by reverse correlation' ...
			   ' analysis']);
	    end;
	    if ~isempty(newinfolist.rctransience),
	      newinfolist.associate(end+1)=...
		  struct('type','reverse correlation transience test',...
			 'owner','protocol_CTX','data',...
			 get(ft(thefig,'RCTransienceText'),'userdata'),...
			 'desc',...
			 ['Transcience as determined by reverse'...
			  ' correlation analysis']);
	    end;
	    newinfolist.associate(end+1)=...
		struct('type','RF location',...
		       'owner','protocol_CTX','data',rf,...
		       'desc','RF location');
	    ud.infolist(end+1) = {newinfolist};
	    set(thefig,'userdata',ud);
	    set(ft(thefig,'RCRespCB'),'value',1);
	  catch,
	    errordlg(['Error in updating centersurroundstim: ' lasterr]);
	    notgood = 1;
	  end; 
	end;
      else, notgood = 1;
      end;
      if notgood, set(ft(thefig,'RCRespCB'),'value',0); end;
    elseif val==0, % a change from 1 to 0 
    end;
   case 'RestoreRCResp',
    g = findinfoinlist(thefig,'RCResp');
    if ~isempty(g),
      info = ud.infolist{g};
      set(ft(thefig,'RCCenterLocEdit'),...
	  'String',mat2str(info.CenterLocation));
      set(ft(thefig,'RFText'),'String',['RF: ' mat2str(info.rf,4)], ...
			'userdata',info.rf);
      set(ft(thefig,'RCLatencyText'),'String',num2str(info.rclatency),...
			'userdata',info.rclatency);
      set(ft(thefig,'RCTransienceText'),'String',num2str(info.rctransience),...
			'userdata',info.rctransience);
      vls = get(ft(thefig,'CenterPopup'),'String');
      for i=1:length(vls),
	if strcmp(vls{i},info.centerval),
	  set(ft(thefig,'CenterPopup'),'value',i);
	end;
      end;
      set(ft(thefig,'RCRespCB'),'value',1);
    end;
   case 'ScreenToolBt'
    z = geteditor('screentool');
    if ~isempty(z),
      figure(z);
      screentool('plotcurr',z);
    else, 
      errordlg('Could not find screentool.');
    end;
   case 'GetCenterBt'
    z = geteditor('screentool');
    if ~isempty(z),
      udz=get(z,'userdata');
      currrect=eval(get(udz.currrect,'String'));
      pos=round([currrect(3)+currrect(1) currrect(4)+currrect(2)]/2);
      diameter=[currrect(3)-currrect(1) currrect(4)-currrect(2)];
      set(ft(thefig,'PosEdit'),'String',mat2str(pos));
      set(ft(thefig,'DiameterEdit'),'String',mat2str(diameter));
    else, 
      errordlg('Could not find screentool.');
    end;
   case 'SetCenterBt',
    z = geteditor('screentool');
    if ~isempty(z),
      taglist = {'RCCenterLocEdit'};varlist={'Center location'};
      [b,vals] = checksyntaxsize(thefig,taglist,{[1 2]},1,varlist);
      if b,
	udz = get(z,'userdata');
	set(udz.currrect,'String',mat2str(round(20*[-1 -1 1 1]+...
						vals{1}([1 2 1 2]))));
	figure(z);
	screentool('plotcurr',z);
      end;
    else, errordlg('Could not find screentool.');
    end;
   case 'CentSizeRespCB',
    val=get(ft(thefig,'CentSizeRespCB'),'value');
    g = findinfoinlist(thefig,'CentSizeResp');
    ud.infolist = ud.infolist(setxor(1:length(ud.infolist),g));
    set(thefig,'userdata',ud);
    if val==1, % a change from 0 to 1
      notgood = 0;
      taglist = {'CenterSizeEdit'}; varlist = {'Centersize'};
      [b,vals] = checksyntaxsize(thefig,taglist,{[1 1]},1,varlist);
      if b,
	newinfolist=struct('name','CentSizeResp');
	newinfolist.associate=struct('type','t','owner','t','data',0,'desc',0);
	newinfolist.associate = newinfolist.associate([]); 
	% make empty
	% ensure that most recently entered test string is the one saved
	if get(ft(thefig,'CentSizeCB'),'value'),
	  newinfolist.associate(end+1)=...
	      struct('type','Cent Size test',...
		     'owner','protocol_CTX',...
		     'data',get(ft(thefig,'CentSizeTestEdit'),'String'),...
		     'desc','Test number string for cent size test');
	end;
	newassocs = get(ft(thefig,'CSLatencyText'),'userdata');
	if ~isempty(newassocs),
	  newinfolist.associate(end+1)=...
	      struct('type','Has surround',...
		     'owner','protocol_CTX',...
		     'data',get(ft(thefig,'HasSurroundCB'),'value'),...
		     'desc','Does cell have inhibitory surround?');
	  newinfolist.associate = [newinfolist.associate newassocs];
	end;
	ud.infolist(end+1) = {newinfolist};
	set(thefig,'userdata',ud);
      else, notgood =1;
      end;
      if notgood, set(ft(thefig,'CentSizeRespCB'),'value',0); end;
    elseif val==0, % a change from 1 to 0
    end;
   
   case 'RestorePhaseResp'
    g = findinfoinlist(thefig,'PhaseResp');
    if ~isempty(g),
      cksds=getcksds(1); 
      c=getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat');
      cell=getfield(data,c{1});
      display_phase_info(cell,thefig);
    end
   case 'RestorePosResp'
    g = findinfoinlist(thefig,'PosResp');
    if ~isempty(g),
      cksds=getcksds(1); 
      c=getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat');
      cell=getfield(data,c{1});
      display_pos_info(cell,thefig);
    end
    case 'RestoreLengthResp'
    g = findinfoinlist(thefig,'LengthResp');
    if ~isempty(g),
      cksds=getcksds(1); 
      c=getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat');
      cell=getfield(data,c{1});
      display_length_info(cell,thefig);
    end
   case 'RestoreWidthResp'
    g = findinfoinlist(thefig,'WidthResp');
    if ~isempty(g),
      cksds=getcksds(1); 
      c=getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat');
      cell=getfield(data,c{1});
      display_width_info(cell,thefig);
    end
   case 'RestoreColorResp'
    g = findinfoinlist(thefig,'ColorResp');
    if ~isempty(g),
      cksds=getcksds(1); 
      c=getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat');
      cell=getfield(data,c{1});
      display_color_info(cell,thefig);
    end
  
   case 'RestoreCentSizeResp',
    g = findinfoinlist(thefig,'CentSizeResp');
    if ~isempty(g),
      info = ud.infolist{g};
      cksds=getcksds(1); c=getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat');cell=getfield(data,c{1});
      asc=findassociate(cell,'Center size','protocol_CTX',[]);
      if ~isempty(asc),
	NewStimGlobals;
	set(ft(thefig,'CenterSizeEdit'),'String',...
			  num2str(asc.data*NewStimPixelsPerCm));
      else, set(ft(thefig,'CenterSizeEdit'),'String','');
      end;
      asc=findassociate(cell,'Has surround','protocol_CTX',[]);
      if ~isempty(asc),
	set(ft(thefig,'HasSurroundCB'),'value',asc.data);
      else, set(ft(thefig,'HasSurroundCB'),'value',0); end;
	asc=findassociate(cell,'Center latency test','protocol_CTX',[]);
	if ~isempty(asc),
	  set(ft(thefig,'CSLatencyText'),'String',num2str(asc.data));
	else, set(ft(thefig,'CSLatencyText'),'String',''); end;
          asc=findassociate(cell,'Center transience test','protocol_CTX',[]);
	  if ~isempty(asc),
	    set(ft(thefig,'CSTransienceText'),'String',asc.data);
	  else, set(ft(thefig,'CSTransienceText'),'String',''); end;
	    asc=findassociate(cell,'Cent Size Params','protocol_CTX',[]);
	    if ~isempty(asc),
	      set(ft(thefig,'CentSizeAnalEdit'),'String',asc.data.evalint);
	      set(ft(thefig,'CSEarlyEdit'),'String',asc.data.earlyint);
	      set(ft(thefig,'CSLateEdit'),'String',asc.data.lateint);
	    else, set(ft(thefig,'CentSizeAnalEdit'),'String','[0 0.1]');
	      set(ft(thefig,'CSEarlyEdit'),'String','');
	      set(ft(thefig,'CSLateEdit'),'String','');
	    end;
	    asc=findassociate(cell,'Sustained/Transient response',...
			      'protocol_CTX',[]);
	    if ~isempty(asc),
	      set(ft(thefig,'SustainedTransientPopup'),'value',3-asc.data);
	    end;
	    set(ft(thefig,'CentSizeRespCB'),'value',1);
	    if isfield(info,'outstr'),
	      set(ft(thefig,'SustainedTransientPopup'),'userdata',info.outstr);
	    end;
	    assoclist = ctxassociatelist('CentSize');
	    saveasslist = [];
	    for i=1:length(assoclist),
	      ass = findassociate(cell,assoclist{i},'protocol_CTX',[]);
	      if ~isempty(ass),
		saveasslist = [saveasslist ass];
	      end;
	    end;
	    set(ft(thefig,'CSLatencyText'),'userdata',saveasslist);
    end;
   case 'ConeRespCB',
    val=get(ft(thefig,'ConeRespCB'),'value');
    g = findinfoinlist(thefig,'ConeResp');
    ud.infolist = ud.infolist(setxor(1:length(ud.infolist),g));
    set(thefig,'userdata',ud);
    if val==1, % a change from 0 to 1
      newinfo.name='ConeResp';
      newinfo.associate=struct('type','t','owner','t','data',0,'desc',0);
      newinfo.associate=newinfo.associate([]); % make empty
      newinfo.name = 'ConeResp';
      if get(ft(thefig,'ConeCB'),'value'),
	newinfo.associate(end+1)=...
	    struct('type',...
		   'Cone test',...
		   'owner','protocol_CTX',...
		   'data',get(ft(thefig,'ConeTestEdit'),'String'),...
		   'desc','Test number string for cone test');
      end;
      ascs=get(ft(thefig,'CenterMplusCB'),'userdata');
      if ~isempty(ascs), newinfo.associate=[newinfo.associate ascs]; end;
      ud.infolist(end+1) = {newinfo};
      set(thefig,'userdata',ud);
    elseif val==0, % a change from 1 to 0
    end;
   case 'RestoreConeResp',
    g = findinfoinlist(thefig,'ConeResp');
    if ~isempty(g),
      info = ud.infolist{g};
      cksds=getcksds(1); c=getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat');cell=getfield(data,c{1});
      asc=findassociate(cell,'Cone test significant firing','protocol_CTX',[]);
      if ~isempty(asc),
	set(ft(thefig,'CenterMplusCB'),'value',asc.data.H(1));
	set(ft(thefig,'CenterMminusCB'),'value',asc.data.H(2));
	set(ft(thefig,'CenterSplusCB'),'value',asc.data.H(3));
	set(ft(thefig,'CenterSminusCB'),'value',asc.data.H(4));
	set(ft(thefig,'CenterPlusCB'),'value',0);
	set(ft(thefig,'CenterMinusCB'),'value',0);
	set(ft(thefig,'SurroundMplusCB'),'value',asc.data.H(5));
	set(ft(thefig,'SurroundMminusCB'),'value',asc.data.H(6));
	set(ft(thefig,'SurroundSplusCB'),'value',asc.data.H(7));
	set(ft(thefig,'SurroundSminusCB'),'value',asc.data.H(8));
	set(ft(thefig,'SurroundPlusCB'),'value',0);
	set(ft(thefig,'SurroundMinusCB'),'value',0);
      end;
      set(ft(thefig,'ConeRespCB'),'value',1);
      assoclist = ctxassociatelist('ConeTest');
      saveasslist = [];
      for i=1:length(assoclist),
	ass = findassociate(cell,assoclist{i},'protocol_CTX',[]);
	if ~isempty(ass),
	  saveasslist = [saveasslist ass];
	end;
      end;
      set(ft(thefig,'CenterMplusCB'),'userdata',saveasslist);
    end;    
   case 'RestoreOTResp',
    g = findinfoinlist(thefig,'OTResp');
    if ~isempty(g),
      cksds=getcksds(1); 
      c=getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat');
      cell=getfield(data,c{1});
      display_associate(cell,'OT Pref', thefig);
      display_associate(cell,'OT F1/F0', thefig);
      display_associate(cell,'OT Circular variance', thefig);
      display_associate(cell,'OT Tuning width', thefig);
      display_associate(cell,'OT Orientation index', thefig);
      display_associate(cell,'OT Direction index', thefig);
    end
   case 'RestoreVEPResp',
    g = findinfoinlist(thefig,'VEPResp');
    if ~isempty(g),
      cksds=getcksds(1); 
      c=getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat');
      cell=getfield(data,c{1});
      display_VEP_info(cell, thefig);

      assoclist = ctxassociatelist('VEP Test');
      saveasslist = [];
      for i=1:length(assoclist),
	ass = findassociate(cell,assoclist{i},'protocol_CTX',[]);
	if ~isempty(ass),
	  saveasslist = [saveasslist ass];
	end;
      end;
      set(ft(thefig,'VEP Test'),'userdata',saveasslist);
    end

   case 'RestoreFDTResp',
    g = findinfoinlist(thefig,'FDTResp');
    if ~isempty(g),
      info = ud.infolist{g};
      cksds=getcksds(1); c = getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat');
      cell=getfield(data,c{1});
      display_FDT_info(cell,thefig);
      
      assoclist = ctxassociatelist('FDT Test');
      saveasslist = [];
      for i=1:length(assoclist),
	ass = findassociate(cell,assoclist{i},'protocol_CTX',[]);
	if ~isempty(ass),
	  saveasslist = [saveasslist ass];
	end;
      end;
      set(ft(thefig,'FDT Test'),'userdata',saveasslist);
    end;
           
   case 'RestoreTFResp',
    g = findinfoinlist(thefig,'TFResp');
    if ~isempty(g),
      info = ud.infolist{g};
      cksds=getcksds(1); 
      c = getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat');
      cell=getfield(data,c{1});
      display_TF_info(cell,thefig);
      assoclist = ctxassociatelist('TF Test');
      saveasslist = [];
      for i=1:length(assoclist),
	ass = findassociate(cell,assoclist{i},'protocol_CTX',[]);
	if ~isempty(ass),
	  saveasslist = [saveasslist ass];
	end;
      end;
      set(ft(thefig,'TF Test'),'userdata',saveasslist);
    end;
    
    
   case {'Restorebw SFResp','Restoreequilum SFResp','Restoregreen SFResp',...
	 'Restoreblue SFResp'}
    stimulusname=thetag(8:end-4);
    g = findinfoinlist(thefig,[stimulusname 'Resp']);
    if ~isempty(g),
      info = ud.infolist{g};
      cksds=getcksds(1); 
      c = getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat'); 
      cell=getfield(data,c{1});
      display_SF_info(cell,thefig,stimulusname);
      assoclist = ctxassociatelist([stimulusname ' Test']);
      saveasslist = [];
      for i=1:length(assoclist),
	ass = findassociate(cell,assoclist{i},'protocol_CTX',[]);
	if ~isempty(ass),
	  saveasslist = [saveasslist ass];
	end;
      end;
      set(ft(thefig,[stimulusname ' Test']),'userdata',saveasslist);
    end;
    
   case 'RestoreContrastResp',
    g = findinfoinlist(thefig,'ContrastResp');
    if ~isempty(g),
      info=ud.infolist{g};cksds=getcksds(1);c=getcells(cksds,ud.nameref);
      data=load(getexperimentfile(cksds),c{1},'-mat');
      newcell=getfield(data,c{1});
      display_contrast_info(newcell,thefig);
      assoclist = ctxassociatelist('Contrast Test');
      saveasslist = [];
      for i=1:length(assoclist),
	ass = findassociate(newcell,assoclist{i},'protocol_CTX',[]);
	if ~isempty(ass),
	  saveasslist = [saveasslist ass];
	end;
      end;
      set(ft(thefig,'Contrast Test'),'userdata',saveasslist);
    end;
   case {'RCCB','RC1CB','RC2CB','CentSizeCB',...
	 'bw SFCB','equilum SFCB','blue SFCB','green SFCB',...
	 'ContrastCB',...
	 'PhaseCB',...
	 'ConeCB','TFCB','OTCB','FDTCB',...
	  'PosCB','LengthCB','WidthCB','ColorCB','VEPCB'},
    cases={'RCCB','RC1CB','RC2CB','CentSizeCB',...
	   'bw SFCB','equilum SFCB','blue SFCB','green SFCB',...
	   'ContrastCB',...
	   'PhaseCB',...
	   'ConeCB','TFCB','OTCB','FDTCB',...
	   'PosCB','LengthCB','WidthCB','ColorCB','VEPCB'};
    infos={'RC','RC1','RC2','CentSize',...
	   'bw SF','equilum SF','blue SF','green SF',...
	   'Contrast',...
	   'Phase','Cone','TF','OT','FDT',...
	   'Pos','Length','Width','Color','VEP'};
    tests={'RCTestEdit','RC1TestEdit','RC2TestEdit','CentSizeTestEdit',...
	   'bw SF Test','equilum SF Test','blue SF Test','green SF Test',...
	   'Contrast Test','Phase Test',...
	   'ConeTestEdit','TF Test','OT Test','FDT Test',...
	   'Pos Test','Length Test','Width Test','Color Test','VEP Test'};
    b = 0;
    % note: old condition RC changed to RC1 2002-08-18
    for i=1:length(cases),
      if strcmp(thetag,cases{i}),b=i;break;end;
    end;
    if b==1,return;end; % RCCB no longer supported
    g = findinfoinlist(thefig,infos{b});
    ud.infolist = ud.infolist(setxor(1:length(ud.infolist),g));
    val = get(ft(thefig,thetag),'value');
    if isempty(val),disp(['Empty: ' thetag '.']); end;
    if val==1,
      newinfolist.test=get(ft(thefig,tests{b}),'String');
      newinfolist.name = infos{b};

      %newinfolist.assoc = assoc;
      ud.infolist(end+1) = {newinfolist};
    end;
    set(thefig,'userdata',ud);
   case {'RestoreRC','RestoreRC1','RestoreRC2','RestoreCentSize',...
	 'Restorebw SF','Restoreequilum SF','Restoreblue SF',...
	 'Restoregreen SF','RestoreContrast',...
	 'RestorePhase','RestoreCone',...
	 'RestoreTF','RestoreOT','RestoreFDT',...
	 'RestorePos','RestoreLength','RestoreWidth','RestoreColor',...
	 'RestoreVEP'},
    cases={'RestoreRC','RestoreRC1','RestoreRC2','RestoreCentSize',...
	   'Restorebw SF','Restoreequilum SF','Restoreblue SF',...
	   'Restoregreen SF','RestoreContrast',...
	   'RestorePhase','RestoreCone',...
	   'RestoreTF','RestoreOT','RestoreFDT',...
	   'RestorePos','RestoreLength','RestoreWidth','RestoreColor',...
	   'RestoreVEP'};
    buts={'RC1CB','RC1CB','RC2CB','CentSizeCB',...
	  'bw SFCB','equilum SFCB','blue SFCB','green SFCB',...
	  'ContrastCB',...
	  'PhaseCB',...
	  'ConeCB','TFCB','OTCB','FDTCB',...
	  'PosCB','LengthCB','WidthCB','ColorCB','VEPCB'};
    infos={'RC','RC1','RC2','CentSize',...
	   'bw SF','equilum SF','blue SF','green SF',...
	   'Contrast','Phase',...
	   'Cone','TF','OT','FDT',...
	   'Pos','Length','Width','Color','VEP'};
    tests={'RC1TestEdit','RC1TestEdit','RC2TestEdit',...
	   'CentSizeTestEdit',...
	   'bw SF Test','equilum SF Test','blue SF Test','green SF Test',...
	   'Contrast Test','Phase Test',...
	   'ConeTestEdit','TF Test','OT Test','FDT Test',...
	   'Pos Test','Length Test','Width Test','Color Test',...
	   'VEP Test'};
    b = 0;
    % note: old condition RC changed to RC1 2002-08-18
    for i=1:length(cases),
      if strcmp(thetag,cases{i}),b=i;break;end;
    end;
    g = findinfoinlist(thefig,infos{b});
    if ~isempty(g),
      info = ud.infolist{g};
      set(ft(thefig,tests{b}),'String',info.test);
      set(ft(thefig,buts{b}),'value',1);
    end;
   case {'AnalyzeRC1Bt','AnalyzeRC2Bt'},
    cases = {'AnalyzeRC1Bt','AnalyzeRC2Bt'};
    tests={'RC1TestEdit','RC2TestEdit'};
    b = 0;
    for i=1:length(cases),
      if strcmp(cases{i},thetag),b=i;break;end;
    end;
    cksds = getcksds(1);
    g = gtn(thefig,tests{b}); ng = 0;
    if ~isempty(g),
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	inp.stimtime = stimtimestruct(s,1);
	inp.spikes={getfield(data,c{1})};inp.cellnames=c;
	where.figure=figure;where.rect=[0 0 1 1];where.units='normalized';
	orient(where.figure,'landscape');
	rc = reverse_corr(inp,'default',where);
	set(ft(thefig,'RC2TestEdit'),'userdata',rc);
      end;
    end;
   case 'RCGrabResultsBt',
       g = get(ft(thefig,'RC2TestEdit'),'userdata');
       if ~isempty(g),
          w = location(g);
          fig = w.figure;
          c = [];
          try, ud2 = get(fig,'userdata');
               for i=1:length(ud2),
                 if (g==ud2{i}),
                   c = getoutput(ud2{i});
                   c = c.crc;
                   break; end;
               end;
          catch, errordlg('Can''t find analysis--must be open.'); ud2=[]; end;
          if ~isempty(c),
             set(ft(thefig,'RCCenterLocEdit'),'String',mat2str(c.pixelcenter));
             set(ft(thefig,'RCLatencyText'),'String',num2str(c.tmax),...
                 'userdata',c.tmax);
             set(ft(thefig,'RCTransienceText'),'String',...
                 num2str(c.transience),'userdata',c.transience);
             set(ft(thefig,'CenterPopup'),'value',2+c.onoff);
          end;
		  ctxexperpanel('SetCenterBt',thefig);
       else, errordlg('No analysis found---try running again.'); end;
   case 'AnalyzeCentSizeBt',
    cksds = getcksds(1);
    g = gtn(thefig,'CentSizeTestEdit'); ng = 0;
    if ~isempty(g),
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	thecell=getfield(data,c{1});
	% need to prepare test and parameter associates
	newassc=struct('type','Cent Size Params',...
		       'owner','protocol_CTX',...
		       'data',struct('evalint',...
				     get(ft(thefig,'CentSizeAnalEdit')),...
				     'earlyint',...
				     get(ft(thefig,'CSEarlyEdit')),...
				     'lateint',...
				     get(ft(thefig,'CSLateEdit'))),'desc',...
		       'Parameters specifying center size test analysis');
	newassc(end+1)=struct('type','Cent Size test',...
			      'owner','protocol_CTX',...
			      'data',...
			      get(ft(thefig,'CentSizeTestEdit'),'String'),...
			      'desc',...
			      'Test number string for cent size test');
	for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
	try, 
	  [nc,outstr,assocs,tc]=ctxcentsizeanalysis(cksds,thecell,c{1},1);
	  set(ft(thefig,'CentSizeTestEdit'),'userdata',tc);
	  set(ft(thefig,'CenterSizeEdit'),'String',num2str(outstr.maxloc));
	  set(ft(thefig,'CSLatencyText'),'String',num2str(outstr.tlat),...
			    'userdata',assocs);
	  set(ft(thefig,'CSEarlyEdit'),'string',mat2str(outstr.earlyint));
	  set(ft(thefig,'CSLateEdit'),'string',mat2str(outstr.lateint));
	  set(ft(thefig,'CSTransienceText'),'String',num2str(outstr.trans));
	  set(ft(thefig,'CentSizeAnalEdit'),'String',...
			    mat2str(outstr.evalint));
	  set(ft(thefig,'SustainedTransientPopup'),'value',...
			    1+2-outstr.sustained);
	catch,
	  errordlg(['Error analyzing center size: ' lasterr]);
	  set(ft(thefig,'CSLatencyText'),'userdata',[]);
	end;
      end;
    end;
   case 'AnalyzeConeTestBt',
    cksds = getcksds(1);
    g = gtn(thefig,'ConeTestEdit'); ng = 0;
    if ~isempty(g),
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	%tc0= docurve(ssp,c,data,'contrast',1,c{1},-1);
	thecell=getfield(data,c{1});
	newassc=...
	    struct('type','Cent Size Params',...
		   'owner','protocol_CTX',...
		   'data',...
		   struct('evalint',get(ft(thefig,'CentSizeAnalEdit')),...
			  'earlyint',get(ft(thefig,'CSEarlyEdit')),'lateint',...
			  get(ft(thefig,'CSLateEdit'))),'desc',...
		   'Parameters specifying center size test analysis');
	newassc(end+1)=...
	    struct('type','Cent Size test',...
		   'owner','protocol_CTX',...
		   'data',get(ft(thefig,'CentSizeTestEdit'),'String'),'desc',...
		   'Test number string for cent size test');
	newassc(end+1)=...
	    struct('type','Cone test','owner','protocol_CTX',...
		   'data',get(ft(thefig,'ConeTestEdit'),'String'),'desc',...
		   'Test number string for cone test');
	ud1 = get(ft(thefig,'CSLatencyText'),'userdata');
	if ~isempty(ud1),
	  newassc = [newassc ud1];
	end;
	for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
	[nc,coneout,assocs,ra]=ctxconetestanalysis(cksds,thecell,c{1},1);
	%global coneout,
	%coneout,
	set(ft(thefig,'CenterMplusCB'),'value',coneout.sigfiring(1),...
			  'userdata',assocs);
	set(ft(thefig,'CenterMminusCB'),'value',coneout.sigfiring(2));
	set(ft(thefig,'CenterSplusCB'),'value',coneout.sigfiring(3));
	set(ft(thefig,'CenterSminusCB'),'value',coneout.sigfiring(4));
	set(ft(thefig,'SurroundMplusCB'),'value',coneout.sigfiring(5));
	set(ft(thefig,'SurroundMminusCB'),'value',coneout.sigfiring(6));
	set(ft(thefig,'SurroundSplusCB'),'value',coneout.sigfiring(7));
	set(ft(thefig,'SurroundSminusCB'),'value',coneout.sigfiring(8));
      end;
    end;
   case 'AnalyzeVEPBt'
    cksds=getcksds(1); 
    ud = get(thefig,'userdata');
    g = gtn(thefig,'VEP Test');
    if ~isempty(g),
      newassc=ctxnewassociate('VEP Test',...
			      get(ft(thefig,'VEP Test'),'String'),...
			      'Test number for VEP test');
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	thecell = getfield(data,c{1});
	for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
	[newcell,outstr,assocs]=...
	    ctxvepanalysis(cksds,thecell,c{1},1,ud.nameref);
	set(ft(thefig,'AnalyzeVEPBt'),'userdata',[]);
	display_VEP_info(newcell,thefig);
	warndlg('Did you set the filter and gain back?');
	add_associates_to_infolist(thefig,'VEPResp',assocs);
      end;
    end;
    
   case 'AnalyzeOTBt',
    cksds = getcksds(1);
    g = gtn(thefig,'OT Test');
    if ~isempty(g),
      newassc=ctxnewassociate('OT Test',...
			      get(ft(thefig,'OT Test'),'String'),...
			      'Test number for OT test');
      
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	thecell = getfield(data,c{1});
	for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
	
	[newcell,outstr,assocs,pc]=ctxotanalysis(cksds,thecell,c{1},1);

	set(ft(thefig,'OT Test'),'userdata',pc);
	set(ft(thefig,'AnalyzeOTBt'),'userdata',[]);

	display_OT_info(newcell,thefig);
	
	% set new periodicscript
	PSp = getparameters(ud.PS);
	ascf1f0=findassociate(newcell,'OT F1/F0','protocol_CTX',[]);
	ascotpref=findassociate(newcell,'OT Pref','protocol_CTX',[]);
	if ascf1f0.data>1   %i.e. if simple cell
	  PSp.angle =  ascotpref.data(2); % take F1 value
	else
	  PSp.angle = ascotpref.data(1); % take F0 value
	end
	ud.PS = periodicscript(PSp);
	set(thefig,'userdata',ud);

	% store associates straight away in figure userdata
	% normally done with RespCB
	add_associates_to_infolist(thefig,'OTResp',assocs);

	% storage of test is done in PhaseCB

      end;
    end;
   case {'Analyzebw SFBt','Analyzeequilum SFBt',...
	 'Analyzeblue SFBt','Analyzegreen SFBt'}
    stimulusname=thetag(8:end-2);
    cksds = getcksds(1); 
    g = gtn(thefig,[stimulusname ' Test']);
    newassc=ctxnewassociate([stimulusname ' Test'],...
		   get(ft(thefig,[stimulusname ' Test']),'String'),...
		   ['Test number for ' stimulusname ' test']);
    [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
    if ~isempty(s),
      newcell = getfield(data,c{1});
      for i=1:length(newassc),
	newcell=associate(newcell,newassc(i));
      end;
      
      [newcell,bwoutstr,assocs,pc]=... 
	  ctxsfanalysis(cksds,newcell,c{1},1,stimulusname);
      
      [newcell,assocs]=calculate_colorsensitivity(newcell,assocs);
      %newcell=calculate_coloropponency(newcell);

      display_SF_info(newcell,thefig,stimulusname);
      
      if strcmp(stimulusname,'bw SF')
	% set new periodicscript
	try
	  PSp = getparameters(ud.PS);
	  ascf1f0=findassociate(newcell,[stimulusname ' F1/F0'],...
				'protocol_CTX',[]);
	  ascpref=findassociate(newcell,[stimulusname ' Pref'],...
				'protocol_CTX',[]);
	  if ascf1f0.data>1   %i.e. if simple cell
	    PSp.sFrequency =  ascpref.data(2); % take F1 value
	  else
	    PSp.sFrequency = ascpref.data(1); % take F0 value
	  end
	  ud.PS = periodicscript(PSp);
	  set(thefig,'userdata',ud);
	catch
	  errordlg('Could not get preferred spatial frequency.');
	end
      end      
            
      add_associates_to_infolist(thefig,[stimulusname 'Resp'],assocs);
      set(ft(thefig,[stimulusname ' Test']),'userdata',assocs);
    end;
   
   case 'AnalyzeTFBt',
    cksds = getcksds(1); 
    g = gtn(thefig,'TF Test');
    if ~isempty(g),
      newassc=struct('type','TF Test',...
		     'owner','protocol_CTX',...
		     'data',get(ft(thefig,'TF Test'),'String'),'desc',...
		     'Test number for TF Test');
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	thecell = getfield(data,c{1});
	for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
	[newcell,outstr,assocs,pc]=ctxtfanalysis(cksds,thecell,c{1},1);
	
	set(ft(thefig,'TF Test'),'userdata',assocs);
	
	display_TF_info(newcell,thefig);
	
	add_associates_to_infolist(thefig,'TFResp',assocs);
	
	% storage of test is done in TFCB
	
	% set new periodicscript
	ud=get(thefig,'userdata');
	ascf1f0=findassociate(newcell,'TF F1/F0','protocol_CTX',[]);
	ascpref=findassociate(newcell,'TF Pref','protocol_CTX',[]);
	PSp = getparameters(ud.PS);
	if ascf1f0.data>1   %i.e. simple cell
	  PSp.tFrequency = ascpref.data(2); % take F1 value
	else
	  PSp.tFrequency = ascpref.data(1); % take F2 value
	end
	ud.PS = periodicscript(PSp);
	set(thefig,'userdata',ud);
	
      end
    end
    
   case 'AnalyzeContrastBt'
    cksds = getcksds(1);
    g = gtn(thefig,'Contrast Test');
    if ~isempty(g),
      newassc=struct('type','Contrast Test','owner','protocol_CTX',...
		     'data',get(ft(thefig,'Contrast Test'),'String'),...
		     'desc',...
		     'Test number for contrast test');
      
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	thecell = getfield(data,c{1});
	for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
	[newcell,outstr,assocs,pc]=ctxcontrastanalysis(cksds,thecell,c{1},1);
	set(ft(thefig,'Contrast Test'),'userdata',assocs);
	display_contrast_info(newcell,thefig);
      
      	add_associates_to_infolist(thefig,'ContrastResp',assocs);

      end;
    end;

   case 'AnalyzeFDTBt',
    cksds = getcksds(1); 
    g = gtn(thefig,'FDT Test');
    if ~isempty(g),
      newassc=struct('type','FDT Test',...
		     'owner','protocol_CTX',...
		     'data',get(ft(thefig,'FDT Test'),'String'),'desc',...
		     'Test number for FDT test');
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	thecell = getfield(data,c{1});
	for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
	
	[newcell,outstr,assocs,pc]=ctxfdtanalysis(cksds,thecell,c{1},1);

	set(ft(thefig,'FDT Test'),'userdata',assocs);

	display_FDT_info(newcell,thefig);
	
	add_associates_to_infolist(thefig,'FDTResp',assocs);
	
	ascpref=findassociate(newcell,'FDT Pref','protocol_CTX',[]);
	ascmaxfiring=findassociate(newcell,'FDT Max firing rate',...
				   'protocol_CTX',[]);
	[m,irow]=max(ascmaxfiring.data);
	[m,icol]=max(m);
	
	ud=get(thefig,'userdata');
	PSp = getparameters(ud.PS);
	PSp.angle = ascpref.data(irow(icol),icol); 
	ud.PS = periodicscript(PSp);
	set(thefig,'userdata',ud);

      end;
    end;
    
    
   case 'AnalyzePosBt',
    cksds = getcksds(1); 
    g = gtn(thefig,'Pos Test');
    if ~isempty(g),
      newassc=struct('type','Pos Test',...
		     'owner','protocol_CTX',...
		     'data',get(ft(thefig,'Pos Test'),'String'),'desc',...
		     'Test number for Pos test');
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	thecell = getfield(data,c{1});
	for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
	[newcell,outstr,assocs,pc]=ctxposanalysis(cksds,thecell,c{1},1);
	set(ft(thefig,'Pos Test'),'userdata',assocs);
	display_pos_info(newcell,thefig);
	add_associates_to_infolist(thefig,'PosResp',assocs);
	% set new parameters for visual stimuli
	ascf1f0=findassociate(newcell,'Pos F1/F0','protocol_CTX',[]);
	ascpref=findassociate(newcell,'Pos Pixels Pref','protocol_CTX',[]);
	if isempty(ascf1f0)
	  errordlg('Could not read F1/F0 value');
	else
	  if ascf1f0.data<1;ind=1;else ind=2;end % select complex or simple 
	  cx=ascpref.data(1,ind);
	  cy=ascpref.data(2,ind);
	  ud=get(thefig,'userdata');
	  PSp = getparameters(ud.PS);
	  hwidth=round( (PSp.rect(3)-PSp.rect(1))/2 );
	  hheight=round( (PSp.rect(4)-PSp.rect(2)) /2 );
	  PSp.rect=[cx-hwidth cy-hheight cx+hwidth cy+hheight];
	  ud.PS = periodicscript(PSp);
	  set(thefig,'userdata',ud);
	  % now set screentool
	  set_screentool_cr(PSp.rect);
	end
      end;
    end;
  
    
   case 'AnalyzeLengthBt',
    cksds = getcksds(1); 
    g = gtn(thefig,'Length Test');
    if ~isempty(g),
      newassc=struct('type','Length Test',...
		     'owner','protocol_CTX',...
		     'data',get(ft(thefig,'Length Test'),'String'),'desc',...
		     'Test number for Length test');
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	thecell = getfield(data,c{1});
	for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
	[newcell,outstr,assocs,pc]=ctxlengthanalysis(cksds,thecell,c{1},1);
	set(ft(thefig,'Length Test'),'userdata',assocs);
	display_length_info(newcell,thefig);
	add_associates_to_infolist(thefig,'LengthResp',assocs);
	% set new parameters for visual stimuli
	ascf1f0=findassociate(newcell,'Length F1/F0','protocol_CTX',[]);
	ascpref=findassociate(newcell,'Length Pixels Pref','protocol_CTX',[]);
	if isempty(ascf1f0)
	 errordlg('Could not read F1/F0 value');
	else
	  if ascf1f0.data<1;ind=1;else ind=2;end % select complex or simple 
	  hlen=round(ascpref.data(ind)/2);  % in pixels!
	  ud=get(thefig,'userdata');
	  PSp = getparameters(ud.PS);
	  cx=round( (PSp.rect(1)+PSp.rect(3))/2 );
	  PSp.rect=[cx-hlen PSp.rect(2) cx+hlen PSp.rect(4)];
	  ud.PS = periodicscript(PSp);
	  set(thefig,'userdata',ud);
	  % now set screentool
	  set_screentool_cr(PSp.rect);
	end
      end;
    end;
  
   case 'AnalyzeWidthBt',
    cksds = getcksds(1); 
    g = gtn(thefig,'Width Test');
    if ~isempty(g),
      newassc=struct('type','Width Test',...
		     'owner','protocol_CTX',...
		     'data',get(ft(thefig,'Width Test'),'String'),'desc',...
		     'Test number for Width test');
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	thecell = getfield(data,c{1});
	for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
	[newcell,outstr,assocs,pc]=ctxwidthanalysis(cksds,thecell,c{1},1);
	set(ft(thefig,'Width Test'),'userdata',assocs);
	display_width_info(newcell,thefig);
	add_associates_to_infolist(thefig,'WidthResp',assocs);
	% set new parameters for visual stimuli
	ascf1f0=findassociate(newcell,'Width F1/F0','protocol_CTX',[]);
	ascpref=findassociate(newcell,'Width Pixels Pref','protocol_CTX',[]);
	if isempty(ascf1f0)
	  errordlg('Could not read F1/F0 value');
	else
	  if ascf1f0.data<1;ind=1;else ind=2;end % select complex or simple 
	  hwidth=round(ascpref.data(ind)/2)  % in pixels!
	  ud=get(thefig,'userdata');
	  PSp = getparameters(ud.PS)
	  cy=round( (PSp.rect(2)+PSp.rect(4))/2 );
	  PSp.rect=[PSp.rect(1) cy-hwidth PSp.rect(3) cy+hwidth];
	  ud.PS = periodicscript(PSp);
	  set(thefig,'userdata',ud);
	  % now set screentool
	  set_screentool_cr(PSp.rect);
	end
      end;
    end;

   case 'AnalyzeColorBt',
    cksds = getcksds(1); 
    g = gtn(thefig,'Color Test');
    if ~isempty(g),
      newassc=struct('type','Color Test',...
		     'owner','protocol_CTX',...
		     'data',get(ft(thefig,'Color Test'),'String'),'desc',...
		     'Test number for Color test');
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	thecell = getfield(data,c{1});
	for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
	[newcell,outstr,assocs,pc]=ctxcoloranalysis(cksds,thecell,c{1},1);
	set(ft(thefig,'Color Test'),'userdata',assocs);
	display_color_info(newcell,thefig);
	add_associates_to_infolist(thefig,'ColorResp',assocs);
      end;
    end;

    
   case 'AnalyzePhaseBt'
    cksds = getcksds(1); 
    g = gtn(thefig,'Phase Test');
    if ~isempty(g),
      newassc=ctxnewassociate('Phase Test',...
			      get(ft(thefig,'Phase Test'),'String'),...
			      'Test number for Phase test');
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	thecell = getfield(data,c{1});
	for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
	[newcell,outstr,assocs,pc]=ctxphaseanalysis(cksds,thecell,c{1},1);
	set(ft(thefig,'Phase Test'),'userdata',pc);
	set(ft(thefig,'AnalyzePhaseBt'),'userdata',[]);
	display_phase_info(newcell,thefig);
	add_associates_to_infolist(thefig,'PhaseResp',assocs);
      end;
    end;
   case 'RC1RunBt', %RCRunBt->RC1RunBt 2002-08-18
       if get(ft(thefig,'DetailCB'),'value')~=1,
          errordlg('Cannot run because previous line check box not checked.');
       else, 
          CTXP_sgs = stimscript(0);
          CTXP_sgs = append(CTXP_sgs, ud.SGS);
          b = transferscripts({'CTXP_sgs'},{CTXP_sgs});
          if b,
               dowait(0.5);
             b=runscriptremote('CTXP_sgs');
             if ~b,
                errordlg('Could not run script--check RunExperiment window.');
             end;
             tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
             set(ft(thefig,'RC1TestEdit'),'String',tn);
          end;
       end;
   case 'RC2RunBt',
    if get(ft(thefig,'DetailCB'),'value')~=1,
      errordlg('Cannot run because previous line check box not checked.');
    else, 
      [cr,dist,sr]=getscreentoolparams;
      ud.SGS2=recenterstim(ud.SGS2,{'rect',cr,'screenrect',sr,'params',1});
      CTXP_sgs2 = stimscript(0);
      CTXP_sgs2 = append(CTXP_sgs2, ud.SGS2);
      p__=getparameters(ud.SGS2);  % check to see if same up to location
      strs={'load toremote -mat;'
	    'if exist(''CTXP_sgs2'')==1,'
	    '   sgs_1=get(CTXP_sgs2,1);'
	    '   sgs_1p=getparameters(sgs_1);'
	    '   sgs_1p.rect = p__.rect;'
	    '   p__.randState = sgs_1p.randState;'
	    '   if sgs_1p==p__,'
	    '     sameparams = 1;'
	    '     sgs_1 = setparameters(sgs_1,p__);'
	    '     CTXP_sgs2=set(CTXP_sgs2,sgs_1,1);'
	    '   else, sameparams = 0; end;'
	    'else, sameparams=0;end;'
	    'save fromremote sameparams -mat;'
	    'save gotit sameparams -mat;'};
      [b,vars] = sendremotecommandvar(strs,{'p__'},{p__});
      if b,
	if vars.sameparams==0,  % we need to transfer new version
	  disp('transferring new version');
	  dowait(0.5);
	  b = transferscripts({'CTXP_sgs2'},{CTXP_sgs2});
	else, disp('stimulus fine.'); end;
      end;
      if b,
	dowait(0.5);
	b=runscriptremote('CTXP_sgs2');
	if ~b,
	  errordlg('Could not run script--check RunExperiment window.');
	end;
	tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
	set(ft(thefig,'RC2TestEdit'),'String',tn);
      end;
    end;
   case 'CentSizeRunBt',
    if get(ft(thefig,'RCRespCB'),'value')~=1,
      errordlg('Cannot run because previous line check box not checked.');
    else, 
      CTXP_cnt = stimscript(0);
      szes = [ 0:5:45 55 65 75 85 95 105];
      taglist = {'CentSizeRepsEdit','CentSizeISIEdit'};sz={[1 1],[1 1]};
      varlist = {'Center size reps','Center size ISI'};
      [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
      if b,
	p = getparameters(ud.css);
	for i=1:length(szes),
	  p.radius = szes(i); p.dispprefs = {'BGpretime',vals{2}};
	  CTXP_cnt = append(CTXP_cnt,centersurroundstim(p));
	end;
	CTXP_cnt = setDisplayMethod(CTXP_cnt,1,vals{1});
	b = transferscripts({'CTXP_cnt'},{CTXP_cnt});
	if b,
	  dowait(0.5);
	  b=runscriptremote('CTXP_cnt');
	  if ~b,
	    errordlg('Could not run script--check RunExperiment window.');
	  end;
	  tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
	  set(ft(thefig,'CentSizeTestEdit'),'String',tn);
	end;
      end;
    end;
   case 'VEPRunBt'
     VEPscript=stimscript(0);
     taglist = {'CentSizeRepsEdit','CentSizeISIEdit'};
     sz={[1 1],[1 1]};
     varlist = {'Center size reps','Center size ISI'};
     [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
     if b
       warndlg('Is filter set to 1Hz-5kHz and gain at 1000x?');
       sizes=[50 100 150];
       p = getparameters(ud.css);
       p.surradius=-1;
       % first white on black
       p.FGc=squirrel_white';
       p.FGs = [ 0 0 0];
       p.BG= [ 0 0 0];
       for i=1:length(sizes),
	 p.radius = sizes(i);
	 p.dispprefs = {'BGpretime',vals{2}};
	 VEPscript=append(VEPscript,centersurroundstim(p)) 
       end
       VEPscript=setDisplayMethod(VEPscript,1,vals{1});
       
       % then black on white
       VEPscript_black=stimscript(0);
       p.FGc = [ 0 0 0];
       p.FGs= squirrel_white';
       p.BG= squirrel_white';
       for i=1:length(sizes),
	 p.radius = sizes(i);
	 p.dispprefs = {'BGpretime',vals{2}};
	 VEPscript_black=append(VEPscript_black,centersurroundstim(p)) 
       end
       VEPscript_black=setDisplayMethod(VEPscript_black,1,vals{1});
       VEPscript=VEPscript+VEPscript_black;
       getDisplayOrder(VEPscript), % just to check
       b=transferscripts({'VEPscript'},{VEPscript});
       if b,
	  dowait(0.5);
	  b=runscriptremote('VEPscript');
	  if ~b,
	    errordlg('Could not run script--check RunExperiment window.');
	  end;
	  tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
	  set(ft(thefig,'VEP Test'),'String',tn);
	end;
     end
   case 'ConeRunBt',
    if get(ft(thefig,'CentSizeRespCB'),'value')~=1,
      errordlg('Cannot run because Center size not checked.');
    else, 
      taglist = {'greenplus','greenminus','blueplus','blueminus',...
		 'CenterSizeEdit','ConeRepsEdit','ConeISIEdit',...
		 'ConeAdaptationEdit'};
      varlist = {'M plus','M minus','S plus','S minus','Center size',...
		 'Cone test reps','Cone test ISI','Adapation'};
      [b,vals] = checksyntaxsize(thefig,taglist,{[1 3],[1 3],[1 3],[1 3],...
		    [1 1],[1 1],[1 1],[1 1]},1,varlist);
      p = getparameters(ud.css); pt = p;
      if b,
	p.radius = vals{5}; p.surrradius = -1; % more trials for center
	p.stimduration = 0.5; p.dispprefs={'BGpretime',0.5};
	centerExtra = append(stimscript(0),centersurroundstim(p));
	centerExtra = setDisplayMethod(centerExtra,1,40); % 40 trials
	p.radius = max([5 vals{5}-5]); p.surrradius = -1;
	p.BG = vals{2}; p.FGs = vals{2}; p.FGc = vals{2};
	p.stimduration = 0.01; % brief as possible for adapting stim
	p.dispprefs = {'BGpretime',vals{8}};
	coneMminusAdapt = append(stimscript(0),centersurroundstim(p));
	p.BG = vals{1}; p.FGs = vals{1}; p.FGc = vals{1};
	coneMplusAdapt = append(stimscript(0),centersurroundstim(p));
	p.BG = vals{3}; p.FGs = vals{3}; p.FGc = vals{3};
	coneSplusAdapt = append(stimscript(0),centersurroundstim(p));
	p.BG = vals{4}; p.FGs = vals{4}; p.FGc = vals{4};
	coneSminusAdapt = append(stimscript(0),centersurroundstim(p));
	p.dispprefs = {'BGpretime',vals{7}};
	coneMcenter = stimscript(0);
	p.BG = vals{2}; p.FGs = vals{2}; p.FGc = vals{1};
	p.stimduration = pt.stimduration; p.contrast = 1;
	coneMcenter = append(coneMcenter,centersurroundstim(p));
	coneMcenter = setDisplayMethod(coneMcenter,1,vals{6});
	conemcenter = stimscript(0);
	p.BG = vals{1}; p.FGs = vals{1}; p.FGc = vals{2};
	p.stimduration = pt.stimduration; p.contrast = 1;
	conemcenter = append(conemcenter,centersurroundstim(p));
	conemcenter = setDisplayMethod(conemcenter,1,vals{6});
	coneScenter = stimscript(0);
	p.BG = vals{4}; p.FGs = vals{4}; p.FGc = vals{3};
	p.stimduration = pt.stimduration; p.contrast = 1;
	coneScenter = append(coneScenter,centersurroundstim(p));
	coneScenter = setDisplayMethod(coneScenter,1,vals{6});
	conescenter = stimscript(0);
	p.BG = vals{3}; p.FGs = vals{3}; p.FGc = vals{4};
	p.stimduration = pt.stimduration; p.contrast = 1;
	conescenter = append(conescenter,centersurroundstim(p));
	conescenter = setDisplayMethod(conescenter,1,vals{6});
	p.radius = vals{5}+10;
	p.surrradius=1000; p.stimduration=pt.stimduration; p.contrast=1;
	coneMsurround = stimscript(0);
	p.BG = vals{2}; p.FGs = vals{1}; p.FGc = vals{2};
	coneMsurround = append(coneMsurround,centersurroundstim(p));
	coneMsurround = setDisplayMethod(coneMsurround,1,vals{6});
	conemsurround = stimscript(0);
	p.BG = vals{1}; p.FGs = vals{2}; p.FGc = vals{1};
	conemsurround = append(conemsurround,centersurroundstim(p));
	conemsurround = setDisplayMethod(conemsurround,1,vals{6});
	coneSsurround = stimscript(0);
	p.BG = vals{4}; p.FGs = vals{3}; p.FGc = vals{4};
	coneSsurround = append(coneSsurround,centersurroundstim(p));
	coneSsurround = setDisplayMethod(coneSsurround,1,vals{6});
	conessurround = stimscript(0);
	p.BG = vals{3}; p.FGs = vals{4}; p.FGc = vals{3};
	conessurround = append(conessurround,centersurroundstim(p));
	conessurround = setDisplayMethod(conessurround,1,vals{6});
	CTXP_cone = centerExtra +...
	    (coneMminusAdapt + coneMcenter) +...
	    (coneMplusAdapt  + conemcenter) +...
	    (coneSminusAdapt  + coneScenter)+...
	    (coneSplusAdapt  + conescenter) +...
	    (coneMminusAdapt + coneMsurround)+...
	    (coneMplusAdapt + conemsurround)+...
	    (coneSminusAdapt + coneSsurround)+...
	    (coneSplusAdapt + conessurround);
	b = transferscripts({'CTXP_cone'},{CTXP_cone});
	if b,
	  dowait(0.5);
	  b = runscriptremote('CTXP_cone');
	  if ~b,
	    errordlg('Could not run script--check RunExperiment window.');
	  end;
	  tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
	  set(ft(thefig,'ConeTestEdit'),'String',tn);
	  set(ft(thefig,'ConeCB'),'value',0);
	  ctxexperpanel('ConeCB',thefig);
	end;
      end;
    end;
   
   case {'bw SFRunBt','equilum SFRunBt','blue SFRunBt','green SFRunBt'}
    stimulusname=thetag(1:end-5)
    if get(ft(thefig,'OTCB'),'value')~=1,
      errordlg('Cannot run because OT check box not checked.');
    else, 
      taglist = {'GratingRepsEdit','GratingISIEdit','SF Range',...
		 [stimulusname ' high chrom'],...
		 [stimulusname ' low chrom']};
      sz={[1 1],[1 1],[],[1 3],[1 3]};
      varlist = {'Grating reps','Grating ISI','SF Range',...
		 [stimulusname ' high chrom'],...
		 [stimulusname ' low chrom']};
      [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
      if b,
	thePS = ud.PS;
	[cr,dist,sr] = getscreentoolparams;
	thePS = recenterstim(thePS,{'rect',cr,'screenrect',sr,'params',1});
	p = getparameters(thePS);
	p.dispprefs = {'BGpretime',vals{2}};
	p.sFrequency = vals{3};
	p.chromhigh = vals{4};
	p.chromlow = vals{5};
	%p.windowShape = 2;
	CTXP_PS = periodicscript(p);
	CTXP_PS = setDisplayMethod(CTXP_PS,1,vals{1});
	b = transferscripts({'CTXP_PS'},{CTXP_PS});
	if b,
	  dowait(0.5);
	  b=runscriptremote('CTXP_PS');
	  if ~b,
	    errordlg('Could not run script--check RunExperiment window.');
	  end;
	  tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
	  set(ft(thefig,[stimulusname ' Test']),'String',tn);
	  set(ft(thefig,[stimulusname 'CB']),'value',0);
	  ctxexperpanel([stimulusname 'CB'],thefig);
	end;
      end;
    end;
   case 'TFRunBt',     
    if get(ft(thefig,'bw SFCB'),'value')~=1,
      errordlg('Cannot run because bw SF response check box not checked.');
    else, 
      taglist = {'GratingRepsEdit','GratingISIEdit','TF Range'};
      sz={[1 1],[1 1],[]};
      varlist = {'Grating reps','Grating ISI','TF Range'};
      [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
      if b,
	p = getparameters(ud.PS);
	p.dispprefs = {'BGpretime',vals{2}};
	p.tFrequency = vals{3};
	CTXP_PS = periodicscript(p);
	[cr,dist,sr] = getscreentoolparams;
	CTXP_PS = recenterstim(CTXP_PS,...
			       {'rect',cr,'screenrect',sr,'params',1});
	CTXP_PS = setDisplayMethod(CTXP_PS,1,vals{1});
	b = transferscripts({'CTXP_PS'},{CTXP_PS});
	if b,
	  dowait(0.5);
	  b=runscriptremote('CTXP_PS');
	  if ~b,
	    errordlg('Could not run script--check RunExperiment window.');
	  end;
	  tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
	  set(ft(thefig,'TF Test'),'String',tn);
	  set(ft(thefig,'TFCB'),'value',0);
	  ctxexperpanel('TFCB',thefig);
	end;
      end;
    end;
    
    
    
   case 'OTRunBt',     
    taglist = {'GratingRepsEdit','GratingISIEdit','OTRangeEdit'};
    sz={[1 1],[1 1],[]};
    varlist = {'Grating reps','Grating ISI','OT Range'};
    [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
    if b,
      p = getparameters(ud.PS);
      p.dispprefs = {'BGpretime',vals{2}};
      p.angle = vals{3};
      %p.windowShape=2;
      CTXP_PS = periodicscript(p);
      [cr,dist,sr] = getscreentoolparams;
      CTXP_PS = recenterstim(CTXP_PS,...
			     {'rect',cr,'screenrect',sr,'params',1});
      CTXP_PS = setDisplayMethod(CTXP_PS,1,vals{1});
      b = transferscripts({'CTXP_PS'},{CTXP_PS});
      if b,
	dowait(0.5);
	b=runscriptremote('CTXP_PS');
	if ~b,
	  errordlg('Could not run script--check RunExperiment window.');
	end;
	tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
	set(ft(thefig,'OT Test'),'String',tn);
	set(ft(thefig,'OTCB'),'value',0);
	ctxexperpanel('OTCB',thefig);
      end;
    end;
   case 'ContrastRunBt',     
    if get(ft(thefig,'TFCB'),'value')~=1,
      errordlg('Cannot run because TF response check box not checked.');
    else, 
      taglist = {'GratingRepsEdit','GratingISIEdit','Contrast Range'};
      sz={[1 1],[1 1],[]};
      varlist = {'Grating reps','Grating ISI','Contrast Range'};
      [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
      if b,
	thePS = ud.PS;
	[cr,dist,sr] = getscreentoolparams;
	thePS= recenterstim(thePS,...
			    {'rect',cr,'screenrect',sr,'params',1});
	p = getparameters(thePS);
	p.dispprefs = {'BGpretime',vals{2}};
	p.contrast = vals{3};
	CTXP_PS = periodicscript(p);
	CTXP_PS = setDisplayMethod(CTXP_PS,1,vals{1});
	b = transferscripts({'CTXP_PS'},{CTXP_PS});
	if b,
	  dowait(0.5);
	  b=runscriptremote('CTXP_PS');
	  if ~b,
	    errordlg('Could not run script--check RunExperiment window.');
	  end;
	  tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
	  set(ft(thefig,'Contrast Test'),'String',tn);
	  set(ft(thefig,'ContrastCB'),'value',0);
	  ctxexperpanel('ContrastCB',thefig);
	end;
      end;
    end;
    
    
    
   case 'PosRunBt',     
    taglist = {'GratingRepsEdit','GratingISIEdit','PosEdit',...
	       'Pos Area','Pos Numbers','Pos Size'};
    sz={[1 1],[1 1],[],[],[],[]};
    varlist = {'Grating reps','Grating ISI','PosEdit',...
	       'Pos Area','Pos Numbers','Pos Size'};
    [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
    if b,
      center=vals{3};
      area=vals{4};  % total size of overlapping patches
      numbers=vals{5}; % number of patches to try in length and width direc.
      patchsize=vals{6};  % [w h] size of individual patch
      
      thePS = ud.PS; % get current properties
      p=getparameters(thePS);
      p.dispprefs = {'BGpretime',vals{2}};
      p.windowShape = 2; % angled rectangle
      
      POS_SCRIPT=stimscript('');
      
      stepx=round(area(1)/ numbers(1));
      stepy=round(area(2)/numbers(2));
      hsx=round(patchsize(1)/2);
      hsy=round(patchsize(2)/2);
   
      for r=0:numbers(1)-1
	for c=0:numbers(2)-1
	  x = center(1) - round( (numbers(1)-1)/2 )*stepx + stepx*r;
	  y = center(2) - round( (numbers(2)-1)/2 )*stepy + stepy*c; 
	  p.rect=[ x-hsx y-hsx x+hsx y+hsx ];
	  p.sPhaseShift=r*(numbers(2))+c+1; % dirty trick to use periodic_curve
	  POS_SCRIPT=append(POS_SCRIPT,periodicstim(p));
	end
      end
      
      POS_SCRIPT = setDisplayMethod(POS_SCRIPT,1,vals{1});
      b = transferscripts({'POS_SCRIPT'},{POS_SCRIPT});
      if b,
	dowait(0.5);
	b=runscriptremote('POS_SCRIPT');
	if ~b,
	  errordlg('Could not run script--check RunExperiment window.');
	end;
	tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
	set(ft(thefig,'Pos Test'),'String',tn);
	set(ft(thefig,'PosCB'),'value',0);
	ctxexperpanel('PosCB',thefig);
      end;
    end;

   case 'LengthRunBt', 
    taglist = {'GratingRepsEdit','GratingISIEdit',...
	       'Length Range'};
    sz={[1 1],[1 1],[]};
    varlist = {'Grating reps','Grating ISI',...
	       'Length Range'};
    [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
    if b,

      thePS = ud.PS; % get current properties
      p = getparameters(thePS);
      p.dispprefs = {'BGpretime',vals{2}};
      p.windowShape = 2; % angled rectangle

      LENGTH_SCRIPT=stimscript('');
      
      lengths=vals{3}; 
      y1=p.rect(2); 
      y2=p.rect(4);
      xc=round((p.rect(3)+p.rect(1))/2);
      for l=1:length(lengths)
	p.rect=[xc-round(lengths(l)/2) y1 xc+round(lengths(l)/2) y2];
	p.sPhaseShift=l; % dirty trick to use periodic_curve
	LENGTH_SCRIPT=append(LENGTH_SCRIPT,periodicstim(p));
      end
      
      LENGTH_SCRIPT = setDisplayMethod(LENGTH_SCRIPT,1,vals{1});
      b = transferscripts({'LENGTH_SCRIPT'},{LENGTH_SCRIPT});
      if b,
	dowait(0.5);
	b=runscriptremote('LENGTH_SCRIPT');
	if ~b,
	  errordlg('Could not run script--check RunExperiment window.');
	end;
	tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
	set(ft(thefig,'Length Test'),'String',tn);
	set(ft(thefig,'LengthCB'),'value',0);
	ctxexperpanel('LengthCB',thefig);
      end;
    end;

   case 'WidthRunBt', 
    taglist = {'GratingRepsEdit','GratingISIEdit',...
	       'Width Range'};
    sz={[1 1],[1 1],[]};
    varlist = {'Grating reps','Grating ISI',...
	       'Width Range'};
    [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
    if b,
      thePS = ud.PS; % get current properties
      p = getparameters(thePS);
      p.dispprefs = {'BGpretime',vals{2}};
      p.windowShape = 2; % angled rectangle
	
      WIDTH_SCRIPT=stimscript('');
      
      widths=vals{3}; 

      x1=p.rect(1); 
      x2=p.rect(3);
      yc=round((p.rect(4)+p.rect(2))/2);
      
      for l=1:length(widths)
	p.rect=[x1 yc-round(widths(l)/2) x2 yc+round(widths(l)/2)];
	p.sPhaseShift=l; % dirty trick to use periodic_curve
	WIDTH_SCRIPT=append(WIDTH_SCRIPT,periodicstim(p));
      end
      WIDTH_SCRIPT = setDisplayMethod(WIDTH_SCRIPT,1,vals{1});
      b = transferscripts({'WIDTH_SCRIPT'},{WIDTH_SCRIPT});
      if b,
	dowait(0.5);
	b=runscriptremote('WIDTH_SCRIPT');
	if ~b,
	  errordlg('Could not run script--check RunExperiment window.');
	end;
	tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
	set(ft(thefig,'Width Test'),'String',tn);
	set(ft(thefig,'WidthCB'),'value',0);
	ctxexperpanel('WidthCB',thefig);
      end;
    end;
   
   case 'ColorRunBt', 
    taglist = {'GratingRepsEdit','GratingISIEdit',...
	       'Color Range'};
    sz={[1 1],[1 1],[]};
    varlist = {'Grating reps','Grating ISI',...
	       'Color Range'};
    [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
    if b,
      thePS = ud.PS; % get current properties
      p = getparameters(thePS);
      p.dispprefs = {'BGpretime',vals{2}-0.5,'BGposttime',0.5};
      p.windowShape = 2; % angled rectangle
	
      COLOR_SCRIPT=stimscript('');
      n_stimuli=vals{3};
      
      for lambda=linspace(0,1,n_stimuli)
	p.chromhigh = lambda*squirrel_green_plus'  + (1-lambda)*squirrel_blue_minus';
	p.chromlow  = lambda*squirrel_green_minus' + (1-lambda)*squirrel_blue_plus';
	p.sPhaseShift=lambda; % dirty trick to use periodic_curve
	COLOR_SCRIPT=append(COLOR_SCRIPT,periodicstim(p));
      end
      COLOR_SCRIPT = setDisplayMethod(COLOR_SCRIPT,1,vals{1});
      b = transferscripts({'COLOR_SCRIPT'},{COLOR_SCRIPT});
      if b,
	dowait(0.5);
	b=runscriptremote('COLOR_SCRIPT');
	if ~b,
	  errordlg('Could not run script--check RunExperiment window.');
	end;
	tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
	set(ft(thefig,'Color Test'),'String',tn);
	set(ft(thefig,'ColorCB'),'value',0);
	ctxexperpanel('ColorCB',thefig);
      end;
    end;

    
   case 'FDTRunBt',     
    if get(ft(thefig,'TFCB'),'value')~=1,
      errordlg('Cannot run because TF response check box not checked.');
    else 
      taglist = {'GratingRepsEdit','GratingISIEdit','FDT Direction Range',...
                 'FDT Contrast Range'};
      sz={[1 1],[1 1],[],[]};
      varlist = {'Grating reps','Grating ISI','Direction Range',...
                 'Contrast Range'};
      [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
      if b,
        thePS = ud.PS;
        [cr,dist,sr] = getscreentoolparams;
        thePS= recenterstim(thePS,{'rect',cr,'screenrect',sr,'params',1});
        p = getparameters(thePS);
        p.dispprefs = {'BGpretime',vals{2}};
        p.angle = vals{3};

        p.contrast = vals{4}(1);
        CTXP_PS=periodicscript(p);
        for i=2:length(vals{4}) % add separate scripts to make analysis easier
          p.contrast = vals{4}(i);
          CTXP_PS=CTXP_PS+periodicscript(p);
        end
        CTXP_PS = setDisplayMethod(CTXP_PS,1,vals{1});
        b = transferscripts({'CTXP_PS'},{CTXP_PS});
        if b,
          dowait(0.5);
          b=runscriptremote('CTXP_PS');
          if ~b,
            errordlg('Could not run script--check RunExperiment window.');
          end;
          tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
          set(ft(thefig,'FDT Test'),'String',tn);
          set(ft(thefig,'FDTCB'),'value',0);
          ctxexperpanel('FDTCB',thefig);
        end;
      end;
    end;         

    
    
   case {'PhaseRunBt'},
    cases = {'PhaseRunBt'};
    tes = {'Phase Test'};
    cbs = {'PhaseCB'};
    [d,i] = intersect(cases,thetag);
    
    if get(ft(thefig,'TFCB'),'value')~=1,
      errordlg('Cannot run because TF check box not checked.');
    else, 
      taglist = {'GratingRepsEdit','GratingISIEdit','Phase Range',...
		 'Phase Cycles'};
      sz={[1 1],[1 1],[],[1 1]};
      varlist = {'Grating reps','Grating ISI','Phase Range',['Number' ...
		    ' of cycles']};
      [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
      if b,
	p = getparameters(ud.PS);
	p.dispprefs = {'BGpretime',vals{2}};
	p.sPhaseShift = vals{3};
	p.nCycles = vals{4}; % times 1/Tf is time.
	p.imageType = 2;   % sinusoid spatially
	p.animType = 0;    % static
	p.flickerType = 0; % light->background->light
	CTXP_PS = periodicscript(p);
	[cr,dist,sr] = getscreentoolparams;
	CTXP_PS = recenterstim(CTXP_PS,...
			       {'rect',cr,'screenrect',sr,'params',1});
	CTXP_PS = setDisplayMethod(CTXP_PS,1,vals{1});
	b = transferscripts({'CTXP_PS'},{CTXP_PS});
	if b,
	  dowait(0.5);
	  b=runscriptremote('CTXP_PS');
	  if ~b,
	    errordlg('Could not run script--check RunExperiment window.');
	  end;
	  tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
	  set(ft(thefig,tes{i}),'String',tn);
	  set(ft(thefig,cbs{i}),'value',0);
	  ctxexperpanel(cbs{i},thefig);
	end;
      end;
    end;
   case {'CompareLuminanceBt'}
    if get(ft(thefig,'bw SFCB'),'value')~=1 |...
	  get(ft(thefig,'equilum SFCB'),'value')~=1 ,
      errordlg('Cannot run because not both color check boxes are checked.');
    else
      cksds = getcksds(1); 
      g = gtn(thefig,['bw SF Test']);
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	cell = getfield(data,c{1});
	ascbwf0=findassociate(cell,'bw SF Response Curve F0','protocol_CTX',[]);
	ascbwf1=findassociate(cell,'bw SF Response Curve F1','protocol_CTX',[]);
	ascequilumf0=findassociate(cell,'equilum SF Response Curve F0','protocol_CTX',[]);
	ascequilumf1=findassociate(cell,'equilum SF Response Curve F1', ...
		    'protocol_CTX',[]);
	ascbwdog=findassociate(cell,'bw SF DOG','protocol_CTX',[]);
	ascequilumdog=findassociate(cell,'equilum SF DOG','protocol_CTX',[]);

	
%	try
	  sfrange_interp=logspace( log10(min( min(ascbwf1.data(1,:)),0.01)) ...
				   ,log10(2),50);
	  hcp=comparison_plot( {...
	      {[sfrange_interp; dog(ascbwdog.data(:,1)',sfrange_interp)],...
	       [sfrange_interp; dog(ascequilumdog.data(:,1)',sfrange_interp)]},...
	      {[sfrange_interp; dog(ascbwdog.data(:,2)',sfrange_interp)],...
	       [sfrange_interp; dog(ascequilumdog.data(:,2)',sfrange_interp)]},...
			   },...
			   {'Spatial frequency','Spatial frequency'},...
			   {'Rate (Hz)','F1 (Hz)'},...
			   { {'B/W','Equilum'},{'B/W','Equilum'}},'-' );
%	catch
	  comparison_plot( {{ascbwf0.data([1 2 4],:),ascequilumf0.data([1 2 4],:)},...
			    {ascbwf1.data([1 2 4],:),ascequilumf1.data([1 2 4],:)}},...
			   {'Spatial frequency','Spatial frequency'},...
			   {'Rate (Hz)','F1 (Hz)'},...
			   { {'B/W','Equilum'},{'B/W','Equilum'}},'.',hcp );
%	end
      end;
    end
    
   case {'CompareConesBt'}
    if get(ft(thefig,'blue SFCB'),'value')~=1 |...
	  get(ft(thefig,'green SFCB'),'value')~=1 ,
      errordlg('Cannot run because not both color check boxes are checked.');
    else
      cksds = getcksds(1); 
      g = gtn(thefig,['blue SF Test']);
      [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
      if ~isempty(s),
	cell = getfield(data,c{1});
	ascbluef0=findassociate(cell,'blue SF Response Curve F0','protocol_CTX',[]);
	ascbluef1=findassociate(cell,'blue SF Response Curve F1','protocol_CTX',[]);
	ascgreenf0=findassociate(cell,'green SF Response Curve F0','protocol_CTX',[]);
	ascgreenf1=findassociate(cell,'green SF Response Curve F1', ...
		    'protocol_CTX',[]);
	comparison_plot( {{ascbluef0.data([1 2 4],:),ascgreenf0.data([1 2 4],:)},...
			 {ascbluef1.data([1 2 4],:),ascgreenf1.data([1 2 4],:)}},...
			 {'Spatial frequency','Spatial frequency'},...
			 {'Rate (Hz)','F1 (Hz)'},...
			 { {'Blue','Green'},{'Blue','Green'}} );
      end;
    end

   
   case 'VarRestore', % restore variables from saved
    sn = get(ft(thefig,'VarNameEdit'),'String');
    ef = getexperimentfile(cksds);
    g = [];
    try, g=load(ef,sn,'-mat');
    catch, errordlg(['Could not read variable ' sn ' from experiment file '...
		     ef '.']); sn=[];
    end;
    if ~isempty(sn)&~isempty(fieldnames(g)),
      filldefaults(thefig,struct('name','temp','ref',0),'');
      infolist = getfield(g,sn);
      ud.infolist = {}; set(thefig,'userdata',ud);
      for i=1:length(infolist),
	ud.infolist(end+1) = {infolist{i}};
	set(thefig,'userdata',ud);
	ctxexperpanel(['Restore' infolist{i}.name],thefig);
	%try, ctxexperpanel(['Restore' infolist{i}.name],thefig);
	%catch, ud.infolist=ud.infolist(1:end-1);
	%end;
      end;
    else, errordlg(['Could not read variable ' sn ' from experiment file.']);
    end;
   otherwise, disp(['unhandled tag ' thetag '.']);
  end;
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handy subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ag = docurve(s,c,data,paramname,tuning,title,lastfig)
inp.st = s; 
inp.spikes = getfield(data,c{1}); 
inp.paramname = paramname;
inp.title=title;
where.figure=figure;where.rect=[0 0 1 1]; where.units='normalized';
orient(where.figure,'landscape');
if tuning,
  tc = tuning_curve(inp,'default',where);
  ag = tc;
else,
  inp.paramnames = {paramname};
  pc = periodic_curve(inp,'default',where);
  p = getparameters(pc);
  p.graphParams(4).whattoplot = lastfig;
  pc = setparameters(pc,p);
  ag = pc;
end;

function [s,c,data] = getstimcellinfo(cksds,nameref,testname)
ng = 0;
try, s = getstimscripttimestruct(cksds,testname);
catch, errordlg('Stimulus data not found.'); ng=1; end;
try, c = getcells(cksds,nameref);
catch, errordlg('Cell data not found.'); ng=1; end;
% assume only single units
try, data=load(getexperimentfile(cksds),c{1},'-mat');
catch, ng=1;errordlg('Cell data not found in experiment file.'); end;
if ng==1, s = []; c = []; data = []; end;

function t = gtn(h1,tag)
t = [];
str = get(ft(h1,tag),'String');
cksds = getcksds;
tn = getalltests(cksds);
if isempty(intersect(tn,str)),
  errordlg(['No such test ' str '.']);
else, t = str;
end;


function b = islistfilledin(h1,taglist)
b=1; str='';
for i=1:length(taglist),
   b=b&(~istse(h1,taglist{i}));
   str = [str ', ' taglist{i}];
end;
if length(taglist)>1, str = str(3:end); end;
str = ['Error: ' str ' must be filled in before you can do that.'];
if ~b,
  errordlg(str);
end;

function b = istse(h1,tag) % is string field of element with tag 'tag' empty?
b = isempty(get(ft(h1,tag),'String'));

function h = ft(h1,st)  % shorthand
h = findobj(h1,'Tag',st);

function l = findinfoinlist(thefig,name)
l = []; ud = get(thefig,'userdata');
for i=1:length(ud.infolist),
   if strcmp(ud.infolist{i}.name,name),l=[l i];end;
end;


function cksds = getcksds (doup)
cksds = [];
z = geteditor('RunExperiment');
if ~isempty(z),
   if nargin==1, if doup, runexpercallbk('datapath',z); end; end;
   udre = get(z,'userdata');
   cksds = udre.cksds;
end;


function display_associate(cell, name, thefig)
  asc=findassociate(cell,name,'protocol_CTX',[]);
  if ~isempty(asc),
    if ~isempty(find(asc(end).data>=100))
      set(ft(thefig,name),'String',mat2str(asc(end).data,3));
    else
      set(ft(thefig,name),'String',mat2str(asc(end).data,2));
    end
  else
    set(ft(thefig,name),'String','');
  end;

function set_button_associate(cell, name, thefig)
  asc=findassociate(cell,name,'protocol_CTX',[]);
  if ~isempty(asc),
    set(ft(thefig,name),'Value',asc.data);
  end;

function add_associates_to_infolist(thefig,name,assocs)
  ud=get(thefig,'userdata');
  g = findinfoinlist(thefig,name);
  ud.infolist = ud.infolist(setxor(1:length(ud.infolist),g));
  newinfolist=struct('name',name);
  newinfolist.associate=assocs;
  ud.infolist(end+1) = {newinfolist};
  set(thefig,'userdata',ud);
  
function display_SF_info(cell,thefig,stimulusname);
  display_associate(cell,[stimulusname ' Pref'],thefig);
  display_associate(cell,[stimulusname ' Low'],thefig);
  display_associate(cell,[stimulusname ' High'],thefig);
  display_associate(cell,[stimulusname ' F1/F0'],thefig);
  display_associate(cell,[stimulusname ' Max drifting grating firing'],thefig);
  
  display_associate(cell,'bw SF Color sensitivity',thefig);
  display_associate(cell,'color opponency',thefig);
  set_color_backgroundcolors(thefig);

function display_contrast_info(cell,thefig)
  display_associate(cell,'C50', thefig);
  display_associate(cell,'Cgain 0-16', thefig);
  display_associate(cell,'Cgain 16-100', thefig);
  display_associate(cell,'Contrast Max rate', thefig);

function display_FDT_info(cell,thefig)
  display_associate_as_list(cell,'FDT Pref',thefig);
  display_associate_as_list(cell,'FDT Tuning width', thefig);
  display_associate_as_list(cell,'FDT Circular variance', thefig);
  display_associate_as_list(cell,'FDT Direction index', thefig);
  display_associate_as_list(cell,'FDT Max firing rate', thefig);
  display_associate_as_list(cell,'FDT F1/F0', thefig);

function display_TF_info(cell,thefig)
  display_associate(cell,'TF Pref', thefig);
  display_associate(cell,'TF Low', thefig);
  display_associate(cell,'TF High', thefig);
  display_associate(cell,'TF F1/F0', thefig);
  display_associate(cell,'TF Max drifting grating firing', thefig);
	
function display_length_info(cell,thefig)
  display_associate(cell,'Length Pixels Pref', thefig);
  display_associate(cell,'Length Pixels Low', thefig);
  display_associate(cell,'Length Pixels High', thefig);
  display_associate(cell,'Length F1/F0', thefig);
  display_associate(cell,'Length Max drifting grating firing', thefig);

function display_width_info(cell,thefig)
  display_associate(cell,'Width Pixels Pref', thefig);
  display_associate(cell,'Width Pixels Low', thefig);
  display_associate(cell,'Width Pixels High', thefig);
  display_associate(cell,'Width F1/F0', thefig);
  display_associate(cell,'Width Max drifting grating firing', thefig);

function display_pos_info(cell,thefig)
  display_associate(cell,'Pos Pixels Pref', thefig);
  display_associate(cell,'Pos Degrees Pref', thefig);
  display_associate(cell,'Pos F1/F0', thefig);

function display_matrix_as_list(handle,matrix)
  if ~isempty(matrix)
    list=mat2str(matrix(1,:),3);
    for i=2:size(matrix,1)
      list=[list '|' mat2str(matrix(i,:),3)];
    end
    set(handle,'String',list);
    set(handle,'SelectionHighlight','off');
    set(handle,'Value',size(matrix,1));
  end
  
function display_associate_as_list(cell,name, thefig)
  asc=findassociate(cell,name,'protocol_CTX',[]);
  if ~isempty(asc)
    display_matrix_as_list(ft(thefig,[name ' List']),asc.data);
  end
    
function display_OT_info(cell,thefig)  
  display_associate(cell,'OT Pref', thefig);
  display_associate(cell,'OT F1/F0', thefig);
  display_associate(cell,'OT Circular variance', thefig);
  display_associate(cell,'OT Tuning width', thefig);
  display_associate(cell,'OT Orientation index', thefig);
  display_associate(cell,'OT Direction index', thefig);
  display_associate(cell,'OT Max drifting grating firing', thefig);

function display_VEP_info(cell,thefig)
  display_associate(cell,'VEP Latency',thefig);
  display_associate(cell,'VEP Test',thefig);
  
function display_color_info(cell,thefig)
  display_associate(cell,'Color Balance', thefig);
  display_associate(cell,'Color Min rate', thefig);
  display_associate(cell,'Color Max rate', thefig);
  display_associate(cell,'Color F1/F0', thefig);
  
function display_phase_info(cell,thefig)
  display_associate(cell,'Phase Early rate', thefig);
  display_associate(cell,'Phase Late rate', thefig);
  display_associate(cell,'Phase Latency', thefig);
  display_associate(cell,'Phase Transience', thefig);
  display_associate(cell,'Phase Adapt', thefig);
  display_associate(cell,'Phase Linearity', thefig);
  display_associate(cell,'Phase Spontaneous rate', thefig);
  asc=findassociate(cell,'Phase Sustained?','protocol_CTX',[]);
  if ~isempty(asc)
    if asc.data==1
      set(ft(thefig,'Phase Sustained?'),'String','yes');
    else
      set(ft(thefig,'Phase Sustained?'),'String','no');
    end
  end
  
	

  
function [newcell,assocs]=calculate_colorsensitivity(cell,assocs)
  try % to calculate color sensitivity
    ascbw=findassociate(cell,'bw SF Max drifting grating firing',...
			'protocol_CTX',[]);
    ascequilum=findassociate(cell,'equilum SF Max drifting grating firing',...
			'protocol_CTX',[]);

    colorsens=ascequilum.data./ascbw.data;
  catch
    colorsens=NaN;
  end;
  assocs(end+1)=ctxnewassociate('bw SF Color sensitivity',...
			colorsens,['Color sensitivity index (see' ...
		    ' Hawken and Shapley, 2001)']);
  newcell=associate(cell,assocs(end));

function set_color_backgroundcolors(thefig)
  stimuli={'bw','equilum','blue','green'};
  for i=1:length(stimuli)
    try
      tag=[stimuli{i} ' SF high chrom'];
      color=eval(get(ft(thefig,tag), 'String'))/256;
      set(ft(thefig,tag),'BackgroundColor',color);
      if sum(color)>1.5
	fg=[0 0 0];
      else
	fg=[1 1 1];
      end
      set(ft(thefig,tag),'ForegroundColor',fg);
    end
    try
      tag=[stimuli{i} ' SF low chrom'];
      color=eval(get(ft(thefig,tag), 'String'))/256;
      set(ft(thefig,tag),'BackgroundColor',color);
      if sum(color)>1.5
	fg=[0 0 0];
      else
	fg=[1 1 1];
      end
      set(ft(thefig,tag),'ForegroundColor',fg);
    end
  end
  
function h1=comparison_plot( data,xlabels,ylabels,legends,style,h1 )
% { {plot1_data1,plot1_data2},{plot2_data1,plot2_data2,plot3_data3}
% }
  %try
  colors='kbrgymc';
  if nargin<5
    style='-';
  end
  if nargin<6
    h1=figure;
  end
  
  
    n_plots=length(data);
    for p=1:n_plots
      subplot(n_plots,1,p);
      hold on;
      thisdata=data{p};
      n_lines=length(thisdata);
      figs=[];
      for i=1:n_lines
	switch size(thisdata{i},1)
	 case 1% only y-values
	   h=plot(thisdata{i},colors(i));
	 case 2% x and y-values
	   h=plot(thisdata{i}(1,:),thisdata{i}(2,:),[style colors(i)]);
	 case 3% and stddev
	   h=errorbar(thisdata{i}(1,:),thisdata{i}(2,:),thisdata{i}(3,:),[style ...
		    colors(i)]);
	 case 4% and sem
	   h=errorbar(thisdata{i}(1,:),thisdata{i}(2,:),thisdata{i}(3,:),...
		      [style colors(i)]);
	   h=errorbar(thisdata{i}(1,:),thisdata{i}(2,:),thisdata{i}(4,:),...
		      [style colors(i)]);
	end
	if ~isempty(h)
	  figs(end+1)=h(1);
	end
      end
      ylabel(ylabels{p});
      xlabel(xlabels{p});
      ax=axis;
      set(gca,'XScale','log');
      axis(ax);
      legend(figs,legends{p});
    end
%  catch
 %   errordlg('Could not produce comparison graph. Reanalyze data.');
 % end

 
 
function set_cone_isolating(thefig)
  squirrelcolor
  set(ft(thefig,'blue SF high chrom'),'String',mat2str(squirrel_blue_plus'));
  set(ft(thefig,'blue SF low chrom'),'String',mat2str(squirrel_blue_minus'));
  set(ft(thefig,'green SF high chrom'),'String',mat2str(squirrel_green_plus'));
  set(ft(thefig,'green SF low chrom'),'String',mat2str(squirrel_green_minus'));
  set_color_backgroundcolors(thefig);
  set(ft(thefig,'UseConeIsolatingBt'),'Value',1);
  set(ft(thefig,'UsePRIsolatingBt'),'Value',0);

  
function set_PR_isolating(thefig)
  squirrelcolor
  set(ft(thefig,'blue SF high chrom'),'String',mat2str(squirrel_s_plus'));
  set(ft(thefig,'blue SF low chrom'),'String',mat2str(squirrel_s_minus'));
  set(ft(thefig,'green SF high chrom'),'String',mat2str(squirrel_m_plus'));
  set(ft(thefig,'green SF low chrom'),'String',mat2str(squirrel_m_minus'));
  set_color_backgroundcolors(thefig);
  set(ft(thefig,'UseConeIsolatingBt'),'Value',0);
  set(ft(thefig,'UsePRIsolatingBt'),'Value',1);


  
 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h1 = drawfig

h1 = ctxpanelfig;

function PS=baseperiodicscript()
  squirrelcolor
  [cr,dist,sr] = getscreentoolparams;
  PSp = struct('imageType',2,'animType',4,'flickerType',0,'angle',[0],...
	       'chromhigh',squirrel_white','chromlow',[0 0 0],...
	       'sFrequency',0.2,...
	       'sPhaseShift',0,'tFrequency',4,'barWidth',0.5,... % ,'distance',57
	       'rect',[0 0 300 300],'nCycles',5,'contrast',0.8,...
	       'background',0.5,'backdrop',0.5,'barColor',1,'nSmoothPixels',2,...
	       'fixedDur',0,'windowShape',2,'dispprefs',{{'BGpretime',2}});
  PS = periodicscript(PSp);
  PS = recenterstim(PS,{'rect',cr,'screenrect',sr,'params',1});





function filldefaults(h1,nameref,expf)
squirrelcolor
set(h1,'Tag','ctxexperpanel');

set(findobj(h1,'style','checkbox'),'value',0);

[cr,dist,sr] = getscreentoolparams;

SGSp=struct('rect',[0 0 630 480],'BG',round(mean([squirrel_white'/2; 0 0 0])),...
              'values',[round(squirrel_white'/2); 0 0 0],'dist',[1;1],...
              'pixSize',[42 32],'N',4000,'fps',10,'randState',rand('state'),...
              'dispprefs',{{}});
SGS2p=struct('rect',[0 0 180 180],'BG',round(mean([squirrel_white'/2; 0 0 0])),...
              'values',[round(squirrel_white'/2); 0 0 0],'dist',[1;1],...
              'pixSize',[12 12],'N',4000,'fps',10,'randState',rand('state'),...
              'dispprefs',{{}});
SGS = stochasticgridstim(SGSp);
SGS2 = stochasticgridstim(SGS2p);
SGS = recenterstim(SGS,{'rect',cr,'screenrect',sr,'params',1});
CSSp = struct('center',[mean(cr([1 3])) mean(cr([2 4]))],'BG',[0 0 0],...
              'FGc',squirrel_white','FGs',[0 0 0],'contrast',1,...
              'lagon',0,'lagoff',-1,...
              'surrlagon',0,'surrlagoff',-1,'radius',50,'surrradius',-1,...
              'stimduration',0.5,'dispprefs',{{}});
css = centersurroundstim(CSSp);
PS = baseperiodicscript;

ud = struct('SGS',SGS,'SGS2',SGS2,'css',css,'PS',PS,'nameref',nameref,...
      'infolist',[]);
set(h1,'userdata',ud);

mps = getscreentoolmonitorposition;
set(ft(h1,'MonXEdit'),'String',num2str(mps.MonPosX));
set(ft(h1,'MonYEdit'),'String',num2str(mps.MonPosY));
set(ft(h1,'MonZEdit'),'String',num2str(mps.MonPosZ));

ods = getscreentoolopticdisks;
set(ft(h1,'LeftVertEdit'),'String',num2str(ods.LeftVert));
set(ft(h1,'RightVertEdit'),'String',num2str(ods.RightVert));
set(ft(h1,'LeftHortEdit'),'String',num2str(ods.LeftHort));
set(ft(h1,'RightHortEdit'),'String',num2str(ods.RightHort));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set default parameters in figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% colors
set(ft(h1,'greenplus'),'String',mat2str(squirrel_green_plus'));
set(ft(h1,'greenminus'),'String',mat2str(squirrel_green_minus'));
set(ft(h1,'blueplus'),'String',mat2str(squirrel_blue_plus'));
set(ft(h1,'blueminus'),'String',mat2str(squirrel_blue_minus'));


%general grating properties
set(ft(h1,'GratingRepsEdit'),'String','5');
set(ft(h1,'GratingISIEdit'),'String','3');

%general center/surround properties
set(ft(h1,'CentSizeRepsEdit'),'String','5');  % was 10
set(ft(h1,'CentSizeISIEdit'),'String','0.5');
set(ft(h1,'CentSizeAnalEdit'),'String','[0 0.1]');

set(ft(h1,'CSEarlyEdit'),'String','');
set(ft(h1,'CSLateEdit'),'String','');

% C/S cone test
set(ft(h1,'ConeRepsEdit'),'String','10');
set(ft(h1,'ConeISIEdit'),'String','0.5');
set(ft(h1,'ConeAdaptationEdit'),'String','15');

% Orientation tuning
set(ft(h1,'OTRangeEdit'),'String','[0:30:330]');

% Position 
set(ft(h1,'Pos Area'),'String','[150 150]');
set(ft(h1,'Pos Numbers'),'String','[3 3]');
set(ft(h1,'Pos Size'),'String','[100 100]');

% Spatial frequency
set(ft(h1,'SF Range'),'String','[0.015 0.04 0.1 0.15 0.2 0.4 0.8 1.2 1.6]');
set(ft(h1,'bw SF high chrom'),'String',mat2str(squirrel_white'));
set(ft(h1,'bw SF low chrom'),'String',mat2str([0 0 0]));
set(ft(h1,'equilum SF high chrom'),'String',mat2str(squirrel_green_equal'));
set(ft(h1,'equilum SF low chrom'),'String',mat2str(squirrel_blue_equal'));
set_cone_isolating(h1);

% Length
set(ft(h1,'Length Range'),'String','[50 75 112 169 253 380]'); % pixels

% Width
set(ft(h1,'Width Range'),'String','[50 75 112 169 253 380]'); % pixels


% Temporal frequency 
set(ft(h1,'TF Range'),'String','[0.5 1 2 4 8 16 32]');

% Color balance
set(ft(h1,'Color Range'),'String','10'); % 10 different gratings

% Counter phase
set(ft(h1,'Phase Cycles'),'String','10');
set(ft(h1,'Phase Range'),'String','[0:pi/6:(2*pi-pi/6)]');

% Contrast response
set(ft(h1,'Contrast Range'),'String','[0.02 0.04 0.08 0.16 0.32 0.64 1]');

% Fine direction tuning
set(ft(h1,'FDT Direction Range'),'String','[0:22.5:337.5]'); 
set(ft(h1,'FDT Contrast Range'),'String','[0.25 0.50 0.75]');






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up popup menus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(ft(h1,'EyePopup'),'String',{' ',...
		    'contra exclusively',...
		    'contra very dominant',...
		    'contra slightly dominant',...
		    'no difference',...
		    'ipsi slightly dominant',...
		    'ipsi very dominant',...
		    'ipsi exclusively'});
set(ft(h1,'CenterPopup'),'String',{' ','black','white','neither'});
% disabled because this is measured more explicitly other places
set(ft(h1,'ONOFFPopup'),'String',{' ','ON','OFF','other'},'enable','off',...
	'visible','off');
set(ft(h1,'SustainedTransientPopup'),'String',{' ','Sustained','Transient',...
                     'neither'});
set(ft(h1,'CTXLayerPopup'),'String',{' ','1','2','3',...
                                     '4','5','6'});
set(ft(h1,'IsolationPopup'),'String',{' ','Perfect','Nearly perfect',...
'multiunit'});
set(ft(h1,'NameRefText'),'String',[nameref.name ' | ' int2str(nameref.ref)]);
set(ft(h1,'ExportLogBt'),'enable','off');
vname =['protocol_CTX_' nameref.name '_' int2str(nameref.ref) '_' expf];
vname(find(vname=='-')) = '_'; set(ft(h1,'VarNameEdit'),'String',vname);




function lgnctxexperpanel(cbo, fig)

  % if cbo is text, then is command; else, the tag is used as command
  % if fig is given, it is used; otherwise, callback figure is used

  % things to add
  %   adding cell info
  %   make saveexpvar safer
  %   extending analysis to intracellular signals w/ Sooyoung's code
  %   write off-line analysis
  %   add increment cells button
  

squirrelcolor;

global lgnctx_databaseNLT;

if nargin==0, % open new figure and draw it
  z = geteditor('RunExperiment');
  if isempty(z),errordlg('Needs an experiment to run tests.');return;end;
  z2= geteditor('screentool');
  if isempty(z2),errordlg('Needs screentool to run tests.');return;end;
  [cr] = getscreentoolparams;
  if isempty(cr),errordlg('Needs good current rect in screentool.');return;end;
  cksds = getcksds;
  if isempty(cksds), errordlg(['No existing data---make sure you hit '...
                 'return after directory in RunExperiment window']);
                 return;
  end; % now we're sure we've got it or returned
  h1 = drawfig;
  filldefaults(h1,[],[]);
  lgnctxexperpanel('UpdateBt',h1);
  lgnctxexperpanel('LGNElectrodeList',h1);
else,  % respond to command
  if nargin==2, thefig = fig; else, thefig = gcbf; end;
  if isa(cbo,'char'), thetag=cbo; else, thetag = get(cbo,'Tag'); end;
  ud = get(thefig,'userdata');
  cksds = getcksds;
  if isempty(cksds),
    errordlg('Cannot find directory structure in RunExperiment.');
  end;
  switch thetag,
    case 'UpdateBt',
		% update LGN list
		sel = get(ft(thefig,'LGNElectrodeList'),'value');
		nrfs = getsubnamerefs(cksds,'lgn');
		strs = {};
		for i=1:length(nrfs),
			strs{i} = [ nrfs(i).name ' | ' int2str(nrfs(i).ref) ];
		end;
		if length(strs)<max(sel), sel = []; end;
		set(ft(thefig,'LGNElectrodeList'),'string',strs,'value',sel);
		nrfs = getsubnamerefs(cksds,'ctx');
		val = get(ft(thefig,'CTXCellsPopup'),'value');
		strsctx = {''};
		for i=1:length(nrfs),
			strsctx{i+1} = [ nrfs(i).name ' | ' int2str(nrfs(i).ref) ];
		end;
		val=length(nrfs)+1;
		set(ft(thefig,'CTXCellsPopup'),'string',strsctx,'value',val);
    case 'LGNElectrodeList',
		sel=get(ft(thefig,'LGNElectrodeList'),'value');
		str=get(ft(thefig,'LGNElectrodeList'),'string');
		nrfs.name = ''; nrfs.ref = 1; nrfs = nrfs([]); % make empty
		strs = {};
		for i=1:length(sel),
			strs=cat(2,strs,getcells(cksds,getnamereffromstring(str{sel(i)})));
		end;
		v = 1:length(strs);
		set(ft(thefig,'LGNCellList'),'string',strs,'value',v);
	case 'AddDB',
		try,
			lgnctxexperpanel('SaveBt');
			cksds = getcksds(1);
			c = getcells(cksds,ud.nameref);
			data=load(getexperimentfile(cksds),c{1},'-mat');
			eval([c{1} '=getfield(data,c{1});']);
			if exist(lgn_databaseNLT)==2,
				save(lgn_databaseNLT,c{1},'-append','-mat');
			else, save(lgn_databaseNLT,c{1},'-mat'); end;
			disp([c{1} ' added to database']);
		catch, errordlg(['Could not export:' lasterr]); end;
    case 'IncCTXBt',
    case 'IncLGNBt',
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
                         'MonZEdit'};
         varlist={'RightVert','LeftVert','LeftHort','RightHort','Depth',...
                  'MonX (cm)','MonY (cm)','MonZ (cm)'};
         szlist={[1 1],[1 1],[1 1],[1 1],[1 1],[1 1],[1 1],[1 1]};
         if islistfilledin(thefig,taglist),
          [b,vals] = checksyntaxsize(thefig,taglist,szlist,1,varlist);
          if b,
            v = get(ft(thefig,'EyePopup'),'value');
            if v==1,
                errordlg('Eye popup must be filled in.'); notgood = 1;
            else,  % we're good, add
               newinfolist = cell2struct(vals,taglist,2);
               newinfolist.eye = v;
               newinfolist.name = 'Details';
               % prepare associations
               opticDisk.RightVert = newinfolist.RightVertEdit;
               opticDisk.LeftVert = newinfolist.LeftVertEdit;
               opticDisk.RightHort = newinfolist.RightHortEdit;
               opticDisk.LeftHort = newinfolist.LeftHortEdit;
               newinfolist.associate = struct('type','optic disk location',...
                 'owner','protocol_LGN','data',opticDisk,...
                 'desc','Optic disk locations (in degrees).');
               vls = get(ft(thefig,'EyePopup'),'String');
               v=get(ft(thefig,'EyePopup'),'value');
               newinfolist.associate(2) = struct('type','Dominant eye',...
                 'owner','protocol_LGN',...
                 'data',vls{v},'desc','Dominant eye');
               newinfolist.associate(3) = struct('type','Electrode depth',...
                 'owner','protocol_LGN',...
                 'data',newinfolist.DepthEdit','desc','Electrode depth');
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
    case {'OTPrefCB','SFPrefCB','TFPrefCB'},
	   cases={'OTPrefCB','SFPrefCB','TFPrefCB'};
	   edits = {'OTPrefEdit','SFPrefEdit','TFPrefEdit'};
	   varnames={'Orientation','Spatial frequency','Temporal frequency'};
	   paramnames = {'angle','sFrequency','tFrequency'};
	   for ii=1:length(cases),if strcmp(cases{ii},thetag),break;end;end;
	   val=get(ft(thefig,cases{ii}),'value');
	   if val==1, % a change from 0 to 1
         notgood = 0;
		 taglist = edits(ii); varlist = varnames(ii);
         [b,vals] = checksyntaxsize(thefig,taglist,{[1 1]},1,varlist);
         if b,
           newinfolist = cell2struct(vals,varlist);
           PSp = getparameters(ud.PS);
           PSp = setfield(PSp,paramnames{ii},vals{1});
           ud.PS = periodicscript(PSp);
           set(thefig,'userdata',ud);
         else, notgood =1;
         end;
		 if notgood, set(ft(thefig,cases{ii}),'value',0); end;
       elseif val==0, % a change from 1 to 0
       end;
    case 'LinearityCB',
       val=get(ft(thefig,'LinearityCB'),'value');
       g = findinfoinlist(thefig,'LinearityResp');
       ud.infolist = ud.infolist(setxor(1:length(ud.infolist),g));
       set(thefig,'userdata',ud);
       if val==1, % a change from 0 to 1
         notgood = 0;
         newinfolist.LPopup=get(ft(thefig,'LinearityPopup'),'value');
         newinfolist.lis = get(ft(thefig,'LinearityIndexText'),'String');
         newinfolist.li = get(ft(thefig,'LinearityIndexText'),'userdata');
         if (newinfolist.LPopup==1), notgood = 1;
               errordlg('Tuned popup must be filled in.');
         elseif isempty(newinfolist.li),
             errordlg('Linearity must be computed.'); notgood = 1;
         else, % okay to proceed
             newinfolist.name = 'LinearityResp';
             newinfolist.associate= struct('type','F2/F1 Linearity',...
               'owner','protocol_LGN',...
               'data',newinfolist.li,'desc','Linearity Index');
		     if get(ft(thefig,'Phase1CB'),'value'),
				newinfolist.associate(end+1)=struct('type',...
				'Phase 1 test',...
				'owner','protocol_LGN',...
				'data',get(ft(thefig,'Phase1TestEdit'),'String'),...
				'desc','Test number string for phase 1 test');
		     end;
		     if get(ft(thefig,'Phase2CB'),'value'),
				newinfolist.associate(end+1)=struct('type',...
				'Phase 2 test',...
				'owner','protocol_LGN',...
				'data',get(ft(thefig,'Phase2TestEdit'),'String'),...
				'desc','Test number string for phase 2 test');
		     end;
		     if get(ft(thefig,'Phase3CB'),'value'),
				newinfolist.associate(end+1)=struct('type',...
				'Phase 3 test',...
				'owner','protocol_LGN',...
				'data',get(ft(thefig,'Phase3TestEdit'),'String'),...
				'desc','Test number string for phase 3 test');
		     end;
             ud.infolist(end+1) = {newinfolist};
             set(thefig,'userdata',ud);
         end;
         if notgood, set(ft(thefig,'LinearityCB'),'value',0); end;
       elseif val==0, % a change from 1 to 0
       end;
    case 'RestoreLinearityResp',
       g = findinfoinlist(thefig,'LinearityResp');
       if ~isempty(g),
         info=ud.infolist{g};
         set(ft(thefig,'LinearityPopup'),'value',info.LPopup);
         set(ft(thefig,'LinearityIndexText'),'String',info.lis,...
                'userdata',info.li);
         set(ft(thefig,'LinearityCB'),'value',1);
       end;
    case {'RC1CB','RC2CB','SFCB','SusTransLGNCB','ContrastCB',...
		  'Phase1CB','Phase2CB',...
          'Phase3CB','TFCB','OTCB','SpontaneousCB'},
       cases={'RC1CB','RC2CB','SFCB','SusTransLGNCB','ContrastCB',...
	      'Phase1CB','Phase2CB', 'Phase3CB','TFCB','OTCB','SpontaneousCB'};
       tests={'RC1TestEdit','RC2TestEdit','SFTestEdit','SusTransLGNEdit',...
	          'ContrastTestEdit','Phase1TestEdit',...
				'Phase2TestEdit','Phase3TestEdit','TFTestEdit','OTTestEdit',...
				'SpontaneousCB'};
       % these lists are used in RestoreTestInfo as well
       asTests = {'SGS coarse tests','SGS fine tests','SF tests',...
			'SusTransLGN tests','Contrast tests','Phase1 tests',...
			'Phase2 tests', 'Phase3 tests','TF tests','OT tests',...
				'SpontaneousCB'};
	   asBestTests={'SGS coarse best test','SGS fine best test',...
			'SF best test','SusTransLGN best test','Contrast best test',...
			'Phase1 best test','Phase2 best test','Phase3 best test',...
			'TF best test','OT best test','SpontaneousCB'};
	   if get(ft(thefig,thetag),'value')==0, return; end; % nothing to do
       for ii=1:length(cases), if strcmp(thetag,cases{ii}),break;end; end;
	   teststr = get(ft(thefig,tests{ii}),'string');
	   if isempty(teststr), return; end; % nothing to do
       [c,d]= getcellinfo(cksds,teststr);
       if isempty(c), errordlg(['Test ' teststr ' not found.']);
	   else,
			for i=1:length(c),
				% first add test to test list
				assoc = [];
				oldassoc=findassociate(d{i},asTests{ii},[],[]);
				if ~isempty(oldassoc),
					[dum1,jj]=intersect(oldassoc.data,{teststr});
					if isempty(jj),
						assoc=oldassoc;
						assoc.data = cat(2,assoc.data,{teststr});
					else, assoc = []; end; % nothing to do
				else,
					assoc.type=asTests{ii};assoc.owner='protocol_lgnctx';
					assoc.data = {teststr}; assoc.desc='List of tests';
				end;
				if ~isempty(assoc),d{i}=associate(d{i},assoc); end;
				% update best test to be this one, will have to modify later
				clear assoc;
				assoc.type=asBestTests{ii};assoc.owner='protocol_lgnctx';
				assoc.data = teststr; assoc.desc='Best test';
				d{i}=associate(d{i},assoc);
				saveexpvar(cksds,d{i},c{i});
			end;
	   end;
       set(thefig,'userdata',ud);
	case 'RestoreTestInfo',
	   [c,d] = getcurrentcells(thefig,cksds,0);
       [s,v]=listdlg('PromptString','Select a cell','SelectionMode','single',...
			'ListString',c);
       if isempty(s), return; end; % user didn't choose anything, nothing to do
	   asBestTests={'SGS coarse best test','SGS fine best test',...
			'SF best test','SusTransLGN best test','Contrast best test',...
			'Phase1 best test','Phase2 best test','Phase3 best test',...
			'TF best test','OT best test','SpontaneousCB'};
       % these lists are used in the checkbox section as well
       tests={'RC1TestEdit','RC2TestEdit','SFTestEdit','SusTransLGNEdit',...
	          'ContrastTestEdit','Phase1TestEdit',...
				'Phase2TestEdit','Phase3TestEdit','TFTestEdit','OTTestEdit',...
				'SpontaneousCB'};
       for i=1:length(asBestTests),
          ass=findassociate(d{s},asBestTests{i},'protocol_lgnctx',[]);
		  if ~isempty(ass), set(ft(thefig,tests{i}),'string',ass.data); end;
       end;
    case {'AnalyzeRC1Bt','AnalyzeRC2Bt'},
	   cases = {'AnalyzeRC1Bt','AnalyzeRC2Bt'};
	   tests={'RC1TestEdit','RC2TestEdit'};
	   b = 0;
	   for i=1:length(cases),
		   if strcmp(cases{i},thetag),b=i;break;end;
	   end;
	   cksds = getcksds(1);
       g = gtn(thefig,tests{b}), ng = 0;
       if ~isempty(g),
		%reflist = getcurrentrefs(thefig),
		rclist.rc=1;rclist.cellname=1;rclist.isctx=0;rclist.center=[];
		rclist=rclist([]);%make empty list
		%for i=1:length(reflist),
			%try, 
				[s,c,data]=getcurrentstimcellinfo(thefig,cksds,g);
				if ~isempty(s),
				  for j=1:length(c),
					inp.stimtime=stimtimestruct(s,1);
					inp.spikes={getfield(data{j},c{j})};inp.cellnames=c(j);
					where.figure=figure;where.rect=[0 0 1 1];
					where.units='normalized';
					orient(where.figure,'landscape');
					rc=reverse_corr(inp,'default',where);
					tmp.rc = rc; tmp.cellname = c{j};tmp.isctx=0;tmp.center=[];
					if findstr(upper(c{j}),'CTX'),tmp.isctx=1; end;
					rclist = [rclist tmp];
			      end;
				end;
		 	%end;
		%end;
		set(ft(thefig,'RC2TestEdit'),'userdata',rclist);
       end;
    case 'RCGrabResultsBt',
       rclist  = get(ft(thefig,'RC2TestEdit'),'userdata');
       foundlgndata = 0;
       if ~isempty(rclist),
		  for j=1:length(rclist),
			w = location(rclist(j).rc);
			fig = w.figure;  % find current rc that is in the figure
			c = [];
			try, ud2 = get(fig,'userdata');
				for i=1:length(ud2),
					if (rclist(j).rc==ud2{i}),
						c = getoutput(ud2{i});
						c = c.crc;
						break; end;
				end;
			catch, errordlg('Can''t find analysis--must be open.'); ud2=[]; end;
			if ~isempty(c),
              ax = ft(thefig,'ScreenAxes');
			  axes(ax); hold on;
			  rclist(j).center = c.pixelcenter;
			  xx=rclist(j).center([1 1 1 1 1])+10*[-1 1 1 -1 -1];
			  yy=rclist(j).center([2 2 2 2 2])+10*[1 1 -1 -1 1];
              if rclist(j).isctx,
  			  	set(ft(thefig,'RCCenterLocEdit'),'String', ...
					mat2str(c.pixelcenter));
			  	lgnctxexperpanel('SetCenterBt',thefig);
			    axes(ax);
				ff=ft(ft(thefig,'ScreenAxes'),'CTXPlot');
				if ~isempty(ff), delete(ff); end;
				ff=fill(xx,yy,[0 0 1]);
				set(ff,'Tag','CTXPlot');
			  else
				if ~foundlgndata,
					ff = ft(ft(thefig,'ScreenAxes'),'LGNPlot');
					if ~isempty(ff), delete(ff); end;
					foundlgndata = 1;
				end;
				ff=fill(xx,yy,[0 1 0]);
				set(ff,'Tag','LGNPlot');
              end;
			  set(ax,'Tag','ScreenAxes');
			  set(ax,'xlim',[0 640],'ylim',[0 480],'ydir','reverse');
			end; % if ~isempty(c)
		  end;  % for
	   else, errordlg('No analysis found---try running again.'); end;
    case 'ScreenClearBt',
		ff = ft(ft(thefig,'ScreenAxes'),'CTXPlot');
		if ~isempty(ff), delete(ff); end;
		ff = ft(ft(thefig,'ScreenAxes'),'LGNPlot');
		if ~isempty(ff),delete(ff); end;
	case 'PlotCTXScreenBt',
	case 'PlotLGNScreenBt',
	case 'EditCTXInfoBt',
		ng = 0;
		v = get(ft(thefig,'CTXCellsPopup'),'value');
		str = get(ft(thefig,'CTXCellsPopup'),'string');
  		ref = getnamereffromstring(str{v});
  		try, c = getcells(cksds,ref);  % should only be one
   		catch, errordlg(['Cell data for ' str{v} ' not found.']); ng=1;
  		end;
        if ~ng,
		if isempty(c),
			errordlg('Cell data must be present first.');
		else,
			h0 = lgnctx_intinfo;
			filldefaults_int(h0,cksds,c{1});
			lgnctxexperpanel('IntCellRestoreBt',h0);
		end;
	end;
	case 'EditLGNInfoBt',
		v = get(ft(thefig,'LGNCellList'),'value');
		str = get(ft(thefig,'LGNCellList'),'string');
		for i=1:length(v),
			h0 = lgnctx_extinfo;
			filldefaults_ext(h0,cksds,str{v(i)});
			lgnctxexperpanel('ExtCellRestoreBt',h0);
		end;
	case 'IntCellRestoreBt',
		cksds=get(ft(thefig,'CellInfoStatic'),'userdata');
		cellname=get(ft(thefig,'CellInfoStatic'),'string');
		data = [];
		try,
			data=load(getexperimentfile(cksds),cellname,'-mat');
		    data=getfield(data,cellname);
		catch,
			errordlg(['Could not load data from cell ' cellname '.']);
			return;
		end;
		asc=findassociate(data,'optic disks locations','protocol_lgnctx',[]);
		if ~isempty(asc),
		   set(ft(thefig,'rightVertEdit'),'string',num2str(asc.data.RightVert));
		   set(ft(thefig,'leftVertEdit'),'string',num2str(asc.data.LeftVert));
		   set(ft(thefig,'rightHortEdit'),'string',num2str(asc.data.RightHort));
		   set(ft(thefig,'leftHortEdit'),'string',num2str(asc.data.LeftHort));
		end;
		asc=findassociate(data,'monitor position','protocol_lgnctx',[]);
		if ~isempty(asc),
		   set(ft(thefig,'MonPosXEdit'),'string',num2str(asc.data.MonPosX));
		   set(ft(thefig,'MonPosYEdit'),'string',num2str(asc.data.MonPosY));
		   set(ft(thefig,'MonPosZEdit'),'string',num2str(asc.data.MonPosZ));
		end;
		asc=findassociate(data,'depth','protocol_lgnctx',[]);
		if ~isempty(asc),
			set(ft(thefig,'DepthEdit'),'string',num2str(asc.data));
		end;
		asc=findassociate(data,'eye dominance','protocol_lgnctx',[]);
		if ~isempty(asc),
			set(ft(thefig,'EyePopup'),'value',asc.data+1);
		end;
		asc=findassociate(data,'hemisphere','protocol_lgnctx',[]);
		if ~isempty(asc),
			set(ft(thefig,'HemispherePopup'),'value',asc.data+1);
		end;
		asc=findassociate(data,'Vout','protocol_lgnctx',[]);
		if ~isempty(asc),
			set(ft(thefig,'VoutEdit'),'string',num2str(asc.data));
		end;
	case 'IntCellSaveBt',
		od = []; mp = [];
		try, od=getscreentoolopticdisks(thefig); end;
		try, mp=getscreentoolmonitorposition(thefig); end;
		assoc.type='';assoc.owner='';assoc.data=1;assoc.desc=1;assoc=assoc([]);
		if ~isempty(od),
			assoc=[assoc struct('type','optic disks locations',...
					'owner','protocol_lgnctx','data',od,...
					'desc','optic disk locations')];
		end;
		if ~isempty(mp),
			assoc=[assoc struct('type','monitor position',...
					'owner','protocol_lgnctx','data',mp,...
					'desc','monitor position')];
		end;
		d = [];
		try, ds=get(ft(thefig,'DepthEdit'),'string');
			 if ~isempty(ds), d=str2num(ds); end;
		catch,errordlg(['Syntax error in depth;must be #--depth not saved.']);
		end;
		if ~isempty(d),
			assoc=[assoc struct('type','depth','owner','protocol_lgnctx',...
				'data',d,'desc','depth of cell')];
		end;
		v_eye = get(ft(thefig,'EyePopup'),'value');
		if v_eye>1,
			assoc=[assoc struct('type','eye dominance',...
				'owner','protocol_lgnctx',...
				'data',v_eye-1,'desc','eye dominance')];
		end;
		v_hemisphere = get(ft(thefig,'HemispherePopup'),'value');
		if v_hemisphere>1,
			assoc=[assoc struct('type','hemisphere',...
				'owner','protocol_lgnctx','data',v_hemisphere-1,...
				'desc','hemisphere, 1=left, 2=right')];
		end;
		vo = [];
		try, vos=get(ft(thefig,'VoutEdit'),'string');
			if ~isempty(vos),vo=str2num(vos);end;
		catch, errordlg(['Syntax error in Vout;must be #--Vout not saved.']);
		end;
		if ~isempty(vo),
			assoc=[assoc struct('type','Vout','owner','protocol_lgnctx',...
				'data',vo,'desc','Voltage offset in intracellular record')];
		end;
		cksds=get(ft(thefig,'CellInfoStatic'),'userdata');
		cellname=get(ft(thefig,'CellInfoStatic'),'string');
		data = [];
		try,
			data=load(getexperimentfile(cksds),cellname,'-mat');
		    data=getfield(data,cellname);
		catch,
			errordlg(['Could not load data from cell ' cellname '.']);
			return;
		end;
		for i=1:length(assoc)
			data=associate(data,assoc(i));
		end;
		saveexpvar(cksds,data,cellname);
	case 'GetODLocsBt',
		ods = getscreentoolopticdisks;
		if ~isempty(ods),
			set(ft(thefig,'rightVertEdit'),'String',num2str(ods.RightVert));
			set(ft(thefig,'leftVertEdit'),'String',num2str(ods.LeftVert));
			set(ft(thefig,'rightHortEdit'),'String',num2str(ods.RightHort));
			set(ft(thefig,'leftHortEdit'),'String',num2str(ods.LeftHort));
		end;
	case 'GetMonPosBt',
		mp = getscreentoolmonitorposition;
		if ~isempty(mp),
			set(ft(thefig,'MonPosXEdit'),'string',num2str(mp.MonPosX));
			set(ft(thefig,'MonPosYEdit'),'string',num2str(mp.MonPosY));
			set(ft(thefig,'MonPosZEdit'),'string',num2str(mp.MonPosZ));
		end;
	case 'ExtCellRestoreBt',
		cksds=get(ft(thefig,'CellInfoStatic'),'userdata');
		cellname=get(ft(thefig,'CellInfoStatic'),'string');
		data = [];
		try,
			data=load(getexperimentfile(cksds),cellname,'-mat');
		    data=getfield(data,cellname);
		catch,
			errordlg(['Could not load data from cell ' cellname '.']);
			return;
		end;
		asc=findassociate(data,'optic disks locations','protocol_lgnctx',[]);
		if ~isempty(asc),
		   set(ft(thefig,'rightVertEdit'),'string',num2str(asc.data.RightVert));
		   set(ft(thefig,'leftVertEdit'),'string',num2str(asc.data.LeftVert));
		   set(ft(thefig,'rightHortEdit'),'string',num2str(asc.data.RightHort));
		   set(ft(thefig,'leftHortEdit'),'string',num2str(asc.data.LeftHort));
		end;
		asc=findassociate(data,'monitor position','protocol_lgnctx',[]);
		if ~isempty(asc),
		   set(ft(thefig,'MonPosXEdit'),'string',num2str(asc.data.MonPosX));
		   set(ft(thefig,'MonPosYEdit'),'string',num2str(asc.data.MonPosY));
		   set(ft(thefig,'MonPosZEdit'),'string',num2str(asc.data.MonPosZ));
		end;
		asc=findassociate(data,'depth','protocol_lgnctx',[]);
		if ~isempty(asc),
			set(ft(thefig,'DepthEdit'),'string',num2str(asc.data));
		end;
		asc=findassociate(data,'eye dominance','protocol_lgnctx',[]);
		if ~isempty(asc),
			set(ft(thefig,'EyePopup'),'value',asc.data+1);
		end;
		asc=findassociate(data,'hemisphere','protocol_lgnctx',[]);
		if ~isempty(asc),
			set(ft(thefig,'HemispherePopup'),'value',asc.data+1);
		end;
	case 'ExtCellSaveBt',
		od = []; mp = [];
		try, od=getscreentoolopticdisks(thefig); end;
		try, mp=getscreentoolmonitorposition(thefig); end;
		assoc.type='';assoc.owner='';assoc.data=1;assoc.desc=1;assoc=assoc([]);
		if ~isempty(od),
			assoc=[assoc struct('type','optic disks locations',...
					'owner','protocol_lgnctx','data',od,...
					'desc','optic disk locations')];
		end;
		if ~isempty(mp),
			assoc=[assoc struct('type','monitor position',...
					'owner','protocol_lgnctx','data',mp,...
					'desc','monitor position')];
		end;
		d = [];
		try, ds=get(ft(thefig,'DepthEdit'),'string');
			 if ~isempty(ds), d=str2num(ds); end;
		catch,errordlg(['Syntax error in depth;must be #--depth not saved.']);
		end;
		if ~isempty(d),
			assoc=[assoc struct('type','depth','owner','protocol_lgnctx',...
				'data',d,'desc','depth of cell')];
		end;
		v_eye = get(ft(thefig,'EyePopup'),'value');
		if v_eye>1,
			assoc=[assoc struct('type','eye dominance',...
				'owner','protocol_lgnctx',...
				'data',v_eye-1,'desc','eye dominance')];
		end;
		v_hemisphere = get(ft(thefig,'HemispherePopup'),'value');
		if v_hemisphere>1,
			assoc=[assoc struct('type','hemisphere',...
				'owner','protocol_lgnctx','data',v_hemisphere-1,...
				'desc','hemisphere, 1=left, 2=right')];
		end;
		cksds=get(ft(thefig,'CellInfoStatic'),'userdata');
		cellname=get(ft(thefig,'CellInfoStatic'),'string');
		data = [];
		try,
			data=load(getexperimentfile(cksds),cellname,'-mat');
		    data=getfield(data,cellname);
		catch,
			errordlg(['Could not load data from cell ' cellname '.']);
			return;
		end;
		for i=1:length(assoc)
			data=associate(data,assoc(i));
		end;
		saveexpvar(cksds,data,cellname);
    case 'AnalyzeCentSizeBt',
	   cksds = getcksds(1);
       g = gtn(thefig,'CentSizeTestEdit'); ng = 0;
       if ~isempty(g),
         [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
         if ~isempty(s),
		   thecell=getfield(data,c{1});
		   % need to prepare test and parameter associates
		   newassc=struct('type','Cent Size Params',...
		   		'owner','protocol_LGN',...
		   		'data',struct('evalint',get(ft(thefig,'CentSizeAnalEdit')),...
				'earlyint',get(ft(thefig,'CSEarlyEdit')),'lateint',...
				get(ft(thefig,'CSLateEdit'))),'desc',...
				'Parameters specifying center size test analysis');
		   newassc(end+1)=struct('type','Cent Size test',...
		   		'owner','protocol_LGN',...
		   		'data',get(ft(thefig,'CentSizeTestEdit'),'String'),'desc',...
				'Test number string for cent size test');
		   for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
		   try, 
  		     [nc,outstr,assocs,tc]=lgncentsizeanalysis(cksds,thecell,c{1},1);
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
    case {'AnalyzeOTBt','AnalyzeSFBt','AnalyzeTFBt','AnalyzeContrastBt', ...
			'AnalyzePhase1Bt','AnalyzePhase2Bt','AnalyzePhase3Bt'},
	   cases={'AnalyzeOTBt','AnalyzeSFBt','AnalyzeTFBt','AnalyzeContrastBt',...
	               'AnalyzePhase1Bt','AnalyzePhase2Bt','AnalyzePhase3Bt'};
	   testEditStrs = {'OTTestEdit','SFTestEdit','TFTestEdit',...
	   		'ContrastTestEdit',...
	   		'Phase1TestEdit','Phase2TestEdit','Phase3TestEdit'};
	   ps={'angle','sFrequency','tFrequency','contrast','sPhaseShift',...
	   		'sPhaseShift','sPhaseShift'};
	   prefEdits={'OTPrefEdit','SFPrefEdit','TFPrefEdit'};
	   for ii=1:length(cases), if strcmp(cases{ii},thetag),break;end;end;
	   cksds = getcksds(1);
       g = gtn(thefig,testEditStrs{ii});
       if ~isempty(g),
		 %reflist = getcurrentrefs(thefig),
		 %for i=1:length(reflist),
			[s,c,data]=getcurrentstimcellinfo(thefig,cksds,g);
			if ~isempty(s),
				for j=1:length(c),
				    isctx = ~isempty(findstr(upper(c{j}),'CTX'));
					pc = docurve(s,c(j),data{j},ps{ii},0,c{j},6);
					if isctx&get(ft(thefig,'AnalyzeCTXINTCB'),'value'),
						A.t0 = 0.001; A.t1 = 0.007; % spike removal params
						sdint=getfield(load(getexperimentfile(cksds),...
							c{j},'-mat'),c{j});
						A.spiketimes=get_data(sdint,[0 Inf],2);
						v=get(ft(thefig,'CTXCellsPopup'),'value');
						str = get(ft(thefig,'CTXCellsPopup'),'string');
						ref = getnamereffromstring(str{v});
						  %do=getDisplayOrder(s.stimscript);
						  %do=do(1:48);
						  %s.mti=s.mti(1:48);
						  %s.stimscript=setDisplayMethod(s.stimscript,2,do);
						cksmd=cksfiltereddata(getpathname(cksds),ref.name,...
							ref.ref,3,A,'','');
						comps=analyze_periodicscript_cont(cksmd, ...
								s,ps{ii},1e-3,'whole');
						plot_periodicscript_comps(comps);
					end,
					if isctx&ii<4,
						co = getoutput(pc);
						[m,mi] = max(co.f0curve{1}(2,:));
						v = co.f1curve{1}(1,mi);
						set(ft(thefig,prefEdits{ii}),'String',num2str(v));
					end;
					switch ii,
						case 2, % sf
					       if isctx,
							   s1=get(ft(thefig,'Phase1TestEdit'),'String');
					           s2=get(ft(thefig,'Phase2TestEdit'),'String');
					           s3=get(ft(thefig,'Phase3TestEdit'),'String');
					           if isempty([s1 s2 s3]),
					              set(ft(thefig,'PhaseSF1Edit'),'String',...
								     num2str(v));
					              set(ft(thefig,'PhaseSF2Edit'),'String',...
								     num2str(2*v));
					              set(ft(thefig,'PhaseSF3Edit'),'String',...
								     num2str(3*v));
							   end;
					       end;
						case {5,6,7}, % spatial phase tests
						   if ~isempty(findstr(upper(c{j}),'CTX')),
 						      set(ft(thefig,testEditStrs{ii}),'userdata',pc);
						   end;
					end;
				end;
			end;
         %end;
       end;
    case 'CorrelationBt',
	   val=get(ft(thefig,'CorrelationPopup'),'value');
       ref=getcurrentctxref(thefig);
	   ctxcellname=getcells(cksds,ref);
	   if ~isempty(ref),
		testlist = gettests(cksds,ref.name,ref.ref);
		[s,v]=listdlg('PromptString','Tests to include','ListString',testlist);
		if v>0,
			testlist = testlist(s);
			lgncells=getcurrentlgncells(thefig);
			for i=1:length(lgncells),
				if val==1, % extracellular correlation
					[dum1,dum2,dum3]=lgnctxxcorr(cksds,lgncells{i},ctxcellname{1},testlist,1);
				elseif val==2, % intracellular correlation
					[dum1,dum2,dum3]=lgnctxdomuir(cksds,ref,lgncells{i},testlist,1);
				end;
			end;
		end;
	   end;
    case 'ComputeLinearityBt',
       st{1}=get(ft(thefig,'Phase1TestEdit'),'String');
       pc{1} = get(ft(thefig,'Phase1TestEdit'),'userdata');
       st{2}=get(ft(thefig,'Phase2TestEdit'),'String');
       pc{2} = get(ft(thefig,'Phase2TestEdit'),'userdata');
       st{3}=get(ft(thefig,'Phase3TestEdit'),'String');
       pc{3} = get(ft(thefig,'Phase3TestEdit'),'userdata');
       str = {};
       for i=1:3,
          if ~isempty(st{i})&(~isempty(pc{i})), str=cat(2,str,{st{i}});end;
       end;
       if ~isempty(str),
         [s,v]=listdlg('PromptString',...
             'Which test just barely makes cell fire?',...
             'SelectionMode','single','ListString',str);
         if v,
           b = 0;
           for i=1:3, if strcmp(str{s},st{i}), b=i; end; end;
           co = getoutput(pc{b});
           li= (co.f0curve{1}(2,:)*co.f2f1curve{1}(2,:)')...
                 /(sum(co.f0curve{1}(2,:))+0.00001);
           set(ft(thefig,'LinearityIndexText'),'String',...
                 ['Linearity index: ' num2str(li)],'userdata',li);
           if li>1, set(ft(thefig,'LinearityPopup'),'value',3);
           else, set(ft(thefig,'LinearityPopup'),'value',2); end;
         end;
       else, errordlg('At least one phase test must be run.');
       end;
    case 'SpontaneousRunBt', %RCRunBt->RC1RunBt 2002-08-18
		  val = [];
		  try, 
			  val = str2num(get(ft(thefig,'SpontaneousEdit'),'string'));
		  catch, errordlg(['Time length not valid']); end;
		  if ~isempty(val),
	          LGNP_sgs_sp = stimscript(0);
			  psg=getparameters(stochasticgridstim('default'));
			  psg.rect = [0 0 640 480];
			  psg.BG = [ 128 128 128]; psg.values = [128 128 128];
			  psg.fps = 15; psg.N = psg.fps * val;
			  psg.dist = 1; psg.pixSize = [640 480];
	          LGNP_sgs_sp = append(LGNP_sgs_sp, stochasticgridstim(psg));
	          b = transferscripts({'LGNP_sgs_sp'},{LGNP_sgs_sp});
	          if b,
				dowait(0.5);
				b=runscriptremote('LGNP_sgs_sp');
				if ~b,
					errordlg('Could not run script:check RunExperiment window');
				end;
				tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
				set(ft(thefig,'SpontaneousTestEdit'),'String',tn);
			  end;
		  end;
    case 'RC1RunBt', %RCRunBt->RC1RunBt 2002-08-18
          LGNP_sgs = stimscript(0);
          LGNP_sgs = append(LGNP_sgs, ud.SGS);
          b = transferscripts({'LGNP_sgs'},{LGNP_sgs});
          if b,
               dowait(0.5);
             b=runscriptremote('LGNP_sgs');
             if ~b,
                errordlg('Could not run script--check RunExperiment window.');
             end;
             tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
             set(ft(thefig,'RC1TestEdit'),'String',tn);
          end;
    case 'RC2RunBt',
		  [cr,dist,sr]=getscreentoolparams;
		  ud.SGS2=recenterstim(ud.SGS2,{'rect',cr,'screenrect',sr,'params',1});
          LGNP_sgs2 = stimscript(0);
          LGNP_sgs2 = append(LGNP_sgs2, ud.SGS2);
		  p__=getparameters(ud.SGS2);  % check to see if same up to location
		  strs={'load toremote -mat;'
		        'if exist(''LGNP_sgs2'')==1,'
		        '   sgs_1=get(LGNP_sgs2,1);'
				'   sgs_1p=getparameters(sgs_1);'
				'   sgs_1p.rect = p__.rect;'
				'   p__.randState = sgs_1p.randState;'
				'   if sgs_1p==p__,'
				'     sameparams = 1;'
				'     sgs_1 = setparameters(sgs_1,p__);'
				'     LGNP_sgs2=set(LGNP_sgs2,sgs_1,1);'
				'   else, sameparams = 0; end;'
				'else, sameparams=0;end;'
				'save fromremote sameparams -mat;'
				'save gotit sameparams -mat;'};
		  [b,vars] = sendremotecommandvar(strs,{'p__'},{p__});
		  if b,
            if vars.sameparams==0,  % we need to transfer new version
				disp('transferring new version');
				dowait(0.5);
				b = transferscripts({'LGNP_sgs2'},{LGNP_sgs2});
			else, disp('stimulus fine.'); end;
		  end;
          if b,
               dowait(0.5);
             b=runscriptremote('LGNP_sgs2');
             if ~b,
                errordlg('Could not run script--check RunExperiment window.');
             end;
             tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
             set(ft(thefig,'RC2TestEdit'),'String',tn);
          end;
    case 'SusTransLGNRunBt',
          LGNP_cnt = stimscript(0);
          szes = [ 0:5:45 55 65 75 85 95 105];
          taglist = {'CentSizeRepsEdit','CentSizeISIEdit'};sz={[1 1],[1 1]};
          varlist = {'Center size reps','Center size ISI'};
          [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
          if b,
            p = getparameters(ud.css);
            for i=1:length(szes),
              p.radius = szes(i); p.dispprefs = {'BGpretime',vals{2}};
              LGNP_cnt = append(LGNP_cnt,centersurroundstim(p));
            end;
            LGNP_cnt = setDisplayMethod(LGNP_cnt,1,vals{1});
            b = transferscripts({'LGNP_cnt'},{LGNP_cnt});
            if b,
               dowait(0.5);
               b=runscriptremote('LGNP_cnt');
               if ~b,
                  errordlg('Could not run script--check RunExperiment window.');
               end;
               tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
               set(ft(thefig,'CentSizeTestEdit'),'String',tn);
            end;
          end;
    case 'SFRunBt',     
       if get(ft(thefig,'OTPrefCB'),'value')~=1,
          errordlg('Cannot run because OT response check box not checked.');
       else, 
          taglist = {'GratingRepsEdit','GratingISIEdit','SFRangeEdit'};
          sz={[1 1],[1 1],[]};
          varlist = {'Grating reps','Grating ISI','SF Range'};
          [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
          if b,
            p = getparameters(ud.PS);
            p.dispprefs = {'BGpretime',vals{2}};
            p.sFrequency = vals{3};
            LGNP_PS = periodicscript(p);
			[cr,dist,sr] = getscreentoolparams;
			LGNP_PS = recenterstim(LGNP_PS,...
			{'rect',cr,'screenrect',sr,'params',1});
            LGNP_PS = setDisplayMethod(LGNP_PS,1,vals{1});
            b = transferscripts({'LGNP_PS'},{LGNP_PS});
            if b,
               dowait(0.5);
               b=runscriptremote('LGNP_PS');
               if ~b,
                  errordlg('Could not run script--check RunExperiment window.');
               end;
               tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
               set(ft(thefig,'SFTestEdit'),'String',tn);
               set(ft(thefig,'SFCB'),'value',0);
               lgnctxexperpanel('SFCB',thefig);
            end;
          end;
       end;
    case 'TFRunBt',     
       if get(ft(thefig,'SFPrefCB'),'value')~=1,
          errordlg('Cannot run because SF response check box not checked.');
       else, 
          taglist = {'GratingRepsEdit','GratingISIEdit','TFRangeEdit'};
          sz={[1 1],[1 1],[]};
          varlist = {'Grating reps','Grating ISI','TF Range'};
          [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
          if b,
            p = getparameters(ud.PS);
            p.dispprefs = {'BGpretime',vals{2}};
            p.tFrequency = vals{3};
            LGNP_PS = periodicscript(p);
			[cr,dist,sr] = getscreentoolparams;
			LGNP_PS = recenterstim(LGNP_PS,...
			{'rect',cr,'screenrect',sr,'params',1});
            LGNP_PS = setDisplayMethod(LGNP_PS,1,vals{1});
            b = transferscripts({'LGNP_PS'},{LGNP_PS});
            if b,
               dowait(0.5);
               b=runscriptremote('LGNP_PS');
               if ~b,
                  errordlg('Could not run script--check RunExperiment window.');
               end;
               tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
               set(ft(thefig,'TFTestEdit'),'String',tn);
               set(ft(thefig,'TFCB'),'value',0);
               lgnctxexperpanel('TFCB',thefig);
            end;
          end;
       end;
    case 'OTRunBt',     
          taglist={'GratingRepsEdit','GratingISIEdit','OTRangeEdit','CurrStepsEdit'};
          sz={[1 1],[1 1],[],[]};
          varlist={'Grating reps','Grating ISI','OT Range','Current inj. range'};
          [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
          if b,
            p = getparameters(ud.PS);
            p.dispprefs = {'BGpretime',vals{2}};
            p.angle = vals{3};
			if get(ft(thefig,'CurrStepsCB'),'value'),
				p.dispprefs={'BGpretime',vals{2},'BGposttime',2};
			end;
            LGNP_PS = periodicscript(p);
			[cr,dist,sr] = getscreentoolparams;
			LGNP_PS = recenterstim(LGNP_PS,...
				{'rect',cr,'screenrect',sr,'params',1});
			if get(ft(thefig,'CurrStepsCB'),'value'),
				stimlength=duration(get(LGNP_PS,1))-1; % assume all are same
				z = geteditor('RunExperiment');
				if isempty(z),
					errordlg('No RunExperiment window!');
					error('No RunExperiment window!');
				end;
				LGNP_PS = setDisplayMethod(LGNP_PS,1,vals{1}*length(vals{4}));
				do=getDisplayOrder(LGNP_PS);
				cmdstr = {['igorcurrentsteps(' mat2str(vals{4}) ',' mat2str(do) ...
					',' mat2str(stimlength) ')']};
				set(ft(z,'extdevlist'),'string',cmdstr,'value',1);
			else, LGNP_PS = setDisplayMethod(LGNP_PS,1,vals{1});
			end;
            b = transferscripts({'LGNP_PS'},{LGNP_PS});
            if b,
               dowait(0.5);
               b=runscriptremote('LGNP_PS');
               if ~b,
                  errordlg('Could not run script--check RunExperiment window.');
               end;
               tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
               set(ft(thefig,'OTTestEdit'),'String',tn);
               set(ft(thefig,'OTCB'),'value',0);
               lgnctxexperpanel('OTCB',thefig);
            end;
          end;
    case 'ContrastRunBt',     
       if get(ft(thefig,'TFPrefCB'),'value')~=1,
          errordlg('Cannot run because TF response check box not checked.');
       else, 
          taglist = {'GratingRepsEdit','GratingISIEdit','ContrastRangeEdit'};
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
            LGNP_PS = periodicscript(p);
            LGNP_PS = setDisplayMethod(LGNP_PS,1,vals{1});
            b = transferscripts({'LGNP_PS'},{LGNP_PS});
            if b,
               dowait(0.5);
               b=runscriptremote('LGNP_PS');
               if ~b,
                  errordlg('Could not run script--check RunExperiment window.');
               end;
               tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
               set(ft(thefig,'ContrastTestEdit'),'String',tn);
               set(ft(thefig,'ContrastCB'),'value',0);
               lgnctxexperpanel('ContrastCB',thefig);
            end;
          end;
       end;
    case {'Phase1RunBt','Phase2RunBt','Phase3RunBt'},
       cases = {'Phase1RunBt','Phase2RunBt','Phase3RunBt'};
       tes = {'Phase1TestEdit','Phase2TestEdit','Phase3TestEdit'};
       cbs = {'Phase1CB','Phase2CB','Phase3CB'};
       [d,i] = intersect(cases,thetag);
       sfs={'PhaseSF1Edit','PhaseSF2Edit','PhaseSF3Edit'};
       if get(ft(thefig,'TFPrefCB'),'value')~=1,
          errordlg('Cannot run because TF response check box not checked.');
       else, 
          taglist = {'GratingRepsEdit','GratingISIEdit','PhaseRangeEdit',...
                sfs{i}};
          sz={[1 1],[1 1],[],[1 1]};
          varlist = {'Grating reps','Grating ISI','Phase Range','@SF'};
          [b,vals] = checksyntaxsize(thefig,taglist,sz,1,varlist);
          if b,
            p = getparameters(ud.PS);
            p.dispprefs = {'BGpretime',vals{2}};
            p.sPhaseShift = vals{3};
            p.sFrequency = vals{4};
            % switch to counterphase
            p.imageType = 2; p.animType = 2; p.flickerType = 2;
            LGNP_PS = periodicscript(p);
			[cr,dist,sr] = getscreentoolparams;
			LGNP_PS = recenterstim(LGNP_PS,...
			{'rect',cr,'screenrect',sr,'params',1});
            LGNP_PS = setDisplayMethod(LGNP_PS,1,vals{1});
            b = transferscripts({'LGNP_PS'},{LGNP_PS});
            if b,
               dowait(0.5);
               b=runscriptremote('LGNP_PS');
               if ~b,
                  errordlg('Could not run script--check RunExperiment window.');
               end;
               tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
               set(ft(thefig,tes{i}),'String',tn);
               set(ft(thefig,cbs{i}),'value',0);
               lgnctxexperpanel(cbs{i},thefig);
            end;
          end;
       end;
    case 'VarRestore', % restore variables from saved
       sn = get(ft(thefig,'VarNameEdit'),'String');
       ef = getexperimentfile(cksds);
       g = [];
       try, g=load(ef,sn,'-mat');
       catch, errordlg(['Could not read that variable from experiment file '...
                        ef '.']); sn=[];
       end;
       if ~isempty(sn)&~isempty(fieldnames(g)),
         filldefaults(thefig,struct('name','temp','ref',0),'');
         infolist = getfield(g,sn);
         ud.infolist = {}; set(thefig,'userdata',ud);
         for i=1:length(infolist),
            ud.infolist(end+1) = {infolist{i}};
            set(thefig,'userdata',ud);
            lgnctxexperpanel(['Restore' infolist{i}.name],thefig);
            %try, lgnctxexperpanel(['Restore' infolist{i}.name],thefig);
            %catch, ud.infolist=ud.infolist(1:end-1);
            %end;
         end;
       else, errordlg(['Could not read that variable from experiment file.']);
       end;
  otherwise, disp(['unhandled tag ' thetag '.']);
  end;
%  switch thetag, % save if necessary
%     case {'DetailCB','RCRespCB','RCCB','CentSizeCB','CentSizeRespCB',...
%          'SFCB','ContrastCB','Phase1CB','Phase2CB','Phase3CB',...
%          'TFCB','OTCB','SFPrefCB','OTPrefCB','TFPrefCB','ConeCB',...
%          'LinearityCB','ConeRespCB'},
%         if get(ft(thefig,thetag),'value')==1,lgnctxexperpanel('Save',thefig);end;
%  end;
end;

 % handy subfunctions

 % return namerefs matching str (see findstr), not case sensitive
function namerefs = getsubnamerefs(cksds,str)
namerefs =[];
z = geteditor('RunExperiment');
udre = get(z,'userdata');
udre2 = get(udre.list_aq,'userdata');

nrf = getallnamerefs(cksds);
if isempty(udre2)&isempty(nrf),
	errordlg('Needs an aquisition record or recorded data.'); return;
end;
for i=1:length(udre2),
	goodmatch = 0;
	for j=1:length(nrf), if udre2(i)==nrf(j),goodmatch=1; end; end;
	nn.name = udre2(i).name;nn.ref = udre2(i).ref;
	if ~goodmatch, nrf=[nrf nn]; end;
end;

inds = [];
for i=1:length(nrf),
	if ~isempty(findstr(upper(str),upper(nrf(i).name))),inds=[inds i];end;
end;
namerefs = nrf(inds);

function ag = docurve(s,c,data,paramname,tuning,title,lastfig)
inp.st = s; inp.spikes = getfield(data,c{1}); inp.paramname = paramname;
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
data = {};
for i=1:length(c),
  try, data{i}=load(getexperimentfile(cksds),c{i},'-mat');
  catch, ng=1;errordlg(['Cell data ' c{i} 'not found in experiment file.']);end;
end;
if ng==1, s = []; c = []; data = []; end;

function [c,data] = getcellinfo(cksds,testname)
ng = 0;
try, refs = getnamerefs(cksds,testname);
catch, errordlg(['Could not find records in directory ' testname '.']);ng=1;end;
c = {};
for i=1:length(refs),
    cn = {};
	try, cn = getcells(cksds,refs(i));
	catch,
		errordlg(['Cell data for ' refs(i).name ' | ' int2str(refs(i).ref) ...
				' not found.']); ng=1;
	end;
    c = cat(2,c,cn);
end;
data = {};
for i=1:length(c),
  try, data{i}=load(getexperimentfile(cksds),c{i},'-mat');
	   data{i}=getfield(data{i},c{i});
  catch, ng=1;errordlg(['Cell data ' c{i} 'not found in experiment file.']);end;
end;
if ng==1, c = []; data = []; end;


function [c,d] = getcurrentcells(thefig,cksds,onlyanalysis)
c = {}; d = {}; ng = 0;
if get(ft(thefig,'AnalyzeCTXCB'),'value')|(~onlyanalysis),
  v = get(ft(thefig,'CTXCellsPopup'),'value');
  str = get(ft(thefig,'CTXCellsPopup'),'string');
  ref = getnamereffromstring(str{v});
  try, c = cat(2,c,getcells(cksds,ref));
  catch, errordlg(['Cell data for ' str{v} ' not found.']); ng=1;
  end;
end;
if get(ft(thefig,'AnalyzeLGNCB'),'value')|(~onlyanalysis),
  str=get(ft(thefig,'LGNCellList'),'string');
  sel=get(ft(thefig,'LGNCellList'),'value');
  if isempty(c), c = c'; end;
  c = cat(2,c,str(sel)');
end;
for i=1:length(c),
  try, d{i}=load(getexperimentfile(cksds),c{i},'-mat');
	d{i}=getfield(d{i},c{i});
  catch, ng=1;errordlg(['Cell data ' c{i} 'not found in experiment file.']);end;
end;
if ng, c = {}; d = {}; end;

function [s,c,data] = getcurrentstimcellinfo(thefig,cksds,testname)
ng = 0;
try, s = getstimscripttimestruct(cksds,testname);
catch, errordlg('Stimulus data not found.'); ng=1; end;
c = {};
if get(ft(thefig,'AnalyzeCTXCB'),'value'),
  v = get(ft(thefig,'CTXCellsPopup'),'value');
  str = get(ft(thefig,'CTXCellsPopup'),'string');
  ref = getnamereffromstring(str{v});
  try, c = cat(2,c,getcells(cksds,ref));
  catch, errordlg(['Cell data for ' str{v} ' not found.']); ng=1;
  end;
end;
if get(ft(thefig,'AnalyzeLGNCB'),'value'),
  str=get(ft(thefig,'LGNCellList'),'string');
  sel=get(ft(thefig,'LGNCellList'),'value');
  c = cat(2,c,str(sel)');
end;
data = {};
for i=1:length(c),
  try, data{i}=load(getexperimentfile(cksds),c{i},'-mat');
  catch, ng=1;errordlg(['Cell data ' c{i} 'not found in experiment file.']);end;
end;
if ng==1, s = []; c = []; data = []; end;

function refs = getcurrentctxref(thefig)
refs.name='test';refs.ref=1;refs=refs([]);
v=get(ft(thefig,'CTXCellsPopup'),'value');
str=get(ft(thefig,'CTXCellsPopup'),'string');
refs(end+1)=getnamereffromstring(str{v});

function cells = getcurrentlgncells(thefig);
refs.name='test';refs.ref = 1; refs = refs([]); % make empty struct
vals = get(ft(thefig,'LGNCellList'),'value');
str = get(ft(thefig,'LGNCellList'),'String');
cells = str(vals);

function refs = getcurrentrefs(thefig)
refs.name='test';refs.ref = 1; refs = refs([]); % make empty struct
if get(ft(thefig,'AnalyzeCTXCB'),'value'),
	v = get(ft(thefig,'CTXCellsPopup'),'value');
	str = get(ft(thefig,'CTXCellsPopup'),'string');
	refs(end+1) = getnamereffromstring(str{v});
end;
if get(ft(thefig,'AnalyzeLGNCB'),'value'),
	vals = get(ft(thefig,'LGNCellList'),'value');
	str = get(ft(thefig,'LGNCellList'),'String');
	for i=1:length(vals),
		refs(end+1) = getnamereffromstring(str{vals(i)});
	end;
end;

function nref = getnamereffromstring(str)
i = findstr(str,' | ');
if isempty(i), nref = []; return; end;
nref.name=str(1:i-1);
nref.ref=str2num(str(i+3:end));


 % get test number
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

function h1 = drawfig

h1 = lgnctxpanelfig;

function filldefaults_int(h1,cksds,cellname)
set(h1,'Tag','lgnctxexperpanel');
set(ft(h1,'EyePopup'),'String',...
  {'','Ipsi completely dom','Ipsi mostly dom','Ipsi slightly dom',...
  'equal','Contra slightly dom','Contra mostly dom','Contra completely dom'},...
  'value',1);
set(ft(h1,'HemispherePopup'),'String',{'','left','right'},'value',1);
set(ft(h1,'CellInfoStatic'),'string',cellname,'userdata',cksds);
set(ft(h1,'VoutEdit'),'string',0);

function filldefaults_ext(h1,cksds,cellname)
set(h1,'Tag','lgnctxexperpanel');
set(ft(h1,'EyePopup'),'String',...
  {'','Ipsi completely dom','Ipsi mostly dom','Ipsi slightly dom',...
  'equal','Contra slightly dom','Contra mostly dom','Contra completely dom'},...
  'value',1);
set(ft(h1,'HemispherePopup'),'String',{'','left','right'},'value',1);
set(ft(h1,'CellInfoStatic'),'string',cellname,'userdata',cksds);
set(ft(h1,'VoutEdit'),'string',0);

function filldefaults(h1,nameref,expf)
squirrelcolor
set(h1,'Tag','lgnctxexperpanel');

set(findobj(h1,'style','checkbox'),'value',0);

[cr,dist,sr] = getscreentoolparams;

SGSp=struct('rect',[0 0 630 480],'BG',round(mean([squirrel_white'; 0 0 0])),...
              'values',[squirrel_white'; 0 0 0],'dist',[1;1],...
              'pixSize',[42 32],'N',4000,'fps',30,'randState',rand('state'),...
              'dispprefs',{{}});
SGS2p=struct('rect',[0 0 255 255],'BG',round(mean([squirrel_white'; 0 0 0])),...
              'values',[squirrel_white'; 0 0 0],'dist',[1;1],...
              'pixSize',[17 17],'N',4000,'fps',30,'randState',rand('state'),...
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

PSp = struct('imageType',2,'animType',4,'flickerType',0,'angle',[0],...
             'chromhigh',squirrel_white','chromlow',[0 0 0],'sFrequency',0.1,...
             'sPhaseShift',0,'tFrequency',4,'barWidth',0.5,... % 'distance',57,
             'rect',[0 0 400 400],'nCycles',5,'contrast',0.8,...
             'background',0.5,'backdrop',0.5,'barColor',1,'nSmoothPixels',2,...
             'fixedDur',0,'windowShape',0,'dispprefs',{{'BGpretime',2}});
PS = periodicscript(PSp);
PS = recenterstim(PS,{'rect',cr,'screenrect',sr,'params',1});

ud = struct('SGS',SGS,'SGS2',SGS2,'css',css,'PS',PS,'infolist',[]);
set(h1,'userdata',ud);

% set default parameters in figure

set(ft(h1,'CurrStepsEdit'),'string','[100 -100 -300]');

set(ft(h1,'SusTransLGNRepsEdit'),'String','10');
set(ft(h1,'SusTransLGNISIEdit'),'String','0.5');

set(ft(h1,'GratingRepsEdit'),'String','5');
set(ft(h1,'GratingISIEdit'),'String','1');
set(ft(h1,'OTRangeEdit'),'String','[0:30:330]');
set(ft(h1,'TFRangeEdit'),'String','[0.5 1 2 4 8 16 32]');
set(ft(h1,'SFRangeEdit'),'String','[0.05 0.1 0.2 0.4 0.6 0.8 1.2]');
set(ft(h1,'ContrastRangeEdit'),'String','[0.02 0.08 0.16 0.32 0.64 0.8 1]');
set(ft(h1,'PhaseRangeEdit'),'String','[0:pi/6:(pi-pi/6)]');

% set up popup menus
set(ft(h1,'LinearityPopup'),'String',{' ','Linear','Non-linear'});
set(ft(h1,'CTXCellsPopup'),'String',{' '});
set(ft(h1,'LGNCellList'),'max',2);
set(ft(h1,'LGNElectrodeList'),'max',2);
set(ft(h1,'ExportLogBt'),'enable','off');
set(ft(h1,'AddDB'),'enable','off');

set(ft(h1,'PlotLGNScreenBt'),'enable','off','visible','off');
set(ft(h1,'PlotCTXScreenBt'),'enable','off','visible','off');

set(ft(h1,'SusTransLGNRunBt'),'enable','off');
set(ft(h1,'SpontaneousEdit'),'string','60');
set(ft(h1,'IncCTXBt'),'enable','off','visible','off');
set(ft(h1,'IncLGNBt'),'enable','off','visible','off');

set(ft(h1,'ScreenAxes'),'xlim',[0 640],'ylim',[0 480],'ydir','reverse');

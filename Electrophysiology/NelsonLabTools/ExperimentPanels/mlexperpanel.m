function mlexperpanel(cbo, fig)

  % if cbo is text, then is command; else, the tag is used as command
  % if fig is given, it is used; otherwise, callback figure is used

squirrelcolor;

global ml_databaseNLT;

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
			mlexperpanel('SaveBt');
			cksds = getcksds(1);
			c = getcells(cksds,ud.nameref);
			data=load(getexperimentfile(cksds),c{1},'-mat');
			eval([c{1} '=getfield(data,c{1});']);
			if exist(ml_databaseNLT)==2,
				save(ml_databaseNLT,c{1},'-append','-mat');
			else, save(ml_databaseNLT,c{1},'-mat'); end;
			disp([c{1} ' added to database']);
		catch, errordlg(['Could not export:' lasterr]); end;
    case 'SaveBt', % formerly ExportNameRefBt
       bts = {'DetailCB','RCCB','RC1CB','RC2CB','RCRespCB',...
          'MotionCB','MotionRespCB','RotationCB','RotationRespCB',...
		  'ExpandCB','ExpandRespCB','OTCB','OTPrefCB','SFCB','SFPrefCB',...
          'TFCB','TFPrefCB','ContrastCB','Phase1CB','Phase2CB','Phase3CB',...
          'LinearityCB','MotionRespCB','ContrastRespCB'};
       good = 1;
       try, for i=1:length(bts), mlexperpanel(bts{i},thefig); end;
       catch, errordlg(['Cannot export - ' bts{i} ' not ready.']); good=0;end;
       try, c=getcells(cksds,ud.nameref);
            data=load(getexperimentfile(cksds),c{1},'-mat');
            data = getfield(data,c{1});
       catch, errordlg(['Could not load cell data.']); good = 0; end;
       if good,
          mlexperpanel('OldSaveBt',thefig);
          ud = get(thefig,'userdata'); cksds=getcksds;
          mods = {'Details','RCResp','CentSizeResp','MotionResp','OTResp',...
                  'LinearityResp','SFResp','TFResp','ContrastResp','Misc'};
          for i=1:length(mods),
             g = findinfoinlist(thefig,mods{i});
             if ~isempty(g),
                info = ud.infolist{g};
                if isfield(info,'associate'),
                  for j=1:length(info.associate),
					 % delete any earlier associate of same type
                     [a,I]=findassociate(data,info.associate(j).type,...
						'protocol_ML',[]);
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
       bts = {'DetailCB','RCCB','RC1CB','RC2CB','RCRespCB',...
          'MotionCB','MotionRespCB','RotationCB','RotationRespCB',...
		  'ExpandCB','ExpandRespCB','OTCB','OTPrefCB','SFCB','SFPrefCB',...
          'TFCB','TFPrefCB','ContrastCB','Phase1CB','Phase2CB','Phase3CB',...
          'LinearityCB','ContrastRespCB'};
	   numbuts = 0;
       try,
		   for i=1:length(bts),
		     mlexperpanel(bts{i},thefig);
		     if get(ft(thefig,bts{i}),'value'),numbuts=numbuts+1; end;
	       end;
       catch, errordlg(['Cannot save - ' bts{i} ' not ready.']); return; end;
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
       newinfo.gratingresp = get(ft(thefig,'GratingRespPopup'),'value');
       newinfo.MLlayer = get(ft(thefig,'MLLayerPopup'),'value');
       newinfo.MLputlayer = get(ft(thefig,'MLPutLayerPopup'),'value');
       newinfo.isolation = get(ft(thefig,'IsolationPopup'),'value');
       newinfo.comments = get(ft(thefig,'CommentsEdit'),'String');
       newinfo.css = ud.css; newinfo.SGS = ud.SGS; newinfo.PS = ud.PS;
	   newinfo.SGS2 = ud.SGS2;
       newinfo.nameref = ud.nameref;
       newinfo.name = 'Misc';
       newinfo.associate = [];
          v = get(ft(thefig,'GratingRespPopup'),'value');
          vls = get(ft(thefig,'GratingRespPopup'),'String');
       if v~=1,
         newinfo.associate(end+1) = struct('type','Grating response',...
         'owner','protocol_ML','data',vls{v},'desc',...
         'Experimenter''s report if grating response was good.');
       end;
          v   = get(ft(thefig,'MLLayerPopup'),'value');
          vls = get(ft(thefig,'MLLayerPopup'),'String');
		  v2  = get(ft(thefig,'MLPutLayerPopup'),'value');
		  vls2= get(ft(thefig,'MLPutLayerPopup'),'String');
          vls3= get(ft(thefig,'IsolationPopup'),'String');
       if newinfo.MLlayer~=1,
          newinfo.associate(end+1)=struct('type','ML Layer',...
             'owner','protocol_ML',...
             'data',vls{v},'desc','ML layer as identified by histology');
       end;
	   if newinfo.MLputlayer~=1,
		   newinfo.associate(end+1)=struct('type','ML Putative Layer',...
		      'owner','protocol_ML',...
			  'data',vls2{v2},'desc','ML layer as identified by mapping');
	   end;
       if newinfo.isolation~=1,
		   newinfo.associate(end+1)=struct('type','Unit isolation',...
			  'owner','protocol_ML',...
			  'data',vls3{newinfo.isolation},'desc',...
              'Quality of unit isolation as determined by experimenter');
       end;
       if ~isempty(newinfo.comments),
            newinfo.associate(end+1)=struct('type','Comments',...
            'owner','protocol_ML',...
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
          set(ft(thefig,'GratingRespPopup'),'value',info.gratingresp);
          set(ft(thefig,'MLLayerPopup'),'value',info.MLlayer);
		  if isfield(info,'MLputlayer'),
			  set(ft(thefig,'MLPutLayerPopup'),'value',info.MLputlayer);end;
          if isfield(info,'isolation'),
			  set(ft(thefig,'IsolationPopup'),'value',info.isolation);end;
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
                 'owner','protocol_ML','data',opticDisk,...
                 'desc','Optic disk locations (in degrees).');
               vls = get(ft(thefig,'EyePopup'),'String');
               v=get(ft(thefig,'EyePopup'),'value');
               newinfolist.associate(2) = struct('type','Dominant eye',...
                 'owner','protocol_ML',...
                 'data',vls{v},'desc','Dominant eye');
               newinfolist.associate(3) = struct('type','Electrode depth',...
                 'owner','protocol_ML',...
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
    case 'RestoreDetails',
       g = findinfoinlist(thefig,'Details');
       if ~isempty(g),
         info = ud.infolist{g};
         taglist={'RightVertEdit','LeftVertEdit',...
                         'LeftHortEdit',...
                         'RightHortEdit','DepthEdit','MonXEdit','MonYEdit',...
                         'MonZEdit'};
         varlist={'RightVert','LeftVert','LeftHort','RightHort','Depth',...
                  'MonX (cm)','MonY (cm)','MonZ (cm)'};
         for i=1:length(taglist),
           set(ft(thefig,taglist{i}),...
                 'String',num2str(getfield(info,taglist{i})));
         end;
         set(ft(thefig,'EyePopup'),'value',info.eye);
         set(ft(thefig,'DetailCB'),'value',1);
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
            NewStimGlobals; % for NewStimPixelsPerCm
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
				newinfolist.associate(end+1)=struct('type','RC coarse test',...
				'owner','protocol_ML',...
				'data',get(ft(thefig,'RC1TestEdit'),'String'),...
				'desc','Test number string for RC coarse test');
			 end;
			 if get(ft(thefig,'RC2CB'),'value'),
				newinfolist.associate(end+1)=struct('type','RC fine test',...
				'owner','protocol_ML',...
				'data',get(ft(thefig,'RC2TestEdit'),'String'),...
				'desc','Test number string for RC fine test');
			 end;
             if ~isempty(newinfolist.rclatency),
               newinfolist.associate(end+1)= struct('type',...
                'reverse correlation latency test',...
                'owner','protocol_ML',...
                'data',get(ft(thefig,'RCLatencyText'),'userdata'),...
                'desc',...
                'Latency as determined by reverse correlation analysis');
             end;
             if ~isempty(newinfolist.rctransience),
                newinfolist.associate(end+1)=struct('type',...
                'reverse correlation transience test',...
                'owner','protocol_ML',...
                'data',get(ft(thefig,'RCTransienceText'),'userdata'),...
                'desc',...
                'Transcience as determined by reverse correlation analysis');
             end;
             newinfolist.associate(end+1)= struct('type','RF location',...
                'owner','protocol_ML','data',rf,...
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
         set(ft(thefig,'RCTransienceText'),'String',...
			num2str(info.rctransience),'userdata',info.rctransience);
         vls = get(ft(thefig,'CenterPopup'),'String');
         for i=1:length(vls),
            if strcmp(vls{i},info.centerval),
               set(ft(thefig,'CenterPopup'),'value',i);
            end;
         end;
         set(ft(thefig,'RCRespCB'),'value',1);
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
    case 'MotionRespCB',
       val=get(ft(thefig,'MotionRespCB'),'value');
       g = findinfoinlist(thefig,'MotionResp');
       ud.infolist = ud.infolist(setxor(1:length(ud.infolist),g));
       set(thefig,'userdata',ud);
       if val==1, % a change from 0 to 1
		newinfo.name='MotionResp';
		newinfo.associate=struct('type','t','owner','t','data',0,'desc',0);
		newinfo.associate=newinfo.associate([]); % make empty
		if get(ft(thefig,'MotionCB'),'value'),
				newinfo.associate(end+1)=struct('type',...
				'Motion test',...
				'owner','protocol_ML',...
				'data',get(ft(thefig,'MotionTestEdit'),'String'),...
				'desc','Test number string for random motion test');
		end;
		newinfo.associate=[newinfo.associate ];
        ud.infolist(end+1) = {newinfo};
        set(thefig,'userdata',ud);
       elseif val==0, % a change from 1 to 0
       end;
    case 'RestoreMotionResp',
       g = findinfoinlist(thefig,'MotionResp');
       if ~isempty(g),
			info = ud.infolist{g};
		    cksds=getcksds(1); c=getcells(cksds,ud.nameref);
		    data=load(getexperimentfile(cksds),c{1},'-mat');
			cell=getfield(data,c{1});
			set(ft(thefig,'MotionRespCB'),'value',1);
			assoclist = mlassociatelist('Motion test');
			saveasslist = [];
			for i=1:length(assoclist),
				ass = findassociate(cell,assoclist{i},'protocol_ML',[]);
				if ~isempty(ass),
					saveasslist = [saveasslist ass];
				end;
			end;
       end;
    case 'RotationRespCB',
       val=get(ft(thefig,'RotationRespCB'),'value');
       g = findinfoinlist(thefig,'RotationResp');
       ud.infolist = ud.infolist(setxor(1:length(ud.infolist),g));
       set(thefig,'userdata',ud);
       if val==1, % a change from 0 to 1
		newinfo.name='RotationResp';
		newinfo.associate=struct('type','t','owner','t','data',0,'desc',0);
		newinfo.associate=newinfo.associate([]); % make empty
		if get(ft(thefig,'RotationCB'),'value'),
				newinfo.associate(end+1)=struct('type',...
				'Rotation test',...
				'owner','protocol_ML',...
				'data',get(ft(thefig,'RotationTestEdit'),'String'),...
				'desc','Test number string for random motion test');
		end;
		newinfo.associate=[newinfo.associate ];
        ud.infolist(end+1) = {newinfo};
        set(thefig,'userdata',ud);
       elseif val==0, % a change from 1 to 0
       end;
    case 'RestoreRotationResp',
       g = findinfoinlist(thefig,'RotationResp');
       if ~isempty(g),
			info = ud.infolist{g};
		    cksds=getcksds(1); c=getcells(cksds,ud.nameref);
		    data=load(getexperimentfile(cksds),c{1},'-mat');
			cell=getfield(data,c{1});
			set(ft(thefig,'RotationRespCB'),'value',1);
			assoclist = mlassociatelist('Rotation test');
			saveasslist = [];
			for i=1:length(assoclist),
				ass = findassociate(cell,assoclist{i},'protocol_ML',[]);
				if ~isempty(ass),
					saveasslist = [saveasslist ass];
				end;
			end;
       end;
    case 'ExpandRespCB',
       val=get(ft(thefig,'ExpandRespCB'),'value');
       g = findinfoinlist(thefig,'ExpandResp');
       ud.infolist = ud.infolist(setxor(1:length(ud.infolist),g));
       set(thefig,'userdata',ud);
       if val==1, % a change from 0 to 1
		newinfo.name='ExpandResp';
		newinfo.associate=struct('type','t','owner','t','data',0,'desc',0);
		newinfo.associate=newinfo.associate([]); % make empty
		if get(ft(thefig,'ExpandCB'),'value'),
				newinfo.associate(end+1)=struct('type',...
				'Expand test',...
				'owner','protocol_ML',...
				'data',get(ft(thefig,'ExpandTestEdit'),'String'),...
				'desc','Test number string for random motion test');
		end;
		newinfo.associate=[newinfo.associate ];
        ud.infolist(end+1) = {newinfo};
        set(thefig,'userdata',ud);
       elseif val==0, % a change from 1 to 0
       end;
    case 'RestoreExpandResp',
       g = findinfoinlist(thefig,'ExpandResp');
       if ~isempty(g),
			info = ud.infolist{g};
		    cksds=getcksds(1); c=getcells(cksds,ud.nameref);
		    data=load(getexperimentfile(cksds),c{1},'-mat');
			cell=getfield(data,c{1});
			set(ft(thefig,'ExpandRespCB'),'value',1);
			assoclist = mlassociatelist('Expand test');
			saveasslist = [];
			for i=1:length(assoclist),
				ass = findassociate(cell,assoclist{i},'protocol_ML',[]);
				if ~isempty(ass),
					saveasslist = [saveasslist ass];
				end;
			end;
       end;
    case 'OTPrefCB',
       val=get(ft(thefig,'OTPrefCB'),'value');
       g = findinfoinlist(thefig,'OTResp');
       ud.infolist = ud.infolist(setxor(1:length(ud.infolist),g));
       set(thefig,'userdata',ud);
       if val==1, % a change from 0 to 1
         notgood = 0;
         taglist = {'OTPrefEdit'}; varlist = {'OrientationTuning'};
         [b,vals] = checksyntaxsize(thefig,taglist,{[1 1]},1,varlist);
         if b,
           newinfolist = cell2struct(vals,varlist);
           newinfolist.OTPopup=get(ft(thefig,'OTPopup'),'value');
           newinfolist.dis = get(ft(thefig,'DirectionIndText'),'String');
           newinfolist.di = get(ft(thefig,'DirectionIndText'),'userdata');
           newinfolist.ois = get(ft(thefig,'OrIndText'),'String');
           newinfolist.oi = get(ft(thefig,'OrIndText'),'userdata');
           newinfolist.associate= struct('type','Direction Index',...
              'owner','protocol_ML',...
              'data',get(ft(thefig,'DirectionIndText'),'userdata'),...
              'desc','Direction index');
           newinfolist.associate(2)= struct('type','Orientation Index',...
              'owner','protocol_ML',...
              'data',get(ft(thefig,'OrIndText'),'userdata'),...
              'desc','Orientation index');
           newinfolist.associate(3)= struct('type','Direction preference',...
              'owner','protocol_ML','data',newinfolist.OrientationTuning,...
              'desc','Direction with maximum response.');
           co=get(ft(thefig,'OTPrefEdit'),'userdata');
		   if ~isempty(co),
			  newinfolist.associate(end+1)=struct('type',...
				'Orientation response','owner','protocol_ML','data',co,...
			    'desc','Periodic curve output to orientation grating');
		   end;
			if get(ft(thefig,'OTCB'),'value'),
				newinfolist.associate(end+1)=struct('type',...
				'Orientation test',...
				'owner','protocol_ML',...
				'data',get(ft(thefig,'OTTestEdit'),'String'),...
				'desc','Test number string for orientation test');
			end;
           newinfolist.co = co;
           if (newinfolist.OTPopup==1), notgood = 1;
               errordlg('Tuned popup must be filled in.');
           else, % okay to proceed
             newinfolist.name = 'OTResp';
             ud.infolist(end+1) = {newinfolist};
             PSp = getparameters(ud.PS);
             PSp.angle = vals{1};
             ud.PS = periodicscript(PSp);
             set(thefig,'userdata',ud);
           end;
         else, notgood =1;
         end;
         if notgood, set(ft(thefig,'OTPrefCB'),'value',0); end;
       elseif val==0, % a change from 1 to 0
       end;
    case 'RestoreOTResp',
       g = findinfoinlist(thefig,'OTResp');
       if ~isempty(g),
         info=ud.infolist{g};
         set(ft(thefig,'OTPrefEdit'),'String',num2str(info.OrientationTuning));
         set(ft(thefig,'DirectionIndText'),'String',info.dis,...
              'userdata',info.di);
         set(ft(thefig,'OrIndText'),'String',info.ois,'userdata',info.oi);
         set(ft(thefig,'OTPopup'),'value',info.OTPopup);
         set(ft(thefig,'OTPrefCB'),'value',1);
         if isfield(info,'co'),
			set(ft(thefig,'OTPrefEdit'),'userdata',info.co);
		 end;
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
               'owner','protocol_ML',...
               'data',newinfolist.li,'desc','Linearity Index');
		     if get(ft(thefig,'Phase1CB'),'value'),
				newinfolist.associate(end+1)=struct('type',...
				'Phase 1 test',...
				'owner','protocol_ML',...
				'data',get(ft(thefig,'Phase1TestEdit'),'String'),...
				'desc','Test number string for phase 1 test');
		     end;
		     if get(ft(thefig,'Phase2CB'),'value'),
				newinfolist.associate(end+1)=struct('type',...
				'Phase 2 test',...
				'owner','protocol_ML',...
				'data',get(ft(thefig,'Phase2TestEdit'),'String'),...
				'desc','Test number string for phase 2 test');
		     end;
		     if get(ft(thefig,'Phase3CB'),'value'),
				newinfolist.associate(end+1)=struct('type',...
				'Phase 3 test',...
				'owner','protocol_ML',...
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
    case 'SFPrefCB',
       val=get(ft(thefig,'SFPrefCB'),'value');
       g = findinfoinlist(thefig,'SFResp');
       ud.infolist = ud.infolist(setxor(1:length(ud.infolist),g));
       set(thefig,'userdata',ud);
       if val==1, % a change from 0 to 1
         notgood = 0;
         taglist = {'SFPrefEdit'}; varlist = {'spatial frequency preference'};
         [b,vals] = checksyntaxsize(thefig,taglist,{[1 1]},1,varlist);
         if b,
           newinfolist = cell2struct(vals,taglist);
           newinfolist.name = 'SFResp';
           newinfolist.associate=struct('type',...
            'Spatial frequency preference',...
            'owner','protocol_ML','data',newinfolist.SFPrefEdit,...
            'desc','Spatial frequency with maximum response.');
           co = get(ft(thefig,'SFPrefEdit'),'userdata');
		   if ~isempty(co),
			  newinfolist.associate(end+1)=struct('type',...
				'Spatial frequency response','owner','protocol_ML',...
				'data',co,'desc',...
				'Periodic curve response to spatial frequency gratings');
		   end;
		   if get(ft(thefig,'SFCB'),'value'),
				newinfolist.associate(end+1)=struct('type',...
				'Spatial frequency test',...
				'owner','protocol_ML',...
				'data',get(ft(thefig,'SFTestEdit'),'String'),...
				'desc','Test number string for spatial frequency test');
		   end;
		   newinfolist.co = co;
           ud.infolist(end+1) = {newinfolist};
           PSp = getparameters(ud.PS);
           PSp.sFrequency = vals{1};
           ud.PS = periodicscript(PSp);
           set(thefig,'userdata',ud);
         else, notgood =1;
         end;
         if notgood, set(ft(thefig,'SFPrefCB'),'value',0); end;
       elseif val==0, % a change from 1 to 0
       end;
    case 'RestoreSFResp',
       g = findinfoinlist(thefig,'SFResp');
       if ~isempty(g),
         info = ud.infolist{g};
         set(ft(thefig,'SFPrefEdit'),'String',info.SFPrefEdit);
         set(ft(thefig,'SFPrefCB'),'value',1);
		 if isfield(info,'co'),
			set(ft(thefig,'SFPrefEdit'),'userdata',info.co);
		 end;
       end;
    case 'TFPrefCB',
       val=get(ft(thefig,'TFPrefCB'),'value');
       g = findinfoinlist(thefig,'TFResp');
       ud.infolist = ud.infolist(setxor(1:length(ud.infolist),g));
       set(thefig,'userdata',ud);
       if val==1, % a change from 0 to 1
         notgood = 0;
         taglist = {'TFPrefEdit'}; varlist = {'temporal frequency preference'};
         [b,vals] = checksyntaxsize(thefig,taglist,{[1 1]},1,varlist);
         if b,
             newinfolist = cell2struct(vals,taglist);
             newinfolist.name = 'TFResp';
             PSp = getparameters(ud.PS);
             PSp.tFrequency = vals{1};
             ud.PS = periodicscript(PSp);
			newinfolist.associate=struct('type','t','owner','t','data',0,...
					'desc',0);
			newinfolist.associate = newinfolist.associate([]); % make empty
			if get(ft(thefig,'TFCB'),'value'),
				newinfolist.associate(end+1)=struct('type','TF test',...
					'owner','protocol_ML',...
					'data',get(ft(thefig,'TFTestEdit'),'String'),...
					'desc','Test number for TF test');
			end;
			newassocs = get(ft(thefig,'TFTestEdit'),'userdata');
			if ~isempty(newassocs),
				newinfolist.associate = [newinfolist.associate newassocs];
			end;
            ud.infolist(end+1) = {newinfolist};
            set(thefig,'userdata',ud);
         else, notgood =1;
         end;
         if notgood, set(ft(thefig,'TFPrefCB'),'value',0); end;
       elseif val==0, % a change from 1 to 0
       end;
    case 'RestoreTFResp',
       g = findinfoinlist(thefig,'TFResp');
       if ~isempty(g),
         info = ud.infolist{g};
		 cksds=getcksds(1); c = getcells(cksds,ud.nameref);
		 data=load(getexperimentfile(cksds),c{1},'-mat');
		 cell=getfield(data,c{1});
		 asc=findassociate(cell,'TF Pref','protocol_ML',[]);
		 if ~isempty(asc),
			 set(ft(thefig,'TFPrefEdit'),'String',num2str(asc.data));
		 else, set(ft(thefig,'TFPrefEdit'),'String','');
		 end;
		assoclist = mlassociatelist('TF Test');
		saveasslist = [];
		for i=1:length(assoclist),
			ass = findassociate(cell,assoclist{i},'protocol_ML',[]);
			if ~isempty(ass),
				saveasslist = [saveasslist ass];
			end;
		end;
		set(ft(thefig,'TFTestEdit'),'userdata',saveasslist);
		set(ft(thefig,'TFPrefCB'),'value',1);
       end;
    case 'ContrastRespCB',
       val=get(ft(thefig,'ContrastRespCB'),'value');
       g = findinfoinlist(thefig,'ContrastResp');
       ud.infolist = ud.infolist(setxor(1:length(ud.infolist),g));
       set(thefig,'userdata',ud);
       if val==1,
          notgood = 0;
          if ~notgood,
            newinfolist.name = 'ContrastResp';
  		    newassc=struct('type','Contrast test','owner','protocol_ML',...
		        'data',get(ft(thefig,'ContrastTestEdit'),'String'),'desc',...
				'Test number for contrast test');
			assoc = get(ft(thefig,'ContrastTestEdit'),'userdata');
			newinfolist.associate=newassc;
            newinfolist.associate=[newinfolist.associate assoc];
			co=get(ft(thefig,'AnalyzeContrastBt'),'userdata');
            ud.infolist(end+1) = {newinfolist};
            set(thefig,'userdata',ud);
          end;
       else, notgood=1;
       end;
       if notgood, set(ft(thefig,'ContrastRespCB'),'value',0); end;
    case 'RestoreContrastResp',
       g = findinfoinlist(thefig,'ContrastResp');
       if ~isempty(g),
            info=ud.infolist{g};cksds=getcksds(1);c=getcells(cksds,ud.nameref);
		    data=load(getexperimentfile(cksds),c{1},'-mat');
			newcell=getfield(data,c{1});
			asc=findassociate(newcell,'C50','protocol_ML',[]);
			if ~isempty(asc),
				set(ft(thefig,'C50pcGainText'),'String',num2str(asc.data(1,2)));
			else, set(ft(thefig,'C50pcGainText'),'String',''); end;
			asc = findassociate(newcell,'Cgain 0-16','protocol_ML',[]);
			if ~isempty(asc),
				set(ft(thefig,'C016GainText'),'String',asc.data(1,2));
			else, set(ft(thefig,'C016GainText'),'String','');end;
			asc = findassociate(newcell,'Cgain 16-100','protocol_ML',[]);
			if ~isempty(asc),
				set(ft(thefig,'C16100GainText'),'String',asc.data(1,2));
			else, set(ft(thefig,'C16100GainText'),'String','');end;
			asc = findassociate(newcell,'Contrast Max rate','protocol_ML',[]);
			if ~isempty(asc),
				set(ft(thefig,'ContrastMaxRateText'),'String',asc.data(1,2));
			else, set(ft(thefig,'ContrastMaxRateText'),'String',''); end;
			assoclist = mlassociatelist('Contrast test');
			saveasslist = [];
			for i=1:length(assoclist),
				ass = findassociate(newcell,assoclist{i},'protocol_ML',[]);
				if ~isempty(ass),
					saveasslist = [saveasslist ass];
				end;
			end;
			set(ft(thefig,'ContrastTestEdit'),'userdata',saveasslist);
			set(ft(thefig,'ContrastRespCB'),'value',1);
       end;
    case {'RCCB','RC1CB','RC2CB','SFCB','ContrastCB',...
		  'Phase1CB','Phase2CB',...
          'Phase3CB','MotionCB','TFCB','OTCB','RotationCB','ExpandCB'},
       cases={'RCCB','RC1CB','RC2CB','SFCB','ContrastCB',...
	      'Phase1CB','Phase2CB',...
          'Phase3CB','MotionCB','TFCB','OTCB','RotationCB','ExpandCB'};
       infos={'RC','RC1','RC2','SF','Contrast',...
	      'Phase1','Phase2','Phase3','Motion','TF','OT','Rotation','Expand'};
       tests={'RCTestEdit','RC1TestEdit','RC2TestEdit',...
	          'SFTestEdit',...
              'ContrastTestEdit','Phase1TestEdit','Phase2TestEdit',...
              'Phase3TestEdit','MotionTestEdit','TFTestEdit','OTTestEdit',...
			  'RotationTestEdit','ExpandTestEdit'};
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
          ud.infolist(end+1) = {newinfolist};
       end;
       set(thefig,'userdata',ud);
    case {'RestoreRC','RestoreRC1','RestoreRC2',...
		  'RestoreSF','RestoreContrast',...
          'RestorePhase1','RestorePhase2','RestorePhase3','RestoreMotion',...
          'RestoreTF','RestoreOT','RestoreRotation','RestoreExpand'},
       cases={'RestoreRC','RestoreRC1','RestoreRC2',...
	      'RestoreSF','RestoreContrast',...
          'RestorePhase1','RestorePhase2','RestorePhase3','RestoreMotion',...
          'RestoreTF','RestoreOT','RestoreRotation','RestoreExpand'};
       buts={'RC1CB','RC1CB','RC2CB','SFCB','ContrastCB',...
	         'Phase1CB','Phase2CB',...
             'Phase3CB','MotionCB','TFCB','OTCB','RotationCB','ExpandCB'};
       infos={'RC','RC1','RC2','SF','Contrast','Phase1','Phase2',...
	   			'Phase3','Motion','TF','OT','Rotation','Expand'};
       tests={'RC1TestEdit','RC1TestEdit','RC2TestEdit',...
	          'SFTestEdit',...
              'ContrastTestEdit','Phase1TestEdit','Phase2TestEdit',...
              'Phase3TestEdit','MotionTestEdit','TFTestEdit','OTTestEdit',...
			  'RotationTestEdit','ExpandTestEdit'};
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
		  mlexperpanel('SetCenterBt',thefig);
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
		   		'owner','protocol_ML',...
		   		'data',struct('evalint',get(ft(thefig,'CentSizeAnalEdit')),...
				'earlyint',get(ft(thefig,'CSEarlyEdit')),'lateint',...
				get(ft(thefig,'CSLateEdit'))),'desc',...
				'Parameters specifying center size test analysis');
		   newassc(end+1)=struct('type','Cent Size test',...
		   		'owner','protocol_ML',...
		   		'data',get(ft(thefig,'CentSizeTestEdit'),'String'),'desc',...
				'Test number string for cent size test');
		   for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
		   try, 
  		     [nc,outstr,assocs,tc]=mlcentsizeanalysis(cksds,thecell,c{1},1);
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
    case 'AnalyzeMotionTestBt',
	   cksds = getcksds(1);
       g = gtn(thefig,'MotionTestEdit'); ng = 0;
       if ~isempty(g),
         [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
		 thecell=getfield(data,c{1});
         if ~isempty(s),
			pc=docurve(s,c,data,'direction',1,c{1},1);
			newassc=struct('type','Motion test','owner','protocol_ML',...
				'data',get(ft(thefig,'MotionTestEdit'),'String'),'desc',...
				'Test number string for planar motion test');
			for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
         end;
       end;
    case 'AnalyzeRotationTestBt',
	   cksds = getcksds(1);
       g = gtn(thefig,'RotationTestEdit'); ng = 0;
       if ~isempty(g),
         [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
		 thecell=getfield(data,c{1});
         if ~isempty(s),
			pc=docurve(s,c,data,'angvelocity',1,c{1},1);
			newassc=struct('type','Rotation test','owner','protocol_ML',...
				'data',get(ft(thefig,'RotationTestEdit'),'String'),'desc',...
				'Test number string for rotation test');
			for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
         end;
       end;
    case 'AnalyzeExpandTestBt',
	   cksds = getcksds(1);
       g = gtn(thefig,'ExpandTestEdit'); ng = 0;
       if ~isempty(g),
         [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
		 thecell=getfield(data,c{1});
         if ~isempty(s),
			pc=docurve(s,c,data,'velocity',1,c{1},1);
			newassc=struct('type','Expand test','owner','protocol_ML',...
				'data',get(ft(thefig,'ExpandTestEdit'),'String'),'desc',...
				'Test number string for Expand test');
			for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
         end;
       end;
    case 'AnalyzeOTBt',
	   cksds = getcksds(1);
       g = gtn(thefig,'OTTestEdit');
       if ~isempty(g),
         [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
         if ~isempty(s),
           pc = docurve(s,c,data,'angle',0,c{1},6);
           set(ft(thefig,'OTTestEdit'),'userdata',pc);
           co = getoutput(pc);
           [m,i] = max(co.f1curve{1}(2,:)); ang = co.f1curve{1}(1,i);
		   co = rmfield(rmfield(co,'spontrast'),'rast');
           co = rmfield(rmfield(co,'cycg_rast'),'cyci_rast');
           set(ft(thefig,'OTPrefEdit'),'String',num2str(ang),...
				'userdata',co);
           mlexperpanel(ft(thefig,'ComputeDirectionIndBt'),thefig);
         end;
       end;
    case 'AnalyzeSFBt',
	   cksds = getcksds(1); 
       g = gtn(thefig,'SFTestEdit');
       if ~isempty(g),
         [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
         if ~isempty(s),
           pc = docurve(s,c,data,'sFrequency',0,c{1},6);
           set(ft(thefig,'SFTestEdit'),'userdata',pc);
           co = getoutput(pc);
           [m,i] = max(co.f1curve{1}(2,:)); sf = co.f1curve{1}(1,i);
		   co = rmfield(rmfield(co,'spontrast'),'rast');
           co = rmfield(rmfield(co,'cycg_rast'),'cyci_rast');
           set(ft(thefig,'SFPrefEdit'),'String',num2str(sf),...
				'userdata',co);
           s1=get(ft(thefig,'Phase1TestEdit'),'String');
           s2=get(ft(thefig,'Phase2TestEdit'),'String');
           s3=get(ft(thefig,'Phase3TestEdit'),'String');
           if isempty([s1 s2 s3]),
              set(ft(thefig,'PhaseSF1Edit'),'String',num2str(sf));
              set(ft(thefig,'PhaseSF2Edit'),'String',num2str(2*sf));
              set(ft(thefig,'PhaseSF3Edit'),'String',num2str(3*sf));
           end;
         end;
       end;
    case 'AnalyzeTFBt',
	   cksds = getcksds(1); 
       g = gtn(thefig,'TFTestEdit');
       if ~isempty(g),
		newassc=struct('type','TF test',...
				'owner','protocol_ML',...
				'data',get(ft(thefig,'TFTestEdit'),'String'),'desc',...
				'Test number for TF test');
		[s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
		if ~isempty(s),
			thecell = getfield(data,c{1});
			for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
			[pc]=docurve(s,c,data,'tFrequency',0,c{1},7);
			%set(ft(thefig,'TFTestEdit'),'userdata',assocs);
			%set(ft(thefig,'TFPrefEdit'),'String',mat2str(outstr.tfpref));
         end;
       end;
    case 'AnalyzeContrastBt'
	   cksds = getcksds(1);
       g = gtn(thefig,'ContrastTestEdit');
       if ~isempty(g),
		newassc=struct('type','Contrast test','owner','protocol_ML',...
			'data',get(ft(thefig,'ContrastTestEdit'),'String'),'desc',...
			'Test number for contrast test');
         [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
         if ~isempty(s),
		   thecell = getfield(data,c{1});
		   for i=1:length(newassc),thecell=associate(thecell,newassc(i));end;
		   [pc]=docurve(s,c,data,'contrast',0,c{1},7);
		   set(ft(thefig,'ContrastTestEdit'),'userdata',assocs);
         end;
       end;
    case 'AnalyzePhase1Bt'
	   cksds = getcksds(1);
       g = gtn(thefig,'Phase1TestEdit');
       if ~isempty(g),
         [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
         if ~isempty(s),
           pc = docurve(s,c,data,'sPhaseShift',0,c{1},7);
           set(ft(thefig,'Phase1TestEdit'),'userdata',pc);
		   set(ft(thefig,'AnalyzePhase1Bt'),'userdata',[]);
         end;
       end;
    case 'AnalyzePhase2Bt'
	   cksds = getcksds(1);
       g = gtn(thefig,'Phase2TestEdit');
       if ~isempty(g),
         [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
         if ~isempty(s),
           pc = docurve(s,c,data,'sPhaseShift',0,c{1},7);
           set(ft(thefig,'Phase2TestEdit'),'userdata',pc);
		   set(ft(thefig,'AnalyzePhase2Bt'),'userdata',[]);
         end;
       end;
    case 'AnalyzePhase3Bt'
	   cksds = getcksds(1);
       g = gtn(thefig,'Phase3TestEdit');
       if ~isempty(g),
         [s,c,data]=getstimcellinfo(cksds,ud.nameref,g);
         if ~isempty(s),
           pc = docurve(s,c,data,'sPhaseShift',0,c{1},7);
           set(ft(thefig,'Phase3TestEdit'),'userdata',pc);
		   set(ft(thefig,'AnalyzePhase3Bt'),'userdata',[]);
         end;
       end;
    case 'ComputeDirectionIndBt',
       pc = get(ft(thefig,'OTTestEdit'),'userdata');
       if ~isempty(pc),
          co = getoutput(pc);
          taglist = {'OTPrefEdit'};varlist={'OT tuning'};
          [b,vals] = checksyntaxsize(thefig,taglist,{[1 1]},1,varlist);
          if b,
             ang = vals{1};
             j1 = findclosest(co.f1curve{1}(1,:),mod(ang,360));
             j2 = findclosest(co.f1curve{1}(1,:),mod(ang+180,360));
             j3 = findclosest(co.f1curve{1}(1,:),mod(ang+90,360));
             j4 = findclosest(co.f1curve{1}(1,:),mod(ang+270,360));
             m1 = co.f1curve{1}(2,j1); m2 = co.f1curve{1}(2,j2);
             m3 = co.f1curve{1}(2,j3); m4 = co.f1curve{1}(2,j4);
             DI = (m1-m2)/(m1+0.0001); % direction index
             OI = (m1+m2-m3-m4)/(0.0001+(m1+m2)/2); % orientation
             set(ft(thefig,'DirectionIndText'),'String',num2str(DI),...
               'userdata',DI);
             set(ft(thefig,'OrIndText'),'String',num2str(OI),'userdata',OI);
          end;
       else, errordlg('Data must be analyzed first.');
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
    case 'RC1RunBt', %RCRunBt->RC1RunBt 2002-08-18
       if get(ft(thefig,'DetailCB'),'value')~=1,
          errordlg('Cannot run because previous line check box not checked.');
       else, 
          MLP_sgs = stimscript(0);
          MLP_sgs = append(MLP_sgs, ud.SGS);
          b = transferscripts({'MLP_sgs'},{MLP_sgs});
          if b,
               dowait(0.5);
             b=runscriptremote('MLP_sgs');
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
          MLP_sgs2 = stimscript(0);
          MLP_sgs2 = append(MLP_sgs2, ud.SGS2);
		  p__=getparameters(ud.SGS2);  % check to see if same up to location
		  strs={'load toremote -mat;'
		        'if exist(''MLP_sgs2'')==1,'
		        '   sgs_1=get(MLP_sgs2,1);'
				'   sgs_1p=getparameters(sgs_1);'
				'   sgs_1p.rect = p__.rect;'
				'   p__.randState = sgs_1p.randState;'
				'   if sgs_1p==p__,'
				'     sameparams = 1;'
				'     sgs_1 = setparameters(sgs_1,p__);'
				'     MLP_sgs2=set(MLP_sgs2,sgs_1,1);'
				'   else, sameparams = 0; end;'
				'else, sameparams=0;end;'
				'save fromremote sameparams -mat;'
				'save gotit sameparams -mat;'};
		  [b,vars] = sendremotecommandvar(strs,{'p__'},{p__});
		  if b,
            if vars.sameparams==0,  % we need to transfer new version
				disp('transferring new version');
				dowait(0.5);
				b = transferscripts({'MLP_sgs2'},{MLP_sgs2});
			else, disp('stimulus fine.'); end;
		  end;
          if b,
               dowait(0.5);
             b=runscriptremote('MLP_sgs2');
             if ~b,
                errordlg('Could not run script--check RunExperiment window.');
             end;
             tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
             set(ft(thefig,'RC2TestEdit'),'String',tn);
          end;
       end;
    case 'MotionRunBt',  % here
         taglist = {'MotionRepsEdit','MotionISIEdit','MotionSizeEdit',...
            'MotionNumDotsEdit','MotionRangeEdit','MotionVelocityEdit'};
         varlist = {'Motion reps','Motion ISI','Motion size',...
		 	'Motion numdots','Motion range','Motion velocity'};
         [b,vals] = checksyntaxsize(thefig,taglist,{[1 1],[1 1],[1 1],...
		 		[1 1],[],[1 1]},varlist);
         if b,
		   reps=vals{1};isi=vals{2};sz=vals{3};numdots=vals{4};range=vals{5};
		   MLP_motion=stimscript(0);
		   MDp = getparameters(ud.mds); MDp.motiontype='planar';
		   MDp.numdots=numdots;MDp.dotsize=sz;MDp.dispprefs={'BGpretime',isi};
		   MDp.velocity = vals{6};
		   MDp.duration = 0.5;
		   for i=1:length(range),
			   MDp.direction=range(i);
			   r=rand(100,100); MDp.randState = rand('state');
			   MLP_motion=append(MLP_motion,movingdotsstim(MDp));
		   end;
		   MLP_motion=setDisplayMethod(MLP_motion,1,reps);
           b = transferscripts({'MLP_motion'},{MLP_motion});
           if b,
             dowait(0.5);
             b = runscriptremote('MLP_motion');
             if ~b,
                errordlg('Could not run script--check RunExperiment window.');
             end;
             tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
             set(ft(thefig,'MotionTestEdit'),'String',tn);
             set(ft(thefig,'MotionCB'),'value',0);
             mlexperpanel('MotionCB',thefig);
           end;
	   end;
    case 'RotationRunBt',  % here
         taglist = {'RotationRepsEdit','RotationISIEdit','RotationSizeEdit',...
            'RotationNumDotsEdit','RotationRangeEdit','RotationVelocityEdit'};
         varlist = {'Rotation reps','Rotation ISI','Rotation size',...
		 	'Rotation numdots','Rotation range','Rotation velocity'};
         [b,vals] = checksyntaxsize(thefig,taglist,{[1 1],[1 1],[1 1],...
		 		[1 1],[],[1 1]},varlist);
         if b,
		   reps=vals{1};isi=vals{2};sz=vals{3};numdots=vals{4};range=vals{5};
		   MLP_rotation=stimscript(0);
		   MDp = getparameters(ud.mds); MDp.motiontype='radial';
		   MDp.numdots=numdots;MDp.dotsize=sz;MDp.dispprefs={'BGpretime',isi};
		   MDp.velocity = vals{6};
		   MDp.direction=0;
		   MDp.duration = 0.5;
		   for i=1:length(range),
			   MDp.angvelocity=range(i);
			   r=rand(100,100); MDp.randState = rand('state');
			   MLP_rotation=append(MLP_rotation,movingdotsstim(MDp));
		   end;
		   MLP_rotation=setDisplayMethod(MLP_rotation,1,reps);
           b = transferscripts({'MLP_rotation'},{MLP_rotation});
           if b,
             dowait(0.5);
             b = runscriptremote('MLP_rotation');
             if ~b,
                errordlg('Could not run script--check RunExperiment window.');
             end;
             tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
             set(ft(thefig,'RotationTestEdit'),'String',tn);
             set(ft(thefig,'RotationCB'),'value',0);
             mlexperpanel('RotationCB',thefig);
		  end;
	   end;
    case 'ExpandRunBt',  % here
         taglist = {'ExpandRepsEdit','ExpandISIEdit','ExpandSizeEdit',...
            'ExpandNumDotsEdit','ExpandRangeEdit','ExpandVelocityEdit'};
         varlist = {'Expand reps','Expand ISI','Expand size',...
		 	'Expand numdots','Expand range','Expand velocity'};
         [b,vals] = checksyntaxsize(thefig,taglist,{[1 1],[1 1],[1 1],...
		 		[1 1],[],[1 1]},varlist);
         if b,
		   reps=vals{1};isi=vals{2};sz=vals{3};numdots=vals{4};range=vals{5};
		   MLP_expand=stimscript(0);
		   MDp = getparameters(ud.mds); MDp.motiontype='radial';
		   MDp.numdots=numdots;MDp.dotsize=sz;MDp.dispprefs={'BGpretime',isi};
		   MDp.velocity = vals{6};
		   MDp.direction=90;
		   MDp.duration = 0.5;
		   for i=1:length(range),
			   MDp.velocity=range(i);
			   r=rand(100,100); MDp.randState = rand('state');
			   MLP_expand=append(MLP_expand,movingdotsstim(MDp));
		   end;
		   MLP_expand=setDisplayMethod(MLP_expand,1,reps);
           b = transferscripts({'MLP_expand'},{MLP_expand});
           if b,
             dowait(0.5);
             b = runscriptremote('MLP_expand');
             if ~b,
                errordlg('Could not run script--check RunExperiment window.');
             end;
             tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
             set(ft(thefig,'ExpandTestEdit'),'String',tn);
             set(ft(thefig,'ExpandCB'),'value',0);
             mlexperpanel('ExpandCB',thefig);
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
            MLP_PS = periodicscript(p);
			[cr,dist,sr] = getscreentoolparams;
			MLP_PS = recenterstim(MLP_PS,...
			{'rect',cr,'screenrect',sr,'params',1});
            MLP_PS = setDisplayMethod(MLP_PS,1,vals{1});
            b = transferscripts({'MLP_PS'},{MLP_PS});
            if b,
               dowait(0.5);
               b=runscriptremote('MLP_PS');
               if ~b,
                  errordlg('Could not run script--check RunExperiment window.');
               end;
               tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
               set(ft(thefig,'SFTestEdit'),'String',tn);
               set(ft(thefig,'SFCB'),'value',0);
               mlexperpanel('SFCB',thefig);
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
            MLP_PS = periodicscript(p);
			[cr,dist,sr] = getscreentoolparams;
			MLP_PS = recenterstim(MLP_PS,...
			{'rect',cr,'screenrect',sr,'params',1});
            MLP_PS = setDisplayMethod(MLP_PS,1,vals{1});
            b = transferscripts({'MLP_PS'},{MLP_PS});
            if b,
               dowait(0.5);
               b=runscriptremote('MLP_PS');
               if ~b,
                  errordlg('Could not run script--check RunExperiment window.');
               end;
               tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
               set(ft(thefig,'TFTestEdit'),'String',tn);
               set(ft(thefig,'TFCB'),'value',0);
               mlexperpanel('TFCB',thefig);
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
            MLP_PS = periodicscript(p);
			[cr,dist,sr] = getscreentoolparams;
			MLP_PS = recenterstim(MLP_PS,...
				{'rect',cr,'screenrect',sr,'params',1});
            MLP_PS = setDisplayMethod(MLP_PS,1,vals{1});
            b = transferscripts({'MLP_PS'},{MLP_PS});
            if b,
               dowait(0.5);
               b=runscriptremote('MLP_PS');
               if ~b,
                  errordlg('Could not run script--check RunExperiment window.');
               end;
               tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
               set(ft(thefig,'OTTestEdit'),'String',tn);
               set(ft(thefig,'OTCB'),'value',0);
               mlexperpanel('OTCB',thefig);
            end;
          end;
    case 'ContrastRunBt',     
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
            MLP_PS = periodicscript(p);
            MLP_PS = setDisplayMethod(MLP_PS,1,vals{1});
            b = transferscripts({'MLP_PS'},{MLP_PS});
            if b,
               dowait(0.5);
               b=runscriptremote('MLP_PS');
               if ~b,
                  errordlg('Could not run script--check RunExperiment window.');
               end;
               tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
               set(ft(thefig,'ContrastTestEdit'),'String',tn);
               set(ft(thefig,'ContrastCB'),'value',0);
               mlexperpanel('ContrastCB',thefig);
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
            MLP_PS = periodicscript(p);
			[cr,dist,sr] = getscreentoolparams;
			MLP_PS = recenterstim(MLP_PS,...
			{'rect',cr,'screenrect',sr,'params',1});
            MLP_PS = setDisplayMethod(MLP_PS,1,vals{1});
            b = transferscripts({'MLP_PS'},{MLP_PS});
            if b,
               dowait(0.5);
               b=runscriptremote('MLP_PS');
               if ~b,
                  errordlg('Could not run script--check RunExperiment window.');
               end;
               tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
               set(ft(thefig,tes{i}),'String',tn);
               set(ft(thefig,cbs{i}),'value',0);
               mlexperpanel(cbs{i},thefig);
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
            mlexperpanel(['Restore' infolist{i}.name],thefig);
            %try, mlexperpanel(['Restore' infolist{i}.name],thefig);
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
%         if get(ft(thefig,thetag),'value')==1,mlexperpanel('Save',thefig);end;
%  end;
end;

 % handy subfunctions

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

function h1 = drawfig

h1 = mlpanelfig;

function filldefaults(h1,nameref,expf)
squirrelcolor
set(h1,'Tag','mlexperpanel');

set(findobj(h1,'style','checkbox'),'value',0);

[cr,dist,sr] = getscreentoolparams;

SGSp=struct('rect',[0 0 630 480],'BG',round(mean([squirrel_white'; 0 0 0])),...
              'values',[squirrel_white'; 0 0 0],'dist',[1;1],...
              'pixSize',[42 32],'N',4000,'fps',30,'randState',rand('state'),...
              'dispprefs',{{}});
SGS2p=struct('rect',[0 0 180 180],'BG',round(mean([squirrel_white'; 0 0 0])),...
              'values',[squirrel_white'; 0 0 0],'dist',[1;1],...
              'pixSize',[12 12],'N',9000,'fps',30,'randState',rand('state'),...
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

MDp = getparameters(movingdotsstim('')); % start with default parameters
MDp.rect = [ 80 0 560 480]; MDp.lifetimes = 0.5;
mds = movingdotsstim(MDp);

PSp = struct('imageType',1,'animType',4,'flickerType',0,'angle',[0],...
             'chromhigh',squirrel_white','chromlow',[0 0 0],'sFrequency',0.05,...
             'sPhaseShift',0,'tFrequency',2,'barWidth',0.3,... % 'distance',57,
             'rect',[0 0 640 480],'nCycles',5,'contrast',1,...
             'background',0.5,'backdrop',0.5,'barColor',1,'nSmoothPixels',2,...
             'fixedDur',0,'windowShape',0,'dispprefs',{{'BGpretime',2}});
PS = periodicscript(PSp);
PS = recenterstim(PS,{'rect',cr,'screenrect',sr,'params',1});

ud = struct('SGS',SGS,'SGS2',SGS2,'css',css,'PS',PS,'nameref',nameref,...
      'infolist',[],'mds',mds);
set(h1,'userdata',ud);

% set default parameters in figure

set(ft(h1,'MotionRepsEdit'),'String','5');
set(ft(h1,'MotionISIEdit'),'String','2');
set(ft(h1,'MotionNumDotsEdit'),'String','20');
set(ft(h1,'MotionSizeEdit'),'String','1.2');
set(ft(h1,'MotionRangeEdit'),'String','[0:30:330]');
set(ft(h1,'MotionVelocityEdit'),'String','32');
set(ft(h1,'RotationRepsEdit'),'String','5');
set(ft(h1,'RotationISIEdit'),'String','2');
set(ft(h1,'RotationNumDotsEdit'),'String','20');
set(ft(h1,'RotationSizeEdit'),'String','1.2');
set(ft(h1,'RotationRangeEdit'),'String','[-360:90:360]');
set(ft(h1,'RotationVelocityEdit'),'String','32');
set(ft(h1,'ExpandRepsEdit'),'String','5');
set(ft(h1,'ExpandISIEdit'),'String','2');
set(ft(h1,'ExpandNumDotsEdit'),'String','20');
set(ft(h1,'ExpandSizeEdit'),'String','1.2');
set(ft(h1,'ExpandRangeEdit'),'String','[-100:25:100]');
set(ft(h1,'ExpandVelocityEdit'),'String','32','visible','off');

set(ft(h1,'GratingRepsEdit'),'String','5');
set(ft(h1,'GratingISIEdit'),'String','2');
set(ft(h1,'OTRangeEdit'),'String','[0:30:330]');
set(ft(h1,'TFRangeEdit'),'String','[0.5 1 2 4 8 16 32]');
set(ft(h1,'SFRangeEdit'),'String','[0.05 0.1 0.2 0.4 0.8 1.6]');
set(ft(h1,'ContrastRangeEdit'),'String','[0.02 0.16 0.32 0.64 1]');
set(ft(h1,'PhaseRangeEdit'),'String','[0:pi/6:(pi-pi/6)]');

% set up popup menus
set(ft(h1,'EyePopup'),'String',{' ','both','ipsi','contra'});
% disabled because this is measured more explicitly other places
set(ft(h1,'OTPopup'),'String',{' ','strongly orientation',...
                         'weakly orientation',...
                         'strongly directionally','weakly directionally',...
                         'weakly or not at all'});
set(ft(h1,'MLLayerPopup'),'String',{' ','1','2/3','2','3','4','5/6','5','6'});
set(ft(h1,'MLPutLayerPopup'),'String',...
				{' ','1','2/3','2','3','4','5/6','5','6'});
set(ft(h1,'IsolationPopup'),'String',{' ','Perfect','Nearly perfect',...
'multiunit'});
set(ft(h1,'LinearityPopup'),'String',{' ','Linear','Non-linear'});
set(ft(h1,'GratingRespPopup'),'String',{' ','good','poor'});
set(ft(h1,'NameRefText'),'String',[nameref.name ' | ' int2str(nameref.ref)]);
set(ft(h1,'ExportLogBt'),'enable','off');
vname =['protocol_ML_' nameref.name '_' int2str(nameref.ref) '_' expf];
vname(find(vname=='-')) = '_'; set(ft(h1,'VarNameEdit'),'String',vname);


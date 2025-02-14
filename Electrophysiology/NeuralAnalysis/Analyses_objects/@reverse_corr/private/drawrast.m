function drawrast(rc)

p = getparameters(rc);

if p.showrast,
  disp('drawing rast.');
  w = location(rc); in = rc.internal; I = getinputs(rc);
  [r1,r2,r3,r4]=getdrawrects(rc);

  ra = [];
  l = findobj(w.figure,'tag','analysis_generic',...
        'uicontextmenu',contextmenu(rc));
  for i=1:length(l),
     ud = get(l(i),'userdata');
     if isa(ud,'cell')&strcmp(ud{1},'revaxes'),
         l=l(i);
         if length(ud)>1,ra=ud{2};end;
         break;
     end;
  end;
%  ra;


  if ~isempty(ra), delete(ra); end;
  [b,t] = getbins(rc); v = {};
  ps = getparameters(getstim(rc)); vals = ps.values;
  for i=1:length(b),
    vl=find((b{i}(:,in.selectedbin))'~=p.bgcolor);
    for j=1:length(t{i}),
       vt=[t{i}.frameTimes(vl)];
       v = cat(1,v,{vt});
    end;
  end;
  where.units=w.units;
  where.figure=w.figure;where.rect=r1;
  
  ra=raster(struct('spikes',I.spikes{p.datatoview(1)},'triggers',{v},'condnames',{1}),'default',where);
  
  
  ctxmenu = contextmenu(ra);
  f = findobj(ctxmenu,'label','Move to ...');
  if ishandle(f), set(f,'Enable','off'); end;
  if ishandle(l), ud{2} = ra; set(l,'userdata',ud); end;
end;

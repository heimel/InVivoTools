function drawshowdata(rc)

p = getparameters(rc); w = location(rc); in = rc.internal; I = getinputs(rc);
if p.showdata,
  [r1,r2,r3,r4]=getdrawrects(rc);

  l = findobj(w.figure,'tag','analysis_generic','uicontextmenu',...
      contextmenu(rc),'userdata','showdata');
  if ishandle(l), delete(l); end;
  a = axes('units',w.units,'position',r4,'tag','analysis_generic',...
	'uicontextmenu',contextmenu(rc),'userdata','showdata');
  ps = getparameters(getstim(rc));  vals = ps.values;  % get colors
  if p.chanview==0, % use intensity, varies between 0 and 1 % add transform here
       vals = sqrt(sum(vals.*vals/(255*255),2))/norm([1 1 1]);
  else, vals = vals(:,p.chanview);
  end;
  [b,t] = getbins(rc); v = []; vt = []; class(t{1});
  for i=1:length(b),
    vl=vals(b{i}(:,in.selectedbin))';
    v = cat(1,v, reshape([vl;vl],1,2*prod(size(vl))));
    for j=1:length(t{i}),
       dt = mean(diff(t{i}.frameTimes));
      vtl=[t{i}.frameTimes' [t{i}.frameTimes(2:end) t{i}.frameTimes(end)+dt]']';
       vt = cat(1,vt,reshape(vtl,1,prod(size(vtl))));
    end;
  end;
  spk=min(v)-abs(min(v(find(v~=min(v))))-min(v));
  dat = get_data(I.spikes{p.datatoview(1)},[vt(1) vt(end)]);
  plot(dat,repmat(spk,size(dat)),'ko','tag','spikes');
  hold on;
  plot(vt,v,'b');
  set(a,'ylim',[2*spk-min(v) max(v)+min(v)-spk]);
  set(a,'tag','analysis_generic','userdata','showdata');
end;

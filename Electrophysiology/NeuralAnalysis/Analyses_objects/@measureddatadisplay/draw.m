function t = draw(mdd)

%  Part of the NeuralAnalysis package
%
%  DRAW(MDD)
%
%  Draws the output to the location in the MEASUREDDATADISPLAY object MDD.
%
%  See also:  MEASUREDDATADISPLAY, ANALYSIS_GENERIC/DRAW

disp('Drawing measureddatadisplay object');
w = location(mdd); p = getparameters(mdd); I = getinputs(mdd);
if ~isempty(w),
  z = getgraphicshandles(mdd);
  k = [];
  if ~isempty(z),
     try, zz = get(z,'Type');
          if ~iscell(zz), zz = {zz}; end;
          [dummy,k] = intersect(zz,'axes');
     end;
  end;
  figure(w.figure); figRect = get(w.figure,'Position');
  if strcmp(w.units,'pixels'), ssw=figRect(3); ssh = figRect(4);
  else, ssw = 1; ssh = 1; end;
  passrect = [w.rect([1 2]) w.rect([3 4])+w.rect([1 2])];
  if strcmp(w.units,'pixels'),passrect=pixels2normalized(w.figure,passrect);end;
  drawrect = grect2local([ 0.1 0.1 0.8 0.8 ],...
                         w.units,passrect,w.figure);
  oldxaxis = [];
  if ~isempty(k),
     axobj = z(k);
     axes(axobj);
     set(axobj,'units',w.units,'position',drawrect);
     ud = get(axobj,'userdata');
     oldxaxis = get(axobj,'xlim');
  else,
     try, delete(z); end;
     axobj = axes('units',w.units','Position',drawrect);
     ud = [];
  end;
  axis auto; hold on;
  if ischar(p.xaxis)&...
         strcmp(p.xaxis,'auto'),
        xmin = p.xauto(1);
        xmax = p.xauto(2);
  else, xmin = p.xaxis(1);
        xmax = p.xaxis(2);
  end;
  if ~isempty(ud),  % delete any plots that are not good anymore
     for i=1:length(ud.prevparams),
         if (~eqlen(ud.prevxaxis,[xmin xmax])|(ud.prevoffset~=p.offset)),
               try, delete(ud.plot{i}); ud.plot{i} = [];
                    ud.ybegin(i) = 0; ud.yend(i) = 0; end;
         else, j = ud.prevparams(i) == p.displayParams,
               if isempty(j),
                  try, delete(ud.plot{i}); ud.plot{i} = [];
                    ud.ybegin(i) = 0; ud.yend(i) = 0; end;
               end;
         end;
     end;
  else, ud.prevparams = []; ud.plot = {};
        ud.ybegin=zeros(length(p.displayParams),1); ud.yend=ud.ybegin;
  end;
  yaccum = 0; ytopaccum = 0;
  for i=1:length(p.displayParams),
     doplot = 0;
     if i<=length(ud.prevparams),
        if ~(p.displayParams(i)==ud.prevparams(i))|...
             (~eqlen(ud.prevxaxis,[xmin xmax])|(ud.prevoffset~=p.offset)),
           doplot = 1; try, delete(ud.plot{i}); end;
        else,  doplot=0; end;
     else, doplot=1;
     end;
         %disp(['here, doplot=' int2str(doplot) '.']);
         if p.displayParams(i).draw, 
            if doplot,
               b = get_memory(I.measureddata{i},[xmin xmax]);
               if b*1e-6>=p.memwarning,
                  t = 0;
                  try, for k=1:length(ud.plot),delete(ud.plot{k});end;
                       set(axobj,'userdata',[]); end;
                  errordlg('memory warning exceeded.');%handle better
                  return;
               end;
               %disp(['Getting data ' int2str(i) '.']);
               %struct(I.measureddata{i}),
               diff([xmin xmax]),
               [data,t] = get_data(I.measureddata{i},[xmin xmax],2);
               disp(['time interval: ' num2str(diff([t(1) t(end)])) '.']);
               ud.plot{i} = [];
               if p.removemeans&~isempty(data),
                  for j=1:size(data,2),data(:,j)=data(:,j)-mean(data(:,j));end;
               end;
               for j=1:size(data,2),
                 if isa(I.measureddata{i},'spikedata'),
                      % plot spikedata
                 elseif p.displayParams(i).line&doplot,
                    size(t),size(data(:,j)),
                    ud.plot{i} = [ud.plot{i};
                    plot(t,yaccum+data(:,j)*p.displayParams(i).scaling,...
                            'LineWidth',p.displayParams(i).linesz,...
                            'Color',p.displayParams(i).color,...
                            'uicontextmenu',contextmenu(mdd));];
                 elseif ~isempty(p.displayParams(i).sym)&doplot,
                    ud.plot{i} = [ud.plot{i};
                    plot(t,yaccum+data(:,j)*p.displayParams(i).scaling,...
                            p.displayParams.sym,...
                            'MarkerSize',p.displayParams(i).markerSize,...
                            'Color',p.displayParams(i).color,...
                            'uicontextmenu',contextmenu(mdd));];
                 end;
                 if p.lineatzero,
                    ud.plot{i} = [ud.plot{i}; 
                    plot([xmin xmax],[yaccum yaccum],'k',...
                         'linewidth',p.lineatzerosz);];
                 end;
                 % update position
                 diffyaccum = yaccum;
                 if ~isempty(data),
                   switch p.displayParams(i).sepmeth,
                   case 0, % use min/max
                       yaccum=yaccum-(max(data(:,j))-min(data(:,j)))*...
                              p.displayParams(i).scaling*...
                              p.displayParams(i).sepdist; 
                   case 1, % use standard deviation
                       yaccum=yaccum-std(data(:,j))*...
                              p.displayParams(i).scaling*...
                              p.displayParams(i).sepdist; 
                   case 2, % use constant offset
                       yaccum=yaccum-p.displayParams(i).sepdist;
                   end;
                 end;
                 diffyaccum = abs(diffyaccum-yaccum);
                 if (i==1)&(j==1),ud.ybegin(i)=yaccum;ytopaccum=diffyaccum;end;
                 if (j==size(data,2)), ud.yend(i) = yaccum;end;
               end;
            else, yaccum = ud.yend(i);
            end;
         yaccum = yaccum - p.offset;
         end;  % if draw
  end;
  ud.prevparams = p.displayParams;
  ud.prevxaxis = [xmin xmax];
  ud.prevoffset = p.offset;
  if ischar(p.yaxis)&strcmp(p.yaxis,'auto'),
     ylims = get(axobj,'ylim');
     set(axobj,'ylim',[min([yaccum+p.offset ylims(1)]) ...
                      max([ylims(2) ytopaccum])]);
  else, set(axobj,'ylim',p.yaxis);
  end;
  set(axobj,'Tag','analysis_generic','uicontextmenu',contextmenu(mdd),...
       'userdata',ud,'xlim',[xmin xmax]);
end;
t = 1;
configuremenu(mdd);

function draw(pc)

%  Part of the NeuralAnalysis package
%
%  DRAW(PERIODIC_CURVEOBJ)
%
%  Draws the output to the location in the PERIODIC_CURVE object PERIODIC_CURVEOBJ.
%
%  See also:  ANALYSIS_GENERIC/DRAW

%disp('drawing periodic_curve'),
w = location(pc); p = getparameters(pc); I = getinputs(pc); c = getoutput(pc);

theud = {};

if ~isempty(w),
   z = getgraphicshandles(pc);
   if ~isempty(z), % delete objects
        for i=1:length(z),
          if strcmp(get(z(i),'type'),'axes'),
             disp('found the axes');
             ud2 = get(z(i),'userdata');
             for jj=1:length(ud2), delete(ud2{jj}); end; % delete old raster objects
          end;
          delete(z(i));
        end;
   end;
   ud = get(w.figure,'userdata');
   figure(w.figure); r = zeros(4,4);
   [r(1,:),r(2,:),r(3,:),r(4,:)]=getdrawrects(pc);
   titleax = axes('position',w.rect,'units',w.units,'visible','off',...
           'uicontextmenu',contextmenu(pc),'tag','analysis_generic');
   text(0.5,0.95,I.title,'Interpreter','none','HorizontalAlignment','center');
   for i=1:4,
     if ~eqlen(r(i,:),[-1 -1 -1 -1]),
        switch p.graphParams(i).whattoplot,
          case 0, % raster showing whole trial plots
               where.figure=w.figure; where.rect=r(i,:); where.units=w.units;
               theud{length(theud)+1}=setlocation(c.rast{p.graphParams(i).whichdata(1)});
          case 1, % raster plot showing cycle by cycle
               where.figure=w.figure; where.rect=r(i,:); where.units=w.units;
               theud{length(theud)+1}=setlocation(c.cycg_rast{p.graphParams(i).whichdata(1)},where);
          case 2, % raster plot showing cycle by cycle for 1 stim
               where.figure=w.figure; where.rect=r(i,:); where.units=w.units;
               theud{length(theud)+1}=setlocation(c.cyci_rast{p.whichdata(1)}{p.whichdata(2)});
          case {3,4,5,6,7,8,9,10,11,12}, % draw a graph
              qp=p.graphParams(i).whattoplot;
              if isempty(p.graphParams(i).whichdata), whd=1;
              elseif length(p.graphParams(i).whichdata)==1, whd=[1 1];
              else, whd = whichdata;
              end;
              ylabels={ '','','rate (Hz)','F1 (Hz)','F2 (Hz)','F1/F0','F2/F1','rate (Hz)','F1 (Hz)','F2 (Hz)','F1/F0','F2/F1'};
              curves ={[],[],c.curve,c.f1curve,c.f2curve,c.f1f0curve,c.f2f1curve,...
                             c.cycg_curve,c.cycg_f1curve,c.cycg_f2curve,c.cycg_f1f0curve,c.cycg_f2f1curve,...
                             c.cyci_curve{whd(1)},c.cyci_f1curve{whd(1)},c.cyci_f2curve{whd(1)},...
                                 c.cyci_f1f0curve{whd(1)},c.cyci_f2f1curve{whd(1)}};
              cax=axes('units',w.units,'position',r(i,:),...
                 'tag','analysis_generic','uicontextmenu',contextmenu(pc));
                 colord = get(cax,'ColorOrder'); hold on;
              if p.graphParams(i).whattoplot>=3&p.graphParams(i).whattoplot<=12,
                if length(c.vals2)==0, loop=1;
                elseif ~isempty(p.graphParams(i).whichdata),
                    if size(p.graphParams(i).whichdata)==1, loop=p.graphParams(i).whichdata;
                    else, loop=p.graphParams(i).whichdata(:,1); end;
                else, loop=1:length(c.vals2); end;
              else, loop = p.graphParams(i).whichdata(2:end); % loop over stims
              end;
              for z=loop,
                   crd=mod(z,size(colord,1));
                   z,
                   h=plot(curves{qp}{z}(1,:),curves{qp}{z}(2,:),'color',colord(crd,:));
                   for jj=1:length(h),set(h(jj),'linewidth',2);end;
                   if p.graphParams(i).showstderr
                     h=errorbar(curves{qp}{z}(1,:),curves{qp}{z}(2,:),curves{qp}{z}(4,:));
                     for jj=1:length(h),set(h(jj),'linewidth',2,'color',colord(crd,:));end;
                   end;
                   if p.graphParams(i).showstddev,
                     h=errorbar(curves{qp}{z}(1,:),curves{qp}{z}(2,:),curves{qp}{z}(3,:));
                     for jj=1:length(h),set(h(jj),'linewidth',2,'color',colord(crd,:));end;
                   end;
              end;
              if p.graphParams(i).showspont&~isempty(c.spont)&... % draw spontaneous if requested and available
                    (p.graphParams(i).whattoplot==3|p.graphParams(i).whattoplot==8),
                   xlim=get(cax,'xlim');
                   h1=plot(xlim,c.spont(1)*[1 1],'--');
                   h2=plot(xlim,c.spont(1)*[1 1]+c.spont(2)*[1 1],'--');
                   h3=plot(xlim,c.spont(1)*[1 1]-c.spont(2)*[1 1],'--');
                   crd=mod(length(c.vals2)+1,size(colord,1));
                   set(h1,'color',colord(crd,:)); set(h2,'color',colord(crd,:));
                   set(h3,'color',colord(crd,:));
              end;
              if any(p.graphParams(i).whattoplot==[6 11 16]),
                  xlim=get(cax,'xlim');
                  h1=plot(xlim,pi/2*[1 1],'--k');
              end;
              if any(p.graphParams(i).whattoplot==[7 12 17]),
                  xlim=get(cax,'xlim');
                  h1=plot(xlim,[1 1],'--k');
              end;
              xlabel(I.paramnames{1});
              ylabel(ylabels{p.graphParams(i).whattoplot});
              set(cax,'tag','analysis_generic','uicontextmenu',contextmenu(pc));
        end; % switch
     end;  % if 
   end; % for i=1:4
   % add a title
   %if ~isempty(rct2),
   %   rastwhere.figure = w.figure; rastwhere.units=w.units; rastwhere.rect=rct2;
   %   tc.internals.rast = setlocation(tc.internals.rast,rastwhere);
   %end;
   %if ~isempty(rct3), 
   %   spontwhere.figure=w.figure; spontwhere.units=w.units;spontwhere.rect=rct3;
   %   tc.internals.spont = setlocation(tc.internals.spont,spontwhere);
   %end;
   %set(cxa,'userdata',{ tc.internals.rast tc.internals.spont});
end;

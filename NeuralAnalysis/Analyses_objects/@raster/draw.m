function t = draw(ra)

%  Part of the NeuralAnalysis package
% 
%  DRAW(RASTEROBJ)
%
%  Draws the output to the location in the RASTER object RASTEROBJ.
%
%  See also:  RASTER, ANALYSIS_GENERIC/DRAW

%disp('drawing raster'),
w = location(ra); p = getparameters(ra); I = getinputs(ra);

if ~isempty(w),
   psthaxeslist = []; % list of psth axes
   z = getgraphicshandles(ra);
   if ~isempty(z), % delete objects
	for i=1:length(z), delete(z(i)); end;
   end;
   figure(w.figure); figRect = get(w.figure,'Position');
   if strcmp(w.units,'pixels'), ssw=figRect(3);ssh=figRect(4);
   else, ssw = 1; ssh=1; end;
   % decompose figure
   width = w.rect(3); height = w.rect(4);
   M = max([1 round(sqrt(length(I.triggers)*(width/height)))]);
   N = max([1 ceil(length(I.triggers)/M)]);
   m=w.rect(1):(width/M):(w.rect(1)+width);
   n=w.rect(2):(height/N):(w.rect(2)+height);
   mi = 1; ni = 1; ohno = length(n)+1-ni;
   for i=1:length(I.triggers),
     if ni>N, warning('Ni! Ni!'); end; % shouldn't happen
     if p.fracpsth>0,
       %disp('plotting psth');
       f = 1;
       if p.normpsth,
	 f=1/(length(I.triggers{i})*p.res);
       end;
       
       psthrect=[0.1*ssw 0.1*ssh 0.8*ssw ssh*0.8*p.fracpsth];
       %psthrect=[w.rect(1)+0.1*w.rect(3) w.rect(2)+0.1*w.rect(4) ...
	%	 w.rect(3)*0.8           w.rect(4)*0.8*p.fracpsth],
        %[m(mi) n(ohno-1) m(mi+1) n(ohno)],
       psthrect=grect2local(psthrect,w.units,...
                  [m(mi) n(ohno-1) m(mi+1) n(ohno)],w.figure);
       pp=axes('units',w.units,'position',psthrect);
       psthaxeslist(end+1) = pp;
       if p.psthmode==0, % bars
	  h = bar(ra.internals.bins{i},ra.internals.counts{i}*f);
       else, h = plot(ra.internals.bins{i},ra.internals.counts{i}*f);
       end;
       set(h,'uicontextmenu',contextmenu(ra));
       if p.showvar==1,
	  hold on;
          h2=plot(ra.internals.bins{i},ra.internals.counts{i}*f+...
		ra.internals.variation{i}*f,'r');
          h3=plot(ra.internals.bins{i},ra.internals.counts{i}*f-...
		ra.internals.variation{i}*f,'r');
	  set(h2,'uicontextmenu',contextmenu(ra));
          set(h3,'uicontextmenu',contextmenu(ra));
       end;
       if p.showcbars,
          lims=axis;
          hold on;
	  plot([ra.internals.bins{i}(ra.internals.cstart{i}) ...
            ra.internals.bins{i}(ra.internals.cstart{i})],10000*[-1 1],'y',...
		'linewidth',2,'uicontextmenu',contextmenu(ra));
	  plot([ra.internals.bins{i}(ra.internals.cstop{i}) ...
               ra.internals.bins{i}(ra.internals.cstop{i})] ,10000*[-1 1],'y',...
		'linewidth',2,'uicontextmenu',contextmenu(ra));
          axis(lims);
       end;
       set(pp,'xlim',[ra.internals.bins{i}(1) ra.internals.bins{i}(end)]);
       set(pp,'uicontextmenu',contextmenu(ra));
       set(pp,'tag','analysis_generic');
       xlabel('Time (s)');
       if p.normpsth,ylabel('rate (Hz)');else,ylabel('counts');end;
       if p.fracpsth==1, title(I.condnames{i}); end;
     end;
     if p.fracpsth<1,
      rarect=[0.1*ssw 0.1*ssh+ssh*0.8*p.fracpsth 0.8*ssw ...
                  0.9*ssh-(0.1*ssh+0.8*ssh*p.fracpsth)];
      %rarect=[w.rect(1)+0.1*w.rect(3) ...
      %           w.rect(2)+(0.1+0.8*p.fracpsth)*w.rect(4) ...
%		 w.rect(3)*0.8  ...
%                 (w.rect(2)+w.rect(4)-0.1*w.rect(4))- ...
%                     (w.rect(2)+(0.1+0.8*p.fracpsth)*w.rect(4))];
      rarect=grect2local(rarect,w.units,[m(mi) n(ohno-1) m(mi+1) n(ohno)],w.figure);
      r=axes('units',w.units,'position',rarect,'tag','analysis_generic');
      if ~isempty(ra.computations.rast{i}),
%           if 1
        A=[ra.computations.rast{i}(1,:); ra.computations.rast{i}(1,:)];
        
        b = ra.computations.rast{i}(2,:);
        trials = uniq(sort(b));
        for ti = 1:length(trials)
            b(b==trials(ti)) = ti;
        end
        
        
        B=[b-0.45; b+0.45];
        %h=plot(ra.computations.rast{i}(1,:),ra.computations.rast{i}(2,:),'k.');
        h=plot(A,B,'k');
        set(h,'uicontextmenu',contextmenu(ra));%,'MarkerSize',1);
      else, h = [];
      end;
      if p.showcbars,
          lims=axis;
          hold on;
	  plot([ra.internals.bins{i}(ra.internals.cstart{i}) ...
            ra.internals.bins{i}(ra.internals.cstart{i})],10000*[-1 1],'y',...
		'linewidth',2,'uicontextmenu',contextmenu(ra));
	  plot([ra.internals.bins{i}(ra.internals.cstop{i}) ...
               ra.internals.bins{i}(ra.internals.cstop{i})] ,10000*[-1 1],'y',...
		'linewidth',2,'uicontextmenu',contextmenu(ra));
          axis(lims);
      end;
      if p.fracpsth>0, set(r,'xtick',[]);
      else, xlabel('Time(s)'); end;
      title(I.condnames{i});
      set(r,'ylim',[0 length(I.triggers{i})+1]);
      if exist('b','var')
          set(r,'ylim',[0 max(b)+1]);
      end
      set(r,'YDir','reverse','YTick',[0 length(I.triggers{i})]);
      set(r,'xlim',[ra.internals.bins{i}(1) ra.internals.bins{i}(end)]);
      set(r,'YAxisLocation','right');
      set(r,'uicontextmenu',contextmenu(ra));
      set(r,'tag','analysis_generic');
      ylabel('Trigger #');
     end;
     mi = mi + 1; if mi>M, ni = ni + 1; mi = 1; end;
     ohno=length(n)+1-ni;
   end;
   if p.axessameheight==1,
      themax = 0; themin = 0;
      for jj=1:length(psthaxeslist),
          axes(psthaxeslist(jj));
          A = axis;
          if A(4)>themax, themax = A(4); end;
          if A(3)<themin, themin = A(3); end;
      end;
      for jj=1:length(psthaxeslist),
          axes(psthaxeslist(jj));
          A = axis;
          axis([A(1) A(2) themin themax]);
      end;
   end;
end;
t=0;

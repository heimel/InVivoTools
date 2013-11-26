function [r,p]=make_popgraph(strains,types,stim_type,measure,eye, ...
  labels,ylab,prefax,cluster_strains,...
  notshowsig,save_option,spaced,barcolor,test)
%
%  DEPRECATED in favor of POPGRAPH (Sept. 2006)
%
% empty type is a space between bars
% if PREFAX is 2-vector then only used as preferred vertical axis
% SPACED indicates if individual measurements should be spaced
% along the axis
%
% BARCOLOR is 3x1 rgb value for facecolor of bars.
% if BARCOLOR == -1 then do not show bars
%
% 2005, Alexander Heimel
%

disp('MAKE_POPGRAPH is deprecated. Use POP2GRAPH instead.');

if nargin<14
  test=[];
end
if isempty(test)
  test='ttest';
end

if nargin<13
  barcolor=[];
end

if nargin<12
  spaced=[];
end
if isempty(spaced)
  spaced=0;
end

if nargin<11
  save_option=[];
end
if isempty(save_option)
  save_option=1;
end

if nargin<10
  notshowsig=[];
end
if isempty(notshowsig)
  notshowsig=-1;
end

if nargin<9
  cluster_strains=[];
end
if isempty(cluster_strains)
  cluster_strains=1;
end


if nargin<8
  prefax=[];
end

if nargin<7
  ylab=[];
end

if nargin< 6
  labels=[];
end

if ~iscell(strains)
  strains={strains};
end

if ~iscell(barcolor)
  tmpbarcolor=barcolor;
  barcolor={};
  for s=1:length(strains)
    for t=1:length(types)
      barcolor{s,t}=tmpbarcolor;
    end
  end
  clear('tmpbarcolor');
end



for s=1:length(strains)
  if isempty(find(strains{s}=='='))
    strains{s}=['strain=' strains{s}];
  end
end


r={};
r_sem={};
mice={};

mousedb=load_mousedb;
testdb=load_testdb;
s=1;
while s<=length(strains)
  n_points=0;
  for i=1:length(types)
    if ~isempty(types{i})
      if isempty(findstr(types{i},'type='))
        type_mouse=['type=' types{i}];
      else
        type_mouse=types{i};
      end
      
      [r{s,i},r_sem{s,i},mice{s,i}]=...
        get_results([strains{s} ', ' type_mouse], ...
        stim_type,measure,eye,[],mousedb,testdb);
      n_points=n_points+length(r{s,i});
    end
  end
  s=s+1;
  %  if n_points>0 % if no points, don't use
  %    s=s+1;
  %  else
  %    s
  %    if s<length(strains)
  %      strains={strains{[(1:s-1) (s+1:end)]}};
  %    else
  %      strains={strains{1:end-1}};
  %      break
  %    end
  %    disp(['No datapoints for strain '  strains{s} '. Leaving out']);
  %  end
end

figure;
left=0.15;
width=min(0.7,0.2*length(strains)*length(types));
subplot('position',[left 0.20 width 0.7]);
hold on

xt=1;
x=[];
if cluster_strains==1
  for s=1:length(strains)
    % if no points, then don't plot
    n_points=length( [r{s,:}] );
    if n_points>0


      for i=1:length(types)
        if ~isempty(types{i})
          x(s,i)=xt;
          plot_point(x(s,i),r{s,i},barcolor{s,i});
          plot_points(x(s,i),r{s,i},spaced);
          %text( x(i),0,num2str(length(mice{i})));
          xt=xt+1;
        else
          x(s,i)=xt;
          xt=xt+0.5;
        end
      end
      xt=xt+1;
    else
      for i=1:length(types);
        x(s,i)=- s*length(types)-i;
      end
      %disp(['No points for strain ' strains{s} '. Not plotting.']);
    end
  end

else
  for i=1:length(types)
    if ~isempty(types{i})
      for s=1:length(strains)
        x(s,i)=xt;
        plot_point(x(s,i),r{s,i},barcolor{s,i});
        plot_points(x(s,i),r{s,i},spaced);
        %text( x(i),0,num2str(length(mice{i})));
        xt=xt+1;
      end
      xt=xt+1;
    else
      x(s,i)=xt;
      xt=xt+0.5;
    end
  end

end


ax=axis;
ax(1)=0.5; ax(2)=max(x(:))+0.5;% ax(3)=0; ax(4)=0.8;
axis(ax);

if ~isempty(prefax)
  if length(prefax)==4
    axis(prefax);
    ax=axis;
  else
    ax([3 4])=prefax;
  end
end

% following code is suspicious in case some strains are missing
[sx,sind]=sort(x(:));
set(gca,'XTick',sx);
if ~isempty(labels)
  if length(labels(:))==length(x(:))
    set(gca,'XTickLabel',labels(sind));
  else
    set(gca,'XTickLabel',labels);
  end
else
  set(gca,'XTick',[]);
end

if cluster_strains==1 && length(strains)>1
  for s=1:length(strains)
    if x(s,1)>0 % otherwise, it is not plotted
      strain=strains{s};
      k=findstr(strain,'strain=');
      if ~isempty(k)
        strain=strain(k+7:end);
      end
      k=findstr(strain,'BXD-');
      if ~isempty(k)
        strain=strain(k+4:end);
      end
      k=findstr(strain,'C57');
      if ~isempty(k)
        strain='B6';
      end
      k=findstr(strain,'DBA');
      if ~isempty(k)
        strain='D2';
      end
      h=text( ( x(s,1)+x(s,length(types)))/2-0.2,...
        ax(3)-(ax(4)-ax(3))/50, strain);
      set(h,'Rotation',70);
      set(h,'HorizontalAlignment','right');
      set(h,'VerticalAlignment','middle');
      set(h,'FontSize',ceil(10-length(strains)/10));
    end
  end
end


%text(1.3,ax(3)-(ax(4)-ax(3))/5,'p35');
%text(3.3,ax(3)-(ax(4)-ax(3))/5,'adult');

if ~isempty(ylab)
  ylabel(ylab);
end



p=[];
height=(ax(4)-ax(3))/10;
w=0.1;

% plot significances
if cluster_strains==1
  for s=1:length(strains)
    for i=1:length(types)
      for j=i+1:length(types)
        nsig=((s-1)*length(types)*length(types))+...
          (i-1)* length(types)+j;
        if isempty(find(notshowsig==nsig))
          %	ax(4)=ax(4)+height;
          y=ax(4)+height*(j-i-1);
          [h,p(s,i,j)]=plot_significance( r{s,i},x(s,i),...
            r{s,j},x(s,j),y,height,w);
          if p(s,i,j)<1
            disp([num2str(nsig) ': Strain ' strains{s}...
              ' Types ' types{i} ' and ' types{j}...
              ' significantly different , p = ' num2str(p(s,i,j))]);
          end
        end
      end
    end
  end
  ax(4)=ax(4)+height*(length(types)-1);
  axis(ax);
elseif cluster_strains==0
  for i=1:length(types)
    for s=1:length(strains)
      for t=s+1:length(strains)
        nsig=((i-1)*length(strains)*length(strains))+...
          (s-1)* length(strains)+t;
        if isempty(find(notshowsig==nsig))
          y=ax(4)+height*(t-s);
          [h,p(s,t,i)]=plot_significance( r{s,i},x(s,i),...
            r{t,i},x(t,i),y,height,w);
          if p(s,t,i)<1 % h==1
            disp([num2str(nsig) ': ' ...
              'Strains ' strains{s} ' and ' strains{t} ...
              ' Type ' types{i} ...
              ' significantly different , p = ' num2str(p(s,t,i))]);
          end
        end
      end
    end
  end
  ax(4)=ax(4)+height*(length(strains)-1);
  axis(ax);
else
  disp('---');
  for j=1:length(types)
    for i=1:length(types)
      for s=1:length(strains)
        for t=s+1:length(strains)
          nsig=(j-1)*length(types)*length(strains)*length(strains)+...
            (i-1)*length(strains)*length(strains)+...
            (s-1)* length(strains)+t;
          if isempty(find(notshowsig==nsig))
            y=ax(4)+height*(t-s);
            [h,p(s,t,j,i)]=plot_significance( r{s,j},x(s,j),...
              r{t,i},x(t,i),y,height,w);
            if  p(s,t,j,i)<1
              disp([num2str(nsig) ': ' ...
                'Strain ' strains{s} ' ' types{j} ...
                ' and ' strains{t} ' ' types{i} ...
                ' significantly different , p = ' num2str(p(s,t,j,i))]);
            end
          end
        end
      end
    end
  end
  ax(4)=ax(4)+height*(length(strains)-1);
  axis(ax);
end

if ~isempty(prefax)
  if length(prefax)==4
    axis(prefax);
  end
end


ax=axis;
line([ ax(1) ax(2)],[ax(3) ax(3)],'Color','k');

if length(strains)*length(types)>8
  set(gca,'ygrid','on');
end


switch measure
  case 'iodi',
    a=gca;
    axodi=axis;
    h=subplot('position',[left+width+0.0 0.2 0.01 0.7]);
    set(h,'YAxisLocation','right')
    axis([0 1 (axodi(3)+1)/2  (axodi(4)+1)/2]) ;
    set(gca,'XTick',[]);
    set(gca,'XTickLabel',[]);
    ylabel('imaged Contralateral Bias Index');
    axes(a);
end


bigger_linewidth(3);
smaller_font(-11);

if save_option
  filename=['pop_' [strains{:}] '_' measure '_' eye ];
  save_figure(filename);
end


return

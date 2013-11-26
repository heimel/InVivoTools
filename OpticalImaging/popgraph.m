function [r,p]=popgraph(strains,types,stim_type,measure,eye, ...
  labels,ylab,prefax,cluster_strains,...
  notshowsig,save_option,spaced,color,test,showpoints,label_strains,...
  verbose,mousedb,testdb,reliable)
%
% DEPRECATED, use POP2GRAPH
%
% empty type is a space between bars
% if PREFAX is 2-vector then only used as preferred vertical axis
% SPACED indicates if individual measurements should be spaced
% along the axis
%
% color is 3x1 rgb value for facecolor of bars.
% if color == -1 then do not show bars
%
% 2006, Alexander Heimel, improved from MAKE_POPGRAPH
%

disp('POPGRAPH is deprecated. Use POP2GRAPH instead.');

if nargin<20;reliable=[];end
if nargin<19;testdb=[];end
if nargin<18;mousedb=[];end
if nargin<17;verbose=[];end
if nargin<16;label_strains=[];end
if nargin<15;showpoints=[];end
if nargin<14;test=[];end
if nargin<13;color=[];end
if nargin<12;spaced=[];end
if nargin<11;save_option=[];end
if nargin<10;notshowsig=[];end
if nargin<9;cluster_strains=[];end
if nargin<8;prefax=[];end
if nargin<7;ylab=[];end
if nargin<6;labels=[];end

% defaults

if isempty(reliable);reliable=1,end
if isempty(label_strains);label_strains=1,end
if isempty(notshowsig);notshowsig=-1,end
if isempty(cluster_strains);cluster_strains=1,end
if isempty(save_option);save_option=1,end
if isempty(test);test='ttest',end
if isempty(spaced);spaced=0,end

if ~iscell(strains);
  strains={strains};
end

if isempty(color)
  color=0.7*[1 1 1];
end
if ~iscell(color)
  tmpcolor=color;
  color={};
  for s=1:length(strains)
    for t=1:length(types)
      color{s,t}=tmpcolor;
    end
  end
  clear('tmpcolor');
end

for s=1:length(strains)
  if isempty(find(strains{s}=='='))
    strains{s}=['strain=' strains{s}];
  end
end


% collect results from databases
r={};
r_sem={};
mice={};
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
        stim_type,measure,eye,verbose,mousedb,testdb,reliable);
      n_points=n_points+length(r{s,i});
    end
  end
  s=s+1;
end

% call graph

xt=1;
barcount=1;
if cluster_strains==1
  for s=1:length(strains)
    % if no points for strain s, then don't plot
    n_points=length( [r{s,:}] );
    if n_points>0
      for i=1:length(types)
        if ~isempty(types{i})
          gx(barcount)=xt;
          gy{barcount}=r{s,i};
          gstrain{barcount}=strains{s};
          gtype{barcount}=types{i}
          gcolor{i}=color{s,i};
          xt=xt+1;
          barcount=barcount+1;
        else
          xt=xt+0.5;
        end
      end
      xt=xt+1;
    end
  end
else
  for i=1:length(types)
    if ~isempty(types{i})
      for s=1:length(strains)
        gx(barcount)=xt;
        gy{barcount}=r{s,i};
        gstrain{barcount}=strains{s};
        gtype{barcount}=types{i};
        gcolor{i}=color{s,i};
        xt=xt+1;
        barcount=barcount+1;
      end
      xt=xt+1;
    else
      xt=xt+0.5;
    end
  end
end

h=graph(gy,gx,'style','bar','ylab',ylab,'xticklabels',labels,...
  'prefax',prefax,'errorbars','sem','notshowsig',notshowsig,...
  'spaced',spaced,'color',color,'test',test,'showpoints',showpoints);
p=h.p_sig;

ax=axis;
if label_strains && cluster_strains==1 && length(strains)>1
  for i=1:length(gstrain)
    strain=gstrain{i};
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
    h=text( gx(i),...
      ax(3)-(ax(4)-ax(3))/5, strain);
    set(h,'HorizontalAlignment','center');
  end
end


if save_option
  filename=['pop_' [strains{:}] '_' measure '_' eye ];
  save_figure(filename);
end

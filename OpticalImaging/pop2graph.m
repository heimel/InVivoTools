function [r,p]=pop2graph(groups,stim_types,measures,varargin)
%POP2GRAPH
%
%  [R,P]=POP2GRAPH(GROUPS,MEASURES,VARARGIN);
%
% 2007, Alexander Heimel, based on POPGRAPH

% possible varargins with default values
pos_args={...
  'reliable',1,...  % 1 to only use reliable records, 0 to use all
  'testdb',load_testdb,...
  'mousedb',load_mousedb,...
  'verbose',1,...
  'showpoints',1,...
  'test','ttest',...
  'barcolor',0.7*[1 1 1],...
  'spaced',0,...
  'save_option',1,...
  'notshowsig',[],...
  'prefax',[],...
  'grouplabels',groups,...
  'measurelabels',measures,...
  'style','bar',...
  'eyes','contra',...
  'celltype','su',...     % one of 'all','mu','su'
  };

if nargin<3
  disp('POP2GRAPH is using default arguments:');
  disp(pos_args)
end

assign(pos_args{:});

%parse varargins
nvarargin=length(varargin);
if nvarargin>0
  if rem(nvarargin,2)==1
    warning('odd number of varguments');
    return
  end
  for i=1:2:nvarargin
    found_arg=0;
    for j=1:2:length(pos_args)
      if strcmp(varargin{i},pos_args{j})==1
        found_arg=1;
        assign(pos_args{j}, varargin{i+1});
      end
    end
    if ~found_arg
      warning(['could not parse argument ' varargin{i}]); 
      return
    end
  end
end


if ~iscell(groups);
  groups={groups};
end
grouplabels=shorten_bxdnames(grouplabels);

n_groups=length(groups);

if ~iscell(barcolor)
  tmpbarcolor=barcolor;
  barcolor={};
  for g=1:n_groups
      barcolor{g}=tmpbarcolor;
  end
  clear('tmpbarcolor');
end


% center grouplabels for use in captions
grouplabels=strjust(char(grouplabels),'center');

% center measurelabels for use in captions
measurelabels=strjust(char(measurelabels),'center');

% if no field (i.e. no '=') is specified in groups, assume it should be strain
for g=1:n_groups
  if isempty(find(groups{g}=='='))
    groups{g}=['strain=' groups{g}];
  end
end


% collect results from databases
r={};
r_sem={};
mice={};
for g=1:n_groups
  if ~isempty(groups{g})
  [r{g},r_sem{g},mice{g}]=...
    get_results(groups{g}, ...
    stim_types,measures,eyes,verbose,mousedb,testdb,reliable);
  end
end
  

% call graph
xt=1;
barcount=1;
for g=1:n_groups
  % if no points for group g, then don't plot
  if length( r{g} )>0
    gx(barcount)=xt;
    gy{barcount}=r{g};
    glabel{barcount}=grouplabels(g,:);
    gbarcolor{barcount}=barcolor{g};
    barcount=barcount+1;
  end
  xt=xt+1;
end

h=graph(gy,gx,'style','bar','ylab',measurelabels,...
  'xticklabels',glabel,'prefax',prefax,'errorbars','sem',...
  'notshowsig',notshowsig,'spaced',spaced,'barcolor',barcolor,...
  'test',test,'showpoints',showpoints);
p=h.p_sig;

if save_option
    l=grouplabels';
m=measurelabels';
  filename=['pop_' l(1:min(end,15)) '_' m(:)' '_' eyes ]
  save_figure(filename);
end

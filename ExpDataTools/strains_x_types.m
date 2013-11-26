function groups=strains_x_types( strains,types)
%STRAINS_X_TYPES makes group combinations from all strains with all types
%
% 2007, Alexander Heimel
%

groups={};
for s=1:length(strains)
  for t=1:length(types)
    if isempty(find(strains{s}=='='))
      strain=['strain=' strains{s}];
    else
      strain=strains{s};
    end
    if isempty(find(types{s}=='='))
      type=['type=' types{t}];
    else
      type=types{s};
    end
    
    groups{end+1}=[  strain ','  type];
  end
  if s~=length(strains)
    groups{end+1}='';
  end
end

function fullpath=compose_figurepath( path )
%COMPOSE_FIGUREPATH makes partial path into proper paths 
%
% 2008, Alexander Heimel
%
if isempty(path)
  path='~';
end

fullpath=path;
if isunix
  if path(1)~='/' && path(1)~='~'
    fullpath=['~/' path];
  end
else % dos, newer versions of matlab
  if path(1)=='~' % denoting unix userhome directory
    if length(path)>2
      path=path(3:end);
      warning off MATLAB:MKDIR:DirectoryExists
      mkdir(prefdir(1),path);
    else
      path='';
    end
    fullpath=fullfile(prefdir,path);  
  end
end
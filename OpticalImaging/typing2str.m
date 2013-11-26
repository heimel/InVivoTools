function s=typing2str( t)
%TYPING2STR changes typing number to str
%
%   S=TYPING2STR( T )
%
%   0 = -
%   1 = +
%   2 = hom
%   3 = het
%  else = ''
%  
% 2005, Alexander Heimel
%
  if isempty(t)
    s='';
    return
  end
  
  switch t
   case 0,
    s='-';
   case 1,
    s='+';
   case 2,
    s='hom';
   case 3,
    s='het';
   otherwise
    disp('Warning: unknown typing number');
    s='';
  end
  
  
  

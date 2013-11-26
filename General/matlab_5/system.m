function [status,result] = system( command) 
%SYSTEM wrapper for DOS and UNIX 
%
% 2007, Alexander Heimel
%

switch computer
 case 'PCWIN'
  [status,result] = dos( command); 
 case {'LNX86','GLNX86'}
  [status,result] = unix( command) ;
end

  

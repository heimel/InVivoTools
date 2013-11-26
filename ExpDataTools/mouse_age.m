function [d,w,m]=mouse_age( mouse,at )
%MOUSE_AGE
%
%    [D,W,M]=MOUSE_AGE( MOUSE, AT )
%          MOUSE is e.g. 05.01.2.01
%
% 2005, Alexander Heimel
%

if nargin<2
  at=[];
end


d=[];
w=[];
m=[];

mousedb=load_mousedb;

indmouse=find_record(mousedb,['mouse=' mouse]);
if isempty(indmouse)
  disp(['Could not find mouse ' mouse]);
  return
end
if length(indmouse)>1
  disp(['Too many mice like ' mouse]);
  return
end

[d,w,m]=age(mousedb(indmouse).birthdate,at);

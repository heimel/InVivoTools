function [mousedb,filename]=load_mousedb
%LOAD_MOUSEDB loads mouse_db
%
% 2005, Alexander Heimel
%

[mousedb,filename] = load_expdatabase('mousedb');

logmsg('Temp removal for multiline comments');
for i=1:length(mousedb)
    if size(mousedb(i).comment,1)>1 && ischar(mousedb(i).comment)% i.e. multiline
        mousedb(i).comment = flatten(mousedb(i).comment')';
    end
end



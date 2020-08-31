function [mousedb,filename]=load_mousedb
%LOAD_MOUSEDB loads mouse_db
%
% {MOUSEDB, FILENAME] = LOAD_MOUSEDB
%
% 2005-2020, Alexander Heimel
%

[mousedb,filename] = load_expdatabase('mousedb',[],[],[],false);

for i=1:length(mousedb)
    if size(mousedb(i).comment,1)>1 && ischar(mousedb(i).comment)% i.e. multiline
        mousedb(i).comment = flatten(mousedb(i).comment')';
    end
end



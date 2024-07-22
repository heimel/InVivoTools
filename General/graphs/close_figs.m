function close_figs
%CLOSE_FIGS closes all figures that do not have userdata.persistent == 1
%
%  CLOSE_FIGS
%
% 2007-2024, Alexander Heimel
%

c = get(0,'Children');
for i = 1:length(c)
    if isa(c(i),'matlab.ui.Figure')
        fud = get(c(i),'UserData');
        if isempty(fud) || ~isfield(fud,'persistent') || ~fud.persistent
            close(c(i));
            delete(c(i));
        end
    end
end

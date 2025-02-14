function z = getgraphicshandles(ag)

%  Part of the NeuralAnalysis package
%
%  Z = GETGRAPHICSHANDLES(ANALYSIS_GENERICOBJ)
%
%  Returns a list of graphics handles associated with ANALYSIS_GENERICOBJ.
%  It does this by looking for graphics handles with a 'tag' equal to
%  'analysis_generic' and uicontextmenu equal to the one associated with the
%  analysis_generic object ANALYSIS_GENERICOBJ.
%
%  See also:  ANALYSIS_GENERIC

z = [];
w = location(ag);
if ishandle(w.figure)
    Z=findobj(w.figure,'tag','analysis_generic');
    for i=1:length(Z)
        if ishandle(Z(i)) && ...
                ~isempty(get(Z(i),'uicontextmenu')) &&...
                (get(Z(i),'uicontextmenu')==contextmenu(ag))
            z = [z Z(i)];
        end
    end
end


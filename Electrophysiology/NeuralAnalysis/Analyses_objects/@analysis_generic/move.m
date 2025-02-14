function move(ag, oldfig, newfig)

%  Part of the NeuralAnalysis package
%
%  MOVE (ANALYSIS_GENERICOBJ, OLDFIG, NEWFIG)
%
%  Moves any graphics drawn by ANALYSIS_GENERICOBJ from OLDFIG to NEWFIG.
%  Note that this routine only moves objects from one figure to another, not
%  within a given figure.
%
%  See also:  ANALYSIS_GENERIC, SETLOCATION

set(ag.contextmenu,'parent',newfig);

z = getgraphicshandles(ag);

for i=1:length(z),
	set(z(i),'parent',newfig);
end;

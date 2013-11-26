% TPASSOCIATELISTGLOBALS - Associates that are added to tpstack cells
%
%  Establishes a global variable, TPASSOCIATELIST.
%  

global tpassociatelist

if isempty(tpassociatelist),
	tpassociatelist = struct('type','','owner','twophoton','data','','desc','');
	tpassociatelist = tpassociatelist([]);
end;

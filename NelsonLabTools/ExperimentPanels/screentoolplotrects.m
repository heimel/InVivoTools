function stim = screentoolplotrects(stim,vars)
ax = vars{2};

crax = gca;
axes(ax);
hold on;
p = getparameters(stim);
if isfield(p,'rect'),
	r = p.rect;
	h = fill(r([1 3 3 1]),r([2 2 4 4]),[0 0 1]);
	set(h,'Tag','stim','ButtonDownFcn','screentool axesbuttondown');
end;
axes(crax);
stim = [];

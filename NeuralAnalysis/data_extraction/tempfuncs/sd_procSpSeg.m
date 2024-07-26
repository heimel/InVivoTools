function [st,typ] = sd_procSpSeg(e,s,ppos,segst,k,dt)

ip = segst(k):segst(k+1)-1;	% index into ppos
pp = ppos(ip);				% ppos of the target segment
ev = e(pp);					% energy at ppos
sv = s(ip);					% sign at ppos

pnwin1 = ceil(300e-6/dt);
pnwin2 = ceil(2500e-6/dt);
npwin = ceil(600e-6/dt);
npwin2 = ceil(1500e-6/dt);
ratio  = 0.3;
ratio2 = 0.5;

st = [];
typ = [];

npeak = length(pp);

% return type 
% 1:+
% 2:-
% 3:+-
% 4:-+
% 5:-+-
% 6:+-+-
% 7:overlapped

if npeak == 1
	st = pp;
	if sv == 1
		typ = 1;
	else
		typ = 2;
	end
	return;
end

if npeak == 2
	st = pp;
	typ = [7;7];
	if prod(sv) == 1	% same sign
		return;
	end
	if sv(1) == 1		% +- type
		d = (pp(2) - pp(1));
		if (d > pnwin1) & (d < pnwin2)
			st = pp(1);
			typ = 3;
		end
		return;
	end
	if sv(1) == -1		% -+ type
		d = (pp(2) - pp(1));
		if (d < npwin)
			st = pp(1);
			typ = 4;
		end
		return;
	end
	% something wrong if reached here
	error('check here sd_procSpSeg');
end

if npeak == 3
	inp = find(sv==-1);
	if length(inp) > 0
		st = pp(inp);
		typ = 7*ones(length(st),1);
	else
		st = pp;
		typ = 7*ones(length(st),1);
	end	
	if all(sv == [-1;1;-1])	% -+- type
		if (pp(2) - pp(1)) >= npwin
			return;
		end
		st = pp([1,3]);
		typ = [7;7];
		d = pp(3) - pp(2);
		if (d <= pnwin1) | (d >= pnwin2)
			return;
		end
		if (ev(3) > ratio*max(ev(1),ev(2)) )
			return;
		end
		st = pp(1);
		typ = 5;
		return;
	end
	if all(sv == [1;-1;1])
		if ((pp(2)-pp(1)) > npwin2) | (ev(1) > ratio*max(ev))
			return;
		end
		if (pp(3)-pp(2)) > npwin
			return;
		end
		st = pp(1);
		typ = 4;
		return;
	end
	if all(sv == [-1;1;1])	% -++ type check last ++
		if (pp(2) - pp(1) < npwin) & ( min(e(pp(2):pp(3))) > ratio2*max(ev(2:3)) )
			st = pp(1);
			typ = 4;
			return;
		end
	end
	if all(sv == [1;-1;-1])	% +-- 
		if (pp(2) - pp(1) < pnwin2) & ( min(e(pp(2):pp(3))) > ratio2*max(ev(2:3)) )
			st = pp(1);
			typ = 3;
		end
	end

	return;
end

if npeak == 4
	inp = find(sv==-1);
	if length(inp) > 0
		st = pp(inp);
		typ = 7*ones(length(st),1);
	else
		st = pp;
		typ = 7*ones(length(st),1);
	end	
	if all(sv == [-1;1;-1;-1]);	% -+-- type 
		if (pp(2) - pp(1)) >= npwin
			return;
		end
		st = pp([1,3,4]);
		type = 7*ones(length(st),1);
		d = pp(3) - pp(2);
		if (d<=pnwin1) | (d>=pnwin2)
			return;
		end
		if (ev(3) > ratio*max(ev(1),ev(2)) )
			return;
		end
		st = pp([1,4]);
		typ = 7*ones(length(st),1);
		if min(e(pp(3):pp(4))) > ratio2*max(ev(3:4))
			st = pp(1);
			typ = 5;
			return;
		end
		return;
	end
	if all(sv == [1;-1;1;-1]);
		if (pp(2)-pp(1) > npwin)
			return;
		end
		if (pp(3)-pp(2) > npwin)
			return;
		end
		d = pp(4) - pp(3);
		if (d <= pnwin1) | (d >= pnwin2)
			return;
		end
		if (ev(4) > ratio*max(ev) )
			return;
		end
		st = pp(2);
		typ = 6;
	end
	return;
end

if npeak > 4
	inp = find(sv==-1);
	if length(inp) > 0
		st = pp(inp);
		typ = 7*ones(length(st),1);
	else
		st = pp;
		typ = 7*ones(length(st),1);
	end	
	return;
end






	

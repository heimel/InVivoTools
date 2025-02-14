function [b] = aresimulrecord(md1,md2,always)

% ARESIMULRECORD - are two measureddata objects measured simulatansouly?
%
%   [B] = ARESIMULRECORD(MD1,MD2,[ALWAYS])
%
%  If ALWAYS is 0 or not present, B is 1 if measureddata objects MD1 and MD2
%  were ever recorded at the same %  time.  If ALWAYS is 1, B is 1 if MD1 and
%  MD2 were always recorded at the same time.

b = 0;

int1 = get_intervals(md1);
int2 = get_intervals(md2);

if nargin<3, al = 0; else, al = always; end;


if al,
	b = eqlen(int1,int2);
else,
	for i=1:size(int1,1),
		for j=1:size(int2,1),
			if ((int1(i,1)>=int2(j,1))&(int1(i,1)<=int2(j,2)))|...
				((int1(i,2)<=int2(j,2))&(int1(i,2)>=int2(j,1))),
				b = 1; return;
			end;
		end;
	end;
end;

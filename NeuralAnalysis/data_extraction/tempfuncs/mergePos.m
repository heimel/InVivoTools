function [ppos,s,posmi,posMi] = mergePos(me,pposm,pposM,dt)
 % merges minor spikes and major spikes, keeping only the minor spikes which
 % are members of "segments" of the major spikes;
 % s is -1 for minor peaks, 1 for major peaks

[ppos,ii] = unique([pposm;pposM]); s = ones(size(pposM));
if length(pposm>0),
        posmgood=zeros(size(ppos));
        posmMind=zeros(size(ppos));
        s=zeros(size(ppos));
        posminds = find(ii<=length(pposm));
        posMinds = find(ii>length(pposm));
        posmMind(posminds)=1;
        posmMind(posMinds)=2;
        s(posminds) = -1; s(posMinds) = 1;
 % keep all points of pposM, and keep only pposm's which are members of segments
        posmgood(posMinds) = 1; % all in posM are keepers
        seggie=find(diff(ppos)<=floor(me.MEparams.overlap_sep/dt));
        posmgood(unique([seggie;seggie+1])) = 1; % now all seg members kept
        % now all are members of segments
        % all ppos2's get to stay, ppos1 that aren't seggie members are gone
        fg = find(posmgood);
        ppos = ppos(fg);
        s = s(fg);
        posmMind = posmMind(fg);
        posmi = find(posmMind==1); posMi = find(posmMind==2);
else, posmi = []; posMi = 1:length(pposM);
end;


function [cls,ncsp] = docluster(SC,fea,cspn)

mns = [ 1 1 1 1];
[c1,ucls] = cl_recursive2(SC,fea,1:length(fea),mns,SC.SCparams.maxND,...
		SC.SCparams.thN1,SC.SCparams.stS);
%disp(['ucls size: ' mat2str(size(ucls)) '.']);
% pca
cls1 = c1;
c = 1;
if ~isempty(c1)
        for k=1:length(c1)
                [pc,sc] = princomp(cspn(:,c1(k).idx)');
                fpc = sc(:,1:4);
                npc = abs(sum(pc(:,1:4)));
                [c2,u2] = cl_dcluster2(fpc,c1(k).idx,npc,SC.SCparams.maxND,...
			SC.SCparams.thN2,5);
                if isempty(c2)
                        c2 = c1(k);
                        u2 = [];
                end
                n = length(c2);
                cls1(c:(c+n-1)) = c2;
                c = c+n;
                ucls = [ucls u2];
        end
end
%length(ucls),
%size(cspn(:,ucls)'),
[pc, sc] = princomp(cspn(:,ucls)');
fpc = sc(:,1:4);
ncp = abs(sum(pc(:,1:4)));
[c2,u2] = cl_dcluster2(fpc,ucls,npc,SC.SCparams.maxND,SC.SCparams.thN2,5);
if ~isempty(c2)
        n = length(c2);
        cls1(c:(c+n-1)) = c2;
        c = c+n;
        ucls = u2;
end

gcsp1 = cl_medianTemplates(cspn,cls1);
[cls2,gcsp2,ovl] = cl_findOverlapped(SC,cls1,gcsp1,mns,SC.SCparams.ovlTh,SC.SCparams.ovlMN);
for i=1:length(ovl)
        disp([char(9) num2str(ovl(i).t) ' = ' num2str(ovl(i).i) ' + ' num2str(ovl(i).j)]);
end
disp(['original #clusters: ' num2str(length(cls1))]);
disp(['removed: ' num2str(length(cls1)-length(cls2))]);
[cls,ncsp] = cl_GroupAndMerge(SC,cls2,gcsp2,mns);

disp(['original #clusters: ' num2str(length(cls2))]);
disp(['merged: ' num2str(length(cls2)-length(cls))]);
disp(['num of groups: ' num2str(max([cls.gr]))]);



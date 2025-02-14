function C = getcells(cksds, nameref, inds)

%  Part of the NelsonLabTools package
%
%  C = GETCELLS(MYCKSDIRSTRUCT [, NAMEREF, INDS])
%
%  Returns cells from the experiment associated with MYCKSDIRSTRUCT.  If
%  NAMEREF (a struct with fields 'name' and 'ref') is provided, only cells with
%  the matching NAMREF are returned.  If INDS is given, the matches are limited
%  to those cells whose index match any of the entries in the vector INDS (this
%  only applies to multichannel references).  The cells are returned as a cell
%  list.
%
%  See also:  CKSDIRSTRUCT

C = {};

e = getexperimentfile(cksds);

try
    if nargin==1
        g=load(e,'cell*','-mat');
    else
        g=load(e,['cell_' nameref.name '*_' sprintf('%.4d',nameref.ref) '*'],'-mat');
    end
    if nargin<3
        C = fieldnames(g);
    else
        f = fieldnames(g);
        l=length(['cell_' nameref.name '_' sprintf('%.4d',nameref.ref) '_']);
        for i=1:length(f),
            for j=1:length(inds),
                if strcmp(f{i}(l+1:l+3),sprintf('%.3d',inds(j))),
                    C = cat(2,C,f(i)); break;
                end;
            end;
        end;
    end;
end;

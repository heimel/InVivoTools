function saveexpvar(cksds, vrbl, name, pres)

%  SAVEEXPVAR (MYCKSDIRSTRUCT, VARIABLE, NAME [, PRES])
%
%  Saves an experiment variable VARIABLE to CKSDIRSTRUCT MYCKSDIRSTRUCT with
%  the name NAME.  If PRES is 1, then if CELLVAR is of type MEASUREDDATA, then
%  any associates of MEASUREDDATA are preserved.

if nargin==4
    preserved = pres;
else
    preserved = 0;
end

fn = getexperimentfile(cksds);
if exist(fn,'file')
    a = [];
    if preserved
        warning('off','MATLAB:load:variableNotFound');
        try
            l=load(fn,name,'-mat');
        catch me
            logmsg(me.identifier);
            l = [];
        end
        warning('on','MATLAB:load:variableNotFound');
        if strcmp(version,'5.2.1.1421') % bug in Mac matlab passing empty structs
            if isempty(fieldnames(l))
                isafield = 0;
            else
                isafield = isfield(l,name);
            end
        else
            isafield = isfield(l,name);
        end
        if isafield
            gf = l.(name);
            a=getassociate(gf,1:numassociates(gf));
            if isempty(a)
                a = [];
            end
        end
    end
    if ~isempty(a)
        b = getassociate(vrbl,1:numassociates(vrbl));
        if isempty(b)
            b = [];
        end
        a = [a b];
        if ~isempty(b)
            vbrl=disassociate(vrbl,1:numassociates(vrbl));
        end
        for i=1:length(a)
            vrbl=associate(vrbl,a(i));
        end
    end
    eval([name '=vrbl;']);
    fnlock = [fn '-lock']; % a cheesy semaphore implementation
    openedlock = 0;
    loops = 0;
    while (exist(fnlock,'file')==2)&&loops<30
        dowait(rand); loops = loops + 1;
    end
    if loops==30
        error(['Could not save ' name ' to file ' fn '.']);
    end
    fid0=fopen(fnlock,'w');
    if fid0>0
        openedlock = 1;
    end
    try
        save(fn,name,'-append','-mat');
    catch
        if openedlock
            delete(fnlock);
        end
        error(['Could not save ' name ' to file ' fn '.']);
    end
    if openedlock,
        fclose(fid0);
        delete(fnlock);
    end
end

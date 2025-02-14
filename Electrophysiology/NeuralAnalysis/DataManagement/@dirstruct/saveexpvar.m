function saveexpvar(cksds, vrbl_sev, name_sev, pres)

%  SAVEEXPVAR (MYDIRSTRUCT, VARIABLE, NAME [, PRES])
%
%  Saves an experiment variable VARIABLE to DIRSTRUCT MYDIRSTRUCT with
%  the name_sev NAME.  If PRES is 1, then if CELLVAR is of type MEASUREDDATA, then
%  any associates of MEASUREDDATA are preserved.
%
%  VARIABLE and NAME can also be cell lists of variables and variable name_sevs.

if nargin==4, preserved_sev = pres; else, preserved_sev = 0; end;

if isa(name_sev,'char'),
	vrbl_sev = {vrbl_sev}; name_sev = {name_sev};
end;

fn_sev = getexperimentfile(cksds,1);
if exist(fn_sev)==2,
	warnstate_sev = warning('off');
	doappend_sev = (exist(fn_sev)==2);
	warning(warnstate_sev);
	for i=1:length(name_sev),
		a = [];
		if preserved_sev,
			warnstate_sev = warning('off');
			l=load(fn_sev,name_sev{i},'-mat');
			warning(warnstate_sev);
			if strcmp(version,'5.2.1.1421'), % bug in Mac matlab passing empty structs
				if isempty(fieldname_sevs(l)), isafield_sev = 0;
				else, isafield_sev = isfield(l,name_sev{i}); end;
			else, isafield_sev = isfield(l,name_sev{i});
			end;
			if isafield_sev,
				gf_sev = getfield(l,name_sev{i});
				a=getassociate(gf_sev,1:numassociates(gf_sev));
				if isempty(a), a = []; end;
			end;
		end;
		if ~isempty(a),
			b = getassociate(vrbl_sev{i},1:numassociates(vrbl_sev{i}));
			if isempty(b), b = []; end;
			a = [a b];
			if ~isempty(b),vrbl_sev{i}=disassociate(vrbl_sev{i},1:numassociates(vrbl_sev{i}));end;
			for j=1:length(a), vrbl_sev{i}=associate(vrbl_sev{i},a(j)); end;
		end;
		eval([name_sev{i} '=vrbl_sev{i};']);
	end;
	fnlock_sev = [fn_sev '-lock']; % a cheesy semaphore implementation
	openedlock_sev = 0;
	loops_sev = 0;
	while (exist(fnlock_sev,'file')==2)&loops_sev<30,
		dowait(rand); loops_sev = loops_sev + 1;
	end;
	if loops_sev==30,
		error(['Could not save ' name_sev{1} ' to file ' fn_sev ': file is locked by the existence of experiment-lock file in analysis directory']);
	end;
   	fid0_sev=fopen(fnlock_sev,'w'); if fid0_sev>0, openedlock_sev = 1; end;
	try,
        if doappend_sev, save(fn_sev,name_sev{:},'-append','-v7');
        else,
            save(fn_sev,name_sev{:},'-v7');
        end;
	catch,
		if openedlock_sev, delete(fnlock_sev); end;
		error(['Could not save variables to file ' fn_sev ': ' lasterr '.']);
	end;
	if openedlock_sev, fclose(fid0_sev); delete(fixtilde(fnlock_sev)); end;
end;

function refs = getnamerefs(cksds,testdir)
%  GETNAMEREFS - Return namerefs from a given test directory (CKSDIRSTRUCT)
%
%  refs = GETNAMEREFS(MYCKSDIRSTRUCT,TESTDIR)
%
%  Returns a list of namerefs structures associated with the test directory
%  TESTDIR.
%
%  See also:  CKSDIRSTRUCT

[dum1,loc,dum2] = intersect(cksds.dir_list,testdir);
if ~isempty(loc),
	refs = cksds.dir_str(loc).listofnamerefs;
else,
	refs.name='tmp';refs.ref=1; refs = refs([]); % make an empty one
end;

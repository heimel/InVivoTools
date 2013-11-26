function [testdb, experimental_pc] = expdatabases( type, hostname )
%EXPDATABASES returns name of levelt lab experimental database
%
%  [TESTDB, EXPERIMENTAL_PC] = EXPDATABASES( TYPE, HOSTNAME )
%
% 2011, Alexander Heimel
%
if nargin<1
    type = '';
end
if nargin<2
    hostname = host;
end

if isempty(type)
    type = 'tp';
end

testdb = '';
experimental_pc = false;
switch type
    case 'tp' % two-photon
        switch hostname
            case 'nin158' % friederike
                testdb='tptestdb_friederike';
            case {'nin326','lohmann'} % juliette
                testdb='tptestdb_juliette';
        end
    case 'ls' % linescans
        testdb='lstestdb_friederike';
    otherwise
        warning(['Unknown type ''' type '''']);
        return
end
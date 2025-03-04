function testdb = expdatabases( type, hostname )
%EXPDATABASES returns name of levelt lab experimental database
%
%  [TESTDB] = EXPDATABASES( TYPE, HOSTNAME )
%
%  DEPRECATED
%
% 2011-2012, Alexander Heimel
%

logmsg('DEPRECATED')

if nargin<2 || isempty(hostname)
    hostname = host;
end

if nargin<1 || isempty(type)
    type = 'oi';
end

switch type 
    case 'oi'
        prefix = '';
    otherwise
        prefix = type;
end

switch hostname
    case 'wall-e'
        hostname = 'olympus';
end

testdb = [prefix 'testdb_' hostname]; 

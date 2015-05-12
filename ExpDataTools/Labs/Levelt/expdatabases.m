function testdb = expdatabases( type, hostname )
%EXPDATABASES returns name of levelt lab experimental database
%
%  [TESTDB] = EXPDATABASES( TYPE, HOSTNAME )
%
% 2011-2012, Alexander Heimel
%

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
% 
% switch type
%     case 'oi'
%         switch hostname
%             case {'daneel','andrew','jander'}
%                 testdb=['testdb_' hostname];
%             otherwise
%                 testdb='testdb';
%         end
%     case {'ec','lfp'}
%         switch hostname
%             case {'nin380','nori001','daneel','antigua'}
%                 testdb = ['ectestdb_' hostname ];
%             otherwise
%                 testdb = 'ectestdb';
%         end
%     case 'tp'
%         switch hostname
%             case 'wall-e'
%                 testdb='tptestdb_olympus';
%            case 'nin343' % next to tychoscope
%                 testdb='tptestdb_lavision';
%             otherwise
%                 testdb='tptestdb_olympus';
%         end
%     case 'ls'
%         testdb = 'lstestdb_friederike';
%     otherwise  
%         testdb = [type 'testdb_' hostname];
% end

function [testdb, experimental_pc] = expdatabases( type, hostname )
%EXPDATABASES returns name of levelt lab experimental database
%
%  [TESTDB, EXPERIMENTAL_PC] = EXPDATABASES( TYPE, HOSTNAME )
%
% 2011-2012, Alexander Heimel
%

if nargin<2
    hostname = host;
end

if isempty(type)
   switch hostname
       case {'daneel','andrew','jander'}
           type = 'oi';
       case {'nori001','nin380','antigua'}
           type = 'ec';
       case {'olympus-0603301','wall-e'}
           type = 'tp';
       otherwise
           type = 'oi';
   end
end

experimental_pc = false;
switch type
    case 'oi'
        switch hostname
            case {'daneel','andrew','jander'}
                testdb=['testdb_' hostname];
            otherwise
                testdb='testdb';
        end
    case {'ec','lfp'}
        switch hostname
            case {'nin380','nori001','daneel','antigua'}
                experimental_pc = true;
            otherwise 
                experimental_pc = false;
        end
        if experimental_pc 
            testdb = ['ectestdb_' hostname ];
        else
            testdb = 'ectestdb';
        end
    case 'tp'
        switch hostname
            case 'wall-e'
                testdb='tptestdb_olympus';
                experimental_pc = true;
           case 'nin343' % next to tychoscope
                testdb='tptestdb_lavision';
                experimental_pc = true;
            otherwise
                testdb='tptestdb_olympus';
        end
    case 'ls'
        testdb = 'lstestdb_friederike';
    otherwise  
        testdb = [type 'testdb_' hostname];
        experimental_pc = true;
end
if ~strcmpi(hostname,host)
    experimental_pc = false;
end


function base = networkpathbase
%NETWORKPATHBASE return base of network data path
%
% BASE = NETWORKPATHBASE
%
%  LEVELTLAB dependent, returns path to levelt storage share 
%    should be without trailing fileseparator
%
% 2009-2017, Alexander Heimel
%

persistent base_persistent

if ~isempty(base_persistent)
    base = base_persistent;
    return
end

params = processparams_local([]);

% check if networkpathbase is set in processparams_local
if isfield(params,'networkpathbase') && ...
      ~isempty(params.networkpathbase) && ...
      exist(params.networkpathbase,'file')
  base = params.networkpathbase;
  return
end

if usejava('jvm') && ~exist('OCTAVE_VERSION', 'builtin')
    address = java.net.InetAddress.getLocalHost;
    IPaddress = char(address.getHostAddress);
    if ~strcmp(IPaddress(1:6),'192.87') && ~strcmp(IPaddress,'169.254.112.74') && ~strcmp(IPaddress(1:6),'146.50') % at the NIN or G2P
        logmsg('Not at the NIN, thus no networkpath');
        base = '.';
        base_persistent = base;
        return
    end
end

if isunix
    switch computer
        case {'MACI64','MACI'} 
            base = '/Volumes/MVP/Shared/InVivo';
        otherwise
            base = '/mnt/InVivo';
    end
else % assume windows
  base = 'Z:\InVivo';
  if ~exist(base,'dir')
      base = 'V:\InVivo'; % on nin380
  end
  if ~exist(base,'dir')
      base = '\\vs01.herseninstituut.knaw.nl\MVP\Shared\InVivo';
  end
  if ~exist(base,'dir')
      base = '\\vs01\MVP\Shared\InVivo';
  end
end
base_persistent = base;
  
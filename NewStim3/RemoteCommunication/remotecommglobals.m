% REMOTECOMMGLOBALS - Defines global variables for NewStim remote communications
%
%  Defines the following global variables for NewStim remote communications
%
%   Remote_Comm_enable      : 0/1 if remote comm. should be disabled/enabled
%   Remote_Comm_isremote    : 0/1 if this comp. is the slave (remote) computer
%   Remote_Comm_method      : Sets method for remote communication, must be
%                               'filesystem' if communication is through
%                                            files written to a common server or
%                           :   'sockets' if communication is over network
%                                            using TCP sockets.
%   Remote_Comm_dir         : Directory location to write files(filesystem only)
%   Remote_Comm_remotearchitecture : The operating system of the remote computer
%   Remote_Comm_localprefix: the local prefix of the shared directory with respect to the local computer
%   Remote_Comm_remoteprefix: the prefix of the shared directory as seen by the remote computer
%   Remote_Comm_host        : Internet hostname of remote computer (sockets)
%   Remote_Comm_port        : Port for sockets on remote computer
%
%   Remote_Comm_eol        : End of line used by remote computer e.g.,
%                                 '\n' for unix or '\r' for Mac OS9
%
%   Notes:  For socket communication, one must ensure that any firewall software
%   is configured to allow communication on the given port.
%
%   See REMOTECOMM, TRANSFERSCRIPTS, SENDREMOTECOMMAND, SENDREMOTECOMMANDVAR
%  



global Remote_Comm_isremote Remote_Comm_enable Remote_Comm_method Remote_Comm_dir
global Remote_Comm_host Remote_Comm_port
global Remote_Comm_socket Remote_Comm_conn
global Remote_Comm_eol
global Remote_Comm_remotearchitecture Remote_Comm_localprefix Remote_Comm_remoteprefix

global gNewStim % to replace other globals in the future
gNewStim.RemoteComm.isremote = Remote_Comm_isremote;
gNewStim.RemoteComm.enable = Remote_Comm_enable;
gNewStim.RemoteComm.method = Remote_Comm_method;
gNewStim.RemoteComm.dir = Remote_Comm_dir;
gNewStim.RemoteComm.host = Remote_Comm_host; 
gNewStim.RemoteComm.port = Remote_Comm_port;
gNewStim.RemoteComm.socket = Remote_Comm_socket; 
gNewStim.RemoteComm.conn = Remote_Comm_conn;
gNewStim.RemoteComm.eol = Remote_Comm_eol; 
gNewStim.RemoteComm.remotearchitecture = Remote_Comm_remotearchitecture; 
gNewStim.RemoteComm.localprefix = Remote_Comm_localprefix;
gNewStim.RemoteComm.remoteprefix = Remote_Comm_remoteprefix;




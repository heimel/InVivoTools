%
%  REMOTE COMMUNICATIONS
%
%  The NewStim package offers some provisions for remote communication
%  bewteen a master (local) and a slave (remote) computer.  It is assumed the
%  slave computer is running initstims.m.
%
%  Two interface options are available:
%	1)  Communication via sockets over the internet
%		Requires tcp_udp_ip matlab toolkit on both machines
%               (This option is almost fully implemented but not well tested)
%       2)  Communication via writing files to a commonly-connected server
%               Requires both machines be able to mount the same directory on
%               (This option works well)
%	
%  The following functions are available:
%
%     transferscripts      - transfers script from master to slave computer
%     sendremotecommand    - sends and executes a command to the slave computer
%     sendremotecommandvar - sends a remote command and reads output variables
%                                        from slave computer
%
%  See TRANSFERSCRIPTS, SENDREMOTECOMMAND,SENDREMOTECOMMANDVAR

help remotecomm

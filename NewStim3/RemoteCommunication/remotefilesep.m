function [ theremotefilesep ] = remotefilesep
%REMOTEFILESEP File separate for the remote system (NewStim)
%   Returns the appropriate file separator for the remote 
%   operating system.
%
%   This program examines the variable Remote_Comm_remotearchitecture
%   and returns '/' if the remote computer is unix, ':' if it is a Mac
%   OS 9 machine, and '\' if it is a PC.
%
%   See also: remotecomm, RemoteCommunication, remotecommglobals

remotecommglobals
	switch (lower(Remote_Comm_remotearchitecture)),
		case 'unix',
			theremotefilesep = '/';
		case 'pc',
			theremotefilesep = '\';
		case 'mac',
			theremotefileseps = ':';
        otherwise, 
            error(['Cannot determine remote file separator for architecture: Remote_comm_remotearchitecture']);
	end;


end



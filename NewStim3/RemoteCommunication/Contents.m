% RemoteCommunication - Functions for transferring/controlling stimulation on
%                           a remote computer
%  remotecomm             - A help file describing remote communication
%  sendremotecommand      - Sends a script command to remote computer
%  sendremotecommandvar   - Sends a remote script command, with variables
%  remotecommglobals      - Defines global variables for remote control
%  remotecommopen         - Opens a remote communicaton channel
%  transferscripts        - Transfers script from master to slave computer
%  writeremote            - Sends a script to a remote machine (called by
%                              sendremotecommand*, not called by users)
%  checkremotedir         - Checks to see if remotecomm channel is open
%                              (not normally called by users)
%  StartSlaveMode         - Intializes slave mode


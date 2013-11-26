% NewStim package - visual and auditory stimulation using PsychToolbox
%
% Allows a user or program to create and display various stimuli, and organize
% these stimuli into 'scripts' that describe the order and timing of
% presentation.  The presentation and logging of the stimuli is standardized
% in an effort to simplify integration into recording and analysis systems.
%
% Stephen D. Van Hooser, with others, 1999-2010
%
% For installation and configuration instructions, type 'help NewStimInstall'
%
% Functions:
%  NewStimInit            - Initializes NewStim; call once each MATLAB session
%  
% Stimuli - Stimulus object types, type 'help Stimuli' for contents
% Scripts - Script object types, type 'help Scripts' for contents
%
% NewStimProcs - Misc. procedures
%  NewStimCalibrate-exampe- Example calibration file
%  NewStimGlobals         - Defines global variables for NewStim
%  NewStimList            - Returns a list of all known 'stimulus' types
%  NewStimScriptList      - Returns a list of all known 'stimscript' types
%  NewStimObjectInit      - Creates a blank object of each type
%  NewStimClose           - Releases all NewStim memory, closes all services
%
% NewStimServices - Provides basic services for stimulation and triggering
%  StimScreen             - A graphics window for visual stimulation
%  MonitorScreen          - A graphics window for any purpose
%  GammaCorrectionTable   - Gamma correction services
%  StimSerial             - A serial port output
%  StimPCIDIO96           - Controls a Ni-Daq parallel board PCIDIO96
%  StimParallel           - Controls a parallel port (**unfinished**)
%  RFmap                  - A manual visual receptive field mapper
%
% NewStimDisplayProcs - Carries out stimulus display, logging
%  DisplayStimScript       - Displays a stimscript
%  DisplayTiming           - Make Measured Timing Index for stimscript display
%  DisplayStimScriptIntrinsic - Display stims based on commands from a master
%  stripMTI                - Remove all video memory from Measured Timing Index
%  DecomposeScriptMTI      - Decompose a stimscript & MTI into multiple scripts
%
% NewStimEditor - Functions for graphically editing scripts, stimuli
%  StimEditor             - A GUI for creating/editing NewStim stimuli
%  ScriptEditor           - A GUI for creating/editing NewStim scripts
%  ScriptObjEditor        - A GUI for editing a single NewStim script
%  RemoteScriptEditor     - A GUI tool for transferring NewStim scripts to 
%                               a remote computer
%  UpdateNewStimEditors   - Refreshes all NewStim editor GUIs listed above
%  editdisplayprefs       - A GUI for editing DisplayPrefs objects
%  geteditor              - Returns figure # of a GUI, based on 'Tag' search
%
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
%  
%
% NewStimUtilities
%  catCellStr             - Builds a long string from cell list of strings
%  dowait                 - Wait X seocnds in processor-friendly way if possible
%  foreachstimdo          - Evaluate an expression on a set of stims
%  foreachstimdolocal     - Evaluate expressions on set of local variable stims
%  hasAllFields           - Checks to see if a cell list has a given list of
%                             field names and sizes
%  haspsychtbox           - Returns 0/1 if has PsychToobox installed
%  isstimscripttimestruct - Returns 1 if stimscripttimestruct is valid
%  isstimtimestruct       - Returns 1 if stimscriptstruct is valid
%  lb_getselected         - Returns strings that are currently selected in a 
%                             listbox
%  listofvars             - Returns a list of vars in the main workspace of
%                             a given type
%  putstimrectglobal      - Puts stim parameter into a global variable
%  recenterrect           - Recenters a rectangle on the screen
%  recenterstim           - Recenters a stim
%  rectofinter            - Calculates intersection of 2 rectangles
%  repositionstim         - Set stim to new position
%  sswhatvaries           - Lookup what paramters vary across stimscript
%  stimscripttimestruct   - Create a stimscripttimestruct
%  stimtimestruct         - Create a stimtimestruct
%  textbox                - Build a small textbox for a message
%  uigetvarname           - Prompt user for a valid Matlab variable name
%  valid_varname          - Returns 1 if string is a valid Matlab variable name
%

% CLOSESTIMPCIDIO96 - Closes communication with PCIDIO96 in NewStim
%
%   CLOSESTIMPCIDIO96 - Marks the PCIDIO96 as not initialized.
%
%  This function closes communication with PCIDIO96 by marking
%  the board as being not initialized.  Any subsequent call to
%  OPENSTIMPCIDIO96 will reinitialize the board.  This function
%  should not be necessary unless one is using the PCIDIO96 board for
%  other purposes in between uses by NewStim.
%
%  See also:  OPENSTIMPCIDIO96, STIMPCIDIO96GLOBALS

StimPCIDIO96Globals;

NSPCIDIO96.initialized = 0;

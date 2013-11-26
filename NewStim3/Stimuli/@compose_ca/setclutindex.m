function cca = setclutindex(cca, stimnum, clutindex)

% SETCLUTINDEX - Set clut index for stim in COMPOSE_CA stimlist
%
%  NEWCCA = SETCLUTINDEX(MYCOMPOSE_CA, STIMINDEX, CLUTINDEX)
%
%   Sets the clut index number for the the stim at position
%   STIMINDEX in the stimulus list associated with the
%   MYCOMPOSE_CA stimulus object.
%
%   The clut index determines the color table that is
%   ultimately used when displaying the stimuli to be
%   composed.  If there is only one clut index number
%   across the stimuli, then the color look up table
%   of the first stimulus is used.  If there is more than
%   clut index number, then a color table is constructed
%   consisting of squashed versions of the color tables
%   from the first stimulus in the list with each unique
%   clut index number.  The stimuli themselves are then
%   adjusted to reflect their squashed color look up 
%   tables.
%
%   For example, suppose there are two stimuli, and one
%   clut index number is 1 and the other clut index
%   number is 2. Then, the color table of stimulus 1 is
%   compressed to 127 entries (throwing out every-other-
%   entry to reduce from 255), and the color table of
%   stimulus 2 is also compressed to 127 entries.
%   The new color table is then the concatenation of
%   these compressed color tables.
%   The stimuli are then edited by COMPOSE_CA to reflect
%   their new color tables, and colors that no longer
%   correspond to an entry in the modified table will display
%   as the closest entry.
%
%   The first entry of the first stimulus serves as the 
%   background color for all stimuli and is not compressed.
%
%  
%   One may read the clut index number using GETCLUTINDEX.
%
%   See also:  COMPOSE_CA, COMPOSE_CA/GETCLUTINDEX

if stimnum>=1&stimnum<=numStims(cca),
	cca.clutindex(stimnum) = clutindex;
else, error(['STIMINDEX must be in 1..numStims.']);
end;

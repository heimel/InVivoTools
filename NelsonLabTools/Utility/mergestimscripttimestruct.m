function [stims,mti,disporder]=mergestimscripttimestruct(ssts)

%  [STIMS,MTI,DISORDER]=MERGESTIMSCRIPTTIMESTRUCT(SSTS)
%
%  Given an array of stimscripttimestruct variables in SSTS,
%  the function returns a cell list of all stimuli, a cell
%  list of all of the MTI display information, and the display
%  order of all the stims.  Display order is the same length
%  as MTI.  For example, STIM(DISORDER(1)) was displayed first,
%  and the MTI associated with the display is given in MTI(1).
%
%  See also:  stimscripttimestruct

stims = {}; disporder = []; mti = {};

for i=1:length(ssts),
  st = get(ssts(i).stimscript);
  do = getDisplayOrder(ssts(i).stimscript)+length(stims);
  stims = cat(2,stims,st); disporder = cat(2,disporder,do);
  mti = cat(2,mti,ssts(i).mti);
end;

%
%  REMOTE COMMUNICATIONS
%
%  The NewStim package offers some provisions for (a poor-man's) remote 
%  communications.  This allows scripts to be transferred from one machine to
%  another (for example, from a controlling machine to a stimulus displaying
%  machine).
%
%  The communications takes place by writing to files in one particular
%  directory.  It is assumed that the two machines can both mount this
%  directory.  We use this instead of serial communications because not all
%  computers have convenient serial implementations.
 

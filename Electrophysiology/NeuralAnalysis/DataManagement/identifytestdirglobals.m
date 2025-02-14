% IDENTIFYTESTDIRGLOBALS - Global variables for identifying test directories
%
% IDENTIFYTESTDIRGLOBALS
%
% This function defines global variables for IDENTIFYTESTDIR.  That
% function serves to link a script in a given test directory with
% a label that analysis software can look up.
% 
% For example, a stimulus script might have a set of stimuli such
% that the angle of a grating is varied, and one may want to label this
% stimulus script as "Best orientation test".  Analysis software
% could then look for "Best orientation test" and analyze the data.
%
% Why not have analysis code study the scripts directly and identify
% scripts?  This is an okay solution, but an intermediate step of
% labeling the directories allows any ambiguities to be solved once
% in the labeling step.  Since analysis code is likely to change over
% the course of an investigation, it is possible that ambiguities in
% stimulus identity would need to be resolved each time the code is
% run.  This way, we label once, and can reanalyze many times without
% relabeling.
%
% The following variables are defined:
%
% IDTestDir:  a struct list w/ the following elements:
%              type       type of stimulus script
%                          (e.g., 'Best orientation test')
%              function   function that indicates whether or not
%                          a script is of the given type
% IDreplace:  0/1 should script identities be replaced? (default 0)
% IDmustask:  0/1 should user always confirm? (default 0)
%
% IDTestDir functions can be installed and removed by adding or
% removing them from the struct list directly.  The scripts
% will be tested for membership in increasing order in the list.
%
%
%  An IDTestDir function has the following form:
%
%    [IS_TYPE,MUST_BE_UNIQUE,MUST_ASK,REPLACE_EXISTING]=...
%		MYIDTESTFUNC(TYPE,SCRIPT,MD,NAMEREF,...
%		DIRNAME,OTHERUNLABELEDDIRS,DS)
%                    
%  IS_TYPE should be 1 if the script is of the specified
%     TYPE and 0 otherwise.
%  If MUST_BE_UNIQUE is 1, then the user is asked to choose
%     among any candidates.
%  If MUST_ASK is 1, then the user must approve the link.
%  REPLACE_EXISTING is 1 if the newly identified testdir
%     should replace any previously identified testdir
%  SCRIPT is the stimscript to be tested
%  MD is the MEASUREDDATA object that will be associated
%     with the script.
%  NAMEREF is the name/reference pair associated with MD.
%  DIRNAME is the directory name being tested.
%  OTHERUNLABELEDDIRS is a list of as-yet unclassified
%     test directories.
%
%  There is an example file that can be copied and
%  modified:  VISIONIDTESTFUNC.m
%  

global IDTestDir
global IDreplace
global IDmustask

if isempty(IDTestDir), IDTestDir = struct('type','','function',''); IDTestDir = IDTestDir([]); end;
if isempty(IDreplace), IDreplace = 0; end;
if isempty(IDmustask), IDmustask = 0; end;

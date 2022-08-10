function popd
%POPD sets current working directory to one previously stored by pushd
%
% Use PUSHD to push directory 
%
% 2022, Alexander Heimel

global GLOBAL_PUSHD

cd(GLOBAL_PUSHD);

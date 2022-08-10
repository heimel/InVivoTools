function pushd
%PUSHD saves current working directory to memory
%
% Use POPD to retrieve directory 
%
% 2022, Alexander Heimel

global GLOBAL_PUSHD

GLOBAL_PUSHD = pwd;

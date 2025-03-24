# InVivoTools #

InVivoTools is a system for journaling, analyzing and retrieving data. The Graph_db provides a flexible way to produce graphs for stored data. 

## Installation ##

Download or clone the most recent version from <https://github.com/heimel/InVivoTools>. 
Add the top folder (containing load_invivotools.m) to your MATLAB path.
Add the following line to your MATLAB startup.m file to include InVivoTools folders to 
your MATLAB path. 
```
if exist('load_invivotools','file'), load_invivotools; end
```
If no startup.m file already exists, you can create one in MATLAB by
```
edit(fullfile(userpath,'startup.m'))
```

## Manual ##

The manual can be found at: <https://github.com/heimel/InVivoTools/wiki>

For information on microscopic image analysis, see <https://sites.google.com/site/alexanderheimel/protocols/puncta-analysis-using-matlab>

## Maintainer ##

Maintainer: Alexander Heimel

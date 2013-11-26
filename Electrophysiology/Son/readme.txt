These m-files use features introduced with version 5 of MATLAB and will not work 
with versions earlier than that.
They were developed with MATLAB version 6.1 release 12 so there could be glitches
with versions earlier than that.


Directories
To use the m-files unzip SON.ZIP and either
[1] copy them to a directory on your current MATLAB path
or better
[2] place them in a directory of their own and add this to your MATLAB path. To 
have the new directory included by default each time MATLAB starts edit the 
startup.m file which is probably in the matlab "..\toolbox\local" directory  (it 
might be called startupsav.m if it is not currently used).
A line such as:
path(path,'c:\matlab6p1\work\son');
adds the new directory to the default path. Use 'help path' in MATLAB for 
details


You will probably need to edit the SONTest.m file to point to the correct 
directory for the CED SONFix.exe file if you use the SONTest function. Edit the 
line that has:
SONFIX='c:\spike403\sonfix.exe';


Malcolm Lidierth
25/03/02


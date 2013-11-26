function tp_organization
%
%  organization of data
%    in record struct:
%      experiment = e.g. 05.01.1 
%      mouse = e.g. 12
%      date = e.g. 2009-09-01
%      stack =  e.g. 50 um AP, 280 um ML
%      slice = e.g. 50 um deep
%      epoch = name of one continuous recording, e.g. t00001/* or AMam24a01.tif
%    separate variables:
%      channel = name of the channel, e.g. '1', '488' or 'GFP'
%      frame = number of frame in one epoch
%          (cycle = an extra split made by prairieview, should only be used
%          in prairieview platform specific routines)
%
%
%   example of Friederike's data
%         experiment = 'AMam'
%         mouse = 'a'
%         date = '20090102'
%         stack = '21'
%         slice = ignored
%         epoch = '01'
%         channel = ignored
%         frame = 12
%     will be the 12th frame stored in 'J:\Bl6_AM Data\20090102 AMam21\AMam21a01.tif'
%
%  example of Leveltlab data
%         experiment = ignored
%         mouse = '05.01.1.12'
%         date = '2009-01-01'
%         stack = '1'
%         slice = '50'
%         epoch = 't00001'
%         channel = '1'
%         frame 12
%      will be the 12th frame stored in   
%          InVivo/Twophoton/05.01.1.12/2009-01-01/1/50/t00001/Live_0000.tif
%      if stack or slice are left empty, the directory structure is less deep, e.g.          
%          InVivo/Twophoton/05.01.1.12/2009-01-01/t00001/Live_0000.tif
%      for morphological recordings also epoch could be empty
%
%
%   TPDATAPATH( RECORD ) returns path where imagefile is located
%   TPFILENAME( RECORD, FRAME, CHANNEL) returns filename of imagefile
%
%  2009, Alexander Heimel
%



help tp_organization
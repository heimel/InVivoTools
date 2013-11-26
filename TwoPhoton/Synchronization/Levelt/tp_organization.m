function tp_organization
%TP_ORGANIZATION shows data structure for twophoton data
%
% a twophoton path starts with the experiment (protocol) name, then mouse name, to group mouse data
% then date, then epoch, i.e. D:\08.26\08.26.1.06\2010-05-19
%
%  organization of data
%    in record struct:
%         mouse = mouse name, e.g. '08.26.1.06'
%         date = experimental date '2010-05-19'
%         stack = stack name, e.g. 'Location 1' or '50 um AP, 280 um ML',
%                       default 'Live_0000'
%         slice = slice name, ignored for filestructure
%         epoch = name of one continuous recording, e.g. 't00001'
%         experiment = '08.26'
%         channel = '1'
%         frame 12
%    separate variables:
%      channel = name of the channel, e.g. '1', '488' or 'GFP'
%      frame = number of frame in one epoch, e.g. 12
%
%      will be the 12th frame stored in   
%          InVivo/Twophoton/08.26/08.26.1.06/2010-05-19/t00001/Live_0000.tif
%      if stack or slice are left empty, the directory structure is less deep, e.g.          
%          InVivo/Twophoton/05.01.1.12/2009-01-01/t00001/Live_0000.tif
%      for morphological recordings also epoch could be empty
%
%
%   TPDATAPATH( RECORD ) returns path where epoch directories (t00001, etc) are located
%   TPFILENAME( RECORD, FRAME, CHANNEL) returns filename of imagefile
%   including epoch name (i.e. t00001/Live_0000.tif)
%
%  2009, Alexander Heimel
%



help tp_organization
function initwebcampi
%INITWEBCAMPI
% loops while checking change in acqReady
%
% 2015, Alexander Heimel
%
more off


global gNewStim

gNewStim.Webcam.Window = [];
gNewStim.Webcam.WebcamNumber = 1;
gNewStim.Webcam.Camid = [];
gNewStim.Webcam.Rect = [];%[0 0 640 480];
gNewStim.Webcam.Codec = ':CodecType=DEFAULTencoder';
gNewStim.Webcam.WithSound = 0;

remotecommglobals;

acqready = fullfile(Remote_Comm_dir,'acqReady');

theDir = Remote_Comm_dir;
if ~exist(theDir,'dir')
    msg={['Remote communication folder ' theDir ' does not exist. ']};
    try
        if ~check_network
            msg{end+1} = '';
            msg{end+1} = 'Network connection is unavailable. Check UTP cables, make sure firewall is turned off, or consult with ICT department.';
        else
            msg{end+1} = '';
            msg{end+1} = 'Ethernet connection is working properly. Check NewStimConfiguration or availability of host computer.';
        end
    end
    msg{end+1} = '';
    msg{end+1} = 'Consult NewStim manual troubleshooting section.';
    errormsg(msg);
    return
end
cd(theDir);

if ~Remote_Comm_isremote
    errormsg('Not a remote computer. Change Remote_Comm_isremote in NewStimConfiguration.');
    return
end

acqready_props_prev = dir(acqready);
if isempty(acqready_props_prev)
    acqready_props_prev = [];
    acqready_props_prev.datenum = datenum('2001-01-01');
end

logmsg('Checking for acqReady change');
while 1
    acqready_props = dir(acqready);
    if ~isempty(acqready_props) && acqready_props.datenum > acqready_props_prev.datenum
        logmsg('acqReady changed');
        acqready_props_prev = acqready_props;
        fid = fopen(acqready,'r');
        fgetl(fid); % pathSpec line
        datapath = fgetl(fid);
        fclose(fid);
	
	wc_startpi(datapath);
    else
        pause(0.3);
    end
end



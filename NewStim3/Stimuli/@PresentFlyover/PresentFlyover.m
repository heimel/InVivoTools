
function StimObj = PresentFlyover(sStimParams, OldStimObj)
%PRESENTFLYOVER stimulus to show a disc/ellipse moving across the screen
%
%2021, Robin Haak

if nargin < 2
    OldStimObj = [];
end

%% stimulus parameters
sDefaultParams.strStimType = 'disc'; %'disc' or 'ellipse'
sDefaultParams.strStartPosition = 'right'; %'right' or 'left'
sDefaultParams.vecDiscSizeDeg = [4.1 4.1]; %deg
sDefaultParams.vecEllipseSizeDeg = [1.6 4.4]; %deg
sDefaultParams.dblVelocityDeg = 39; %stimulus speed, deg/s
sDefaultParams.boolRandomTrajectory = false; %if true, x-position is randomized
sDefaultParams.dblStimulusIntensity = 0; %background intensity (0 = black)
sDefaultParams.dblBackgroundIntensity = 0.5; %background intensity (0.5 = mean gray)
sDefaultParams.strDisplayPrefs = '{''BGpretime'',0}'; %str
if isempty(OldStimObj)
    sOldStimParams = sDefaultParams;
else
    sOldStimParams = getparameters(OldStimObj);
end

if nargin < 1
    sStimParams = sDefaultParams;
elseif ischar(sStimParams)
    switch lower(sStimParams)
        case 'graphical'
            sStimParams = structgui(sOldStimParams, capitalize(mfilename));
        case 'default'
            sStimParams = sDefaultParams;
        otherwise
            errormsg('Unknown argument');
            StimObj = [];
            return
    end
end

%% str to cell
sStimParams.cellDisplayPrefs = eval(sStimParams.strDisplayPrefs);
sStimParams = rmfield(sStimParams, 'strDisplayPrefs');

%% add to list of known stimulus types
NewStimListAdd(mfilename);

%% create stimulus object
NewStimObj = stimulus;
sParams = struct('params', sStimParams);
StimObj = class(sParams, mfilename, NewStimObj);
StimObj.stimulus = setdisplayprefs(StimObj.stimulus, displayprefs(sStimParams.cellDisplayPrefs));
end
function ShowStimScreen
%SHOWSTIMSCREEN opens NewStim stimulus window
%
% 200X, Steve Van Hooser
% 200X-2017, Alexander Heimel

StimWindowGlobals
NewStimGlobals

if ~StimComputer
    logmsg('Not a StimComputer. Change in NewStimConfiguration if necessary.');
    return;
end

% check for an undefined window or a broken window and (re)open it in either case
A = isempty(StimWindow); %#ok<NODEF>
if ~A
    try
        r = Screen(StimWindow,'rect');
        A = isempty(r);
    catch
        A = 1;
    end
end % now, A is 1 if we need to make a new window; 0 otherwise

if NS_PTBv>=3
    Screen('Preference', 'EmulateOldPTB',0);
end

if A
    CloseStimScreen;
end  % call anything that needs to be called if window is closed

if A
    screens = Screen('screens');
    if ~any(StimWindowMonitor==screens)
        error(['Available screens are ' ...
            mat2str(screens) ' but StimWindowMonitor is ' ...
            int2str(StimWindowMonitor) '. Perhaps the stimulus monitor is not on?']);
    end
    if NS_PTBv<3
        StimWindow = Screen(StimWindowMonitor,'OpenWindow',0);
        % ask for a certain pixel depth
        Screen(StimWindow,'PixelSize',8,1);
    else	% we may not ask for a pixel depth, it just is what it is
        StimWindowPreviousCLUT = Screen('ReadNormalizedGammaTable',StimWindowMonitor);
        if StimWindowUseCLUTMapping&&~isempty(which('PsychHelperCreateRemapCLUT'))
            PsychImaging('PrepareConfiguration');
            PsychImaging('AddTask', 'AllViews', 'EnableCLUTMapping');
            StimWindow = PsychImaging('OpenWindow', StimWindowMonitor, 128);
        else
            if gNewStim.StimWindow.debug
                Screen('Preference', 'SkipSyncTests', 1);
                Screen('Preference',  'SuppressAllWarnings', 1);
                if isempty(StimWindowRect) %#ok<NODEF>
                    StimWindow = Screen(StimWindowMonitor,'OpenWindow',128,[0 0 640 480]);
                else
                    StimWindow = Screen(StimWindowMonitor,'OpenWindow',128,StimWindowRect);
                end
            else
                StimWindow = Screen(StimWindowMonitor,'OpenWindow',128);
            end
        end;
    end;
    StimWindowDepth = Screen(StimWindow,'PixelSize');
    StimWindowRect = Screen(StimWindow,'Rect'); %#ok<*NASGU>
    StimWindowRefresh = Screen(StimWindow,'FrameRate',[]);
    if StimWindowRefresh==0
        StimWindowRefresh = 60;
    end % fix for some LCDs
    Screen('BlendFunction',StimWindow,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
end


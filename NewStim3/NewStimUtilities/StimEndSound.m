function StimEndSound
% plays sounds to use at end of stimulus
if strcmp(computer,'PCWIN') | strcmp(computer,'PCWIN64') %#ok<OR2>
    beep;pause(0.2);beep;pause(0.2);beep;
elseif strcmp(computer,'MAC2')
    % should check for language version of mac, dutch->glas, english->glass
    snd('Play','glas'); snd('Play','glas'); snd('Play','glas');
elseif isunix
    if strcmp('GLNXA64',computer)
        logmsg('DISABLED 64bit SOUND BECAUSE OF TROUBLE');
        return
    end
    try
        load handel
        sound(y(1:20000),Fs)
    catch
        logmsg('Could not play sound');
    end
end


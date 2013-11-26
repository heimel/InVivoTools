function StimEndSound
% plays sounds to use at end of stimulus

if strcmp(computer,'PCWIN') | strcmp(computer,'PCWIN64') %#ok<OR2>
    beep;pause(0.2);beep;pause(0.2);beep;
elseif strcmp(computer,'MAC2')
    % should check for language version of mac, dutch->glas, english->glass
    snd('Play','glas'); snd('Play','glas'); snd('Play','glas');
end


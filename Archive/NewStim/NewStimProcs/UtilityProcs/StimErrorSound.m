function StimErrorSound
% plays sounds to use on error when showing stimulus

if strcmp(computer,'PCWIN') | strcmp(computer,'PCWIN64')
    beep;pause(0.2);beep;
elseif strcmp(computer,'MAC2')
    % should check for language version of mac, dutch->glas, english->glass
    snd('Play','glas'); snd('Play','glas'); 
end


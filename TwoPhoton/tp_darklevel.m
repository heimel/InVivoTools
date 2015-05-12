function darklevel = tp_darklevel(record)
%TP_DARKLEVEL returns dark level from microscope
%
% 2014, Alexander Heimel
%

params = tpprocessparams(record);

impar = tpreadconfig(record);

darklevel = zeros(impar.NumberOfChannels,1); % as before. not accurate

switch params.darklevel_determination
    case 'none'
        % nothing
    case '5percentile' % works for very low gcamp expression
        for ch=1:impar.NumberOfChannels
            im = tpreadframe(record,ch,ceil(impar.NumberOfFrames/2));
            darklevel(ch) =  prctile(im(:),5);
        end
        logmsg(['Darklevel = ' mat2str(darklevel)]);
    otherwise
        errormsg(['Unknown darklevel determination: ' params.darklevel_determination]);
end
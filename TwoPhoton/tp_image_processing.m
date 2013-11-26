function im = tp_image_processing( im, opt )
%TP_IMAGE_PROCESSING 
%
% 2011, Alexander Heimel
%

if isempty(opt)
    return
end

if isfield(opt,'unmixing') && ~isempty(opt.unmixing) && opt.unmixing
    [unmix,frac_ch1_in_ch2 ,frac_ch2_in_ch1] = tp_unmixchannels(im);  %#ok<NASGU>
    im = uint16(unmix);
end

if isfield(opt,'spatial_filter') && ~isempty(opt.spatial_filter) && opt.spatial_filter
    im = tp_spatial_filter( im, 'medfilt2','');
end




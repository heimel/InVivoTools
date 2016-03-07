function varargout=getfourcc
% This function GETFOURCC gives a list of available Video encoder-codecs in
% the current Windows installation. The FourCC code of a codec in the list
% can be used to select a custom compressor in the AVIFILE function.
%
% Usage :
%
%   getfourcc        Will display a list with available video codecs
%       or
%   L = getfourcc    Returns a struct with all available video codecs
%
%
% Supported OS,
%   Windows NT, 2000, Vista, Windows 7
%
%
% Example Output,
%
%   Four CC  | Description  (Driver / DLL)
% -----------+---------------------------------------------- -----
%     mrle   |  Microsoft - Run Length Encoding (msrle32.dll)
%     msvc   |  Microsoft - Video 1 (msvidc32.dll)
%     i420   |  Intel - Indeo 4 codec (iyuv_32.dll)
%     cvid   |  Supermac - Cinepak (iccvid.dll)
%
%   See also avifile/addframe, avifile/close, movie2avi
%
% Function is written by D.Kroon of the University of Twente (September 2010)

fourcc=struct; nf=0;
for k=1:2
    if(k==1)
        reglok='SOFTWARE\Microsoft\Windows NT\CurrentVersion';
    else
        reglok='SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion';
    end
    try
        keys = winqueryreg('name','HKEY_LOCAL_MACHINE',[reglok '\Drivers32']);
    catch
        continue;
    end
    for i=1:length(keys)
        key=keys{i};
        if(length(key)>4)
            if(strcmp('vidc',key(1:4)));
                name=key(6:end);
                driver=getreg([reglok '\Drivers32'],key);
                switch(upper(name))
                    case 'ANIM', des='Intel - RDX';
                    case 'AUR2', des='AuraVision - Aura 2 Codec - YUV 422';
                    case 'AURA', des='AuraVision - Aura 1 Codec - YUV 411';
                    case 'BT20', des='Brooktree - MediaStream codec';
                    case 'BTCV', des='Brooktree - Composite Video codec';
                    case 'CC12', des='Intel - YUV12 codec';
                    case 'CDVC', des='Canopus - DV codec';
                    case 'CHAM', des='Winnov,- MM_WINNOV_CAVIARA_CHAMPAGNE';
                    case 'CPLA', des='Weitek - 4:2:0 YUV Planar';
                    case 'CVID', des='Supermac - Cinepak';
                    case 'CWLT', des='reserved';
                    case 'DUCK', des='Duck Corp. - TrueMotion 1.0';
                    case 'DVE2', des='InSoft - DVE-2 Videoconferencing codec';
                    case 'DXT1', des='reserved';
                    case 'DXT2', des='reserved';
                    case 'DXT3', des='reserved';
                    case 'DXT4', des='reserved';
                    case 'DXT5', des='reserved';
                    case 'DXTC', des='DirectX Texture Compression';
                    case 'FLJP', des='D-Vision - Field Encoded Motion JPEG With LSI Bitstream Format';
                    case 'GWLT', des='reserved';
                    case 'H260', des='Intel - Conferencing codec';
                    case 'H261', des='Intel - Conferencing codec';
                    case 'H262', des='Intel - Conferencing codec';
                    case 'H263', des='Intel - Conferencing codec';
                    case 'H264', des='Intel - Conferencing codec';
                    case 'H265', des='Intel - Conferencing codec';
                    case 'H266', des='Intel - Conferencing codec';
                    case 'H267', des='Intel - Conferencing codec';
                    case 'H268', des='Intel - Conferencing codec';
                    case 'H269', des='Intel - Conferencing codec';
                    case 'I263', des='Intel - I263';
                    case 'I420', des='Intel - Indeo 4 codec';
                    case 'IYUV', des='Intel - Indeo';
                    case 'IAN', des='Intel - RDX';
                    case 'ICLB', des='InSoft - CellB Videoconferencing codec';
                    case 'ILVC', des='Intel - Layered Video';
                    case 'ILVR', des='ITU-T - H.263+ compression standard';
                    case 'IRAW', des='Intel - YUV uncompressed';
                    case 'IV30', des='Intel - Indeo Video 3 codec';
                    case 'IV31', des='Intel - Indeo Video 3.1 codec';
                    case 'IV32', des='Intel - Indeo Video 3 codec';
                    case 'IV33', des='Intel - Indeo Video 3 codec';
                    case 'IV34', des='Intel - Indeo Video 3 codec';
                    case 'IV35', des='Intel - Indeo Video 3 codec';
                    case 'IV36', des='Intel - Indeo Video 3 codec';
                    case 'IV37', des='Intel - Indeo Video 3 codec';
                    case 'IV38', des='Intel - Indeo Video 3 codec';
                    case 'IV39', des='Intel - Indeo Video 3 codec';
                    case 'IV40', des='Intel - Indeo Video 4 codec';
                    case 'IV41', des='Intel - Indeo Video 4 codec';
                    case 'IV42', des='Intel - Indeo Video 4 codec';
                    case 'IV43', des='Intel - Indeo Video 4 codec';
                    case 'IV44', des='Intel - Indeo Video 4 codec';
                    case 'IV45', des='Intel - Indeo Video 4 codec';
                    case 'IV46', des='Intel - Indeo Video 4 codec';
                    case 'IV47', des='Intel - Indeo Video 4 codec';
                    case 'IV48', des='Intel - Indeo Video 4 codec';
                    case 'IV49', des='Intel - Indeo Video 4 codec';
                    case 'IV50', des='Intel - Indeo 5.0';
                    case 'MP42', des='Microsoft - MPEG-4 Video Codec V2';
                    case 'MPEG', des='Chromatic - MPEG 1 Video I Frame';
                    case 'MRCA', des='FAST Multimedia - Mrcodec';
                    case 'MRLE', des='Microsoft - Run Length Encoding';
                    case 'MSVC', des='Microsoft - Video 1';
                    case 'NTN1', des='Nogatech - Video Compression 1';
                    case 'qpeq', des='Q-Team - QPEG 1.1 Format video codec';
                    case 'RGBT', des='Computer Concepts - 32 bit support';
                    case 'RT21', des='Intel - Indeo 2.1 codec';
                    case 'RVX', des='Intel - RDX';
                    case 'SDCC', des='Sun Communications - Digital Camera Codec';
                    case 'SFMC', des='Crystal Net - SFM Codec';
                    case 'SMSC', des='Radius - proprietary';
                    case 'SMSD', des='Radius - proprietary';
                    case 'SPLC', des='Splash Studios - ACM audio codec';
                    case 'SQZ2', des='Microsoft - VXtreme Video Codec V2';
                    case 'SV10', des='Sorenson - Video R1';
                    case 'TLMS', des='TeraLogic - Motion Intraframe Codec';
                    case 'TLST', des='TeraLogic - Motion Intraframe Codec';
                    case 'TM20', des='Duck Corp. - TrueMotion 2.0';
                    case 'TMIC', des='TeraLogic - Motion Intraframe Codec';
                    case 'TMOT', des='Horizons Technology - TrueMotion Video Compression Algorithm';
                    case 'TR20', des='Duck Corp. - TrueMotion RT 2.0';
                    case 'V422', des='Vitec Multimedia - 24 bit YUV 4:2:2 format';
                    case 'V655', des='Vitec Multimedia - 16 bit YUV 4:2:2 format';
                    case 'VCR1', des='ATI - VCR 1.0';
                    case 'VIVO', des='Vivo - H.263 Video Codec';
                    case 'VIXL', des='Miro Computer Products AG - for use with the Miro line of capture cards.';
                    case 'VLV1', des='Videologic - VLCAP.DRV';
                    case 'WBVC', des='Winbond Electronics - W9960';
                    case 'XLV0', des='NetXL, Inc. - XL Video Decoder';
                    case 'YC12', des='Intel - YUV12 codec';
                    case 'YUV8', des='Winnov, MM_WINNOV_CAVIAR_YUV8';
                    case 'YUV9', des='Intel - YUV9';
                    case 'YUYV', des='Canopus - YUYV compressor';
                    case 'ZPEG', des='Metheus - Video Zipper';
                    case 'CYUV', des='Creative Labs,Inc - Creative Labs YUV';
                    case 'FVF1', des='Iterated Systems Inc. - Fractal Video Frame';
                    case 'IF09', des='Intel - Intel Intermediate YUV9';
                    case 'JPEG', des='Microsoft - Still Image JPEG DIB';
                    case 'MJPG', des='Microsoft - Motion JPEG DIB Format';
                    case 'PHMO', des='IBM - Photomotion';
                    case 'ULTI', des='IBM - Ultimotion';
                    case 'UYVY', des='Microsoft - UYVY';
                    case 'VDCT', des='Vitec Multimedia - Video Maker Pro DIB';
                    case 'VIDS', des='Vitec Multimedia - YUV 4:2:2 CCIR 601 for V422';
                    case 'YU92', des='Intel - YUV';
                    case 'YUY2', des='Microsoft - YUY2';
                    case 'YVU9', des='Toshiba Video Codec';
                    case 'YVYU', des='Microsoft - YVYU';
                    otherwise
                        des=getreg(['SYSTEM\CurrentControlSet\Control\MediaResources\icm\' key],'Description');
                        if(isempty(des)), des=getreg([reglok '\drivers.desc'],driver); end
                end
                found=false;
                for j=1:nf, if(strcmp(fourcc(j).name,name)), found=true; break; end; end
                if(~found)
                    nf=nf+1;
                    fourcc(nf).name=name;
                    fourcc(nf).description=des;
                    fourcc(nf).driver=driver;
                end
            end
        end
    end
end

if(nargout<1)
    fprintf('  Four CC  | Description  (Driver / DLL)\n');
    fprintf('-----------+---------------------------------------------- -----\n');
    for i=1:nf
        fprintf('  %s\t   |  %s(%s)\n',fourcc(i).name,fourcc(i).description,fourcc(i).driver);
    end
else
    varargout{1}=fourcc;
end
function val=getreg(location,key)
try val=winqueryreg('HKEY_LOCAL_MACHINE',location,key); catch, val=''; end

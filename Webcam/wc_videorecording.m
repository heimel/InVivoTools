function wc_videorecording(moviename, codec, withsound, showit, windowed, period, camid)
% VideoRecordingDemo(moviename [, codec=0] [, withsound=0] [, showit=1] [, windowed=1], [period=inf])
%
% 'moviename' name of output movie file. The file must not exist at start
% of recording, otherwise it is overwritten.
%
% 'codec' Indicate the type of video codec you want to use.
%
% The supported codecs and settings with GStreamer can be found in the code
% and are explained in 'help VideoRecording'.
%
% Empirically, the MPEG-4 or H264 codecs seem to provide a good tradeoff
% between quality, compression, speed and cpu load. They allow to reliably
% record drop-free sound and video with a resolution of 640x480 pixels at
% 30 frames per second.
%
% H.264 has better quality and higher compression, but is able to nearly
% saturate a MacBookPro, so reliable recording at 30 fps may be difficult
% to achieve or needs more powerful machines.
%
% Some of the other codecs may provide the highest image quality and lowest
% cpu load, but they also produce huge files, e.g., all the DVxxx codecs
% for PAL and NTSC video capture, as well as the component video codecs.
%
% 'withsound' If set to non-zero, sound will be recorded as well. This is
% the default.
%
% 'showit' If non-zero, video will be shown onscreen during recording
% (default: Show it). Not showing the video during recording will
% significantly reduce system load, so this may help to sustain a skip free
% recording on lower end machines.
%
% 'windowed' If set to non-zero, show captured video in a window located at
% the top-left corner of the screen, instead of fullscreen. Windowed
% display is the default.
%
%  Based on PsychToolbox VideoRecordingDemo, see that file for more info
%  2014, From PsychToolbox, Edited by Alexander Heimel
%

global gNewStim

stimtrigserial = instrfind({'Port','Status'},{gNewStim.Webcam_Serialport_name,'open'});
if isempty(stimtrigserial)
    stimtrigserial = serial(gNewStim.Webcam_Serialport_name);
    fopen(stimtrigserial);
end



% Only report ESCape key press via KbCheck:
KbName('UnifyKeyNames');
RestrictKeysForKbCheck(KbName('ESCAPE'));


if nargin < 1
    errormsg('You must provide a output movie name as first argument!');
end

while exist(moviename, 'file')
    logmsg([ moviename ' existed already.']);
    moviename = [moviename 'n'];
end
logmsg(['Recording to movie file ' moviename]);

% Assign default codec if none assigned:
if nargin < 2
    codec = [];
end

if nargin < 3 || isempty(withsound)
    withsound = 0;
end

if withsound > 0
    % A setting of '2' (ie 2nd bit set) means: Enable sound recording.
    withsound = 2;
else
    withsound = 0;
end

% If no user specified codec, then choose one of the following:
if isempty(codec)
    % These do not work yet:
    %codec = ':CodecType=huffyuv'  % Huffmann encoded YUV + MPEG-4 audio: FAIL!
    %codec = ':CodecType=avenc_h263p'  % H263 video + MPEG-4 audio: FAIL!
    %codec = ':CodecType=yuvraw' % Raw YUV + MPEG-4 audio: FAIL!
    %codec = ':CodecType=xvidenc Keyframe=60 Videobitrate=8192 'Missing!
    
    % These are so slow, they are basically useless for live recording:
    %codec = ':CodecType=theoraenc'% Theoravideo + Ogg vorbis audio: Gut @ 320 x 240
    %codec = ':CodecType=vp8enc_webm'   % VP-8/WebM  + Ogg vorbis audio: Ok @ 320 x 240, miserabel higher.
    %codec = ':CodecType=vp8enc_matroska'   % VP-8/Matroska  + Ogg vorbis audio: Gut @ 320 x 240
    
    % The good ones...
    %codec = ':CodecType=avenc_mpeg4' % % MPEG-4 video + audio: Ok @ 640 x 480.
    %codec = ':CodecType=x264enc Keyframe=1 Videobitrate=8192 AudioCodec=alawenc ::: AudioSource=pulsesrc ::: Muxer=qtmux'  % H264 video + MPEG-4 audio: Tut seshr gut @ 640 x 480
    %codec = ':CodecType=VideoCodec=x264enc speed-preset=1 noise-reduction=100000 ::: AudioCodec=faac ::: Muxer=avimux'
    %codec = ':CodecSettings=Keyframe=60 Videobitrate=8192 '
    
    if IsLinux
        % Linux, where stuff "just works(tm)": Assign default auto-selected codec:
        codec = ':CodecType=DEFAULTencoder';
    end
    
    if IsOSX
        % OSX: Without audio, stuff just works. With audio, we must specify
        % an explicit audio source with very specific parameters (48 kHz sampling rate), as
        % everything else will just hang, at least on OSX 10.9 Mavericks with GStreamer 0.10 and 1.x:
        if withsound
            codec = ':CodecType=DEFAULTencoder ::: AudioSource=osxaudiosrc ! capsfilter caps=audio/x-raw,rate=48000';
        else
            codec = ':CodecType=DEFAULTencoder';
        end
    end
    
    if IsWin
        % Windows: H264 encoder often doesn't work out of the box without
        % overloading the machine. Choose theora encoder instead, which
        % seems to be more well-behaved and fast enough on modern machines.
        % Also, at least my test machine needs an explicitely defined audio
        % source, as the autoaudiosrc does not find any sound sources on
        % the Windows-7 PC :-(
        if withsound
            codec = ':CodecType=theoraenc ::: AudioSource=directsoundsrc';
        else
            codec = ':CodecType=theoraenc';
        end
    end
else
    codec = [':CodecType=' codec];
end
fprintf('Using codec: %s\n', codec);

if nargin < 4
    showit = 1;
end

if showit > 0
    % We perform blocking waits for new images:
    waitforimage = 1; %1
else
    % We only grant processing time to the capture engine, but don't expect
    % any data to be returned and don't wait for frames:
    waitforimage = 4;
    
    % Setting the 3rd bit of 'withsound' (= adding 4) disables some
    % internal processing which is not needed for pure disk recording. This
    % can safe significant amounts of processor load --> More reliable
    % recording on low-end hardware. Setting the 5th bit (bit 4) aka adding
    % +16 will offload the recording to a separate processing thread. Pure
    % recording is then fully automatic and makes better use of multi-core
    % processor machines.
    withsound = withsound + 4 + 16;
end

% Always request timestamps in movie recording time instead of GetSecs() time:
withsound = withsound + 64;

if nargin < 5
    windowed = [];
end

if isempty(windowed)
    windowed = 1;
end

if nargin < 6
    period = [];
end
if isempty(period)
    period = Inf;
end
if nargin<7
    camid = [];
end

pinstat = get(stimtrigserial,'pinstatus');
statcheck_prev = pinstat.DataSetReady;
stimstart = NaN;

if ~isempty(gNewStim.Webcam.Window)
    win = gNewStim.Webcam.Window;
else
    screen=max(Screen('Screens'));
    Screen('Preference', 'SkipSyncTests', 1);
    if windowed > 0
        win = Screen('OpenWindow', screen, 0, [0 0 640 480]);
    else
        win=Screen('OpenWindow', screen, 0);
    end
    Screen('Flip',win);
end

if ~isempty(gNewStim.Webcam.Grabber)
    grabber = gNewStim.Webcam.Grabber;
else
    grabber = Screen('OpenVideoCapture', win, camid, [0 0 640 480], [], [], [], codec, withsound);
    WaitSecs('YieldSecs', 2);
end

KbReleaseWait;

mname = sprintf('SetNewMoviename=%s.mov', moviename);
Screen('SetVideoCaptureParameter', grabber, mname);


try
    Screen('StartVideoCapture', grabber, realmax, 1)
    
    oldtex = 0;
    count = 0;
    t=GetSecs;
    telapsed = 0;
    firstframe = [];
    while ~KbCheck && telapsed < period
        if waitforimage~=4
            [tex pts nrdropped]=Screen('GetCapturedImage', win, grabber, waitforimage, oldtex);
            
            pinstat = get(stimtrigserial,'pinstatus');
            statcheck = pinstat.DataSetReady;
            if isnan(stimstart) && ~strcmp(statcheck,statcheck_prev)
                stimstart = pts-firstframe;
                logmsg(['Stimulus started at ' num2str(stimstart) ' s.']);
                statcheck_prev = statcheck;
            end
            if tex > 0
                if isempty(firstframe)
                    firstframe = pts;
                end
                Screen('DrawText', win, sprintf('Time (s): %.2f', pts-firstframe), 0, 0, 255);
                Screen('DrawTexture', win, tex);
                oldtex = tex;
                Screen('Flip', win);
                count = count + 1;
            else
                WaitSecs('YieldSecs', 0.005);
            end
        else
            WaitSecs('YieldSecs', 0.1);
        end
        telapsed = GetSecs - t;
    end
    Screen('StopVideoCapture', grabber);
    
    if isempty(gNewStim.Webcam.Grabber)
        Screen('CloseVideoCapture', grabber);
    end
    
    avgfps = count / telapsed;
catch me
    logmsg(['Problem: ' me.message]);
    RestrictKeysForKbCheck([]);
    Screen('CloseAll');
end

logmsg(['Frame rate: ' num2str(avgfps)]);
if isempty(gNewStim.Webcam.Window)
    Screen('CloseAll');
end

fclose(stimtrigserial);

fid = fopen([moviename '_stimstart'],'w');
fprintf(fid,'%f',stimstart);
fclose(fid);

RestrictKeysForKbCheck([]);

fprintf('Done. Bye!\n');

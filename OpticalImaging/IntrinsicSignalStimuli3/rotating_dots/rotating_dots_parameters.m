clear all;
dir_script = 'C:\Documents and Settings\dataman\Desktop\moving_dots\';
cd(dir_script);
import parport.ParallelPort
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_repetitions = 30; %30
ncoherence_nsteps = 5;
ncoherence_peak = 1;
ncoherence_start = 0;
coherence_one_vec = linspace(ncoherence_start,ncoherence_peak,ncoherence_nsteps);
plot_fig = 0;
ncoherence_vec = coherence_exp(coherence_one_vec,n_repetitions,plot_fig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ndots_vec = 30;                %Number of dots in the field
nspeeds_vec = 8;               %Speed of the dots (degrees/second)
ndirections = n_repetitions; %Direction 0-360 clockwise from upward
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
total_duration_cycle = 20;
duration_vec = total_duration_cycle/((length(coherence_one_vec)*2)-2);%movie duration in seconds
lifetime_vec = 40;              %Number of frames for each dot to live
color_vec = [255,255,255];      %color of the dots
size_vec = 50;                  %size of dots (pixels)
center_vec = [0,0];             %[x,y] Center of the aperture (degrees)
apertureSize_vec = [30,30];     %[x,y] size of elliptical aperture (degrees)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
display.width = 30;             %Width of screen (cm)
display.dist = 57;              %Distance from screen (cm)
display.bkColor = [0 0 0];      %Background color screen
display = OpenWindow(display);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initial_stat_frame = 1/display.frameRate; %duration initial static frame
pause_initial_start_frame = 2;            %pause in seconds of duration_vec(1,1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% waiting for stimulus signal on parallelport
lpt=open_parallelport;
ready=0;
stop=0;
while ~stop
    [go,stim]=get_gostim(lpt);
    if ~go    % go has to be off, before another stimulus is shown
        ready=1;
    end
    if go && ready
        timing.startup = clock;
        timing.experimentStart = GetSecs;
        stim;
        if stim~=0 % not blank
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            teller_conditions = 0;
            teller_directions = 0;
            alldirections = [];
            %for irep = 1:n_repetitions
            for idot = 1:length(ndots_vec)
                dots.nDots = ndots_vec(idot);
                for ispeed = 1:length(nspeeds_vec)
                    dots.speed = nspeeds_vec(ispeed);
                    %for idirection = 1:ndirections
                    for icoherence = 1:length(ncoherence_vec);
                        dots.coherence = ncoherence_vec(icoherence);
                        %
                        if dots.coherence == ncoherence_vec(1,1)
                            teller_directions = teller_directions + 1;
                            if teller_directions > 1
                                direction_previous = alldirections(teller_directions-1);
                                dots.direction = dots.direction + round(180-rand*360);
                                if dots.direction >= 360
                                    dots.direction = dots.direction - 360;
                                elseif dots.direction < 0
                                    dots.direction = 360 + dots.direction;
                                end
                                alldirections = [alldirections,dots.direction];
                            else
                                dots.direction = round(rand(1)*360);
                                alldirections = [alldirections,dots.direction];
                            end
                        end
                        for iduration = 1:length(duration_vec);
                            duration = duration_vec(iduration);
                            for ilife = 1:length(lifetime_vec);
                                dots.lifetime = lifetime_vec(ilife);
                                for icolor = 1:size(color_vec,1);
                                    dots.color = color_vec(icolor,:);
                                    for isize = 1:length(size_vec);
                                        dots.size = size_vec(isize);
                                        for icenter = 1:size(center_vec,1);
                                            dots.center = center_vec(icenter,:);
                                            for iaperture = 1:size(apertureSize_vec,1);
                                                dots.apertureSize = apertureSize_vec(iaperture,:);
                                                %disp(dots);
                                                teller_conditions = teller_conditions + 1;
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                if teller_conditions == 1
                                                    timing.block(teller_conditions).start = GetSecs;
                                                    rotatingDots(display,dots,initial_stat_frame);
                                                    timing.block(teller_conditions).stop = GetSecs;
                                                    pause(pause_initial_start_frame);
                                                end
                                                timing.block(teller_conditions).start = GetSecs;
                                                rotatingDots(display,dots,duration);
                                                timing.block(teller_conditions).stop = GetSecs;
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    %end
                end
            end
            %end
            stop = 1;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        else
            % blank (do nothing)
        end
        ready=0;
    end
end
timing.experimentStop = GetSecs;
total_duration = timing.experimentStop - timing.experimentStart
block_durations = [];
for i=1:length(ncoherence_vec)
    tmp_time = timing.block(i).stop - timing.block(i).start;
    block_durations = [block_durations,tmp_time];
end
bins = duration_vec(1,1)-0.1:.01:duration_vec(1,1)+0.1;
n=histc(block_durations,bins);
bar(bins,n);
Screen('CloseAll');
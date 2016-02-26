function [head_theta, pos_theta] = angle_cal(record)
% calculates head angle of the mouse and the angle of the stimulus position
% with the head line
%Azadeh Tafreshiha, Jan 2016

% load('\\vs01\MVP\Shared\InVivo\Databases\wctestdb_tinyhat.mat')
%%
global measures global_record

global_record = record;

experimentpath(record);

measures = record.measures;

evalin('base','global measures');
evalin('base','global global_record');
logmsg('Measures available in workspace as ''measures'',, record as ''global_record''.');
%%
nose = measures.nose;
arse = measures.arse;
stim = measures.stim;
hor = [10 0];
L = size(nose,1);
nose_a = NaN(L,2); arse_a = NaN(L,2); stim_a = NaN(L,2);
head_theta = NaN(1,L); pos_theta = NaN(1,L);
for k = 1:L;
    arse_a(k, 1:2) = arse(k,:) - nose(k,:);  %THE COORDINATES ALIGNED TO NOSE
    nose_a(k, 1:2) = nose(k,:) - nose(k,:);
    
    %         figure(k+10); plot([0, nose_a(k,1)], [0, nose_a(k,2)],
    %         'v','MarkerSize',8,...
    %             'MarkerFaceColor', 'b'); hold on;
    %         text(-15,-20,'nose','color','b');
    %
    %         plot([0, arse_a(k,1)], [0, arse_a(k,2)], 'linewidth',3); hold
    %         on; grid on; extent1 = abs(arse_a)+100; ax1=
    %         max(max(extent1)); plot([-ax1 ax1],[0 0],'--b',[0 0],[-ax1
    %         ax1],'--b');
    
    mag = @(v)sqrt(v(1)^2+v(2)^2); %magnitude ||v||
    get_ang = @(v1,v2)acosd(dot(v1,v2) /(mag(v1)*mag(v2))); %cos@ = v.u/||v||*||u||
    head_theta(k) = get_ang(hor,arse_a(k,:));
    
    if ~isempty(stim)
        stim_present = any(stim,2);
        if stim_present(k)== 1
            stim_a(k, 1:2) = stim(k,:) - nose(k,:);
            
            %             figure(k+10); plot([0, stim_a(k,1)], [0,
            %             stim_a(k,2)], 'linewidth',3); hold on;
            %
            %             grid on; extent = abs(stim_a)+100; ax=
            %             max(max(extent)); plot([-ax ax],[0 0],'--b',[0
            %             0],[-ax ax],'--b');
            pos_theta(k) = get_ang(arse_a(k,:) ,stim_a(k,:)) *sign(arse_a(k,2));
            %             text(50,100,sprintf('\\theta =
            %             %.1f,%c',pos_theta(k),char(176)),'color','b');
            %             %char(176) is deg
            %
            %             plot ang arc
            %                     angle_arc_plot([0,0],30,[deg2rad(get_ang(hor,arse_a(k)))
            %                     deg2rad(get_ang...
            %                         (hor,stim_a(k)))],'-','b',2);
        else
            pos_theta(k) = NaN;
            
            %         angle_arc_plot([0,0],10,[-deg2rad(get_ang(hor,arse_a(k,:)))
            %         0],'-','b',2);
        end
    else
        pos_theta = [NaN NaN];
    end
end
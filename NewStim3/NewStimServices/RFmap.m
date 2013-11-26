function [RFrect] = RFmap;


% From Tom Tucker's receptive field mapping program
%

NewStimGlobals;

global RFmap_length RFmap_width RFmap_ori RFmap_flash RFmap_colors RFmap_ptlist RFmap_rlst RFmap_colorind

RFmap_collist = {[255;0]; [0;255]};

if isempty(RFmap_colors)|1,
    % need to init
     RFmap_colorind = 1+mod(0,length(RFmap_collist));
     RFmap_colors = RFmap_collist{RFmap_colorind};
     RFmap_ori = - pi/2;
     RFmap_length= 5.0 * pixels_per_cm;
     RFmap_width = 1.0 * pixels_per_cm;
end;

RFmap_ptlist=zeros(4,2);
RFmap_rlst = zeros(4,3);

StimWindowGlobals; MonitorWindowGlobals;
if StimComputer, ShowStimScreen; end;
if MonitorComputer, ShowMonitorScreen; end;

% RFmap_colors(1,:) = Foreground color
% RFmap_colors(2,:) = Background color
% RFmap_ptlist = bar
% RFmap_ori = angle of inclination
% RFmap_length= length of the bar
% height = height of the bar
% inc = unit increment in length

windowheight = StimWindowRect(4)-StimWindowRect(2);
windowwidth  = StimWindowRect(3)-StimWindowRect(1);
Onrect = StimWindowRect;

screen(MonitorWindow,'FillRect',RFmap_colors(2,:),Onrect);
screen(StimWindow,'FillRect',RFmap_colors(2,:),Onrect);

%MonitorWindow = SCREEN(MonitorWindow,'OpenWindow',RFmap_colors(2,:),Onrect);
%StimWindow = SCREEN(StimWindow,'OpenWindow',RFmap_colors(2,:), Onrect);

widthinc = 5;
lengthinc = 5;
keysdown = 0;
cntinu = 1;
rfl = 500;

xcenter = windowwidth/2.0;
ycenter = windowheight/2.0;
x = xcenter;
y = ycenter;

xradius = RFmap_length/2.0;
yradius = RFmap_width/2.0;
xlong = xradius*cos(RFmap_ori);
xshort = yradius*sin(RFmap_ori);
ylong = xradius*sin(RFmap_ori);
yshort = yradius*cos(RFmap_ori);

RFmap_ptlist(1,1) = x-xlong-xshort;
RFmap_ptlist(1,2) = y-ylong+yshort;
RFmap_ptlist(2,1) = x+xlong-xshort;
RFmap_ptlist(2,2) = y+ylong+yshort;
RFmap_ptlist(3,1) = x+xlong+xshort;
RFmap_ptlist(3,2) = y+ylong-yshort;
RFmap_ptlist(4,1) = x-xlong+xshort;
RFmap_ptlist(4,2) = y-ylong-yshort;

screen(MonitorWindow,'FillPoly',RFmap_colors(1,:),RFmap_ptlist);
screen(StimWindow,'FillPoly',RFmap_colors(1,:),RFmap_ptlist);
					
while (cntinu)		
			[x,y,buttons]=getmouse(MonitorWindow);
			if (any(buttons)) 
				Screen(StimWindow,'FillPoly', RFmap_colors(2,:), RFmap_ptlist);
				Screen(MonitorWindow,'FillPoly', RFmap_colors(2,:), RFmap_ptlist);
				RFmap_ptlist(1,1) = x-xlong-xshort;
				RFmap_ptlist(1,2) = y-ylong+yshort;
				RFmap_ptlist(2,1) = x+xlong-xshort;
				RFmap_ptlist(2,2) = y+ylong+yshort;
				RFmap_ptlist(3,1) = x+xlong+xshort;
				RFmap_ptlist(3,2) = y+ylong-yshort;
				RFmap_ptlist(4,1) = x-xlong+xshort;
				RFmap_ptlist(4,2) = y-ylong-yshort;
				Screen(MonitorWindow,'FillPoly', RFmap_colors(1,:), RFmap_ptlist);
				Screen(StimWindow,'FillPoly', RFmap_colors(1,:), RFmap_ptlist);
				screen(StimWindow,'WaitBlanking');
			end
			
			[keysdown,secs,keycode]= KbCheck;
			if (keysdown)
			    ch = find(keycode);
				
				switch (ch)
				case 125,        % -> for increase in length
					    RFmap_length= RFmap_length+lengthinc;
				
				case 124,       % <- for decrease in length
					    RFmap_length= RFmap_length-lengthinc;
				
				case 127,        % -> for increase in height
						RFmap_width = RFmap_width+widthinc;
								
				case 126,       % <- for decrease in height
						RFmap_width = RFmap_width-widthinc;

				case 70,   % num pad +   rotate counter clockwise
				        RFmap_ori = RFmap_ori - pi/72;
						
			    case 79,   % -   rotate clockwise
				        RFmap_ori = RFmap_ori + pi/72;
				case 54,		   % CTRL+ESC for escaping the program
						cntinu = 0;
						saveflag = 0;					
				case 9,		   % CTRL+C for escaping the program
						cntinu = 0;
						saveflag = 0;
				case 37,		   % CTRL+C for escaping the program
						cntinu = 0;
						saveflag = 1;				
				case 123,   %F1
						if RFmap_rlst(1,1) > 0 
							xdist = rfl*cos(RFmap_rlst(1,3));
						    ydist = rfl*sin(RFmap_rlst(1,3));
							screen(MonitorWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(1,1)+xdist,RFmap_rlst(1,2)+ydist,RFmap_rlst(1,1)-xdist,RFmap_rlst(1,2)-ydist);
							screen(StimWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(1,1)+xdist,RFmap_rlst(1,2)+ydist,RFmap_rlst(1,1)-xdist,RFmap_rlst(1,2)-ydist);
					    end
						xradius = RFmap_length/2;
						yradius = RFmap_width/2;

					    RFmap_rlst(1,1) = RFmap_ptlist(1,1);
					    RFmap_rlst(1,2) = RFmap_ptlist(1,2);
					    RFmap_rlst(1,3) = RFmap_ori;
						xdist = rfl*cos(RFmap_ori);
						ydist = rfl*sin(RFmap_ori);
						screen(MonitorWindow,'DrawLine',mod(RFmap_colors(1,:),255)+100,RFmap_rlst(1,1)+xdist,RFmap_rlst(1,2)+ydist,RFmap_rlst(1,1)-xdist,RFmap_rlst(1,2)-ydist);

				case 121,   %F2
						if RFmap_rlst(2,1) > 0 
							xdist = rfl*cos(RFmap_rlst(2,3));
						    ydist = rfl*sin(RFmap_rlst(2,3));
						    screen(MonitorWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(2,1)+xdist,RFmap_rlst(2,2)+ydist,RFmap_rlst(2,1)-xdist,RFmap_rlst(2,2)-ydist);
						    screen(StimWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(2,1)+xdist,RFmap_rlst(2,2)+ydist,RFmap_rlst(2,1)-xdist,RFmap_rlst(2,2)-ydist);
					    end
					    RFmap_rlst(2,1) = RFmap_ptlist(3,1);
					    RFmap_rlst(2,2) = RFmap_ptlist(3,2);
					    RFmap_rlst(2,3) = RFmap_ori;
						xdist = rfl*cos(RFmap_ori);
						ydist = rfl*sin(RFmap_ori);
						screen(MonitorWindow,'DrawLine',mod(RFmap_colors(1,:),255)+100,RFmap_rlst(2,1)+xdist,RFmap_rlst(2,2)+ydist,RFmap_rlst(2,1)-xdist,RFmap_rlst(2,2)-ydist);
				
		       	case 100,     %F3
						if RFmap_rlst(3,1) > 0 
							xdist = rfl*cos(RFmap_rlst(3,3)-pi/2);
						    ydist = rfl*sin(RFmap_rlst(3,3)-pi/2);
						    screen(MonitorWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(3,1)+xdist,RFmap_rlst(3,2)+ydist,RFmap_rlst(3,1)-xdist,RFmap_rlst(3,2)-ydist);
						    screen(StimWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(3,1)+xdist,RFmap_rlst(3,2)+ydist,RFmap_rlst(3,1)-xdist,RFmap_rlst(3,2)-ydist);
					    end
					    RFmap_rlst(3,1) = RFmap_ptlist(2,1);
					    RFmap_rlst(3,2) = RFmap_ptlist(2,2);
					    RFmap_rlst(3,3) = RFmap_ori;
						xdist = rfl*cos(RFmap_ori-pi/2);
						ydist = rfl*sin(RFmap_ori-pi/2);
						screen(MonitorWindow,'DrawLine',mod(RFmap_colors(1,:),255)+100,RFmap_rlst(3,1)+xdist,RFmap_rlst(3,2)+ydist,RFmap_rlst(3,1)-xdist,RFmap_rlst(3,2)-ydist);
			
				case 119,      %%F4
						if RFmap_rlst(4,1) > 0 
							xdist = rfl*cos(RFmap_rlst(4,3)-pi/2);
						    ydist = rfl*sin(RFmap_rlst(4,3)-pi/2);
						    screen(MonitorWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(4,1)+xdist,RFmap_rlst(4,2)+ydist,RFmap_rlst(4,1)-xdist,RFmap_rlst(4,2)-ydist);
						    screen(StimWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(4,1)+xdist,RFmap_rlst(4,2)+ydist,RFmap_rlst(4,1)-xdist,RFmap_rlst(4,2)-ydist);
					    end
					    RFmap_rlst(4,1) = RFmap_ptlist(4,1);
					    RFmap_rlst(4,2) = RFmap_ptlist(4,2);
					    RFmap_rlst(4,3) = RFmap_ori;
						xdist = rfl*cos(RFmap_ori-pi/2);
						ydist = rfl*sin(RFmap_ori-pi/2);
						screen(MonitorWindow,'DrawLine',mod(RFmap_colors(1,:),255)+100,RFmap_rlst(4,1)+xdist,RFmap_rlst(4,2)+ydist,RFmap_rlst(4,1)-xdist,RFmap_rlst(4,2)-ydist);
				
					case 97,    %F5  clear all markings on MonitorWindow
						if RFmap_rlst(1,1) > 0 
							xdist = rfl*cos(RFmap_rlst(1,3));
						    ydist = rfl*sin(RFmap_rlst(1,3));
							screen(MonitorWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(1,1)+xdist,RFmap_rlst(1,2)+ydist,RFmap_rlst(1,1)-xdist,RFmap_rlst(1,2)-ydist);
					    end
						if RFmap_rlst(2,1) > 0 
							xdist = rfl*cos(RFmap_rlst(2,3));
						    ydist = rfl*sin(RFmap_rlst(2,3));
						    screen(MonitorWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(2,1)+xdist,RFmap_rlst(2,2)+ydist,RFmap_rlst(2,1)-xdist,RFmap_rlst(2,2)-ydist);
					    end
						if RFmap_rlst(3,1) > 0 
							xdist = rfl*cos(RFmap_rlst(3,3)-pi/2);
						    ydist = rfl*sin(RFmap_rlst(3,3)-pi/2);
						    screen(MonitorWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(3,1)+xdist,RFmap_rlst(3,2)+ydist,RFmap_rlst(3,1)-xdist,RFmap_rlst(3,2)-ydist);
					    end
						if RFmap_rlst(4,1) > 0 
							xdist = rfl*cos(RFmap_rlst(4,3)-pi/2);
						    ydist = rfl*sin(RFmap_rlst(4,3)-pi/2);
						    screen(MonitorWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(4,1)+xdist,RFmap_rlst(4,2)+ydist,RFmap_rlst(4,1)-xdist,RFmap_rlst(4,2)-ydist);
					    end
				
						
					case 98,    %F6  re-draw markings  on MonitorWindow
						if RFmap_rlst(1,1) > 0 
							xdist = rfl*cos(RFmap_rlst(1,3));
						    ydist = rfl*sin(RFmap_rlst(1,3));
							screen(MonitorWindow,'DrawLine',mod(RFmap_colors(1,:),255)+100,RFmap_rlst(1,1)+xdist,RFmap_rlst(1,2)+ydist,RFmap_rlst(1,1)-xdist,RFmap_rlst(1,2)-ydist);
					    end
						if RFmap_rlst(2,1) > 0 
							xdist = rfl*cos(RFmap_rlst(2,3));
						    ydist = rfl*sin(RFmap_rlst(2,3));
						    screen(MonitorWindow,'DrawLine',mod(RFmap_colors(1,:),255)+100,RFmap_rlst(2,1)+xdist,RFmap_rlst(2,2)+ydist,RFmap_rlst(2,1)-xdist,RFmap_rlst(2,2)-ydist);
					    end
						if RFmap_rlst(3,1) > 0 
							xdist = rfl*cos(RFmap_rlst(3,3)-pi/2);
						    ydist = rfl*sin(RFmap_rlst(3,3)-pi/2);
						    screen(MonitorWindow,'DrawLine',mod(RFmap_colors(1,:),255)+100,RFmap_rlst(3,1)+xdist,RFmap_rlst(3,2)+ydist,RFmap_rlst(3,1)-xdist,RFmap_rlst(3,2)-ydist);
					    end
						if RFmap_rlst(4,1) > 0 
							xdist = rfl*cos(RFmap_rlst(4,3)-pi/2);
						    ydist = rfl*sin(RFmap_rlst(4,3)-pi/2);
						    screen(MonitorWindow,'DrawLine',mod(RFmap_colors(1,:),255)+100,RFmap_rlst(4,1)+xdist,RFmap_rlst(4,2)+ydist,RFmap_rlst(4,1)-xdist,RFmap_rlst(4,2)-ydist);
					    end
						
					case 99,    %F7  clear all markings on StimWindow
						if RFmap_rlst(1,1) > 0 
							xdist = rfl*cos(RFmap_rlst(1,3));
						    ydist = rfl*sin(RFmap_rlst(1,3));
							screen(StimWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(1,1)+xdist,RFmap_rlst(1,2)+ydist,RFmap_rlst(1,1)-xdist,RFmap_rlst(1,2)-ydist);
					    end
						if RFmap_rlst(2,1) > 0 
							xdist = rfl*cos(RFmap_rlst(2,3));
						    ydist = rfl*sin(RFmap_rlst(2,3));
						    screen(StimWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(2,1)+xdist,RFmap_rlst(2,2)+ydist,RFmap_rlst(2,1)-xdist,RFmap_rlst(2,2)-ydist);
					    end
						if RFmap_rlst(3,1) > 0 
							xdist = rfl*cos(RFmap_rlst(3,3)-pi/2);
						    ydist = rfl*sin(RFmap_rlst(3,3)-pi/2);
						    screen(StimWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(3,1)+xdist,RFmap_rlst(3,2)+ydist,RFmap_rlst(3,1)-xdist,RFmap_rlst(3,2)-ydist);
					    end
						if RFmap_rlst(4,1) > 0 
							xdist = rfl*cos(RFmap_rlst(4,3)-pi/2);
						    ydist = rfl*sin(RFmap_rlst(4,3)-pi/2);
						    screen(StimWindow,'DrawLine',RFmap_colors(2,:),RFmap_rlst(4,1)+xdist,RFmap_rlst(4,2)+ydist,RFmap_rlst(4,1)-xdist,RFmap_rlst(4,2)-ydist);
					    end
				
						
					case 101,    %F8  re-draw markings  on StimWindow
						if RFmap_rlst(1,1) > 0 
							xdist = rfl*cos(RFmap_rlst(1,3));
						    ydist = rfl*sin(RFmap_rlst(1,3));
							screen(StimWindow,'DrawLine',mod(RFmap_colors(1,:),255)+100,RFmap_rlst(1,1)+xdist,RFmap_rlst(1,2)+ydist,RFmap_rlst(1,1)-xdist,RFmap_rlst(1,2)-ydist);
					    end
						if RFmap_rlst(2,1) > 0 
							xdist = rfl*cos(RFmap_rlst(2,3));
						    ydist = rfl*sin(RFmap_rlst(2,3));
						    screen(StimWindow,'DrawLine',mod(RFmap_colors(1,:),255)+100,RFmap_rlst(2,1)+xdist,RFmap_rlst(2,2)+ydist,RFmap_rlst(2,1)-xdist,RFmap_rlst(2,2)-ydist);
					    end
						if RFmap_rlst(3,1) > 0 
							xdist = rfl*cos(RFmap_rlst(3,3)-pi/2);
						    ydist = rfl*sin(RFmap_rlst(3,3)-pi/2);
						    screen(StimWindow,'DrawLine',mod(RFmap_colors(1,:),255)+100,RFmap_rlst(3,1)+xdist,RFmap_rlst(3,2)+ydist,RFmap_rlst(3,1)-xdist,RFmap_rlst(3,2)-ydist);
					    end
						if RFmap_rlst(4,1) > 0 
							xdist = rfl*cos(RFmap_rlst(4,3)-pi/2);
						    ydist = rfl*sin(RFmap_rlst(4,3)-pi/2);
						    screen(StimWindow,'DrawLine',mod(RFmap_colors(1,:),255)+100,RFmap_rlst(4,1)+xdist,RFmap_rlst(4,2)+ydist,RFmap_rlst(4,1)-xdist,RFmap_rlst(4,2)-ydist);
                        end
                    case 6,
                        RFmap_colorind = 1+mod(RFmap_colorind-1+1,length(RFmap_collist));
                        RFmap_colors = RFmap_collist{RFmap_colorind};
						screen(MonitorWindow,'FillRect',RFmap_colors(2,:),Onrect);
						screen(StimWindow,'FillRect',RFmap_colors(2,:),Onrect);
						Screen(MonitorWindow,'FillPoly', RFmap_colors(1,:), RFmap_ptlist);
						Screen(StimWindow,'FillPoly', RFmap_colors(1,:), RFmap_ptlist);
						%disp(['remapping colors']);
				end   %switch
				Screen(StimWindow,'FillPoly', RFmap_colors(2,:), RFmap_ptlist);
				Screen(MonitorWindow,'FillPoly', RFmap_colors(2,:), RFmap_ptlist);
				xradius = RFmap_length/2;
				yradius = RFmap_width/2;
				xlong = xradius*cos(RFmap_ori);
				xshort = yradius*sin(RFmap_ori);
				ylong = xradius*sin(RFmap_ori);
				yshort = yradius*cos(RFmap_ori);
				RFmap_ptlist(1,1) = x-xlong-xshort;
				RFmap_ptlist(1,2) = y-ylong+yshort;
				RFmap_ptlist(2,1) = x+xlong-xshort;
				RFmap_ptlist(2,2) = y+ylong+yshort;
				RFmap_ptlist(3,1) = x+xlong+xshort;
				RFmap_ptlist(3,2) = y+ylong-yshort;
				RFmap_ptlist(4,1) = x-xlong+xshort;
				RFmap_ptlist(4,2) = y-ylong-yshort;
				Screen(MonitorWindow,'FillPoly', RFmap_colors(1,:), RFmap_ptlist);
				Screen(StimWindow,'FillPoly', RFmap_colors(1,:), RFmap_ptlist);
				screen(StimWindow,'WaitBlanking');

			end       %if
			
			while (keysdown)
				[keysdown,secs,keycode]= KbCheck;
				ch = find(keycode);
				FlushEvents('keyDown');
		    end
		

end				%( cntinu)	

%set(vs.RFxcenteredit,'String',(num2str( (RFmap_rlst(1,1) + RFmap_rlst(3,1) )/2)));
%set(vs.RFycenteredit,'String',(num2str( (RFmap_rlst(1,2) + RFmap_rlst(3,2))/2)));
%set(vs.RFwidthedit,'String',(num2str( abs(RFmap_rlst(1,1) - RFmap_rlst(3,1)))));
%set(vs.RFlengthedit,'String',(num2str(abs(RFmap_rlst(1,2) - RFmap_rlst(3,2)))));

RFrect = round([ min(RFmap_rlst([1 3],1)) min(RFmap_rlst([1 3],2)) max(RFmap_rlst([1 3],1)) max(RFmap_rlst([1 3],2))]); 

if RFrect(1)==RFrect(3), RFrect(1) = RFrect(1)-10; RFrect(3) = RFrect(3) + 10; end;

Screen('CloseAll');
ShowStimScreen
FlushEvents('keyDown');

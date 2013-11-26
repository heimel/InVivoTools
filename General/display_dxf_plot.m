function SurfObj = display_dxf_plot(file, plot3dview)
%DISPLAY_DXF_PLOT
%
% from internet, bugfixed by Alexander Heimel
%
if nargin<2
    plot3dview = [];
end
if isempty(plot3dview)
    plot3dview = 1;
end

    const = 10/0.254;
%const = 1;
%close all
% file = '../plot';
figure
if plot3dview ==1
    view(3)
end
hold on;
Object = readdxf(file,plot3dview,const);
%axis off

axis equal
hold off

light('Position',[-10 -10 -10],'Style','local')
light('Position',[60,60,60]), lighting gouraud

function  Object = readdxf(file,plot3dview,const)
Color = [[0 0 0]
    [1 0 0]
    [1 1 0]
    [0 1 0]
    [0 1 1]
    [0 0 1]
    [1 0 1]
    [1 1 1]
    [.5 .5 .5]
    [0.75 .75 .75]];
fid = fopen(file);
if (fid == -1)
    error(['Cannot open file ' file]);
end

for i=1:14
    junk=fgetl(fid);
end
Line = fgetl(fid);

Code = fscanf(fid,'%d');

NewObject.comment = fgetl(fid);
Code = fscanf(fid,'%d');
NewObject.Type = fgetl(fid);
Object = struct([]);

SurfObj=[];
while(isempty(findstr(NewObject.Type,'EOF')))
    switch NewObject.Type
        case 'POLYLINE'
            Code = fscanf(fid,'%d');
            NewObject.Name = fgetl(fid);
            [x,y,z, c] = ReadPolyLine(fid,const);
            NewObject.Data.X = x;
            NewObject.Data.Y = y;
            NewObject.Data.Z = z;
            Object= [Object; NewObject];
            if plot3dview ==1
                plot3(x,y,z,'Color',Color(c+1,:));
            else
                plot(x,y,'Color',Color(c+1,:));
            end
        case '3DFACE'
            Code = fscanf(fid,'%d');
            GroupName = trim(fgets(fid)); %fscanf(fid,'%d',1);
            Unknown = fscanf(fid,'%d');
            NewObject.Name = fgetl(fid);
            [x y z c] = Read3DFace(fid,const);
            
            if plot3dview ==1
                plot3(x,y,z)
            end
            Present = 0;
            if (~isempty(SurfObj))
                uniquename = unique({SurfObj.Name});
                for i=1:length(uniquename)
                    if ~isempty(findstr(SurfObj(i).Name,NewObject.Name));
                        Present = i;
                        break;
                    end
                end
            end
            if (isempty(SurfObj) || (~Present))
                SurfObjTemp.Name = NewObject.Name;
                SurfObjTemp.Vert = [x.' y.' z.'];
                SurfObjTemp.c = c;
                SurfObjTemp.Face = [1 2 3 4];
                SurfObj = [SurfObj SurfObjTemp];
                % patch('vertices',SurfObjTemp.Vert,'faces',SurfObjTemp.Face,'facecolor',rand(1,3));
            else
                SurfObj(Present).Vert=[SurfObj(Present).Vert;[x.' y.' z.']];
                SurfObj(Present).Face=[SurfObj(Present).Face;linspace(SurfObj(Present).Face(end)+1,(SurfObj(Present).Face(end)+4),4)];
            end
            
        case 'LINE'
            Code = fscanf(fid,'%d');
            NewObject.Name = fgetl(fid);
            [x y z c] = ReadLine(fid,const);
            
            if plot3dview ==1
                
                switch c+1
                    case 2
                        line([x(1) y(1) z(1)],...
                            [x(2) y(2) z(2)],'-r0.75',.6,.55);
                        
                    case 4
                        line([x(1) y(1) z(1)],...
                            [x(2) y(2) z(2)],'-g0.75',.6,.55);
                        
                    case 6
                        line([x(1) y(1) z(1)],...
                            [x(2) y(2) z(2)],'-b0.75',.6,.55);
                        
                    otherwise
                        plot3(x,y,z,'Color',Color(c+1,:));
                end
            else
                plot(x,y,'Color',Color(c+1,:));
            end
        otherwise
            %warning(['DISPLAY_DXF_PLOT: Not parsing' NewObject.Type]);
    end
    
    
    NewObject.Type = fgetl(fid);
end
if plot3dview ==1
    for i=1:length(SurfObj)
        patch('vertices',SurfObj(i).Vert,'faces',SurfObj(i).Face,...
            'facecolor',rand(1,3),'Edgecolor','none')
        
        
    end
end
fclose(fid)
%error

% [X,Y] = meshgrid(linspace(SurfObj(end).Vert(1,2),SurfObj(end).Vert(3,2),length(Surface)),...
%     linspace(SurfObj(end).Vert(1,3),SurfObj(end).Vert(3,3),length(Surface)));
% Z = SurfObj(end).Vert(1,1)+X.*0;
% %     contourf(X,Y,Surface)
% j=surf('xdata',Z,...
%     'ydata',X,...
%     'zdata',Y,...
%     'facecolor','texturemap','cdata',Surface-10,'EdgeColor','none');


function [x,y,z,Color] = ReadLine(fid,const)
Code = fscanf(fid,'%i',1);
LineWidth = fscanf(fid,'%f',1);

Code = fscanf(fid,'%d',1);
Color = fscanf(fid,'%d',1);
x= [];
y = [];
z=[];
for i=1:2
    Code = fscanf(fid,'%d',1);
    x = [x fscanf(fid,'%f',1)*const];
    
    Code = fscanf(fid,'%d',1);
    y = [y fscanf(fid,'%f',1)*const];
    Code = fscanf(fid,'%d',1);
    z = [z fscanf(fid,'%f',1)*const];
end

function [x,y,z,Color] = Read3DFace(fid,const)
Code = str2double(trim(fgets(fid))) %fscanf(fid,'%d',1);
Color = str2double(trim(fgets(fid))) %fscanf(fid,'%d',1);
%Code = fscanf(fid,'%d',1);
%Color = fscanf(fid,'%d',1);
x= [];
y = [];
z=[];
for i=1:4
    Code = fscanf(fid,'%d',1);
    if Code ==70
        InvisibleEdge = fscanf(fid,'%d',1);
        Code = fscanf(fid,'%d',1);
    end
    
    
    if Code~=10+i-1
        Code
        warning('Error in 3DFace');
    end
    x = [x fscanf(fid,'%f',1)*const];
    
    Code = fscanf(fid,'%d',1);
    y = [y fscanf(fid,'%f',1)*const];
    Code = fscanf(fid,'%d',1);
    z = [z fscanf(fid,'%f',1)*const];
end
x
y
z

function [x,y,z, Color,fid] = ReadPolyLine(fid,const)
Code = fscanf(fid,'%i',1);
LineWidth = fscanf(fid,'%f',1);
Code = fscanf(fid,'%d',1);
Color = fscanf(fid,'%d',1);

Code = fscanf(fid,'%d',1);
VertFollow = fscanf(fid,'%d',1);

Code = fscanf(fid,'%d',1);
mesh = fscanf(fid,'%d',1);
if mesh ==16
    Code = fscanf(fid,'%d',1);
    m = fscanf(fid,'%d',1);
    Code = fscanf(fid,'%d',1);
    n = fscanf(fid,'%d',1);
else
    g=1;
end
x = [];
y = [];
z = [];
while 1
    CodeVertex = fscanf(fid,'%d',1);
    Vertex = fgetl(fid);Vertex = fgetl(fid);
    if (~isempty(findstr(Vertex,'SEQEND')))
        break;
    end
    if (CodeVertex ==999)
        break;
    end
    if (~isempty(findstr(Vertex,'ENDSEC')))
        break;
    end
    Code = fscanf(fid,'%d',1);
    Name = fgetl(fid);
    Name = fgetl(fid);
    
    Code = fscanf(fid,'%d',1);
    if Code == 62
        Color = fscanf(fid,'%d',1);
        Code = fscanf(fid,'%d',1);
    end
    
    if Code~=10
        error('Error in PolyLine')
    end
    x = [x fscanf(fid,'%f',1)*const];
    
    Code = fscanf(fid,'%d',1);
    y = [y fscanf(fid,'%f',1)*const];
    Code = fscanf(fid,'%d',1);
    z = [z fscanf(fid,'%f',1)*const];
    
    Code = fscanf(fid,'%d',1);
    Code = fscanf(fid,'%d',1);
    
end



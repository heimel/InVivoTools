function cageform( record )
%CAGEFORM prints a cageform from a mouse record
%
%  CAGEFORM( RECORD )
%
% 2012, Alexander Heimel
%


html = fileread('cageform.html');

if isfield(record,'mouse') % i.e. called from mouse_db
    % get protocol
    % assume mousenumber like 04.05.1.01
    protocol_number = record.mouse(1:5);
    experimental_group = str2double(record.mouse(7));
    load(fullfile( expdatabasepath, 'decdb.mat'),'db');
    decdb = db;
    decrecord = decdb(find_record(decdb,['protocol=' protocol_number]));
elseif isfield(record,'protocol') % i.e. called from dec_db
    
    decrecord = record;
    protocol_number = record.protocol;
    
    load(fullfile(expdatabasepath,'mousedb.mat'),'db');
    mousedb = db;
    flds = fieldnames(mousedb);
    record = [];
    for i=1:length(flds)
        record.(flds{i}) = [];
    end
    
end
html = replace_fieldnames( html, record );

if isempty(decrecord)
    warndlg(['Could not find matching dec protocol ' ...
        protocol_number '. Add record to dec_db'],'Cage form');
    disp(['CAGEFORM: Could not find matching dec protocol ' ...
        protocol_number '. Add record to dec_db']);
    flds = fields(decrecord);
    decrecord = [];
    for i=1:length(flds)
        decrecord.(flds{i}) = [];
    end
end
html = replace_fieldnames( html, decrecord );

if isunix
    
  tformname='cageform.html';
  tformname=fullfile(tempdir,tformname);
  fid = fopen(tformname,'w');
  fwrite(fid,html);
  fclose(fid);
  command = [ '!html2ps ' tformname ' | lpr '];
  eval(command);
  msgbox('Sent cage form to printer');
  return
end


hfig    = figure('PaperType','A4','PaperUnits','centimeters','Toolbar','None','visible','on');

X=0;Y=0;
xSize = 14; 
ySize = 17;
%xLeft = (21-xSize)/2; 
%yTop = (30-ySize)/2;
%set(gcf,'PaperPosition',[xLeft yTop xSize ySize])
set(gcf,'PaperPosition',[1 1.5 19 25])

screensize = get(0,'ScreenSize');
height = min(screensize(4)-100, ySize*50);
set(gcf,'Position',[X Y xSize*50 height])

je      = javax.swing.JEditorPane( 'text/html', html );
jp      = javax.swing.JScrollPane( je );

[hcomponent, hcontainer] = javacomponent( jp, [], hfig );
set( hcontainer, 'units', 'normalized', 'position', [0,0,1,1] );

%# Turn anti-aliasing on ( R2006a, java 5.0 )
java.lang.System.setProperty( 'awt.useSystemAAFontSettings', 'on' );
je.putClientProperty( javax.swing.JEditorPane.HONOR_DISPLAY_PROPERTIES, true );
%je.putClientProperty( com.sun.java.swing.SwingUtilities2.AA_TEXT_PROPERTY_KEY, true );

je.setFont( java.awt.Font( 'Arial', java.awt.Font.PLAIN, 12 ) );

%print(hfig)





function text = replace_fieldnames( text, record )
% replace fieldnames by values from record
fields=fieldnames(record);
for i=1:length(fields)
    val=record.(fields{i});
    if iscell(val)
        val=val{1};
    end
    if ~isempty(val)
        if isnumeric(val)
            val=mat2str(val);
        end
      %  val(val=='/')='d';
        val(val=='{')=' ';
        val(val=='}')=' ';
      %  val(val==',')=' ';
        val(val=='''')=' ';
      %  val(val=='(')=' ';
      %  val(val==')')=' ';
    end
    
    if isempty(val)
        val = '';
    end
    text = strrep(text,['\' fields{i}],val);
end


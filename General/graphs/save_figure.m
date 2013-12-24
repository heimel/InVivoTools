function filename=save_figure(filename,path,h)
%SAVE_FIGURE saves figures in png format (cropped)
%
%  SAVE_FIGURE(FILENAME,PATH,H)
%

if nargin<2
    path='';
end
if nargin<3
    h=[];
end
if isempty(h)
    h=gcf;
end

filename=lower(subst_filechars(filename));

if strcmp(filename(max(1,end-3):end),'.png')==1
    filename=filename(1:end-4);
end

path=compose_figurepath(path);

if 0 & isunix % deprecated since arrival of savefig
    
    filename=fullfile(path,filename);
    
    v=version;
    if v(1)=='5' % student version
        saveas(h,[filename '.eps'],'psc2')
        command=['!sed ''s/(Student Version of MATLAB) show//'' ' ...
            filename '.eps > ' filename 'c.eps'];
        eval(command);
        command=['!ps2pdf ' filename 'c.eps ' filename 'c.pdf'];
        eval(command);
        
        command=['!convert -trim ' filename 'c.pdf ' filename '.png'];
        eval(command);
        command=['! rm ' filename 'c.eps ' filename 'c.pdf ' filename '.eps' ];
        eval(command);
    else
        % official version
        % adjust paper size to fit figure
        
        
        set(h,'PaperOrientation','portrait');
        set(h,'PaperPositionMode','auto');
        pp=get(h,'PaperPosition');
        set(h, 'PaperSize', [pp(3) pp(4)]);
        switch v(end-6:end-1)
            case 'R2008a'
                disp('version R2008a');
                saveas(h,[filename 'c.pdf'],'pdf')
                command=['!convert -trim ' filename 'c.pdf ' filename '.png'];
                eval(command);
                command=['! rm '  filename 'c.pdf '];
                eval(command);
            otherwise
                saveas(h,[filename 'c.pdf'],'pdf')
                command=['!pdf2ps ' filename 'c.pdf ' filename 'c.ps'];
                eval(command);
                command=['!convert -trim ' filename 'c.ps ' filename '.png'];
                eval(command)
                command=['! rm '  filename 'c.pdf ' filename 'c.ps '];
                eval(command);
        end
    end
    
    
else % windows pc or recent matlab linux
    savewd=pwd;
    if ~exist(path,'dir')
        disp(['SAVE_FIGURE: ' path ' does not exist. Saving to desktop']);
        path = getdesktopfolder;
    end        
    cd(path);
    if isunix
        savefig([filename '.png'],h,'png');
        %        saveas(h,[filename '.eps'],'epsc2');
        %        saveas(h,[filename '.fig'],'fig');
        
        %disp('SAVE_FIGURE: Turned off svg save.');
        if 0
            plot2svg( [filename '.svg'],h,'png');
        end
    else % windows (assume absence of ghostscript)
        saveas(h,[filename '.png'],'png');
    end
    filename=fullfile(path,filename);
    cd(savewd);
end


filename=[filename '.png'];
disp(['SAVE_FIGURE: Figure saved as ' filename]);

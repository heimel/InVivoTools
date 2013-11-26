function generate_unmixing_graph
%GENERATE_UNMIXING_GRAPH for Daan's paper
%
% 2011, Alexander Heimel
%

plotall = false;
figpath = '~/Desktop/Figures';

left = 100;
right = 100;
top = 50;
bottom = 258;
stack = 'mouse=10.24.1.25,stack=tuft2,slice=day0';

close all

unprocessed.unmixing = 0;
unprocessed.spatial_filter = 1;


processed.unmixing = 1;
processed.spatial_filter = 1;

if ~exist('unimgfp','var')
    
    % get which database
    [testdb, experimental_pc] = expdatabases( 'tp', host );
    
    % load database
    [db,filename]=load_testdb(testdb);
    
    record = db(find_record(db,stack));
    
    
    if 1
        image_processing.unmixing = 1;
        image_processing.spatial_filter = 1;
        filename = tpfilename( record, [], [], image_processing);
        if exist(filename,'file')
            delete( filename );
        end
    end
    
    unprocessed_fname = tpfilename( record, [], [], unprocessed);
    
    params = tpreadconfig(record);
    for channel = 1:params.NumberOfChannels
        im(:,:,:,channel) = tpreadframe(record,channel,1:params.NumberOfFrames,unprocessed);
    end
    unimgfp = double(flatten(im(:,:,:,1)));
    unimrfp = double(flatten(im(:,:,:,2)));
    ind_nonzeros = (unimgfp>0 & unimrfp>0);
    unimgfp = unimgfp(ind_nonzeros);
    unimrfp = unimrfp(ind_nonzeros);
    
    for channel = 1:params.NumberOfChannels
        im(:,:,:,channel) = tpreadframe(record,channel,1:params.NumberOfFrames,processed);
    end
    prcimgfp = double(flatten(im(:,:,:,1)));
    prcimrfp = double(flatten(im(:,:,:,2)));
    ind_nonzeros = (prcimgfp>0 & prcimrfp>0);
    prcimgfp = prcimgfp(ind_nonzeros);
    prcimrfp = prcimrfp(ind_nonzeros);
end


if 0 || plotall
    fig.corr_before = figure;
    figname = 'supfig_unmixing_corr_before';
    title('Before unmixing');
    plot(unimrfp,unimgfp,'.');
    box off
    xlim([min(unimrfp)-10 max(unimrfp)]);
    ylim([min(unimgfp)-10 max(unimgfp)]);
    xlabel('RFP intensity');
    ylabel('GFP intensity');
    [r,p]=corrcoef(unimrfp(1:1000:end),unimgfp(1:1000:end));
    disp(['Correlation unprocessed RFP & GFP, r = ' num2str(r(1,2)) ', p = ' num2str(p(1,2))]);
    smaller_font(-4);
    figpath = '~/Desktop/Figures';
    saveas(fig.corr_before,fullfile(figpath,[figname '.png']),'png');
end


if 0 || plotall
    fig.corr_unmixed = figure;
    figname = 'supfig_unmixing_corr_after';
    title('After unmixing');
    plot(prcimrfp,prcimgfp,'.');
    xlim([min(prcimrfp)-10 max(prcimrfp)]);
    ylim([min(prcimgfp)-10 max(prcimgfp)]);
    xlabel('RFP intensity');
    ylabel('GFP intensity');
    box off5
    [r,p]=corrcoef(prcimrfp(1:1000:end),prcimgfp(1:1000:end));
    disp(['Correlation processed RFP & GFP, r = ' num2str(r(1,2)) ', p = ' num2str(p(1,2))]);
    smaller_font(-4);
    saveas(fig.corr_unmixed,fullfile(figpath,[figname '.png']),'png');
end






im = tppreview(record, 1:params.NumberOfFrames, 1, [1 2],unprocessed, 2);


im = im( left:end-right,top:end-bottom,:);

mx = [-0.1 -0.5];
mn = [-1 -1 ];
gamma = [1 1];





if 0 || plotall
    fig.im1_before = figure;
    set(gcf,'position',[440 371 420 420])
    figname = 'supfig_unmixing_im1_before';
    [previewim,mx,mn,gamma] = tp_image(im,[1 ],mx,mn,gamma,tp_channel2rgb(record));
    set(gca,'position',[0 0 1 1]);
    saveas(fig.im1_before,fullfile(figpath,[figname '.png']),'png');
end

if 0 || plotall
    fig.im2_before = figure;
    set(gcf,'position',[440 371 420 420])
    figname = 'supfig_unmixing_im2_before';
    [previewim,mx,mn,gamma] = tp_image(im,[ 2],mx,mn,gamma,tp_channel2rgb(record));
    set(gca,'position',[0 0 1 1]);
    saveas(fig.im2_before,fullfile(figpath,[figname '.png']),'png');
end

if 0 || plotall
    fig.im12_before = figure;
    set(gcf,'position',[440 371 420 420])
    figname = 'supfig_unmixing_im12_before';
    [previewim,mx,mn,gamma] = tp_image(im,[1 2],mx,mn,gamma,tp_channel2rgb(record));
    set(gca,'position',[0 0 1 1]);
    saveas(fig.im12_before,fullfile(figpath,[figname '.png']),'png');
end

im = tppreview(record, 1:params.NumberOfFrames, 1, [1 2],processed, 2);
mx = [-0.1 -0.5];
mn = [-1 -1 ];
gamma = [1 1];
im = im( left:end-right,top:end-bottom,:);


if 0 || plotall
    fig.im1_unmixed = figure;
    set(gcf,'position',[440 371 420 420])
    figname = 'supfig_unmixing_im1_unmixed';
    [previewim,mx,mn,gamma] = tp_image(im,[1 ],mx,mn,gamma,tp_channel2rgb(record));
    set(gca,'position',[0 0 1 1]);
    saveas(fig.im1_unmixed,fullfile(figpath,[figname '.png']),'png');
end




if 0 || plotall
    fig.im2_unmixed = figure;
    set(gcf,'position',[440 371 420 420])
    figname = 'supfig_unmixing_im2_unmixed';
    tp_image(im,[ 2],mx,mn,gamma,tp_channel2rgb(record));
    set(gca,'position',[0 0 1 1]);
    saveas(fig.im2_unmixed,fullfile(figpath,[figname '.png']),'png');
end


if 0 || plotall
    fig.im12_unmixed = figure;
    set(gcf,'position',[440 371 420 420])
    figname = 'supfig_unmixing_im12_unmixed';
    tp_image(im,[1 2],mx,mn,gamma,tp_channel2rgb(record));
    set(gca,'position',[0 0 1 1]);
    saveas(fig.im12_unmixed,fullfile(figpath,[figname '.png']),'png');
end



%single plane
im = tppreview(record, 10, 1, [1 2],processed, 2);
mx = [-0.1 -0.5];
mn = [-1 -1 ];
gamma = [1 1];
im = im( left:end-right,top:end-bottom,:);

if 1 || plotall
    
    fig.im1_unmixed_extra_green = figure;
    set(gcf,'position',[440 371 420 420])
    figname = 'supfig_unmixing_im1_unmixed_extra_green';
    
    mx = max(flatten(im(:,:,1)));
    
    mn = min(flatten(im(:,:,1)))
    c = zeros(mx-mn,3);
    c(:,2) = (0:(mx-mn-1))/(mx-mn);
    c(1,:) = [0 0 1];
    
    k=prctile(flatten(im(:,:,1)),10);
    im(im<=k) = mn;
    
    imagesc(im(:,:,1));
    axis image;
    axis off;
    colormap(c)
    set(gca,'position',[0 0 1 1]);
    saveas(fig.im1_unmixed_extra_green,fullfile(figpath,[figname '.png']),'png');
end



function local_savefig(name,fig)
figpath = '~/Desktop/Figures';
save_figure([name '.png'],figpath,fig);
%saveas(fig,fullfile(figpath,[name '.png']),'png');
saveas(fig,fullfile(figpath,[name '.ai']),'ai');
warning('off','MATLAB:print:Illustrator:DeprecatedDevice');


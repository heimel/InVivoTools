experiment('13.14');
host('jander');
db = load_testdb('oi');

record = db(106);
close_figs
experimentpath(record)
for d=1:10
    record.blocks = d;
    data = oi_read_all_data( record);
    
    
    dat=mean(data,4);
    da=mean(dat,3);figure;
    for i=1:11;
        subplot(4,3,i);
        imagesc( (dat(:,:,i)'-da')./(da'));
        set(gca,'clim',[-0.001 0.04]);
        
        axis off image;
    end
    
end
function record = oi_compute_significance( record )
%OI_COMPUTE_SIGNIFICANCE computes pixels with significant response
%
% 2014, Alexander Heimel
%

[response_framenumbers,baseline_framenumbers] = oi_get_framenumbers(record);



data = oi_read_all_data( record );

% combine conditions
data = data(:,:,:,:,[1 3]);
logmsg('ONLY DOING GROUP 1 AND 3 AT THE MOMENT');

[n_x n_y n_frames n_blocks n_conditions] = size(data); %#ok<ASGLU>

response = data(:,:,response_framenumbers,:,:);
response = squeeze(mean(response,3)); 

baseline = data(:,:,baseline_framenumbers,:,:);
baseline = squeeze(mean(baseline,3));


signif_between_groups = zeros(n_x,n_y);
signif_response = zeros(n_x,n_y);
groups =  reshape(repmat(1:n_conditions,[n_blocks 1]),[n_blocks*n_conditions 1]);
h=waitbar(0,'Computing significance');
for x=1:1:n_x
    for y=1:1:n_y
        r = reshape(response(x,y,:,:),[n_blocks*n_conditions 1]);
        b = reshape(baseline(x,y,:,:),[n_blocks*n_conditions 1]);
        signif_between_groups(x,y) = myanova(r,groups);
        signif_response(x,y) = ...
            myanova([r;b],[groups repmat(0,[n_blocks*n_conditions 1])]);
    end % y
    waitbar(x/n_x,h);
end % x
close(h)

fname = fullfile(oidatapath(record),[record.test '_significance.mat']);
save(fname,'signif_between_groups','signif_response');


        

function out = concave_breakMM(orgmask, erdmask, mincellarea, fast_breakup, con_ratio,show_flag)

% Slight modification of concave_breakAK: prevents display of images
% unless show_flag is set

if(~exist('show_flag','var'))
  show_flag = 0;
end

si = size(orgmask);
[orglabeled orgnum] = bwlabel(orgmask);
workregions = uint8(zeros(si));
reconnect = logical(zeros(si));
dont_reconnect = logical(zeros(si));
temp4 = logical(zeros(si));
workregions = im2uint8(orgmask);
region = uint8(zeros(si));
out = im2uint8(orgmask);

if (fast_breakup==1)
    ultmask = bwulterode(erdmask);
    [ultlabeled erdnum] = bwlabel(ultmask);
    for i=1:orgnum
        region(:) = 255;
        idx = find(orglabeled==i);
        testvals = ultlabeled(idx);
        testmax = max(testvals);
        idx0 = find(testvals==0);
        testvals(idx0) = testmax;
        test = mean(testvals)/testmax;
        if (test==1)
            region(idx)=0;
        end
            workregions(idx) = region(idx); 
    end 
end

eroderange(:,:,1) = erdmask;
[labelrange(:,:,1) numrange(1)] = bwlabel(eroderange(:,:,1));

i = 2;
while(sum(sum(eroderange(:,:,(i-1))))~=0)
    se = strel('disk',(i-1)); 
    eroderange(:,:,i) = imerode(erdmask,se);
    [labelrange(:,:,i) numrange(i)] = bwlabel(eroderange(:,:,i));
    i=i+1;
end
maxradius = i-1;

eroderange = im2uint8(eroderange);

BD = BinaryDilateNoMerge8AK;
BD.doIwhite = 1;
BD.doIlabel = 0;
BD.iterations = -1;
IP = ij.process.ByteProcessor(si(1), si(2));

while (sum(sum(workregions))~=0)
    workregions = im2bw(workregions,0.01);
    [worklabel worknum] = bwlabel(workregions);
    disp(sprintf('Assessing concavity of %i objects...please wait', worknum));
    workregions = im2uint8(workregions);
    for i=1:worknum
        region(:) = 0;
        t = 0;
        j = 1;
        idx = find(worklabel==i);
        while (t==0 & j<=maxradius)
            t2 = 0;
            smallrad = 0;
            temp = labelrange(:,:,j);
            testvals = temp(idx);
            testmax = max(testvals);
            idx0 = find(testvals==0);
            testvals(idx0) = testmax;
            if testmax == 0
                j = maxradius;
            else
            test = mean(testvals)/testmax;
                if (test~=1)
                    minregion = inf;
                    minlabel = 1;
                    temp2 = eroderange(:,:,j);
                    region(idx) = temp2(idx);
                    % find the radius of the smaller object
                    [templabel tempnum] = bwlabel(region);
                    for h=1:tempnum
                        idx2=find(templabel==h);
                        sizeregion = length(idx);
                        if (minregion>=sizeregion)
                            minregion = sizeregion;
                            minidx = idx2;
                        end
                    end   
                    k = j + 1;
                    while (test~=0 & k<=maxradius)
                        temp = eroderange(:,:,k);
                        testvals = temp(minidx);
                        test = sum(testvals);
                        smallrad = k;
                        k = k + 1;
                    end
                    % calculate necessary iterations
                    regiondist = bwdist(region);
                    maxdist = max(regiondist(idx));
                    maxdist = maxdist + 1;
                    BD.iterations = double(maxdist);
                    % dilate no merge 
                    pix = reshape((region),(si(1)*si(2)),1);
                    IP.setPixels(pix);
                    BD.run(IP);
                    pix = IP.getPixels;
                    regdil = fixsignAK((reshape(pix,si(1),si(2))));
                    % save breaks regions 
                    ratio = j/smallrad;
                    temp3 = im2bw(regdil,0.01);
                    if ratio>con_ratio
                        reconnect(idx) = reconnect(idx) | ~temp3(idx);
                    else
                        % check if suprathreshold break connects to previous subthreahold break...if so then add subthreahold break to dont_reconnect
                        temp4(:) = 0;
                        temp4(idx) = ~temp3(idx);
                        reconnect_test = temp4 | reconnect;
                        [testlabel testnum] = bwlabel(reconnect_test);
                        for y=1:testnum
                            testidx = find(testlabel==y);
                            rectest = reconnect_test(testidx) & temp4(testidx);
                            if sum(rectest)==0
                                reconnect_test(testidx) = 0;
                            end
                        end
                        if sum(reconnect_test(:))~=0
                            dont_reconnect = dont_reconnect | reconnect_test;
                        else
                            dont_reconnect = dont_reconnect | temp4;
                        end
                    end
                    workregions(idx) = regdil(idx);
                    out(idx) = regdil(idx);
                    t = 1;
                end
            end    
            if j >= maxradius
                workregions(idx) = 0;
            end
            j = j+1;
        end
    end
end

if(show_flag==1)
  figure;
  imshow(out);
  title('initial');
  figure;
  imshow(reconnect);
  title('reconnect');
  figure;
  imshow(dont_reconnect);
  title('dont\_reconnect');
end

out = im2bw(out, 0.01);
out = out | reconnect;
out = out & ~dont_reconnect;

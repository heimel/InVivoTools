function AlanBrainMap(info,storepath,miceopt,DataDirectory)
global UserQuestions
folder = fullfile(storepath,'AlanBrainShots');

%% Reading in standard images (Thijs Baaijen, 06/2016)
if ~exist(fullfile(storepath,'AlanBrainModel.mat'))
    
    %First screenshot is whole brain, all others are regions
    listscrshts = dir(fullfile(folder,'Screenshot*'));
    Region =cell(length(listscrshts)-1,1);
    Rnames = Region;
    for i = 1:length(Region)
        A = imread([folder '\Screenshot_' num2str(1) '_.png']);
        loadidx = find(cell2mat(cellfun(@(X) ~isempty(strfind(X,['_' num2str(i+1) '_'])),{listscrshts(:).name},'UniformOutput',0))==1);
        B = imread(fullfile(folder,listscrshts(loadidx).name));
        C_RGB = B - A;
        C_GRAY = rgb2gray(C_RGB);
        C_BW = logical(C_GRAY);
        Region{i}=C_BW;
        tmp = strsplit(listscrshts(loadidx).name, '.png');
        tmp = strsplit(tmp{1},'_');
        Rnames{i} = tmp{end};
    end
    
    xpix = size(A,1);
    ypix = size(A,2);
    
    Boundary=[];
    for i = 1:length(Region)
        Boundary{i} = bwboundaries(Region{i});
        if length(Boundary{i}) > 5
            Region{i} = bwmorph(Region{i},'branchpoints',5);
        end
        Boundary{i} = bwboundaries(Region{i});
    end
    
    
    cortex = zeros(755,932);
    for i = 1:length(Region)
        cortex = cortex+Region{i};
    end
    figure;imshow(cortex)
    
    Black = zeros(xpix,ypix);
    imshow(Black);
    AllX = [];AllY = [];
    hold on
    for n = 1:length(Boundary)
        for k=1:length(Boundary{n})
            X = Boundary{n}{k}(:,2);
            Y = Boundary{n}{k}(:,1);
            NewBoundary{n}{k}(:,1) = X;
            NewBoundary{n}{k}(:,2) = Y;
            
            plot(X,Y,'w','Linewidth',1)
            AllX = [AllX;X];
            AllY = [AllY;Y];
        end
    end
    hold off
    
    % Values estimated from Alan Brain using pixonos map
    BregmaX = 375;
    LambdaX = 660;
    BregmaY = 382;
    LambdaY = 382;
    
    AllX = [AllX;BregmaX;LambdaX];
    AllY = [AllY;BregmaY;LambdaY];
    [AllX,ind] = sort(AllX);
    AllY = AllY(ind);
    scatter(AllX,AllY,'.')
    
    % figure to image
    F = getframe;
    I_uint8 = F.cdata(:,:,1);
    I_temp = I_uint8/255;
    I=logical(I_temp);
    imshow(I)
    
    
    AllBoundary = [AllX,AllY];
    Model = [];
    Model.AllX = AllX;
    Model.AllY = AllY;
    Model.Boundaries = NewBoundary;
    Model.Regions = Region;
    Model.EmptyCortex = [];
    Model.WholeCortex = I;
    Model.Lambda = [LambdaX, LambdaY];
    Model.Bregma = [BregmaX,BregmaY];
    Model.Rnames = Rnames;
    
    
    save(fullfile(storepath,'AlanBrainModel'),'Model')
end
%% Per mouse overlay


paths = info.paths;
logs = info.logs;
nrMouse = size(paths,1);
for midx = 1:nrMouse %For this mouse
    if sum(~cellfun(@isempty, {logs{midx,:,:}})) < 1 %If not recorded that day, skip
        continue
    end
    mouse = miceopt{midx};
    
    
    button = 0;
    if exist(fullfile(storepath,mouse,'brainareamodel.mat'))
        load(fullfile(storepath,mouse,'brainareamodel.mat'))
        referenceimage = uint8(imread(fullfile(storepath,mouse,'RefFile.bmp')));
        
        figure;
        imshow(histeq(referenceimage))
        hold on
        h = scatter(Model.AllX,Model.AllY,'k.');
        if UserQuestions
            
            button = questdlg(['Overlay already detected. Do you want to overwrite or keep current overlay?' fullfile(storepath, mouse)],'Change or keep mapping', 'Overwrite','Keep current overlay','Keep current overlay');
        else
            button = 'Keep current overlay';
        end
    end
    if ~strcmp(button,'Keep current overlay')
        load(fullfile(storepath,'AlanBrainModel.mat'))
        referenceimage = uint8(imread(fullfile(storepath,mouse,'RefFile.bmp')));
        
        %Open image
        f = figure; imshow(histeq(referenceimage));
        
        hold on
        %Get Bregma and Lambda information
        disp('Choose First Bregma & then Lambda location, doubleclick for last position...')
        title('Choose First Bregma & then Lambda location, doubleclick for last position...')
        notstopped = 1;
        while notstopped
            
            if exist('hh','var')
                delete(hh)
            end
            [x,y] = getline(f);
            
            %Bregma has the first x
            BregmaMouse = [x(1) y(1)];
            LambdaMouse = [x(2) y(2)];
            
            hh(1) = plot(BregmaMouse(1),BregmaMouse(2),'r*','MarkerSize',25);
            hold on
            hh(2) = text(BregmaMouse(1),BregmaMouse(2),'Bregma');
            
            hh(3) = plot(LambdaMouse(1),LambdaMouse(2),'b*','MarkerSize',25);
            hold on
            hh(4) = text(LambdaMouse(1),LambdaMouse(2),'Lambda');
            button = questdlg('Lambda/Bregma okay?','LambdaBregmaSelection', 'OK','try again','OK');
            if strcmp(button,'OK')
                notstopped = 0;
            end
            
        end
        
        %First scale Alan brain map to same nr pixels
        xpixnew = size(referenceimage,2);
        ypixnew = size(referenceimage,1);
        
        xpixold = size(Model.WholeCortex,2);
        ypixold = size(Model.WholeCortex,1);
        
        XImageScale = xpixnew/xpixold;
        YImageScale = ypixnew/ypixold;
        
        Model.Lambda(1) = Model.Lambda(1)*XImageScale;
        Model.Lambda(2) = Model.Lambda(2)*YImageScale;
        Model.Bregma(1) = Model.Bregma(1)*XImageScale;
        Model.Bregma(2) = Model.Bregma(2)*YImageScale;
        Model.AllX = Model.AllX*XImageScale;
        Model.AllY = Model.AllY*YImageScale;
        for i = 1:length(Model.Boundaries)
            for j = 1:length(Model.Boundaries{i})
                Model.Boundaries{i}{j}(:,1)=  Model.Boundaries{i}{j}(:,1)*XImageScale;
                Model.Boundaries{i}{j}(:,2)=  Model.Boundaries{i}{j}(:,2)*YImageScale;
            end
        end
        
        % Scaling
        XScale = (Model.Lambda(1) - Model.Bregma(1))/(LambdaMouse(1)-BregmaMouse(1));
        YScale = (Model.Lambda(2) - Model.Bregma(2))/(LambdaMouse(2)-BregmaMouse(2));
        if YScale ==0
            YScale = 1;
        end
        AllX_sc=Model.AllX/XScale;
        AllY_sc=Model.AllY/YScale;
        
        %shift Averaged
        shiftX = (Model.Bregma(1)/XScale - BregmaMouse(1));
        shiftY =  (Model.Bregma(2)/YScale -  BregmaMouse(2));
        
        % Apply shift
        AllXshift = AllX_sc-shiftX;
        AllYshift = AllY_sc-shiftY;
        
        ind_800=find(AllXshift>800);
        AllXshift(ind_800)=[];
        AllYshift(ind_800)=[];
        % AllYshift = AllYshift + 15;
        % plots
        figure;
        imshow(histeq(referenceimage))
        hold on
        h = scatter(AllXshift,AllYshift,'k.');
        
        % Position map better on brain
        title('Press a for shifting to the left, d for shifting to the right, s for shifting down, w for shifting up, f/g for xscale down/up, v/b for yscale down/up, k for okay')
        disp('Press a for shifting to the left, d for shifting to the right, s for shifting down, w for shifting up, f/g for xscale down/up, v/b for yscale down/up, k for okay')
        okay = 0;
        key = '0';
        while ~okay
            if strcmp(key,'d')
                shiftX = shiftX-1;
                key = '0';
            elseif strcmp(key,'a')
                shiftX = shiftX+1;
                key = '0';
            elseif strcmp(key,'w')
                shiftY = shiftY + 1;
                key = '0';
            elseif strcmp(key,'s')
                shiftY = shiftY -1;
                key = '0';
            elseif strcmp(key,'f')
                XScale = XScale*1.01;
                
                key = '0';
            elseif strcmp(key,'g')
                XScale =XScale*0.99;
                
                key = '0';
            elseif strcmp(key,'v')
                YScale = YScale*1.01;
                key = '0' ;
            elseif strcmp(key,'b')
                YScale = YScale*0.99;
                key = '0';
            elseif strcmp(key,'k')
                
                okay = 1;
            else
                while ~waitforbuttonpress;
                    pause(0.0001)
                end
                key = get(gcf,'CurrentCharacter');
                
            end
            if exist('h')
                delete(h)
            end
            AllX_sc=Model.AllX/XScale;
            AllY_sc=Model.AllY/YScale;
            % Apply shift
            AllXshift = AllX_sc-shiftX;
            AllYshift = AllY_sc-shiftY;
            
            h = scatter(AllXshift,AllYshift,'k.');
        end
        
        %Check with mapping if available
        checkdir=dir(fullfile(storepath,mouse,'*mapping'));
        if ~isempty(checkdir)
            tmpdir = dir(fullfile(storepath,mouse,checkdir.name,[mouse '*.mat']));
            maptmp = load(fullfile(storepath,mouse,checkdir.name,tmpdir.name));
            a = fieldnames(maptmp);
            mapses = eval(['maptmp.' a{1}]);
            keep = strsplit(checkdir.name,'_mapping');
            keep2 = strsplit(tmpdir.name,'session');
            keep2 = strsplit(keep2{end},'.mat');
            
            loadim = dir(fullfile(DataDirectory,mouse,keep{1},[mouse keep2{1}],[mouse keep2{1} '_1'],'0000*.tiff'));
            tmp = imread(fullfile(DataDirectory,mouse,keep{1},[mouse keep2{1}],[mouse keep2{1} '_1'],loadim.name));
            
            figure('name',[mouse '_mapping']);
            subplot(2,2,1)
            imagesc(imfuse(histeq(referenceimage),histeq(tmp)))%,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]));
            title('Before')
            % Now Use the reference to change pixels of
            tmpdir = dir(fullfile(storepath,mouse,checkdir.name,['AligningResults.mat']));
            load(fullfile(storepath,mouse,checkdir.name,tmpdir.name));
            tmp2 = imtranslate(tmp,Aligning(1,2:3),'FillValues',0,'OutputView','same');
            
            subplot(2,2,2)
            imagesc(imfuse(histeq(referenceimage),histeq(tmp2)))%,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]));
            title('After')
            
            %apply aligning results
            mapses.everything = imtranslate(mapses.everything,Aligning([2:3]),'FillValues',0,'OutputView','same');
            mapses.segmented = imtranslate(mapses.segmented,Aligning([2:3]),'FillValues',0,'OutputView','same');
            mapses.amplitude = imtranslate(mapses.amplitude,Aligning([2:3]),'FillValues',0,'OutputView','same');
            
            for i = 1:length(mapses.amplitudeBorders)
                mapses.amplitudeBorders{i}= mapses.amplitudeBorders{i} - repmat(Aligning([2:3]),[size(mapses.amplitudeBorders{i},1),1]);
            end
            
            figure; subplot(2,3,1:2)
            imagesc(mapses.everything)
            axis square
            colormap(jet)
            freezeColors
            hold on
            h = scatter(AllXshift,AllYshift,'k.');
            
            subplot(2,3,4:5)
            imagesc(histeq(referenceimage))
            colormap(gray)
            axis square
            hold on
            hh = scatter(AllXshift,AllYshift,'k.');
            
            %             figure; subplot(2,3,1:2)
            %             imagesc(mapses.segmented)
            %             freezeColors
            %             hold on
            %             h = scatter(AllXshift,AllYshift,'k.');
            %
            %             subplot(2,3,4:5)
            %             imagesc(histeq(referenceimage))
            %             colormap(gray)
            %             hold on
            %             hh = scatter(AllXshift,AllYshift,'k.');
            
            button2 = questdlg('Reshift based on this?','Reshift option', 'Reshift','Keep this','Keep this');
            if strcmp(button2,'Reshift')
                disp('Press a for shifting to the left, d for shifting to the right, s for shifting down, w for shifting up, f/g for xscale down/up, v/b for yscale down/up, k for okay')
                okay = 0;
                key = '0';
                while ~okay
                    if strcmp(key,'d')
                        shiftX = shiftX -1;
                        key = '0';
                    elseif strcmp(key,'a')
                        shiftX = shiftX+1;
                        key = '0';
                    elseif strcmp(key,'w')
                        shiftY = shiftY + 1;
                        key = '0';
                    elseif strcmp(key,'s')
                        shiftY = shiftY -1;
                        key = '0';
                    elseif strcmp(key,'f')
                        XScale = XScale*1.01;
                        
                        key = '0';
                    elseif strcmp(key,'g')
                        XScale =XScale*0.99;
                        
                        key = '0';
                    elseif strcmp(key,'v')
                        YScale = YScale*1.01;
                        key = '0' ;
                    elseif strcmp(key,'b')
                        YScale = YScale*0.99;
                        key = '0';
                    elseif strcmp(key,'k')
                        okay = 1;
                    else
                        while ~waitforbuttonpress;
                            pause(0.0001)
                        end
                        key = get(gcf,'CurrentCharacter');
                        
                    end
                    if exist('h')
                        subplot(2,2,1)
                        delete(h)
                        subplot(2,2,2)
                        delete(hh)
                    end
                    AllX_sc=Model.AllX/XScale;
                    AllY_sc=Model.AllY/YScale;
                    % Apply shift
                    AllXshift = AllX_sc-shiftX;
                    AllYshift = AllY_sc-shiftY;
                    
                    subplot(2,3,1:2)
                    imagesc(mapses.segmented)
                    freezeColors
                    hold on
                    h = scatter(AllXshift,AllYshift,'k.');
                    subplot(2,3,4:5)
                    hold on
                    hh = scatter(AllXshift,AllYshift,'k.');
                end
            end
            
            
            figure; subplot(2,3,1:2)
            imagesc(mapses.everything)
            axis square
            colormap(jet)
            freezeColors
            hold on
            h = scatter(AllXshift,AllYshift,'k.');
            
            subplot(2,3,4:5)
            imagesc(mapses.segmented)
            colormap(gray)
            axis square
            hold on
            hh = scatter(AllXshift,AllYshift,'k.');
        end
        % plots
        figure;
        imshow(histeq(referenceimage))
        hold on
        h = scatter(AllXshift,AllYshift,'k.');
        
        % Save Model with current shifts and scale
        for i = 1:length(Model.Boundaries)
            for j = 1:length(Model.Boundaries{i})
                Model.Boundaries{i}{j}(:,1)=  Model.Boundaries{i}{j}(:,1)/XScale - shiftX;
                Model.Boundaries{i}{j}(:,2)=  Model.Boundaries{i}{j}(:,2)/YScale - shiftY;
            end
        end
        Model.shiftX = shiftX;
        Model.shiftY = shiftY;
        Model.Xscale = XScale;
        Model.Yscale = YScale;
        %     Model.AllX = AllXshift;
        %     Model.AllY = AllYshift;
        %% remove:   0 < AllY/X > 800
        X = AllXshift;  Y =  AllYshift;
        indX= find(X>800);      indY= find(Y>800);
        indX2=find(X<0);        indY2= find(Y<0);
        X(indX) = [];  X(indX2) = [];   X(indY) = [];  X(indY2) = [];
        Y(indX) = [];  Y(indX2) = [];   Y(indY) = [];  Y(indY2) = [];
        %%
        Model.AllX = X;
        Model.AllY = Y;
        Model.Lambda(1) = Model.Lambda(1)/XScale-shiftX;
        Model.Lambda(2) = Model.Lambda(2)/YScale-shiftY;
        Model.Bregma(1) = Model.Bregma(1)/XScale-shiftX;
        Model.Bregma(2) = Model.Bregma(2)/YScale-shiftY;
        
        %% apply shift to Model.regions (based on shifted boundaries)
        for i = 1:length(Model.Boundaries)
            for j = 1:length(Model.Boundaries{i})
                x=Model.Boundaries{i}{j}(:,1); y = Model.Boundaries{i}{j}(:,2);
                indX= find(x>800);      indY= find(y>800);
                indX2=find(x<0);        indY2= find(y<0);
                x(indX) = [];  x(indX2) = [];   x(indY) = [];  x(indY2) = [];
                y(indX) = [];  y(indX2) = [];   y(indY) = [];  y(indY2) = [];
                Model.Regions{i} = logical(poly2mask(x, y, 800, 800));
            end
        end
        
        
        save(fullfile(storepath,mouse,'brainareamodel'),'Model')
        saveas(gcf,fullfile(storepath,mouse,'BrainAreaModel'),'fig')
        
    end
    
end
end
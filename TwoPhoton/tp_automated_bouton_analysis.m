function record = tp_automated_bouton_analysis( record)

% see tp_analyse_neurites
measures = record.measures;
ROIlist = record.ROIs.celllist;
indices = [measures.index]; %indices of all rois

axons = find([measures.axon]);
ind_axons = indices(axons);  % just the axons
Bgintensity = 0; %background density

%ObjPos = [];
for i = 1:length(axons) % over axons
    axon = axons(i);
    axoni = ind_axons(i);   %axon index number 
    boutons = find(([measures.linked2neurite]==axoni) & [measures.bouton]);
    t_boutons = find(([measures.linked2neurite]==axoni) & [measures.t_bouton]);
    axon_ints = find(([measures.linked2neurite]==axoni) & [measures.axon_int]);
    BgRoi = find([measures.bg], 1, 'first');
    if ~isempty(BgRoi)
        Bgintensity = ROIlist(BgRoi).intensity_mean(2); %green 2nd channel
        if isnan(Bgintensity)
            Bgintensity = 0;
        end
    end
   % ObjPos(i).axonidx = axoni;
   %find closest spot on axon for each bouton +and take this position as position order
   axi = ROIlist(axon).xi;
   axj = ROIlist(axon).yi;
    for j = 1:length(boutons)
        bouton = boutons(j);
        %position of this bouton
        bi = mean(ROIlist(bouton).xi);
        bj = mean(ROIlist(bouton).yi);  

        [~, posindx] = min((axi - bi).*(axi - bi) + (axj - bj).*(axj - bj));
        ROIlist(bouton).extra = posindx;
       % ObjPos(i).BoutonPos(j).pos = posindx; %position along the axon
       % plot(ROIlist(axon).xi(posindx), ROIlist(axon).yi(posindx), '*')      
    end
    %indexed position of t_boutons
    for j = 1:length(t_boutons)
        t_b = t_boutons(j);
        %position of this t_bouton
        bi = mean(ROIlist(t_b).xi);
        bj = mean(ROIlist(t_b).yi);  

        [~, posindx] = min((axi - bi).*(axi - bi) + (axj - bj).*(axj - bj));
        ROIlist(t_b).extra = posindx;  
    end
    
    %find closest spot on axon for each axon_int and take this position as position order
    for j = 1:length(axon_ints)
        ax_int = axon_ints(j);
        %position of this bouton
        ai = mean(ROIlist(ax_int).xi);
        aj = mean(ROIlist(ax_int).yi);  

        [~, posindx] = min((axi - ai).*(axi - ai) + (axj - aj).*(axj - aj));
        %ObjPos(i).AxintPos(j).pos = posindx; %position along the axon   
        ROIlist(ax_int).extra = posindx;
    end
    
    
    %now we have ordered boutons and axonints in space, take two axon ints
    %besides each bouton and calculate fractional response of bouton.
    
    if( length(axon_ints) > 1)
        if ~isempty(boutons)
            for j = 1:length(boutons)
                bouton = boutons(j);
                bp = ROIlist(bouton).extra;
                nxtb = find([ROIlist(axon_ints).extra] < bp, 1, 'last'); %next before
                nxta = find([ROIlist(axon_ints).extra] > bp, 1, 'first'); %next after
                
                if(~isempty(nxtb) && ~isempty(nxta))
                    intnxt1 = ROIlist(axon_ints(nxtb)).intensity_mean(2)-Bgintensity;
                    intnxt2 = ROIlist(axon_ints(nxta)).intensity_mean(2)-Bgintensity;
                    
                    intensity = ROIlist(bouton).intensity_mean(2)-Bgintensity;
                    measures(bouton).intensity_rel2dendrite = intensity*2/(intnxt1 + intnxt2);
                    %disp(['Axon: ' num2str(axoni) 'Bouton: ' num2str(bouton) ] )
                    
                elseif(~isempty(nxtb) || ~isempty(nxta))
                        if ~isempty(nxtb)
                            intnxt = ROIlist(axon_ints(nxtb)).intensity_mean(2)-Bgintensity;
                        else
                            intnxt = ROIlist(axon_ints(nxta)).intensity_mean(2)-Bgintensity;
                        end
                        intensity = ROIlist(bouton).intensity_mean(2)-Bgintensity;
                        measures(bouton).intensity_rel2dendrite = intensity/intnxt;
                        %disp(['Axon: ' num2str(axoni) 'Bouton: ' num2str(bouton) ] )
                else
                    disp('no relevant axon_ints to compare with!!!!')
                    
                end
            end
        else
            disp('No Boutons')
        end
        
       if ~isempty(t_boutons)
            for j = 1:length(t_boutons)
                t_b = t_boutons(j);
                bp = ROIlist(t_b).extra;
                nxtb = find([ROIlist(axon_ints).extra] < bp, 1, 'last'); %next before
                nxta = find([ROIlist(axon_ints).extra] > bp, 1, 'first'); %next after
                if(~isempty(nxtb) && ~isempty(nxta))
                    intnxt1 = ROIlist(axon_ints(nxtb)).intensity_mean(2)-Bgintensity;
                    intnxt2 = ROIlist(axon_ints(nxta)).intensity_mean(2)-Bgintensity;
                    
                    intensity = ROIlist(t_b).intensity_mean(2)-Bgintensity;
                    measures(t_b).intensity_rel2dendrite = intensity*2/(intnxt1 + intnxt2);
                   % disp(['Axon: ' num2str(axoni) 'Bouton: ' num2str(bouton) ] )
               elseif(~isempty(nxtb) || ~isempty(nxta))
                        if ~isempty(nxtb)
                            intnxt = ROIlist(axon_ints(nxtb)).intensity_mean(2)-Bgintensity;
                        else
                            intnxt = ROIlist(axon_ints(nxta)).intensity_mean(2)-Bgintensity;
                        end
                        intensity = ROIlist(t_b).intensity_mean(2)-Bgintensity;
                        measures(t_b).intensity_rel2dendrite = intensity/intnxt;
                else
                    disp('no relevant axon_ints to compare with!!!!')
                end
            end
        else
            disp('No t_boutons')
        end
        
    else
        disp('Data missing, no axon_ints')
    end
end

record.ROIs.celllist = ROIlist;
record.measures = measures;









    


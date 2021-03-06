function jc_plottransprobsummary(trnsprob_sal, trnsprob_cond, marker,linecolor,divtrns,contrns)
%trnsprob_sal from jc_find_trans_prob
%divtrns = {'bc','cd','qq'} (divergent transitions from 'b' to 'c', 'c' to
%'d', 'q' to 'q'
%convtrns = {'q'} (convergent transitions to these syllables
%for difference matrices, trnsprob_sal = {trnsprob of all saline
%conditions} and trnsprob_cond = {trnsprob of all drug conditions}, paired
%analysis with drug-saline 


%% plot transition probability changes
plottransprob = input('plot transition probability changes:','s');
if plottransprob == 'y'
    fignum = input('figure number for plotting transition prob summary:');
    figure(fignum);
    subtightplot(1,4,1,0.07,0.08,0.08);hold on;
    %plot changes in the dominant divergent transition 
    for i = 1:length(divtrns)
        postnotes = fieldnames(trnsprob_sal.(divtrns{i}).divergence);
        [~, ind] = sort(structfun(@(x) x(1),trnsprob_sal.(divtrns{i}).divergence),'descend');
        targetind = ind(1);
        x = trnsprob_sal.(divtrns{i}).divergence.(postnotes{targetind});
        if x(2) > 0.5 & x(3) < 0.5
            if strcmp(postnotes{targetind},'x')
                targetind = ind(2);
                x = trnsprob_sal.(divtrns{i}).divergence.(postnotes{targetind});
            end
        end
        mn1 = x(1);
        hi = x(2);
        lo = x(3);
        postnotes2 = fieldnames(trnsprob_cond.(divtrns{i}).divergence);
        if ~isempty(intersect(postnotes{targetind},postnotes2))
            x = trnsprob_cond.(divtrns{i}).divergence.(postnotes{targetind});
            mn2 = x(1);
            hi2 = x(2);
            lo2 = x(3);
        else
            [mn2 hi2 lo2] = [0 0 0];
        end
        mn = mn1/mn1;
        hi = mn+((hi-mn1)/mn1);
        lo = mn-((mn1-lo)/mn1);
        plot(0.5,mn,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
        mn3 = mn2/mn1;
        hi2 = mn3+((hi2-mn2)/mn1);
        lo2 = mn3-((mn2-lo2)/mn1);
        plot(1.5,mn3,marker,[1.5 1.5],[hi2 lo2],linecolor,'linewidth',1,'markersize',12);
        plot([0.5 1.5],[mn mn3],linecolor,'linewidth',1);
    end
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel('Change in probability (normalized)');
    title('Change in dominant divergent transition');

    
    %plot changes in the dominant convergent transition
    if ~isempty(contrns)
        subtightplot(1,4,2,0.07,0.08,0.08);hold on;
        for i = 1:length(contrns)
            prenotes = fieldnames(trnsprob_sal.(contrns{i}).convergence);
            [~, ind] = sort(structfun(@(x) x(1),trnsprob_sal.(contrns{i}).convergence),'descend');
            targetind = ind(1);
            x = trnsprob_sal.(contrns{i}).convergence.(prenotes{targetind});
              if x(2) > 0.5 & x(3) < 0.5
                if strcmp(prenotes{targetind},'x')
                    targetind = ind(2);
                    x = trnsprob_sal.(divtrns{i}).convergence.(prenotes{targetind});
                end
              end
            mn1 = x(1);
            hi = x(2);
            lo = x(3);
            prenotes2 = fieldnames(trnsprob_cond.(contrns{i}).convergence);
            if ~isempty(intersect(prenotes{targetind},prenotes2))
                x = trnsprob_cond.(contrns{i}).convergence.(prenotes{targetind});
                mn2 = x(1);
                hi2 = x(2);
                lo2 = x(3);
            else
                [mn2 hi2 lo2] = [0 0 0];
            end
            mn = mn1/mn1;
            hi = mn+((hi-mn1)/mn1);
            lo = mn-((mn1-lo)/mn1);
            plot(0.5,mn,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
            mn3 = mn2/mn1;
            hi2 = mn3+((hi2-mn2)/mn1);
            lo2 = mn3-((mn2-lo2)/mn1);
            plot(1.5,mn3,marker,[1.5 1.5],[hi2 lo2],linecolor,'linewidth',1,'markersize',12);
            plot([0.5 1.5],[mn mn3],linecolor,'linewidth',1);
        end
        set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
        ylabel('Change in probability (normalized)');
        title('Change in dominant convergent transition');
    end
end


%% plot divergent and convergent difference matrix
plotdiffmat = input('plot average difference matrices:','s');
if plotdiffmat == 'y'
    fignum = input('figure number for plotting difference matrices:');
    figure(fignum);hold on;
    syllables = fieldnames(trnsprob_sal{1});%all syllables
    syllables = [syllables; 'x']; 
    %divergence
    diffmat = zeros(length(syllables),length(syllables));
    for k = 1:length(trnsprob_sal)
        divmat = NaN(length(syllables),length(syllables));
        for i = 1:length(syllables)-1
            divergenttrans = trnsprob_sal{k}.([syllables{i}]).divergence;
            postnotes = fieldnames(trnsprob_sal{k}.([syllables{i}]).divergence);
            [notpostnotes ind] = setdiff(syllables,postnotes);
            divergentprobs = NaN(1,length(syllables));
            divergentprobs(ind) = 0;
            [inpostnotes ind] = intersect(syllables,postnotes);
            for m = 1:length(inpostnotes)
                divergentprobs(ind(m)) = divergenttrans.([inpostnotes{m}])(1);
            end
            divmat(:,i) = divergentprobs;
        end
        divmat2 = NaN(length(syllables),length(syllables));
        for i = 1:length(syllables)-1
            divergenttrans = trnsprob_cond{k}.([syllables{i}]).divergence;
            postnotes = fieldnames(trnsprob_cond{k}.([syllables{i}]).divergence);
            [notpostnotes ind] = setdiff(syllables,postnotes);
            divergentprobs = NaN(1,length(syllables));
            divergentprobs(ind) = 0;
            [inpostnotes ind] = intersect(syllables,postnotes);
            for m = 1:length(inpostnotes)
                divergentprobs(ind(m)) = divergenttrans.([inpostnotes{m}])(1);
            end
            divmat2(:,i) = divergentprobs;
        end
        diffmat = diffmat + (divmat2-divmat);
    end
    diffmat = diffmat./length(trnsprob_sal); 
    subtightplot(1,4,3,0.07,[0.08 0.15],0.08);hold on;
    imagesc(diffmat,[-1 1]);colormap('jet');colorbar;
    set(gca,'xtick',[1:length(syllables)],'xticklabel',syllables,'xaxislocation','top','yticklabel',syllables);
    xlabel({'Difference matrix for divergent transitions', 'From syllable:'})
    ylabel('To syllable')
    axis tight
    %convergence
    diffmat2 = zeros(length(syllables),length(syllables));
    for k = 1:length(trnsprob_sal)
        conmat = NaN(length(syllables),length(syllables));
        for i = 1:length(syllables)-1
            convergenttrans = trnsprob_sal{k}.([syllables{i}]).divergence;
            prenotes = fieldnames(trnsprob_sal{k}.([syllables{i}]).divergence);
            [notprenotes ind] = setdiff(syllables,prenotes);
            convergentprobs = NaN(1,length(syllables));
            convergentprobs(ind) = 0;
            [inprenotes ind] = intersect(syllables,prenotes);
            for m = 1:length(inprenotes)
                convergentprobs(ind(m)) = convergenttrans.([inprenotes{m}])(1);
            end
            conmat(:,i) = convergentprobs;
        end
        conmat2 = NaN(length(syllables),length(syllables));
        for i = 1:length(syllables)-1
            convergenttrans = trnsprob_cond{k}.([syllables{i}]).divergence;
            prenotes = fieldnames(trnsprob_cond{k}.([syllables{i}]).divergence);
            [notprenotes ind] = setdiff(syllables,prenotes);
            convergentprobs = NaN(1,length(syllables));
            convergentprobs(ind) = 0;
            [inprenotes ind] = intersect(syllables,prenotes);
            for m = 1:length(inprenotes)
                convergentprobs(ind(m)) = convergenttrans.([inprenotes{m}])(1);
            end
            conmat2(:,i) = convergentprobs;
        end
        diffmat2 = diffmat2 + (conmat2-conmat);
    end
    diffmat2 = diffmat2./length(trnsprob_sal);
    subtightplot(1,4,4,0.07,[0.08 0.15],0.08);hold on;
    imagesc(diffmat2,[-1 1]);colormap('jet');colorbar;
    set(gca,'xtick',[1:length(syllables)],'xticklabel',syllables,'xaxislocation','top','yticklabel',syllables);
    xlabel({'Difference matrix for convergent transitions', 'To syllable:'})
    ylabel('From syllable')
    axis tight
end


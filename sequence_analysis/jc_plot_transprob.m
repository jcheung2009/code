function jc_plot_transprob(trnsprob,marker,linecolor)
%trnsprob from jc_find_trans_prob
%plots divergence/convergence matrix
%plots 95% CI for each syllable's divergence/convergence transitions

% fignum = input('figure number for plotting transition probability data:');
% figure(fignum);
% 
% syllables = fieldnames(trnsprob); %all syllables 
% %plot divergent transitions 95% CI
% subtightplot(1,2,1,0.07,0.05,0.08);hold on;
% for i = 1:length(syllables)
%     divergenttrans = trnsprob.([syllables{i}]).divergence;
%     postnotes = fieldnames(trnsprob.([syllables{i}]).divergence);
%     for ii = 1:length(postnotes)
%         plot([i i],[divergenttrans.([postnotes{ii}])(2:3)],linecolor,...
%             i,divergenttrans.([postnotes{ii}])(1),marker,'Markersize',10);hold on;
%     end
% end
% set(gca,'xlim',[0 length(syllables)+1],'xtick',[1:length(syllables)],'xticklabel',syllables);
% xlabel('Syllables');
% ylabel('Transition Probability');
% title('Divergent probabilities for all syllables')
% 
% %plot divergent transitions 95% CI
% subtightplot(1,2,2,0.07,0.05,0.08);hold on;
% for i = 1:length(syllables)
%     convergenttrans = trnsprob.([syllables{i}]).convergence;
%     prenotes = fieldnames(trnsprob.([syllables{i}]).convergence);
%     for ii = 1:length(prenotes)
%         plot([i i],[convergenttrans.([prenotes{ii}])(2:3)],linecolor,...
%             i,convergenttrans.([prenotes{ii}])(1),marker,'Markersize',10);hold on;
%     end
% end
% set(gca,'xlim',[0 length(syllables)+1],'xtick',[1:length(syllables)],'xticklabel',syllables);
% xlabel('Syllables');
% ylabel('Transition Probability');
% title('Convergent probabilities for all syllables')

%% transition probability matrices
figure;
syllables = fieldnames(trnsprob); %all syllables 
%divergence

divmat = NaN(length(syllables),length(syllables));
for i = 1:length(syllables)
    divergenttrans = trnsprob.([syllables{i}]).divergence;
    postnotes = fieldnames(trnsprob.([syllables{i}]).divergence);
    [notpostnotes ind] = setdiff(syllables,postnotes);
    divergentprobs = NaN(length(syllables),1);
    divergentprobs(ind) = 0;
    [inpostnotes ind] = intersect(syllables,postnotes);
    for m = 1:length(inpostnotes)
        divergentprobs(ind(m)) = divergenttrans.([inpostnotes{m}])(1);
    end
    divmat(i,:) = divergentprobs;
end
divmat = divmat.*(divmat>=0.05);
g = digraph(divmat,syllables);
width = 5*g.Edges.Weight;
plot(g,'layout','circle','edgelabel',g.Edges.Weight,'linewidth',width);
% imagesc(divmat,[0 1]);colormap('hot');colorbar;
% set(gca,'xtick',[1:length(syllables)],'xticklabel',syllables,'xaxislocation','top','yticklabel',syllables);
% xlabel('Divergent transition probability from syllable:')
% ylabel('To syllable')
% axis tight
        
% subtightplot(1,2,1,0.07,0.08,0.05);hold on;
% %convergence
% subtightplot(1,2,2,0.07,0.08,0.05);hold on;
% conmat = NaN(length(syllables),length(syllables));
% for i = 1:length(syllables)
%     convergenttrans = trnsprob.([syllables{i}]).convergence;
%     prenotes = fieldnames(trnsprob.([syllables{i}]).convergence);
%     [notprenotes ind] = setdiff(syllables,prenotes);
%     convergentprobs = NaN(1,length(syllables));
%     convergentprobs(ind) = 0;
%     [inprenotes ind] = intersect(syllables,prenotes);
%     for m = 1:length(inprenotes)
%         convergentprobs(ind(m)) = convergenttrans.([inprenotes{m}])(1);
%     end
%     conmat(:,i) = convergentprobs;
% end
% g = digraph(conmat,syllables);

% imagesc(conmat,[0 1]);colormap('jet');colorbar;
% set(gca,'xtick',[1:length(syllables)],'xticklabel',syllables,'xaxislocation','top','yticklabel',syllables);
% xlabel('Convergent transition probability to syllable:')
% ylabel('From syllable')
% axis tight

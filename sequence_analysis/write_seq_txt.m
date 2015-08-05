function [] = write_seq_txt(brd,rep,alpha,beta,dir)


load([char(brd) '.alph_' num2str(alpha) '.beta_' num2str(beta) '.rep_' num2str(rep) '.bout_NRM.seq_stdp.mat'])

cd (char(dir))
for i=1:1001
    dlmwrite(['alpha_' num2str(alpha) '.beta_' num2str(beta) '.iteration.' num2str(i) '.txt'], hebbcov_seq.W{i}, 'delimiter', '\t', ...
         'precision', 6)
end

% 
% 
% for i=1:1001
%     dlmwrite(['alpha_2.beta_0.iteration.' num2str(i) '.txt'], hebb_anl.add_W{i}, 'delimiter', '\t', ...
%          'precision', 6)
% end
% 
% 
% 
% 
% for i=1:1001
%     dlmwrite(['alpha_2.beta_0.iteration.' num2str(i) '.txt'], hebb_anl.add_W{i}, 'delimiter', '\t', ...
%          'precision', 6)
% end
% 
% 
% 
% for i=1:1001
%     dlmwrite(['alpha_2.beta_1.iteration.' num2str(i) '.txt'], hebb_anl.add_W{i}, 'delimiter', '\t', ...
%          'precision', 6)
% end
% 
% 
% 
% 
% for i=1:1001
%     dlmwrite(['alpha_' num2str(hebb_anl.min_min.vals(1) '.beta_' num2str(hebb_anl.min_min.vals(2)) '.iteration  num2str(i) '.txt'], hebb_anl.add_W{i}, 'delimiter', '\t', ...
%          'precision', 6)
% end
% 
% 
% 
% for i=1:1001
%     dlmwrite(['iteration.' num2str(i) '.txt'], hebb_anl.add_W{i}, 'delimiter', '\t', ...
%          'precision', 6)
% end
% 
% 
% 

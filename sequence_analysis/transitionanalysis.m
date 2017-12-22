ff = load_batchf('batch.keep');
seq = [];
for i = 1:length(ff)
    load([ff(i).name,'.not.mat']);
    seq = [seq '-' labels];
end

id = strfind(seq,'x');
seq(id) = '';

id = strfind(seq,'abcc');
seq(bsxfun(@plus, 0:3,id')) = '1';
% removeind = [];
% removeind = [removeind strfind(seq,'a')];
% removeind = [removeind strfind(seq,'b')];
% removeind = [removeind strfind(seq,'c')];
% seq(removeind) = '';

id = strfind(seq,'deef');
seq(bsxfun(@plus, 0:3,id')) = '2';
% removeind = [];
% removeind = [removeind strfind(seq,'d')];
% removeind = [removeind strfind(seq,'e')];
% removeind = [removeind strfind(seq,'f')];;
% seq(removeind) = '';

[states,~,seq2] = unique(seq);
[transmat st] = getTransitionMatrix(seq2,1);
transmat(:,1) = [];
transmat(1,:) = [];
states = states(2:end);
removeind = find(sum(transmat)<=10);
transmat(:,removeind) = [];
transmat(removeind,:) = [];
states(removeind) = '';


transmat = transmat./sum(transmat,2);
states = arrayfun(@(x) x,states,'un',0)
transmat(transmat>=0.95)=1;
transmat(transmat<=0.05) = 0;
g = digraph(transmat,states);
width = 5*g.Edges.Weight;
figure;hold on;
plot(g,'layout','circle','linewidth',width);


labels

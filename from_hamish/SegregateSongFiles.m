load ScreenedFiles.mat

mkdir('good')
mkdir('bad')
mkdir('no');

for i=1:length(good)
    movefile(good{i},['good/' good{i}(3:end) '.wav']);
end;

% for i=1:length(no)
%     movefile(no{i},['no/' no{i} 'wav']);    
% end;

for i=1:length(bad)
    movefile(bad{i},['bad/' no{i} 'wav']);
end;


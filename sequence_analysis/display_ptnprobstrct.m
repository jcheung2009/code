function display_ptnprobstrct(ptnprobstrct)

for i = 1:length(ptnprobstrct)
    disp(['pattern: ' , char(ptnprobstrct(i).ptn)]);
    disp(['cnt: ', num2str(ptnprobstrct(i).cnt)]);
    disp(['prob: ', num2str(ptnprobstrct(i).prob)]); 
    disp(['mean count per song: ', num2str(ptnprobstrct(i).cntpersng)]);
    disp(['[]']);
end
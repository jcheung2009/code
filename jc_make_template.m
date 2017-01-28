function template = jc_make_template(batch,syll,chanspec);

[sp tm f sm] = jc_get_avn2(batch,syll,0.01,0.15,'','',chanspec,0);
h = figure;figure(h);hold on;imagesc(tm,f,log(abs(sp)));syn();

timeshft = input('time slice in seconds: ');
timeshft = find(tm >= timeshft);
template = mean(sp(1:2:256,timeshft(1)),2);
template(1:6) = 0;
template = template./max(template);

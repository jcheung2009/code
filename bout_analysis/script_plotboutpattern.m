%plot spectral and temporal bout patterns

config

ff = load_batchf('batch');
% bout_syllC1_pre = [];
% bout_syllC1_post = [];
bout_syllA_pre = [];
bout_syllA_post = [];
for i = 1:length(ff);

    cmd1 = ['load(''analysis/data_structures/bout_syllA_',ff(i).name,''')'];
    cmd2 = ['load(''analysis/data_structures/bout_syllC1_',ff(i).name,''')'];
    eval(cmd1);
    eval(cmd2);
    
    if ~isempty(strfind(ff(i).name,'pre'))
        bout_syllA_pre = [bout_syllA_pre eval(['bout_syllA_',ff(i).name])];
%         bout_syllC1_pre = [bout_syllC1_pre eval(['bout_syllC1_',ff(i).name])];
    elseif ~isempty(strfind(ff(i).name,'post'))
        bout_syllA_post = [bout_syllA_post eval(['bout_syllA_',ff(i).name])];
%         bout_syllC1_post = [bout_syllC1_post eval(['bout_syllC1_',ff(i).name])];
    end
end

fig1 = 1;
fig2 = 2;
fig3 = 3;
fig4 = 4;
fig5 = 5;
jc_plotboutpattern(bout_syllA_pre,'ok','k','syllA',fig1,fig2,fig3);
jc_plotboutpattern(bout_syllA_post,'or','r','syllA',fig1,fig2,fig3);
% jc_plotboutpattern(bout_syllC1_pre,'ok','k','c',fig4,fig5,'');
% jc_plotboutpattern(bout_syllC1_post,'or','r','c',fig4,fig5,'');
% ff = load_batchf('batch');
% daycnt = 1;
% figure;
% h = subtightplot(3,1,1,0.07,0.08,0.15);hold on;
% h2 = subtightplot(3,1,2,0.07,0.08,0.15);hold on;
% h3 = subtightplot(3,1,3,0.07,0.08,0.15);hold on;
% for i = 1:length(ff)
%     if ~isempty(strfind(ff(i).name,'saline'))
%         mcolor = 'k';
%         mrk = 'ok';
%     else
%         mcolor = 'r';
%         mrk = 'or';
%     end
%     
%     cmd1 = ['load(''analysis/data_structures/fv_syllA_',ff(i).name,''')'];
%     eval(cmd1);
%     cmd2 = ['mBootstrapCI([fv_syllA_',ff(i).name,'(:).mxvals])'];
%     [hi lo mn] = eval(cmd2);
%     plot(h,[daycnt daycnt],[hi lo],mcolor,'linewidth',2);hold on;
%     plot(h,daycnt,mn,mrk,'MarkerSize',4);hold on;
%     
%     cmd3 = ['mBootstrapCI([fv_syllA_',ff(i).name,'(:).maxvol])'];
%     [hi lo mn] = eval(cmd3);
%     plot(h2,[daycnt daycnt],[hi lo],mcolor,'linewidth',2);hold on;
%     plot(h2,daycnt,mn,mrk,'MarkerSize',4);hold on;
%     
%     cmd4 = ['mBootstrapCI_CV([fv_syllA_',ff(i).name,'(:).mxvals])'];
%      [mn hi lo] = eval(cmd4);
%     plot(h3,[daycnt daycnt],[hi lo],mcolor,'linewidth',2);hold on;
%     plot(h3,daycnt,mn,mrk,'MarkerSize',4);hold on;
%     
%     daycnt = daycnt+1;
% end
% title(h,'Mean pitch with CI');
% xlabel(h,'Day');
% ylabel(h,'Frequency (Hz)');
% 
% title(h2,'Mean volume with CI');
% xlabel(h2,'Day');
% ylabel(h2,'Amplitude');
% 
% title(h3,'Mean pitch CV with CI');
% xlabel(h3,'Day');
% ylabel(h3,'CV');

 ff = load_batchf('batch2');
 xpt = 3.5;
 marker = 'ro';
 linecolor = 'r';
 fignum = input('figure number for plotting repeat:');
 figure(fignum);hold on;
 for i = 1:length(ff)
     cmd1 = ['load(''analysis/data_structures/fv_repB_',ff(i).name,''')'];
    eval(cmd1);
    cmd2 = ['runlength=[fv_repB_',ff(i).name,'(:).runlength];']
    eval(cmd2);
    jitter = (-1+2*rand)/20;
    xpt = xpt+jitter;
    plot(xpt,mean(runlength),marker,[xpt xpt],[mean(runlength)+std(runlength),...
        mean(runlength)-std(runlength)],linecolor,'linewidth',1,'markersize',12);hold on;
 end
 set(gca,'xlim',[0 4],'xtick',[0.5,1.5,2.5,3.5],'xticklabel',{'probe 1','probe 2','probe 3','probe 4'});
ylabel('Repeat length');


%rewritten to ploy control note as well.

%inactiv_fig2script.m
%main panel is made with call to plothists, and call to plotline.

%raw data panel is made with calls to inactivplotoneday.m
%top pael pulled off illustrator file.
%to make acsf day 1, target note.
%ps is short for plotstruct.
col{1}=[0 0 0]
col{2}=[0 0 0]
col{3}=[0.4 0.4 1]
col{4}=[0.4 0.4 1]

figure;
clear ps;
ps.ax=subplot(1,8,7:8);
ps.marksize=14;
ps.rawvl='adj';
ps.ntvl=2;
ps.indtoplot=6;
ps.col=col;

hs(1).ax=subplot(1,8,1:6);

hs(3).ax=subplot(1,8,1:6);
hs(2).ax=subplot(1,8,1:6);
hs(4).ax=subplot(1,8,1:6);

hs(1).ls='-'
hs(2).ls='--'
hs(3).ls='-'
hs(4).ls='-';

for ii=1:4
    hs(ii).wid=[2];
    hs(ii).orient=['flip'];
    hs(ii).ntvl=ps.ntvl;
    hs(ii).col=col{ii};
    hs(ii).lw=2;
    hs(ii).plothist=1;
end

%assign hstvals for plot
% loadsumdata(bs,2);
hs=gethsts(hs, 6,avls);
hs=getedges(hs,6,avls);
hs(1).marklnht=.65;
hs(2).marklnht=.75;
hs(3).marklnht=.7;
 hs(1).markht=hs(1).marklnht
hs(2).markht=hs(2).marklnht
hs(3).markht=hs(3).marklnht
 %hs(4).hst is the baseline plot from the previous day.
hsorig=gethsts(hs,4, avls);

hs(4)=hsorig(1);
hs(4).edges=hs(3).edges;
inactiv_rawpoints(avls,graphvals,ps);
plothists(hs);

% set up the final panel
exps.plotextraline=1;
exps.indtoplot=10;
exps.ntind=1;
exps.col={[0 0 0]  [0 0 0]  [0.4000 0.4000 1]  [0.4000 0.4000 1]}
exps.runtype='ex'
exps.birdind=2
exps.ax=subplot(1,8,7:8);

inactivplotcomparsingle(avls,exps,bs)



linkaxes([hs(1:4).ax, ps.ax],'y'); 


%plot scale bar
% axes(exps.ax);
% plot([.49 .51], [6300 6300],'Linewidth',5,'color','k');
% % axis off;
% axes(hs(4).ax)
% axis off;
% axes(exps.ax)
% axis([0.49 0.51 6300 7150])
% plot([.49 .51], [avls.initmean{1} avls.initmean{1}],'Linestyle','--','Linewidth',2,'color','k');

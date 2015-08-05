% written 4.14.09
%this script takes two bs inds,
%to create ap5 histograms.
% #
% ap5_bsinds

%eventually calls plothists2,
%for each of four histograms

%with structure hs
% axes(hs(hnm).ax);
%         edg=hs(hnm).edges;
%         vls=hs(hnm).hst;
%         col=hs(hnm).col;
%         ls=hs(hnm).ls;
%         wid=hs(hnm).wid'

%eight histograms in total.

%four baseline (two acsf, two inactivate)
%hs 1:4 are for bird 1.
%hs 5:8 are for bird 2.

%SCALE TO Z-SCORE



bsinds=[9 10]
ax(1)=subplot(121);
ax(2)=subplot(122);

axind=[1 1 2 2 1 1 2 2];

colinds=[1 0 1 0 1 0 1 0]

avlsind=[1 1 1 1 2 2 2 2];
acvec=[1 2 1 2 1 2 1 2]

for ii=1:length(axind)
    hs(ii).axind=axind(ii);
end

for ii=1:length(colinds)
    hs(ii).col=colinds(ii);
    hs(ii).acvec=acvec(ii);
end

for ii=1:length(avlsind)
    hs(ii).avlsind=avlsind(ii);
end

for ii=1:length(bsind)
    [avls(ii),graphvals{ii}]=loadsumdata(bs, bsind(ii))
    hs(ii).ntvl=bs(bsind(ii)).ntind;
    
end

%need to set initmean

for ii=1:length(axind);
    hs(ii)=gethstcomb3(hs(ii),avls,1)
    hs(ii).plothist=1
    hs(ii).wid=[2];
    hs(ii).horline=0;
    hs(ii).orient=['flip'];
    
    hs(ii).lw=3;
    hs(ii).ls='-'
end

plothists2(hs);

%also create a linestruct which plot 18 lines, one for each acsf/mu run.
%each line needs a color
% lns(ii).col
% ls(ii).ax
% ls(ii).ypts
% ls(ii).xpts
% ls(ii).lw
% ls(ii).ls

%call plotlines2
%count up axes
%first set up the initial 12 structures.

% colvec=[1 2 1 1 2 1 1 2 1 1 2 1 3 1 3 1]
% axvec= [1 1 1 3 3 3 4 4 4 6 6 6 2 2 5 5]
% vlsvec=[4 5 6 9 10 12 4 5 6 9 10 12 4 9 4 9]
% ntvec= [1 1 1 1 1 1 2 2 2 2 2 2 1 1 2 2]

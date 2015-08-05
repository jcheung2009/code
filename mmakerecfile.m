function mmakerecfile(datfile)
%
%
% mmakerecfile(datfile)
% creates .rec file for wav files that aren't written with one
%
%

[dat fs] = wavread(datfile);

[pathstr,fn,ext] = fileparts(datfile);

recdata =  struct('header',{{'header space' '' '' '' ''}},'adfreq',fs,'nchan',1,...
    'nsamp',length(dat),'iscatch',0,'outfile','','tbefore',2,'tafter',2,...
    'thresh',4.9,'ttimes',[],'catch',[]);

wrtrecf(datfile,recdata,0);
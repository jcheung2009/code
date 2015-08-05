%designed to call pitchsyntaxanal, and then inactivanal.m

sumpath='/doyale2/twarren/bk68b82/'
strcmd=['cd ' sumpath]
eval(strcmd);
if (~exist('datasum','dir'))
    !mkdir datasum
end
matfilename='pathvals1'

extractvals=1

clear pathvl vals
pathvl{1}='/doyale2/twarren/bk68b82/screen1/'
catchvl{1}='batch26dir'
pathvl{2}='/doyale2/twarren/bk68b82/screen1/'
catchvl{2}='batch29dir'
pathvl{3}='/doyale2/twarren/bk68b82/screen1/'
pathvl{4}='/doyale2/twarren/bk68b82/screen1/'

catchvl{3}='batch26.keep.rand'
catchvl{4}='batch29.keep.rand'

pathvl{5}='/doyale2/twarren/bk68b82/muon041007-1//'
catchvl{5}='batch.keep'
pathvl{6}='/doyale2/twarren/bk68b82/muon041007-2/'
catchvl{6}='batch.keep'
pathvl{7}='/doyale2/twarren/bk68b82/acon041007-1/'
catchvl{7}='batch.keep'
pathvl{8}='/doyale2/twarren/bk68b82/probeinacsf100907/'
catchvl{8}='batch.keep'
pathvl{9}='/doyale2/twarren/bk68b82/muon100907/'
catchvl{9}='batch.keep'
pathvl{12}='/doyale2/twarren/bk68b82/wna3/'
catchvl{12}='batch.catch.keep'
pathvl{13}='/doyale2/twarren/bk68b82/wna3/'
catchvl{13}='batch17.catch.keep'
pathvl{10}='/doyale2/twarren/bk68b82/wnatest/'
catchvl{10}='batch14.keep'


pathvl{11}='/doyale2/twarren/bk68b82/wnatest/'
catchvl{11}='batch15comb.keep'


usex(1:13)=0
numnotes=2
notes='ab'


tbinshft(1)=0.015;
tbinshft(2)=0.015;
NFFT(1)=1024
NFFT(2)=1024;%number of data points to FFTstrcmd=strcat('!cd ' dir{i})
fbins{1}=[2000,3000];
fbins{2}=[3000 4000]
     NT{1}='a';PRENT{1}='';PSTNT{1}='';
    NT{2}='b';PRENT{2}='-';PSTNT{2}='b';


   
  %%%plotvals
  
muon=[5 6 9]
acon=[3 4 7 8 10 11 12 13]
diron=[1 2]
colvals{1}=diron;
colvals{2}=muon
colvals{3}=acon;

graphvals.numcol=3
graphvals.col='rmk'
graphvals.plttext=1
graphvals.txtht=[3260 3200]
graphvals.colvals=colvals
graphvals.pltpnts=1



avls.pvls=pathvl
avls.datfile=matfilename;
avls.cvl=catchvl
avls.sumpath=sumpath
avls.mtflnm=matfilename  
avls.supanal=0
avls.NT=NT
avls.NFFT=NFFT
avls.fbins=fbins
avls.tshft=tbinshft
avls.usex=usex
avls.numnotes=numnotes
avls.mkfv=[1:13]
avls.PRENT=PRENT
avls.PSTNT=PSTNT
avls.bnds{1}='2007-09-20 07:00:00'
avvls.bnds{2}='2007-10-20 07:00:00'

strcmd=['cd ' sumpath 'datasum']
eval(strcmd)

strcmd=['save ' matfilename '.mat avls graphvals'];
eval(strcmd);



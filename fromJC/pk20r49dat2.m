%designed to call pitchsyntaxanal, and then inactivanal.m

sumpath='/doyale2/twarren/pk20r49/'
strcmd=['cd ' sumpath]
eval(strcmd);
if (~exist('datasum','dir'))
    !mkdir datasum
end
matfilename='pathvals1'

extractvals=1




pathvl{3}='/doyale2/twarren/pk20r49/ac260108/'
catchvl{3}='batch.keep27'

pathvl{4}='/doyale2/twarren/pk20r49/200mu70108/'
catchvl{4}='batch.keep'

timon{4}='10:06:00'
timoff{4}='14:17:00'
date{4}='2008-01-27'

pathvl{5}='/doyale2/twarren/pk20r49/wnon/'
catchvl{5}='batch29.catch.keep'

pathvl{6}='/doyale2/twarren/pk20r49/200muampoff13008/'
catchvl{6}='batch.keep'
timon{6}='15:06:00'
timoff{6}='19:03:00'
date{6}='2008-01-30'

pathvl{7}='/doyale2/twarren/pk20r49/acampoff_300108/'
catchvl{7}='batch.catch30'

pathvl{8}='/doyale2/twarren/pk20r49/200muampon1.31.08/'
catchvl{8}='batch.catch'
timon{8}='15:41:00'
timoff{8}='19:41:00'
date{8}='2008-01-31';

pathvl{9}='/doyale2/twarren/pk20r49/acampon13108-3/'
catchvl{9}='batch.catch.keep'

pathvl{10}='/doyale2/twarren/pk20r49/acampon13108-4/'
catchvl{10}='batch01.catch'

pathvl{11}='/doyale2/twarren/pk20r49/acsf_ampon3/'
catchvl{11}='batch.catch'

pathvl{13}='/doyale2/twarren/pk20r49/acsf_ampon2/'
catchvl{13}='batch.train.catch'

pathvl{14}='/doyale2/twarren/pk20r49/200muampon202008/'
catchvl{14}='batch.train.catch'
timon{14}='12:33:00'
timoff{14}='16:34:00'
date{14}='2008-02-02'

pathvl{15}='/doyale2/twarren/pk20r49/probeout20408/'
catchvl{15}='batch.catch'

pathvl{16}='/doyale2/twarren/pk20r49/probein20408/'
catchvl{16}='batch.catch'


pathvl{17}='/doyale2/twarren/pk20r49/200mu20508/'
catchvl{17}='batch.catch'

timon{17}='10:48:00'
timoff{17}='15:05:00'
date{17}='2008-02-05'


pathvl{26}='/doyale2/twarren/pk20r49/acampon210/'
catchvl{26}='batch.catch.keep12'

pathvl{27}='/doyale2/twarren/pk20r49/300mu21208/'
catchvl{27}='batch.catch'

timon{27}='10:35:00'
timoff{27}='14:31:00'
date{27}='2008-02-12'



pathvl{28}='/doyale2/twarren/pk20r49/ac21208ampon/'
catchvl{28}='batch.catch'

pathvl{29}='/doyale2/twarren/pk20r49/acampon13108-4/'
catchvl{29}='batch02.catch'


date{29}=''
% timon{6}='15:06:00'
% timoff{6}='19:03:00'
% date{6}='2008-01-30'


usex(1:29)=0;
avls.analind=[1:29]

numnotes=3
notes='a'

fbins={};
tbinshft{1}=0.02;
% tbinshft{2}=0.015
% tbinshft{3}=0.015
NFFT(1)=512
% NFFT(2)=512
% NFFT(3)=512

fbins{1}=[3000,4000];
% fbins{2}=[3000,4000];
% fbins{3}=[3000,4000];

clear NT    
NT{1}='a'
% NT{2}='f'
% NT{3}='g'

PRENT{1}='';PSTNT{1}='';
PRENT{2}='';PSTNT{2}='';
PRENT{3}='';PSTNT{3}='';
   
  %%%plotvals
muon=[1 4 6 8 14 17 19 24 25 27];  
acon=[2 3 5 7 9 10 11 12 13 15 16 18 20 21 22 23 26 28 29 ]
diron=[]
extraon=[]

clear colvals
colvals{1}=muon;
colvals{2}=acon

graphvals.numcol=2
graphvals.col='rk'
graphvals.plttext=1
graphvals.txtht=[3260 3200]
graphvals.edges=[3000:50:4000]
graphvals.colvals=colvals
graphvals.pltpnts=1

graphvals.timon=timon;
graphvals.timoff=timoff;
graphvals.date=date;
graphvals.colvals=colvals
graphvals.chunkdata=1

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
avls.mkfv=[7]
avls.PRENT=PRENT
avls.PSTNT=PSTNT
avls.repeatanal=[0 0 0]
avls.bnds{1}='2007-09-20 07:00:00'
avvls.bnds{2}='2007-11-20 07:00:00'
avls.offset=2;

strcmd=['cd ' sumpath 'datasum']
eval(strcmd)

strcmd=['save ' matfilename '.mat avls graphvals'];
eval(strcmd);



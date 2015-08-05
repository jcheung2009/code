%designed to call pitchsyntaxanal, and then inactivanal.m
clear date edges PRENT PSTNT tbinshft
clear avls
clear ac wn
clear graphvals
clear tmn;clear tmf fv fvtmp
sumpath='/oriole4/pk32bk28/'
strcmd=['cd ' sumpath]
eval(strcmd);
if (~exist('datasum','dir'))
    !mkdir datasum
end
matfilename='pathvals3'
clear pathvl vals wn;

avls.initmean{1}=7247
avls.initsd{1}=91
avls.initmean{2}=2200;
avls.initsd{2}=100;
avls.initmean{3}=1561;
avls.initsd{3}=43.3;
%%%TKTK
% wn{1}.freqlo=[6000 7280]
% wn{2}.freqhi=[7430 6000]

wn(1).tmon{1}={'2008-5-01 7' '2008-5-07 7'}

wn(1).tmon{2}={'2008-05-26 7' '2008-05-29 7'}
wn(1).tmoff{1}={'2008-05-07 7' '2008-5-13 7'}
wn(1).tmoff{2}={'2008-05-29 7' '2008-06-04 7'}

wn(2).tmon=wn(1).tmon;
wn(2).tmoff=wn(1).tmon;

wn(3).tmon=wn(1).tmon;
wn(3).tmoff=wn(1).tmoff;


pathvl{1}='/oriole4/pk32bk28/probein/'
catchvl{1}='batch.keep';tmn{1}=['7'];tmf{1}=['12:09'];

pathvl{2}='/oriole4/pk32bk28/ac427/'
catchvl{2}='batch.keep.rand';tmn{2}=['15:08'];tmf{2}=['21:00'];

pathvl{3}='/oriole4/pk32bk28/lid427/'
catchvl{3}='batch.keep'
tmn{3}='12:09:00'
tmf{3}='15:08:00'

pathvl{4}='/oriole4/pk32bk28/wnon428/'
catchvl{4}='batch02.catch';tmn{4}=['7'];tmf{4}=['12:29'];

pathvl{5}='/oriole4/pk32bk28/ac502/'
catchvl{5}='batchcomb.catch';tmn{5}=['16:32'];tmf{5}=['21'];

pathvl{6}='/oriole4/pk32bk28/lid502/'
catchvl{6}='batch.catch.keep'
tmn{6}='12:29:00'
tmf{6}='16:32:00'

pathvl{7}='/oriole4/pk32bk28/lid504/'
catchvl{7}='batchcomb'
tmn{7}='10:49:00'
tmf{7}='14:15:00'

pathvl{8}='/oriole4/pk32bk28/ac504/'
catchvl{8}='batch04.catch.keep';tmn{8}=['14:15'];tmf{8}=['21'];

pathvl{9}='/oriole4/pk32bk28/ac504/'
catchvl{9}='batch06.catch.keep';tmn{9}=['7'];tmf{9}=['11:59'];

pathvl{10}='/oriole4/pk32bk28/lid506/'
catchvl{10}='batchcomb'
tmn{10}='11:59:00'
tmf{10}='15:51:00'

pathvl{11}='/oriole4/pk32bk28/lid508/'
catchvl{11}='batchcomb'
tmn{11}='11:23:00'
tmf{11}='14:31:00'

pathvl{12}='/oriole4/pk32bk28/ac506/'
catchvl{12}='batchcomb08';tmn{12}=['7'];tmf{12}=['11:23'];

pathvl{13}='/oriole4/pk32bk28/ac508/'
catchvl{13}='batch10.catch.keep';tmn{13}=['7'];tmf{13}=['11:19'];

pathvl{14}='/oriole4/pk32bk28/ac502/'
catchvl{14}='batch04.catch.keep';tmn{14}=['7'];tmf{14}=['10:49'];

pathvl{15}='/oriole4/pk32bk28/ac508/'
catchvl{15}='batch08comb';tmn{15}=['14:31'];tmf{15}=['21'];

pathvl{16}='/oriole4/pk32bk28/lid510/'
catchvl{16}='batchcomb.catch'
tmn{16}='11:19:00'
tmf{16}='14:23:00'


pathvl{19}='/oriole4/pk32bk28/ac510/'
catchvl{19}='batch10comb.catch';tmn{19}=['14:23'];tmf{19}=['21'];

pathvl{20}='/oriole4/pk32bk28/ac510/'
catchvl{20}='batch12comb';tmn{20}=['7'];tmf{20}=['11:34'];

pathvl{21}='/oriole4/pk32bk28/lid512/'
catchvl{21}='batchcomb2'
tmn{21}='11:34:00'
tmf{21}='14:49:00'

pathvl{22}='/oriole4/pk32bk28/ac512revcontin/'
catchvl{22}='batch14';tmn{22}=['7'];tmf{22}=['15:00'];

pathvl{23}='/oriole4/pk32bk28/lid514/'
catchvl{23}='batchcomb'
tmn{23}='15:00:00'
tmf{23}='18:01:00'

pathvl{24}='/oriole4/pk32bk28/ac514/'
catchvl{24}='batch14.keep'
tmn{24}='18:01';tmf{24}='21';

pathvl{25}='/oriole4/pk32bk28/500mu515/'
catchvl{25}='batch'
tmn{25}='14:23:00'
tmf{25}='17:55:00'

pathvl{26}='/oriole4/pk32bk28/ac515ampoff/'
catchvl{26}='batch.keep.rand';tmn{26}=['7'];tmf{26}=['14:23'];

pathvl{27}='/oriole4/pk32bk28/ac515/'
catchvl{27}='batch15.keep';tmn{27}=['17:55'];tmf{27}=['21'];

pathvl{28}='/oriole4/pk32bk28/ac515/'
catchvl{28}='batch18.keep.rand';tmn{28}=['7'];tmf{28}=['13:13'];

pathvl{29}='/oriole4/pk32bk28/500mu518/'
catchvl{29}='batch'
tmn{29}='13:13:00'
tmf{29}='17:13:00'

pathvl{30}='/oriole4/pk32bk28/ac528/'
catchvl{30}='batch28.keep'
tmn{30}='16:29';tmf{30}='21'

pathvl{31}='/oriole4/pk32bk28/wnon521/'
catchvl{31}='batch28.keep.rand'
tmn{31}='7';tmf{31}='13:26'

pathvl{32}='/oriole4/pk32bk28/500mu528/'
catchvl{32}='batchcomb';tmn{32}='13:26';tmf{32}='16:29'

pathvl{33}='/oriole4/pk32bk28/ac529newtemp/'
catchvl{33}='batch31.keep.rand'
tmn{33}='7'
tmf{33}='15:50'

pathvl{34}='/oriole4/pk32bk28/500mu531/'
catchvl{34}='batch.keep'
tmn{34}='15:50';tmf{34}='19:35'

pathvl{35}='/oriole4/pk32bk28/ac531/'
catchvl{35}='batch31.keep'
tmn{35}=['19:35'];tmf{35}='21'

% pathvl{35}='/oriole4/pk32bk28/ac531/'
% catchvl{35}='batch03.keep.rand'
% tmn{35}=['7'];tmf{35}='12'

pathvl{36}='/oriole4/pk32bk28/ac531/'
catchvl{36}='batch03.keep.rand'
tmn{36}='7';tmf{36}='11:57'

pathvl{37}='/oriole4/pk32bk28/500mu6308/'
catchvl{37}='batch.keep'
tmn{37}='11:57';tmf{37}='18:00'


pathvl{38}='/oriole4/pk32bk28/500mu6608/'
catchvl{38}='batch.keep'
tmn{38}=['12:30'];tmf{38}='19'

pathvl{39}='/oriole4/pk32bk28/ac60508newtemp/'
catchvl{39}='batch.keep'
tmn{39}=['7'];tmf{39}='12:30'






%how to deal with dirfiles -- put all in one directory.
pathvl{40}='/oriole4/pk32bk28/dirfiles/'
catchvl{40}='batch.keep'
tmn{40}='7'
tmf{40}='21'
pathvl{41}='/oriole4/pk32bk28/wnon428/'
catchvl{41}='batchdir'
tmn{41}='7'
tmf{41}='21'

pathvl{42}='/oriole4/pk32bk28/ac506/'
catchvl{42}='batchcomb06'
tmn{42}='15:51'
tmf{42}='21'


pathvl{43}='/oriole4/pk32bk28/ac512/'
catchvl{43}='batchcomb12'
tmn{43}='14:49'
tmf{43}='21'

pathvl{44}='/oriole4/pk32bk28/ac518/'
catchvl{44}='batch18.keep'
tmn{44}='17:13'
tmf{44}='21'

pathvl{45}='/oriole4/pk32bk28/ac6308/'
catchvl{45}='batch03.keep'
tmn{45}='18'
tmf{45}='21'

pathvl{46}='/oriole4/pk32bk28/ac60608/'
catchvl{46}='batch06'
tmn{46}='19'
tmf{46}='21'




usex(1:41)=0;



ac(42)=[0];
avls.analind=[1:42]

numnotes=1
notes='abc'

fbins={};
tbinshft{1}=0.02;
tbinshft{2}=0.02;
tbinshft{3}=0.025;  

NFFT(1)=512
NFFT(2)=512
NFFT(3)=256;
 

fbins{1}=[6800,8000];
fbins{2}=[2000,2500];
 fbins{3}=[1300,1800];
avls.edges{1}=[6000:100:8000]
avls.edges{2}=[2000:100:2500]
avls.edges{3}=[1300:100:1800]


clear NT    
NT{1}='a'
NT{2}='b'
NT{3}='c'

PRENT{1}='';PSTNT{1}='';
PRENT{2}='';PSTNT{2}='';
PRENT{3}='';PSTNT{3}='';


  %%%plotvals
acon=[ 1 2 4 5 8 9 12 13 14 15 19 20 22 24 26 27 28 30 31 33 35 36 39 42 43 44 45 46] ;  
muon=[3 6 7 10 11 16 21 23 25 29 32 34 37 38]
avls.muanal{1}{1}=[3 6 7 10 11 16 21]
avls.muanal{1}{2}=[32 34 37 38]
avls.revanal{1}{1}=[23 25]
avls.maxmeans=[7515 7083]
diron=[40 41]
extraon=[]

clear colvals
colvals{1}=muon;
colvals{2}=acon
colvals{3}=diron;

graphvals.numcol=3
graphvals.col='rkc'
% graphvals.plttext=1
% graphvals.txtht=[3260 3200]
% graphvals.tickht=8000
% graphvals.edges{1}=[6700:80:7900]
% graphvals.edges{2}=[2000:40:2500]
% graphvals.edges{3}=[1300:40:1800]
% graphvals.colvals=colvals
% graphvals.pltpnts=1

avls.sumpath=sumpath;
avls.tmon=tmn;
avls.tmoff=tmf;
graphvals.tmn=tmn;
graphvals.tmf=tmf;
graphvals.acon=ac;
graphvals.date=date;
graphvals.wn=wn;

graphvals.colvals=colvals
graphvals.chunkdata=1

avls.usex=usex
avls.diron=diron;
avls.pvls=pathvl
avls.datfile=matfilename;
avls.cvl=catchvl
avls.sumpath=sumpath
avls.mtflnm=matfilename  
avls.supanal=0
avls.NT=NT
avls.acon=acon;
avls.muon=muon;
avls.NFFT=NFFT
avls.fbins=fbins
avls.tshft=tbinshft
avls.numnotes=numnotes
avls.pretm=3;
avls.mkfv=[4:6 ]
avls.PRENT=PRENT
avls.PSTNT=PSTNT
avls.repeatanal=[0 0 0]
avls.bname='pk32bk28-2'
% avls.edges=edges;
avls.deadtm=.0833/24;
avls.pretm=3/24;
avls.muoffset=1/24;
avls.acoffset=1/24;
avls.exclude=[1 1 1];
avls.changenote=0;

strcmd=['cd ' sumpath 'datasum']
eval(strcmd)

strcmd=['save ' matfilename '.mat avls graphvals'];
eval(strcmd);



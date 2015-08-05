%designed to call pitchsyntaxanal, and then inactivanal.m

sumpath='/doya2/bk28w6/'
strcmd=['cd ' sumpath]
eval(strcmd);
if (~exist('datasum','dir'))
    !mkdir datasum
end
matfilename='pathvals1'

extractvals=1

clear pathvl vals
pathvl{1}='/doya2/bk28w6/screen/'
catchvl{1}='batch.keep.rand'
pathvl{2}='/doya2/bk28w6/temptest2/'
catchvl{2}='batch.keep.rand'
pathvl{3}='/doya2/bk28w6/wnon/'
catchvl{3}='batchcomb'
pathvl{4}='/doya2/bk28w6/postimplant/'
catchvl{4}='batch.keep.catch'
timind{5}='15:00:00 18:58:00'
date{5}='2007-11-09'
pathvl{5}='/doya2/bk28w6/mu20010907-2/'
catchvl{5}='batch.keep'
pathvl{6}='/doya2/bk28w6/probein/'
catchvl{6}='batch.keep'
pathvl{7}='/doya2/bk28w6/ac20010907/'
catchvl{7}='batch.keep'
pathvl{8}='/doya2/bk28w6/ac109007-2/'
catchvl{8}='batch.keep.rand'

 pathvl{9}='/doya2/bk28w6/ac111007_ampon/'
catchvl{9}='batch2'

%on at 817, off at 1355
timon{10}='08:17:00'
timoff{10}='13:55:00'
date{10}='2007-11-13'

pathvl{10}='/doya2/bk28w6/mu111307_ampon/'
catchvl{10}='batch.catch.keep'

%don't analyze, it's redundant.
pathvl{11}='/doya2/bk28w6/ac111007/'
 catchvl{11}='batch.rand.keep'


pathvl{12}='/doya2/bk28w6/screen/'
catchvl{12}='batch31dir'




pathvl{13}='/doya2/bk28w6/ac111307_ampon/'
catchvl{13}='batch13.keep.catch'
%on at 906, off at 1344

timon{14}='09:06:00'
timoff{14}='13:44:00'
date{14}='2007-11-14'

pathvl{14}='/doya2/bk28w6/mu250_11407_ampon/'
catchvl{14}='batch'

pathvl{15}='/doya2/bk28w6/temp/ac111007_ampon/'
catchvl{15}='batch13.keep'

pathvl{16}='/doya2/bk28w6/ac111307_ampon/'
catchvl{16}='batch14.keep'
pathvl{17}='/doya2/bk28w6/ac111407ampon/'
catchvl{17}='batch2.catch'
%on at 930, off at 1341


timon{15}='09:30:00'
timoff{15}='13:41:00'
date{15}='2007-11-15'
timon{16}=timon{15}
timon{17}=timon{15}
date{16}='2007-11-16';
date{17}='2007-11-17'

pathvl{18}='/doya2/bk28w6/mu500_11507_ampon/'
catchvl{18}='batch.catch'
pathvl{19}='/doya2/bk28w6/ac11507ampon/'
catchvl{19}='batch.keep.catch'
pathvl{20}='/doya2/bk28w6/ac11507ampon/'
catchvl{20}='batch16.keep.catch.rand'
pathvl{21}='/doya2/bk28w6/ac11507ampon/'
catchvl{21}='batch17.keep.catch.rand'
pathvl{22}='/doya2/bk28w6/acprobein1128/'
catchvl{22}='batch.keep.rand'
pathvl{23}='/doya2/bk28w6/acprobein1128/'
catchvl{23}='batch30.keep.rand'

pathvl{24}='/doya2/bk28w6/mu200_113007/'
catchvl{24}='batch.keep.rand'

pathvl{25}='/doya2/bk28w6/ac11307/'
catchvl{25}='batch'

pathvl{26}='/doya2/bk28w6/mu500120107/'
catchvl{26}='batch'


%these are the extra labels for z and m

pathvl{27}='/doya2/bk28w6/mu111307_ampon/'
catchvl{27}='batch.keep.notcatch'


pathvl{28}='/doya2/bk28w6/mu250_11407_ampon/'
catchvl{28}='batch.keep.notcatch'

pathvl{29}='/doya2/bk28w6/mu500_11507_ampon/'
catchvl{29}='batch.keep.notcatch'

usex(1:29)=0;
avls.analind=[1:29]

numnotes=1
notes='b'

fbins={};
tbinshft{1}=0.1;
tbinshft{2}=.015
NFFT(1)=512
NFFT(2)=1024
fbins{1}=[2100,2900];
    
fbins{2}=[6000 8000]
fbins{3}=[2100 2900]

clear NT    
NT{1}='b'
NT{2}='a'




PRENT{1}='';PSTNT{1}='';
PRENT{2}='-';PSTNT{2}='a'


   
  %%%plotvals
muon=[5 10  14 18 24 26];  
acon=[1:4 6:9  11 13 15 16 17 19 20 21 22 23 25]
diron=[12]
extraon=[27 28 29]

colvals{1}=diron;
colvals{2}=muon
colvals{3}=acon;
colvals{4}=extraon;

graphvals.numcol=4
graphvals.col='rmkb'
graphvals.plttext=1
graphvals.txtht=[3260 3200]
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
avls.mkfv=[]
avls.PRENT=PRENT
avls.PSTNT=PSTNT
avls.repeatanal=[0 1]
avls.bnds{1}='2007-09-20 07:00:00'
avvls.bnds{2}='2007-11-20 07:00:00'

strcmd=['cd ' sumpath 'datasum']
eval(strcmd)

strcmd=['save ' matfilename '.mat avls graphvals'];
eval(strcmd);



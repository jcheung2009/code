%this script is written to generate pitch contours for bk57w35
%writes data to a .mat file in directory where data is.

%YOU NEED TO SET MUINDS BELOW
%calls jc_pitchcontourFV, in ~/matlab
%      maketimevec2
clear fv fbins bt smoothamp baspath conbins avls

avls.baspath='/oriole2/bk57w35evren/bk57w35/'
avls.datdir='datasum'
CHANGELABEL=0;


% 8-30 off
wnin(1).tmon{1}={'2009-7-21 7'}
% wnin(1).tmon{2}={'2009-9-02 7' '2009-9-04 7'}  
wnin(1).tmoff{1}={'2009-7-28 7'}
% wnin(1).tmoff{2}={'2009-9-04 7' '2009-9-09 7'} 

wnin(1).tmon{2}={'2009-8-02 7'}
% wnin(1).tmon{2}={'2009-9-02 7' '2009-9-04 7'}  
wnin(1).tmoff{2}={'2009-8-06 7'}
% wnin(1).tmoff{2}={'2009-9-04 7' '2009-9-09 7'} 


wnin(1).tmon{3}={'2009-8-19 7'}
% wnin(1).tmon{2}={'2009-9-02 7' '2009-9-04 7'}  
wnin(1).tmoff{3}={'2009-8-28 7'}
% wnin(1).tmoff{2}={'2009-9-04 7' '2009-9-09 7'} 


wnin(1).tmon{2}={'2009-8-03 7'}
% wnin(1).tmon{2}={'2009-9-02 7' '2009-9-04 7'}  
wnin(1).tmoff{2}={'2009-8-11 7'}
% wnin(1).tmoff{2}={'2009-9-04 7' '2009-9-09 7'} 

wnrevin(1).tmon{1}={'2009-7-28 7'}
wnrevin(1).tmoff{1}={'2009-8-02 7'}
% wnrevin(1).tmon{2}={}
% wnrevin(1).tmoff{2}={}
wnrevin(1).tmon{2}={'2009-8-11 7'}
wnrevin(1).tmoff{2}={'2009-8-14 7'}
% wnrevin(1).tmon{3}={'2009-8-30 7'}
% wnrevin(1).tmoff{3}={'2009-9-02 7'}


avls.wnin=wnin
avls.wnrevin=wnrevin

%%%%%%INITIAL BASELINE RUN???
%DELAY 65ms.
% 
% avls.pvls{1}='ampon2_stim'
% avls.cvl{1}='batch.train'
% avls.NT{1}='a'
% avls.fmod{1}=[6600 8000]
% 
% avls.pvls{2}='ampon3_stim'
% avls.cvl{2}='batch.train'
% avls.NT{2}='a'
% avls.fmod{2}=[6600 8000]
% 
% avls.pvls{3}='ampon4_stim'
% avls.cvl{3}='batch.train'
% avls.NT{3}='a'
% avls.fmod{3}=[6600 8000]
% 
avls.pvls{4}='ampon4_stim2'
avls.cvl{4}='batch24'
avls.NT{4}='a'
avls.fmod{4}=[6600 8000]

avls.pvls{5}='ampon4_stim2'
avls.cvl{5}='batch25'
avls.NT{5}='a'
avls.fmod{5}=[6600 8000]

avls.pvls{6}='ampon4_stim2'
avls.cvl{6}='batch27'
avls.NT{6}='a'
avls.fmod{6}=[6600 8000]

avls.pvls{7}='ampon4_stim3'
avls.cvl{7}='batch.train'
avls.NT{7}='a'
avls.fmod{7}=[6600 8000]

avls.pvls{8}='ampon6_stim'
avls.cvl{8}='batch.train'
avls.NT{8}='a'
avls.fmod{8}=[6600 8000]

avls.pvls{9}='ampon7_stim'
avls.cvl{9}='batch30'
avls.NT{9}='a'
avls.fmod{9}=[6600 8000]

avls.pvls{10}='ampon7_stim'
avls.cvl{10}='batch31'
avls.NT{10}='a'

avls.pvls{11}='stimrun2_731'
avls.cvl{11}='batch'
avls.NT{11}='a'

avls.pvls{12}='stim801/'
avls.cvl{12}='batch'
avls.NT{12}='a'

avls.pvls{13}='stim802_am/'
avls.cvl{13}='batch'
avls.NT{13}='a'

avls.pvls{14}='stim802_pm/'
avls.cvl{14}='batch'
avls.NT{14}='a'

avls.pvls{15}='stim803_eve/'
avls.cvl{15}='batch'
avls.NT{15}='a'
avls.fmod{15}=[6400 8000]


avls.pvls{16}='stim804amcor/'
avls.cvl{16}='batch'
avls.NT{16}='a'

avls.pvls{17}='run2/ampoff_stim/'
avls.cvl{17}='batch.train'
avls.NT{17}='a'

avls.pvls{18}='/run2/ampon_stim/'
avls.cvl{18}='batch04'
avls.NT{18}='a'

avls.pvls{19}='/run2/ampon_stim/'
avls.cvl{19}='batch05'
avls.NT{19}='a'

avls.pvls{20}='run2/ampon_stim/'
avls.cvl{20}='batch07'
avls.NT{20}='a'

avls.pvls{21}='run2/ampon_stim/'
avls.cvl{21}='batch09'
avls.NT{21}='a'
avls.fmod{21}=[6200 7500]

avls.pvls{22}='run2/ampon_stim/'
avls.cvl{22}='batch10'
avls.NT{22}='a'

avls.pvls{23}='run2/ampon2_rev_stim/'
avls.cvl{23}='batch.train'
avls.NT{23}='a'

avls.pvls{24}='run2/ampon2_rev_stim/'
avls.cvl{24}='batch.train'
avls.NT{24}='a'

avls.pvls{25}='run2/ampon3_rev_stim/'
avls.cvl{25}='batch12'
avls.NT{25}='a'

avls.pvls{26}='run2/ampon3_rev_stim/'
avls.cvl{26}='batch13'
avls.NT{26}='a'

avls.pvls{27}='run2/ampon3_rev_stim2/'
avls.cvl{27}='batch.train'
avls.NT{27}='a'

avls.pvls{28}='stimaug18/'
avls.cvl{28}='batch'
avls.NT{28}='a'

avls.pvls{29}='stimaug21/'
avls.cvl{29}='batch'
avls.NT{29}='a'

avls.pvls{30}='stimaug22/'
avls.cvl{30}='batch22'
avls.NT{30}='a'

avls.pvls{31}='stimaug23/'
avls.cvl{31}='batch'
avls.NT{31}='a'

avls.pvls{32}='stimaug24/'
avls.cvl{32}='batch24'
avls.NT{32}='a'

avls.pvls{33}='stimaug25/'
avls.cvl{33}='batch'
avls.NT{33}='a'

avls.pvls{34}='stimaug26/'
avls.cvl{34}='batch'
avls.NT{34}='a'

avls.pvls{35}='timrun2/'
avls.cvl{35}='batch'
avls.NT{35}='a'
avls.del{35}=.085
avls.fmod{35}=[6250 8000]
avls.conmod{35}=[2250 2550]

avls.pvls{36}='timrun'
avls.cvl{36}='batch'
avls.NT{36}='a'
avls.del{36}=.065
avls.fmod{36}=[6250 8000]
avls.conmod{36}=[2250 2550]

avls.pvls{37}='stimaug28'
avls.cvl{37}='batch'
avls.NT{37}='a'
avls.del{37}=.065

avls.pvls{38}='stimaug30_standard'
avls.cvl{38}='batch'
avls.NT{38}='a'
avls.del{38}=.065

avls.pvls{39}='831stim-1'
avls.cvl{39}='batch'
avls.NT{39}='a'
avls.del{39}=.065

avls.pvls{40}='831stim-2'
avls.cvl{40}='batch'
avls.NT{40}='a'
avls.del{40}=.065

avls.pvls{41}='831-stim85_10ms'
avls.cvl{41}='batch'
avls.NT{41}='a'
avls.del{41}=.085

avls.pvls{42}='901stim-1'
avls.cvl{42}='batch'
avls.NT{42}='a'
avls.del{42}=.065

avls.pvls{43}='revcontin831'
avls.cvl{43}='batch01'
avls.NT{43}='a'
avls.del{43}=.065

avls.pvls{44}='901-stimstandardCOR'
avls.cvl{44}='batch'
avls.NT{44}='a'
avls.del{44}=.065

avls.pvls{45}='stim902'
avls.cvl{45}='batch'
avls.NT{45}='a'
avls.del{45}=.065

%adding in bas runs
avls.pvls{46}='stimtest2'
avls.cvl{46}='batch.train'
avls.NT{46}='a'
avls.del{46}=.065
avls.fmod{46}=[6200 7500]

avls.pvls{47}='stimtest4'
avls.cvl{47}='batch.train'
avls.NT{47}='a'
avls.del{47}=.065

avls.pvls{48}='ampoff801_tmptest'
avls.cvl{48}='batch02'
avls.NT{48}='a'
avls.del{48}=.065
avls.pvls{49}='run2/ampon'
avls.cvl{49}='batch05'
avls.NT{49}='a'
avls.del{49}=.065

avls.pvls{50}='amponaug19'
avls.cvl{50}='batch22'
avls.NT{50}='a'
avls.del{50}=.065

avls.pvls{51}='802_tmptest2'
avls.cvl{51}='batch.rand'
avls.NT{51}='a'
avls.del{51}=.065

avls.pvls{52}='ampon802_eve'
avls.cvl{52}='batch.rand'
avls.NT{52}='a'
avls.del{52}=.065

avls.pvls{53}='run2/ampon'
avls.cvl{53}='batch'
avls.NT{53}='a'
avls.del{53}=.065

avls.pvls{54}='run2/stimoffaug18'
avls.cvl{54}='batch.rand.keep'
avls.NT{54}='a'
avls.del{54}=.065

avls.pvls{55}='amponaug19'
avls.cvl{55}='batchcomb'
avls.NT{55}='a'
avls.del{55}=.065



fbinshi=[1:9 15 21 35:36 46 ]
fbinsnorm=[10:20 22:34 37:45 47:55]

conbinshi=[35:36]
conbinsnorm=[1:34 37:55]


if(CHANGELABEL)
    for ii=1:length(avls.pvls)
        cmd=['cd ' avls.baspath avls.pvls{ii}];
        eval(cmd);
        cmd=['changelabel(''' avls.cvl{ii} ''',''A'','' '','' '',''a'')']
        eval(cmd);
    end
end
    


%do pitch analysis on these batch inds.


for ii=1:34
    avls.del{ii}=.065;
end
avls.con_tbinshft=.05;
avls.pt_tbinshft=.077;
avls.pt_NFFT=512;
avls.con_NFFT=4096;


for ii=1:length(fbinshi)
    avls.fbins{fbinshi(ii)}=avls.fmod{fbinshi(ii)}
end
for ii=1:length(fbinsnorm)
    avls.fbins{fbinsnorm(ii)}=[6100 8000]
end

for ii=1:length(conbinshi)
    avls.conbins{conbinshi(ii)}=avls.conmod{conbinshi(ii)}
end
for ii=1:length(conbinsnorm)
    avls.conbins{conbinsnorm(ii)}=[2140 2800]
end
avls.contanal=1;
avls.contfv=[54:55]
avls.ptfv=[54:55]
avls.analfv=[54:55]
avls.catchstimfv=[54:55]
avls.pt_tbinshft=.079;
avls.pt_NFFT=512;
avls.con_NFFT=4096;
%TO BE CORRECTED
avls.mnbas=6880
avls.stdbas=104.3
avls.basruns=[46 47]
avls.contnum=3
avls.SOUNDSTR='wav'
avls.STIMSTR='rig'
avls.STIMBNDS=[200 0]
avls.STAN_RUNS=[4:23 25:34 36:40 42:47]
avls.HST_EDGES=[6300:50:8000]
avls.REMOVE_OUTLIERS=1;



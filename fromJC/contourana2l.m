%this script is written to generate pitch contours for bk61w42.
clear fv fbins bt smoothamp

% avls.pvls{1}='/oriole6/bk57w35/test9/'
% avls.cvl{1}='batch.notcatch'
% avls.NT{1}='a'

% tvls.pvls{1}='/oriole6/bk57w35/617_125ma_100Hz_40ms/'

tvls.pvls{1}='/oriole6/bk59w37redo/wnon710/'
tvls.cvl{1}='batch12'
tvls.NT{1}='a'


tvls.pvls{2}='/oriole6/bk59w37redo/out1_23_40ma_out2_1450ma_200Hz_70msdel/'
tvls.cvl{2}='batch'
tvls.NT{2}='a'


tvls.pvls{3}='/oriole6/bk59w37redo/stimon716_35maboth/'
tvls.cvl{3}='batch'
tvls.NT{3}='a'



tvls.pvls{4}='/oriole6/bk59w37redo/stimon717_23out2_14out1_40ma_60ms_75del_200Hz/'
tvls.cvl{4}='batch'
tvls.NT{4}='a'

tvls.pvls{5}='/oriole6/bk59w37redo/stimon718_40ms_75del_out2_14_out1_23'
tvls.cvl{5}='batch'
tvls.NT{5}='a'
tvls.stim{5}=[0.04 0.06]

tvls.pvls{6}='/oriole6/bk59w37redo/stim718_400Hz_40ms_75msdel'
tvls.cvl{6}='batch'
tvls.NT{6}='a'
tvls.stim{6}=[0.07 0.10]

% tvls.pvls{6}='/oriole6/bk59w37redo/stimon718_90msdel_10msburst_70maout1_23_out2_14'
% tvls.cvl{6}='batch'
% tvls.NT{6}='a'
% tvls.stim{6}=[0.075 0.105]

tvls.pvls{7}='/oriole6/bk59w37redo/wnrev719'
tvls.cvl{7}='batch'
tvls.NT{7}='a'
tvls.stim{7}=[0.06 0.08]


tvls.pvls{8}='/oriole6/bk59w37redo/stim718_400Hz_40ms_75msdel'
tvls.cvl{8}='batch'
tvls.NT{8}='a'
tvls.stim{8}=[0.07 0.10]
%original pitchshifted 400Hz runs


tvls.pvls{7}='/oriole6/bk59w37redo/stimprobe719'
tvls.cvl{7}='batch'
tvls.NT{7}='a'

tvls.pvls{8}='/oriole6/bk59w37redo/stim719-2'
tvls.cvl{8}='batch'
tvls.NT{8}='a'

tvls.pvls{11}='/oriole6/bk59w37redo/stim719_3_100msdel_80ma_10mspulse'
tvls.cvl{11}='batch'
tvls.NT{11}='a'

tvls.pvls{12}='/oriole6/bk59w37redo/stim719_110msdel_10ms_80ma'
tvls.cvl{12}='batch'
tvls.NT{12}='a'

tvls.pvls{13}='/oriole6/bk59w37redo/stim719_overnight_75msdel_60mspulse_200Hz'
tvls.cvl{13}='batcheve'
tvls.NT{13}='a'

tvls.pvls{14}='/oriole6/bk59w37redo/stim719_overnight_75msdel_60mspulse_200Hz'
tvls.cvl{14}='batchmorn'
tvls.NT{14}='a'

tvls.pvls{15}='/oriole6/bk59w37redo/stimon720_60ms_200Hz'
tvls.cvl{15}='batch'
tvls.NT{15}='a'

% tvls.pvls{15}='/oriole6/bk57w35/602_400Hz_60ms_origconfig'
% tvls.cvl{15}='batch'
% tvls.NT{15}='a'

tvls.pvls{16}='/oriole6/bk59w37redo/stimon720_5mspulse_80ma_200Hz_105msdel'
tvls.cvl{16}='batch'
tvls.NT{16}='a'

%2nd round of pitchshifted runs
tvls.pvls{17}='/oriole6/bk59w37redo/stim720_3mspulse_200Hz_80ma_105msdel'
tvls.cvl{17}='batch'
tvls.NT{17}='a'

tvls.pvls{18}='/oriole6/bk59w37redo/stim721_STIMONCOR_75del_200Hz_40ma_60ms'
tvls.cvl{18}='batch'
tvls.NT{18}='a'

tvls.pvls{19}='/oriole6/bk59w37redo/stimon_standard_60ms_200Hz_75del_722'
tvls.cvl{19}='batch'
tvls.NT{19}='a'

tvls.pvls{20}='/oriole6/bk59w37redo/stim722_5ms_85mdel_70ma_200Hz'
tvls.cvl{20}='batch'
tvls.NT{20}='a'

tvls.pvls{21}='/oriole6/bk59w37redo/stim722_40ms_40ma_75msdel'
tvls.cvl{21}='batch'
tvls.NT{21}='a'

tvls.pvls{22}='/oriole6/bk59w37redo/stim723_75msdel_40ms_200Hz_40ma'
tvls.cvl{22}='batch'
tvls.NT{22}='a'


tvls.pvls{23}='/oriole6/bk59w37redo/stim723_75msdel_40ms_200Hz_40ma'
tvls.cvl{23}='batch24'
tvls.NT{23}='a'
tvls.modoffset{23}=[];

tvls.pvls{24}='/oriole6/bk59w37redo/stim725_50ma_40ms_200Hz'
tvls.cvl{24}='batch'
tvls.NT{24}='a'
tvls.modoffset{24}=[];

tvls.pvls{25}='/oriole6/bk59w37redo/stim725_85msdel_80ma_5ms_200Hz'
tvls.cvl{25}='batch'
tvls.NT{25}='a'
tvls.modoffset{25}=[];

tvls.pvls{26}='/oriole6/bk59w37redo/stim726_50ma_40ms_75del'
tvls.cvl{26}='batch'
tvls.NT{26}='a'
tvls.modoffset{26}=[];

tvls.pvls{27}='/oriole6/bk59w37/bilat_34_400Hz_150ma_60ms_zerodel'
tvls.cvl{27}='batch'
tvls.NT{27}='a'
tvls.modoffset{27}=[];

tvls.pvls{28}='/oriole6/bk59w37/bilat_23_20ms_125ma_20msdel_400Hz'
tvls.cvl{28}='batch'
tvls.NT{28}='a'
tvls.modoffset{28}=[]

tvls.pvls{29}='/oriole6/bk59w37/bilat_12_400Hz_125ma_20ms_20msdel'
tvls.cvl{29}='batch'
tvls.NT{29}='a'
tvls.modoffset{29}=[]

tvls.pvls{30}='/oriole6/bk59w37/bilat_12_20ms_10msdel_400Hz_125ma'
tvls.cvl{30}='batch'
tvls.NT{30}='a'
tvls.modoffset{30}=[]

tvls.pvls{31}='/oriole6/r34w20/wnon726'
tvls.cvl{31}='batchlim'
tvls.NT{31}='b'
tvls.modoffset{31}=[]

tvls.pvls{32}='/oriole6/bk59w37/implantin'
tvls.cvl{32}='batchpre'
tvls.NT{32}='a'
tvls.modoffset{32}=[]


tvls.pvls{33}='/oriole6/bk59w37/705_bilat12_125ma_60ms_zerodel'
tvls.cvl{33}='batch'
tvls.NT{33}='a'
tvls.modoffset{33}=[]

tvls.pvls{34}='/oriole6/bk59w37/705_bilat_23_125ma_60ms_zerodel'
tvls.cvl{34}='batch'
tvls.NT{34}='a'
tvls.modoffset{34}=[]


% tvls.pvls{19}='/oriole6/bk57w35/603_400Hz_60ms_origconfig'
% tvls.cvl{19}='batch'
% tvls.NT{19}='a'
% 
% tvls.pvls{20}='/oriole6/bk57w35/603_400Hz_60ms_origconfig'
% tvls.cvl{20}='batch'
% tvls.NT{20}='a'
% 
% 
% tvls.pvls{21}='/oriole6/bk57w35/603_400Hz_60ms_origconfig'
% tvls.cvl{21}='batch'
% tvls.NT{21}='a'
% 





muinds=[31]


for ii=1:length(muinds)
    crind=muinds(ii)
    pathvl=tvls.pvls{crind}
    cmd=['cd ' pathvl]
    eval(cmd);
%    load sumdata.mat
    

    tbinshft=-0.02;
    NFFT=4096;%number of data points to FFTstrcmd=strcat('!cd ' dir{i})
    
    
      
            fbins{crind}=[2000 3000];
      
    
    save BINS_B NFFT fbins tbinshft
% frequency analysis just for 'b'
    load BINS_B
    NT=tvls.NT{crind};PRENT='';PSTNT='';
    bt{crind}=tvls.cvl{crind};
    
    fv=findwnote4(bt{crind},NT,PRENT,PSTNT,tbinshft,fbins{crind},4096,1,'obs0');
    pitchdata{crind}=jc_pitchcontourFV(fv,1024,1020,1,fbins{crind}(1),fbins{crind}(2),[2 ],'obs0');
    contours=pitchdata{crind};
    for ii=1:length(fv)
       tmp=evsmooth(fv(ii).datt,32000)
       smoothamp{crind}(:,ii)=resample(tmp,length(pitchdata{crind}(:,1)),length(tmp))
    end
    
    
    save pitchdata.mat contours
end
 
initsamptime=512/32000;
initsamptimediff=1/8000;
pitchtms=initsamptime:initsamptimediff:(4096-512)/32000
pitchtms=pitchtms+tbinshft
figure
subplot(211)
%get the right chunk of data to make example plot
% 
% e[sm,sp,t,f]=evsmooth(fv{3}(58).datt,32000,10,512,0.8,2,100,10000);
% imagesc(t+.016,f,log(abs(sp)));syn;ylim([0,1e4]);
% hold on;
% plot(pitchtms,pitchdata{3}(:,58),'c')
% 
% 
% 
% subplot(212)
% 
% %generate 3 random pre
% inds{1}=[floor(rand(10,1)*108)]
% inds{2}=[floor(rand(5,1)*100)+15]
% inds{3}=[floor(rand(5,1)*100)+50]
% col{1}='k'
% col{2}=[.4 .4 1]
% col{3}=[.5 .5 .5]
% for ii=1:length(muinds)
%     plot(pitchtms,pitchdata{ii}(:,inds{ii}),'Color',col{ii})
%     hold on
% end
% % plot(pitchtms,pitchdata{3}(:,58),'c')
% 
% %plot two vertical lines at .04 and .056
% x1=.04
% y1=.056
% plot([.04 .04], [2150 2650],'k--')
% plot([.056 .056], [2150 2650],'k--')
% 
% 
% 
% 
% %generate postdata
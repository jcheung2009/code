%this script is written to generate pitch contours for bk61w42.
clear fv fbins bt smoothamp

% avls.pvls{1}='/oriole6/bk57w35/test9/'
% avls.cvl{1}='batch.notcatch'
% avls.NT{1}='a'

% tvls.pvls{1}='/oriole6/bk57w35/617_125ma_100Hz_40ms/'
tvls.pvls{1}='/oriole5/pu57w52/20408_AC/'
tvls.cvl{1}='batch06.keep.rand'
tvls.NT{1}='a'

tvls.pvls{2}='/oriole5/pu57w52/21709_ACSF/'
tvls.cvl{2}='batch.keepb'
tvls.NT{2}='a'

tvls.pvls{3}='/oriole6/pk20r49/acampon210/'
tvls.cvl{3}='batch.catch.keep12'
tvls.NT{3}='d'

% tvls.pvls{4}='/oriole6/bk57w35/623_outer_400Hz_zerodel_40ms/'
% tvls.cvl{4}='batch'
% tvls.NT{4}='a'
% 
% tvls.pvls{5}='/oriole6/bk57w35/619_20ms_zerodel_400Hz_100ma'
% tvls.cvl{5}='batch'
% tvls.NT{5}='a'
% tvls.stim{5}=[0.04 0.06]
% 
% tvls.pvls{6}='/oriole6/bk57w35/619_middleconfig400Hz_35msdel_30ms_100ma'
% tvls.cvl{6}='batch'
% tvls.NT{6}='a'
% tvls.stim{6}=[0.075 0.105]
% 
% tvls.pvls{7}='/oriole6/bk57w35/619_middlecon_400Hz_20ms_20msdel'
% tvls.cvl{7}='batch'
% tvls.NT{7}='a'
% tvls.stim{7}=[0.06 0.08]
% 
% 
% tvls.pvls{8}='/oriole6/bk57w35/619_middleconfig_400Hz_zerodel_30ms_100ma'
% tvls.cvl{8}='batch'
% tvls.NT{8}='a'
% tvls.stim{8}=[0.07 0.10]
% %original pitchshifted 400Hz runs
% 
% 
% tvls.pvls{9}='/oriole6/bk57w35/523_100ma_400Hz_40ms'
% tvls.cvl{9}='batch'
% tvls.NT{9}='a'
% 
% tvls.pvls{10}='/oriole6/bk57w35/524_100ma_400Hz_40ms'
% tvls.cvl{10}='batch'
% tvls.NT{10}='a'
% 
% tvls.pvls{11}='/oriole6/bk57w35/526_100ma_400Hz_40ms'
% tvls.cvl{11}='batch'
% tvls.NT{11}='a'
% 
% tvls.pvls{12}='/oriole6/bk57w35/528_100ma_400Hz_40ms'
% tvls.cvl{12}='batch28'
% tvls.NT{12}='a'
% 
% tvls.pvls{13}='/oriole6/bk57w35/601_400Hz_60ms_oldconfig'
% tvls.cvl{13}='batch'
% tvls.NT{13}='a'
% 
% tvls.pvls{14}='/oriole6/bk57w35/601_400Hz_40ms_origconfig'
% tvls.cvl{14}='batch'
% tvls.NT{14}='a'
% 
% tvls.pvls{15}='/oriole6/bk57w35/602_400Hz_60ms_orig_2'
% tvls.cvl{15}='batch'
% tvls.NT{15}='a'
% 
% tvls.pvls{15}='/oriole6/bk57w35/602_400Hz_60ms_origconfig'
% tvls.cvl{15}='batch'
% tvls.NT{15}='a'
% 
% tvls.pvls{16}='/oriole6/bk57w35/603_400Hz_60ms_origconfig'
% tvls.cvl{16}='batch'
% tvls.NT{16}='a'
% 
% %2nd round of pitchshifted runs
% tvls.pvls{17}='/oriole6/bk57w35/623_400Hz_midconfig_15msdel_15ms'
% tvls.cvl{17}='batch'
% tvls.NT{17}='a'
% 
% tvls.pvls{18}='/oriole6/bk57w35/623_400Hz_midconfig_25msdel_15ms'
% tvls.cvl{18}='batch'
% tvls.NT{18}='a'
% tvls.modoffset{18}=.089;
% 
% tvls.pvls{19}='/oriole6/bk57w35/623_400Hz_mid_zerodel_40ms'
% tvls.cvl{19}='batch'
% tvls.NT{19}='a'
% 
% tvls.pvls{20}='/oriole6/bk57w35/623_outer_400Hz_60ms_zerodel'
% tvls.cvl{20}='batch'
% tvls.NT{20}='a'
% 
% tvls.pvls{21}='/oriole6/bk57w35/623_outer_125ma_400ma_60ms'
% tvls.cvl{21}='batch'
% tvls.NT{21}='a'
% 
% tvls.pvls{22}='/oriole6/bk59w37/out2_23_400Hz_150ma_60ms_zerodel'
% tvls.cvl{22}='batch'
% tvls.NT{22}='a'
% tvls.modoffset{22}=[];
% 
% tvls.pvls{23}='/oriole6/bk59w37/bilat_23_400Hz_100ma_60ms_zerodel'
% tvls.cvl{23}='batch'
% tvls.NT{23}='a'
% tvls.modoffset{23}=[];
% 
% tvls.pvls{24}='/oriole6/bk59w37/bilat_23_400Hz_125ma_60ms_zerodel'
% tvls.cvl{24}='batch'
% tvls.NT{24}='a'
% tvls.modoffset{24}=[];
% 
% tvls.pvls{25}='/oriole6/bk59w37/bilat_12_400Hz_125ma_60ms_zerodel'
% tvls.cvl{25}='batch'
% tvls.NT{25}='a'
% tvls.modoffset{25}=[];
% 
% tvls.pvls{26}='/oriole6/bk59w37/bilat_12_400Hz_100ma_60ms_zerodel'
% tvls.cvl{26}='batch'
% tvls.NT{26}='a'
% tvls.modoffset{26}=[];
% 
% tvls.pvls{27}='/oriole6/bk59w37/bilat_34_400Hz_150ma_60ms_zerodel'
% tvls.cvl{27}='batch'
% tvls.NT{27}='a'
% tvls.modoffset{27}=[];
% 
% tvls.pvls{28}='/oriole6/bk59w37/bilat_23_20ms_125ma_20msdel_400Hz'
% tvls.cvl{28}='batch'
% tvls.NT{28}='a'
% tvls.modoffset{28}=[]
% 
% tvls.pvls{29}='/oriole6/bk59w37/bilat_12_400Hz_125ma_20ms_20msdel'
% tvls.cvl{29}='batch'
% tvls.NT{29}='a'
% tvls.modoffset{29}=[]
% 
% tvls.pvls{30}='/oriole6/bk59w37/bilat_12_20ms_10msdel_400Hz_125ma'
% tvls.cvl{30}='batch'
% tvls.NT{30}='a'
% tvls.modoffset{30}=[]
% 
% tvls.pvls{31}='/oriole6/bk59w37/temptest'
% tvls.cvl{31}='batch05.catch'
% tvls.NT{31}='a'
% tvls.modoffset{31}=[]
% 
% tvls.pvls{32}='/oriole6/bk59w37/implantin'
% tvls.cvl{32}='batchpre'
% tvls.NT{32}='a'
% tvls.modoffset{32}=[]
% 
% 
% tvls.pvls{33}='/oriole6/bk59w37/705_bilat12_125ma_60ms_zerodel'
% tvls.cvl{33}='batch'
% tvls.NT{33}='a'
% tvls.modoffset{33}=[]
% 
% tvls.pvls{34}='/oriole6/bk59w37/705_bilat_23_125ma_60ms_zerodel'
% tvls.cvl{34}='batch'
% tvls.NT{34}='a'
% tvls.modoffset{34}=[]
% 
% 
% % tvls.pvls{19}='/oriole6/bk57w35/603_400Hz_60ms_origconfig'
% % tvls.cvl{19}='batch'
% % tvls.NT{19}='a'
% % 
% % tvls.pvls{20}='/oriole6/bk57w35/603_400Hz_60ms_origconfig'
% % tvls.cvl{20}='batch'
% % tvls.NT{20}='a'
% % 
% % 
% % tvls.pvls{21}='/oriole6/bk57w35/603_400Hz_60ms_origconfig'
% % tvls.cvl{21}='batch'
% % tvls.NT{21}='a'
% % 





muinds=[1:2]


for ii=1:length(muinds)
    crind=muinds(ii)
    pathvl=tvls.pvls{crind}
    cmd=['cd ' pathvl]
    eval(cmd);
%    load sumdata.mat
    

    tbinshft=-0.01;
    NFFT=4096;%number of data points to FFTstrcmd=strcat('!cd ' dir{i})
    
    
      
            fbins{crind}=[6500 8400];
      
    
    save BINS_B NFFT fbins tbinshft
% frequency analysis just for 'b'
    load BINS_B
    NT=tvls.NT{crind};PRENT='';PSTNT='';
    bt{crind}=tvls.cvl{crind};
    
    fv=findwnote4(bt{crind},NT,PRENT,PSTNT,tbinshft,fbins{crind},4096,1,'obs0');
    pitchdata{crind}=jc_pitchcontourFV(fv,1024,1020,1,fbins{crind}(1),fbins{crind}(2),[1 ],'obs0');
    contours=pitchdata{crind};
%     for ii=1:length(fv)
%        tmp=evsmooth(fv(ii).datt,32000)
%        smoothamp{crind}(:,ii)=resample(tmp,length(pitchdata{crind}(:,1)),length(tmp))
%     end
    
    
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
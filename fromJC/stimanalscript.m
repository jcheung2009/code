
avls.pvls{1}='/oriole6/bk57w35/stimoff515/'
avls.cvl{1}='batch16.catch.keep.rand'
avls.NT{1}='a'

avls.pvls{2}='/oriole6/bk57w35/520_100ma_40ms_bilat2/'
avls.cvl{2}='batch'
avls.NT{2}='a'

avls.pvls{3}='/oriole6/bk57w35/521_100ma_40ms_bilat2'
avls.cvl{3}='batch'
avls.NT{3}='a'

avls.pvls{4}='/oriole6/bk57w35/522_100ma_40ms_400Hz/'
avls.cvl{4}='batch'
avls.NT{4}='a'

avls.pvls{5}='/oriole6/bk57w35/522_100ma_40ms_400Hz_2/'
avls.cvl{5}='batch'
avls.NT{5}='a'

avls.pvls{6}='/oriole6/bk57w35/523_100ma_400Hz_40ms/'
avls.cvl{6}='batch'
avls.NT{6}='a'

avls.pvls{7}='/oriole6/bk57w35/524_100mz_100Hz_40ms/'
avls.cvl{7}='batch'
avls.NT{7}='a'

avls.pvls{8}='/oriole6/bk57w35/524_100ma_400Hz_40ms/'
avls.cvl{8}='batch'
avls.NT{8}='a'

avls.pvls{9}='/oriole6/bk57w35/526_100mz_100Hz_40ms/'
avls.cvl{9}='batch26'
avls.NT{9}='a'
muinds=[1:9]
% clear fvpt valsa
for ii=1:length(muinds)

    crind=muinds(ii);
    pathvl=avls.pvls{crind}
    cmd=['cd ' pathvl]
    eval(cmd);
    bt=avls.cvl{crind};

    tbinshft=0.079;
    NFFT=512;%number of data points to FFTstrcmd=strcat('!cd ' dir{i})
    fbins=[6000 8000];
    save BINS_B NFFT fbins tbinshft
    % frequency analysis just for 'b'
    load BINS_B
    NT='a';PRENT='';PSTNT='';

    fvpt{crind}=findwnote6(bt,NT,PRENT,PSTNT,tbinshft,fbins,NFFT,1,'obs0');
    valsa{crind}=getvals(fvpt{crind},1,'TRIG');
end



clear notind fbind ctind
for run_num=2:length(fvpt)

   notind{run_num}=[]
    fbind{run_num}=[];
    ctind{run_num}=[];
    fvt=fvpt{run_num};
   
    for ii=1:length(fvt)
        if(fvt(ii).STIMTRIG)
            if(fvt(ii).STIMCATCH)
                ctind{run_num}=[ctind{run_num} ii]
            else
                fbind{run_num}=[fbind{run_num} ii]
            end
        else
            notind{run_num}=[notind{run_num} ii]
        end
    end
end

%make hists
edges=[6600:50:7500]
% for ii=5:5  2:length(muinds)
for ii=2:7
    hstoutctind{ii}=histc(valsa{ii}(ctind{ii},2),edges)
    hsctnrm{ii}=hstoutctind{ii}./length(hstoutctind{ii})
    hstoutfdind{ii}=histc(valsa{ii}(fbind{ii},2),edges)
    hsfbnrm{ii}=hstoutfdind{ii}./length(hstoutfdind{ii})
end
hs{1}=histc(valsa{1}(:,2),edges)

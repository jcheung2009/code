muinds=[13]

%later,evtaf4versions.
REPSOUNDSTR='wav'
REPSTIMSTR='rig'

%original

SOUNDSTR='und'
STIMSTR='im'
REPINDS=[];
TBINSHFT=0
NFFT=512
FBINS=[6000 8000]
SEARCHBNDS=[200 -200]
HST_EDGES=[6300:50:8000]

clear crctind crfbind crnotind

for ii=1:length(muinds)

    crind=muinds(ii);
    pathvl=avls.pvls{crind}
    if (exist('baspath'))
        cmd=['cd ' baspath pathvl]
    else
        cmd=['cd ' pathvl]
    end
    sndstr{crind}=SOUNDSTR;
    stimstr{crind}=STIMSTR;
    if(ismember(crind,REPINDS))
       sndstr{crind}=REPSOUNDSTR;
        stimstr{crind}=REPSTIMSTR;
    end   
    eval(cmd);
    bt=avls.cvl{crind}
    cmd=['load ' bt '.mat'];eval(cmd);
    NT=avls.NT{crind};PRENT='';PSTNT='';
    fvst{crind}=findwnote9(bt,NT,PRENT,PSTNT,TBINSHFT,FBINS,NFFT,1,'obs0',0,SEARCHBNDS,sndstr{crind},stimstr{crind});
    valsa{crind}=getvals2(fvpt,1,'TRIG');
end

clear notind fbind ctind
for ii=1:length(muinds)
run_num=muinds(ii);
   notind{run_num}=[]
    fbind{run_num}=[];
    ctind{run_num}=[];
    fvt=fvst{run_num};
    bt=avls.cvl{run_num}
   
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
    crfbind=fbind{run_num};
    crnotind=notind{run_num};
    crctind=ctind{run_num};
    pathvl=avls.pvls{run_num}
    if (exist('baspath'))
        cmd=['cd ' baspath pathvl]
    else
        cmd=['cd ' pathvl]
    end
    eval(cmd);
    
    
    ctvls=valsa{run_num}(crctind,2);
    fbvls=valsa{run_num}(crfbind,2);
    ctmean=mean(ctvls);
    fbmean=mean(fbvls);
    stdfb=std(fbvls);
    stdct=std(ctvls);
    
    hstoutctind=histc(ctvls,HST_EDGES);
    hsctnrm=hstoutctind./length(hstoutctind);
    hstoutfbind=histc(fbvls,HST_EDGES);
    hsfbnrm=hstoutfbind./length(hstoutfbind);
    crvls=valsa{run_num};
    cmd=['save -append ' bt '.mat crfbind crnotind crctind hsctnrm hsfbnrm crvls ctmean fbmean stdfb stdct']
    eval(cmd);
end



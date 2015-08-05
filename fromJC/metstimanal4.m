%modified 5/5/10, tms calc, asymp calc
%modified t
function [sumbs] = metstimanal4(bs, brdind)
global revstdlimit 
global revnumrunslimit
shsall=[];


revstdlimit=1.5;
revnumrunslimit=4;


minstd=0
mineffn=10
%first calculate the shs values for this run
for ct=1:length(brdind)
    bvl=brdind(ct)
    [avls]=loadsumdata2(bs,bvl);
    %shs is a structure for each run
    [shsout,shsrev]=calcshsvals(avls,bs(bvl),minstd,mineffn);
    
    sumbs(bvl).acz=avls.catchz
%     sumbs(bvl).acprez=avls.acprez
%     sumbs(bvl).acpstz=avls.acpstz
%     sumbs(bvl).rawtimes=avls.rawtimes;
%     sumbs(bvl).mulist=avls.mulist;
    sumbs(bvl).initmean=avls.mnbas;
    sumbs(bvl).initsd=avls.stdbas;
    
    if(isfield(avls,'stdfblim'))
        sumbs(bvl).stdfb=avls.stdfblim;
        sumbs(bvl).fbmean=avls.fbmeanlim;
    else
        sumbs(bvl).stdfb=avls.stdfb;
        sumbs(bvl).fbmean=avls.fbmean;
    end
   sumbs(bvl).stdct=avls.stdct;
   sumbs(bvl).ctmean=avls.ctmean;
        
        
       
        
    sumbs(bvl).bname=bs(bvl).bname;
    sumbs(bvl).bsnum=bvl;
%     sumbs(bvl).acerrz=avls.acerracz
    sumbs(bvl).acmean=avls.ctmean;
    sumbs(bvl).mumean=avls.fbmean;
    sumbs(bvl).del=avls.del;
    if(isfield(avls,'ptvls'))
        sumbs(bvl).ptvls=avls.ptvls;
    end
    for ii=1:length(avls.ptvls)
       sumbs(bvl).STIMTIME{ii}=avls.stcr{ii}/1000+avls.del{ii} 
    end
    if(isfield(avls,'STAN_RUNS'))
        sumbs(bvl).STANRUNS=avls.STAN_RUNS
    end
%     sumbs(bvl).acn=avls.acn;
    sumbs(bvl).mun=avls.crctind;
%     sumbs(bvl).acstdv=avls.acstdv;
%     sumbs(bvl).mustdv=avls.mustdv;
    sumbs(bvl).muz=avls.stimz
    if (isfield(avls,'NOSTIM'))
        sumbs(bvl).NOSTIM=avls.NOSTIM;
    end
        
    sumbs(bvl).pct=((avls.catchz-avls.stimz)./avls.catchz)*100;
    sumbs(bvl).initshiftind=bs(bvl).initshiftind;
    sumbs(bvl).basruns=bs(bvl).basruns;
%     sumbs(bvl).muerrz=avls.mustderrz
    
%     for ii=1:length(avls.acstdv(:,1))
%         sumbs(bvl).acstdz(ii,:)=avls.acstdv(ii,:)/avls.initsd{ii}
%         sumbs(bvl).mustdz(ii,:)=avls.mustdv(ii,:)/avls.initsd{ii}
%     end
   
    for ii=1:length(shsout)
        sumbs(bvl).ntind=bs(bvl).ntind;
        sumbs(bvl).sfact=bs(bvl).sfact;
        sumbs(bvl).allnote=shsout(ii).allnote;
%         sumbs(bvl).effvls=shsout(ii).effvls;
%         sumbs(bvl).combeff=shsout(ii).combeff;
        sumbs(bvl).tmvec=shsout(ii).tmvec;
        sumbs(bvl).tmvc=shsout(ii).tmvec;
        crtmvec=shsout(ii).tmvec
        sumbs(bvl).ac_cv=shsout(ii).cv_ac;
        sumbs(bvl).mu_cv=shsout(ii).cv_mu;
        sumbs(bvl).basruns=bs(bvl).basruns
        
        [out,sortind]=sort(crtmvec(shsout(ii).shiftruns));
        sumbs(bvl).shiftruns{ii}=shsout(ii).shiftruns(sortind);
        sumbs(bvl).subruns{ii}=shsout(ii).subruns;
        sumbs(bvl).initind{ii}=shsout(ii).revind;
        sumbs(bvl).flr_wnon{ii} =shsout(ii).flr_wnon;
        sumbs(bvl).flr_wnoff{ii}=shsout(ii).flr_wnoff;
        sumbs(bvl).flrtmvec=shsout(ii).flrtmvec;
        
%         sumbs(bvl).pct=shsout(ii).pct;
%         sumbs(bvl).offz=shsout(ii).offz;
        sumbs(bvl).drxn{ii}=shsout(ii).drxn;
        sumbs(bvl).asympvl{ii}=shsout(ii).asympvl;
        sumbs(bvl).asympruns{ii}=shsout(ii).asympind;
        sumbs(bvl).cnscasympruns{ii}=shsout(ii).cnsc_asympind;
        sumbs(bvl).allasympruns{ii}=shsout(ii).asympind;
%         sumbs(bvl).muasympdist{ii}=shsout(ii).muasympdist;
%         sumbs(bvl).acasympdist{ii}=shsout(ii).acasympdist;
    if(~isempty(shsrev))
        for ii=1:length(shsrev)
         
      
          [out,sortind]=sort(crtmvec(shsrev(ii).runs));
            tmprevruns=shsrev(ii).runs(sortind);
            stanind=ismember(tmprevruns,sumbs(bvl).STANRUNS)
            sumbs(bvl).revruns{ii}=tmprevruns(stanind);
        sumbs(bvl).revflron{ii}=shsrev(ii).flr_wnon;
        sumbs(bvl).drxnrev{ii}=shsrev(ii).drxn;
        sumbs(bvl).revasympruns{ii}=shsrev(ii).asympruns
        if(~isempty(shsrev(ii).cnscasympruns))
            sumbs(bvl).cnscrevasympruns{ii}=shsrev(ii).cnscasympruns;
        else
            sumbs(bvl).cnscrevasympruns{ii}=[];
        end
        sumbs(bvl).revasympvl{ii}=shsrev(ii).asympvl;
        end
    else
        sumbs(bvl).revruns=[];
    end
    
    shsall=[shsall shsout];
    end
    %calc mulist aclist
    inbs=sumbs(bvl);
    [mulist,aclist]=calcmulist(inbs);
    sumbs(bvl).mulist=mulist;
    sumbs(bvl).aclist=aclist;
    sepbasruns=mksepbasruns(sumbs(bvl));
  sumbs(bvl).sepbasruns=sepbasruns;
end  
    
%
% %     [shs]=combeffvls(shsall);
%     [sumshs.meaneff,sumshs.stderreff]=calcavevl(shs,'eff',numdays);
%     [sumshs.pct, sumshs.stderrpct]=calcavevl(shs,'pct',numdays);
    sumbs=calcwnoff(sumbs);
   
    test=2
    
%      function[sumbs]=addcv(sumbs)
%          for bvlind=1:length(sumbs)
%              crbs=sumbs(bvlind);
%              for ii=1:length(crbs.ptvls)
%                  crctvls=crbs.ptvls{ii}(crbs.crctin
%              
    
     function[sepbasruns]=mksepbasruns(crbs)
        for ii=1:length(crbs.shiftruns)
            
            [mintm,maxtm]=get_edgetms(crbs,ii);
            bastms=crbs.flrtmvec(crbs.basruns);
            ind=find(bastms>mintm&bastms<maxtm)
            if(~isempty(ind))
                sepbasruns{ii}=crbs.basruns(ind);
            else
                sepbasruns{ii}=[];
            end
            
        end
    
function[mintm,maxtm]=get_edgetms(crbs,indnum)
    cr_runs=crbs.shiftruns{indnum};
    cr_tms=crbs.flrtmvec(cr_runs);
    maxtm=min(cr_tms);
    
    if(indnum==1)
        mintm=0;
    else
        mintm=crbs.flrtmvec(crbs.shiftruns{indnum-1}(end));
    end
 
 function [mulist,aclist]=calcmulist(inbs)
    nostimruns=0;
     if(isfield(inbs,'NOSTIM'))
         if(~isempty(inbs.NOSTIM))
            stimruns=find(inbs.NOSTIM==0);
            nostimruns=find(inbs.NOSTIM);
            outruns=intersect(stimruns,inbs.STANRUNS);
         else
             outruns=inbs.STANRUNS
         end
    else
        outruns=inbs.STANRUNS
    end
    [sortvls,sortind]=sort(inbs.tmvec(outruns,1));
    mulist=outruns(sortind);
    aclist=zeros(length(mulist),2);
    if(nostimruns)
       for ii=1:length(nostimruns)
           cr_run=nostimruns(ii);
           cr_rundt=inbs.flrtmvec(cr_run);
           stimind=find(inbs.flrtmvec(mulist)==cr_rundt);
           aclist(stimind,1)=cr_run;
           aclist(stimind,2)=cr_run;
       end
    else
        aclist=[];
    end
   
    
function [shs, shsrev]=calcshsvals(avls,bs,minstd,mineffn)
     wn=avls.wn
     
     if isfield(avls,'wnrev')
        wnrev=avls.wnrev;
     else
         wnrev=[];
         shsrev=[]
     end
     ntind=bs.ntind;
     contrind=bs.contrind;
     allind1=[ntind contrind]     
     contrvl=[zeros(length(ntind),1); ones(length(contrind),1)]
     
     clear subind runs diff
     outruns=[];
%      for zz=1 length(allind1)
    for zz=1
         ii=allind1(zz);
        %each row (jj) is a different shift
        %this loop sets the runs{1}(jj,:)-lim runs, 
        %and runs{2}(jj,:)-all runs
        %also sets the mxshift(jj), drxn{jj}
        for jj=1:length(wn(ii).on(:,1))
                
            [flr_wnon, flr_wnoff, subind,flrtmvec,tmvec]=calcshiftvls(wn, ii, jj,avls)
            [outruns,maxshift(jj),drxn{jj},asympvl{jj}]=findruns(avls,subind,ii,jj,zz,flrtmvec,contrvl,minstd,bs,flr_wnon,flr_wnoff);
            [shs(jj)]=calcoutvls(flrtmvec, flr_wnon, flr_wnoff, avls, maxshift(jj), outruns, allind1,ii,mineffn,drxn{jj},asympvl{jj},tmvec);
        end

        if(~isempty(wnrev))
            if(~isempty(wnrev(ii).on))
                for kk=1:length(wnrev(ii).on(:,1))
                    [flr_wnon,flr_wnonff,subind,flrtmvec]=calcrevshiftvls(wnrev,ii,kk,avls);
                    [revruns,drxn{kk},asympruns{kk},cnsecasympruns{kk},asympvl{kk}]=findrevruns(avls,subind,ii,flrtmvec,bs,flr_wnon,flr_wnoff);
                    [shsrev(kk)]=calcoutrevvls(flrtmvec,flr_wnon,flr_wnoff,avls,revruns,allind1,ii,drxn{kk},asympruns{kk},asympvl{kk},cnsecasympruns{kk});
                end
            else
                shsrev=[];
            end
        else
            shsrev=[];
        end
    end

    function [outruns, mxshift, drxn,asympvl]=findruns(avls,subind,ii,jj,zz,flrtmvec,contrvl,minstd,bs,flrwnon,flrwnoff);
        avls.acz=avls.catchz
        avls.muz=avls.stimz
        
        for subindvl=1:3
                    runs=subind{subindvl};
%                     matchind=find(ismember(crind,avls.mulist));
%                     runs=crind(matchind);
                    [sortruns,sortind]=sort(flrtmvec(runs));
                    %only reset outruns if run is a target run
                    if(sortind&contrvl(zz)==0)
                        outruns{subindvl}=runs(sortind);
                        outrnstmp=runs(sortind);
                    
                        if(subindvl==1)
                            aczvls=avls.acz(ii,outrnstmp);
                            absvls=abs(aczvls);
                            indabs=find(absvls>minstd);
                            outruns{subindvl}=outrnstmp(indabs);
                        end
                    end
        end
                aczall=avls.acz(ii,outruns{2});
                [tmp,mxind]=max(abs(aczall));
                mxshift=aczall(mxind)     
                if(mxshift>0)
                    drxn='up'
                else
                    drxn='do'
                end 
                
                 %calculate outruns{4}, asympind.
                ps.ntind=1;
                ps.indin=outruns{2};
ps.flrwnon=flrwnon;
ps.flrwnoff=flrwnoff;
ps.flrtmvec=flrtmvec;
ps.type='stim'


                    [outruns{4},outruns{5},asympvl]=calcasympind(avls,avls.acz(ii,:),ps)
                
                test=1
        
        function [revruns,drxn,asympruns,cnsec_asympruns,asympvl]=findrevruns(avls,subind,ii,flrtmvec,bs,flrwnon,flrwnoff)
%                     
                avls.acz=avls.catchz
                avls.muz=avls.stimz
%                 matchind=find(ismember(subind,avls.mulist));
                    runs=subind;
                    
                    
                    [sortruns,sortind]=sort(flrtmvec(runs));
                    %only reset outruns if run is a target run
                        outrnstmp=runs(sortind);
                        if(~isempty(outrnstmp))
                            if(avls.acz(ii,outrnstmp(1))>0)
                                drxn='up'
                            else
                                drxn='do'
                            end
                        else
                            drxn='up'
                        end
                        revruns=outrnstmp;
                [asympruns,cnsec_asympruns,asympvl]=calcrevasympind(avls.acz(ii,:),avls.muz(ii,:),revruns,bs,flrwnon,flrwnoff,flrtmvec)
               
                  tst=1;  
                
        function [flr_wnon, flr_wnoff, subind,flrtmvec,tmvec]=calcshiftvls(wn,ntin,shin,avls)

                flr_wnonall(shin,:)=floor(wn(ntin).on(shin,:))
                flr_wnoffall(shin,:)=floor(wn(ntin).off(shin,:));
                indon=find(flr_wnonall(shin,:));
                indoff=find(flr_wnoffall(shin,:))
                flr_wnon=flr_wnonall(shin,indon);
                flr_wnoff=flr_wnoffall(shin,indoff);
                tmvec=avls.adjtimes;
                flrtmvec=floor(avls.adjtimes(:,1));
            %subind{1} are all the inds, subind{2} are the asymp inds.
                subind{1}=find(flrtmvec>=flr_wnon(end)&flrtmvec<flr_wnoff(end));    
                subind{2}=find(flrtmvec>=flr_wnon(1)&flrtmvec<flr_wnoff(end));    
                subind{3}=1:length(flrtmvec);
                
          function [flr_wnon, flr_wnoff, subind,flrtmvec]=calcrevshiftvls(wnrev,ntin,shin,avls)

                flr_wnonall(shin,:)=floor(wnrev(ntin).on(shin,:))
                flr_wnoffall(shin,:)=floor(wnrev(ntin).off(shin,:));
                indon=find(flr_wnonall(shin,:));
                indoff=find(flr_wnoffall(shin,:))
                flr_wnon=flr_wnonall(shin,indon);
                flr_wnoff=flr_wnoffall(shin,indoff);
                
                flrtmvec=floor(avls.adjtimes(:,1));
            %subind{1} are all the inds, subind{2} are the asymp inds.
                subind=find(flrtmvec>=flr_wnon(end)&flrtmvec<flr_wnoff(end));        

function  [shs]=calcoutvls(flrtmvec, flron, flroff, avls,mxshift,outruns,allind1,ntind,mineffn,drxn,asympvl,tmvec)               
                avls.acz=avls.catchz
                avls.muz=avls.stimz
                shs.flrtmvec=flrtmvec;
                shs.tmvec=tmvec;
                shs.flr_wnon=flron;
                shs.drxn=drxn;
                shs.asympvl=asympvl;
  %to calculate this/need to switch into mu coordinates.
                shs.flr_wnoff=flroff;
                shs.acz=avls.acz(ntind,:);
                for ii=1:length(shs.acz)
                    crctind=avls.crctind{ii};
                    if(isfield(avls,'crfbindlim'))
                        crfbind=avls.crfbindlim{ii};
                    else
                        crfbind=avls.crfbind{ii}
                    end
                    if(~isempty(avls.ptvls{ii}))
                        crptvls=avls.ptvls{ii}(:,2);
                        shs.cv_ac(ii)=std(crptvls(crctind))./mean(crptvls(crctind));
                   
                        shs.cv_mu(ii)=std(crptvls(crfbind))./mean(crptvls(crfbind));
                    end
                    end
                shs.muz=avls.muz(ntind,:);
%                 shs.acerrz=avls.acerracz(ntind,:)
                
               

                shs.mxshift=mxshift
%                 shs.muerrz=avls.mustderrz(ntind,:)
                shs.shiftruns=outruns{2}
                shs.subruns=outruns{1};
                shs.allruns=outruns{3}(1,:);
                shs.asympind=outruns{4};
                shs.cnsc_asympind=outruns{5};
%                 shs.muasympdist=muasympdist;
%                 shs.acasympdist=acasympdist;
                shs.allnote=allind1;
%                 shs.bname=avls.bname'
                %if control note
                shs.ntype='targ'
                 %this is for all vals
%                  [shs.effvls,shs.combeff,shs.ac_cv, shs.mu_cv]=get_effvls(avls,allind1,mineffn);
%                  [shs.offz,shs.offerrz,shs.off,shs.offerr]=getoff(avls,allind1);
                 %this will selected indices for reversion runs
                 %and selected off values, pct values, and errors.
                 [shs.revind]=select_rev(shs,avls);
                 numcontrind=length(allind1)-1;
                %currently just for subruns vals, but I am going to change this. 
%                 [shs.pct,shs.pcter]=getpctvls2(avls,allind1(1),shs);
%                 
                
  
  function  [shsrv]=calcoutrevvls(tmvec, flron, flroff, avls,outruns,allind1,ntind,drxn,asympruns,asympvl,cnsecasympruns)               
                shsrv.drxn=drxn;
                shsrv.flrtmvec=tmvec;
                shsrv.flr_wnon=flron;
  %to calculate this/need to switch into mu coordinates.
                shsrv.flr_wnoff=flroff;
                shsrv.runs=outruns;
                shsrv.asympruns=asympruns;
                shsrv.cnscasympruns=cnsecasympruns;
                shsrv.asympvl=asympvl;
                
%                 shsrv.bname=avls.bname'
                %if control note
                %currently just for subruns vals, but I am going to change this. 
                   

                
                
  %the point of the function is to go throuch each of the shs subruns, combine the multiple
  %effvls into a daily estimate, and then interpolate the estimate
%   and interpolate through all the gap days                      
  function [mnvl,stdvl]=calcavevl(shs,yfieldname,numdays)
      initval=-1000
      %initialize effinterpvl matrix to 0
      %number of rows is number of shifts
      %ncol is numdays.
          
  %FIX THIS HERE...CREATING TOO MANY EFFINTERPVLS OUTS!!
  %create one output for run
  %and then combine them
  interpcomb=[];
  for ii=1:length(shs)
          shscr=shs(ii);
          if ~isempty(shs(ii).subruns)
                [dys]=calcxvls(shscr)
          else
              dys=[];
          end 
              nrow=length(shs(ii).subruns)
                ncol=numdays;
          
          interpvlstmp=zeros(ncol,1);
          interpvlstmp=interpvlstmp-1000;
          if ~isempty(dys)
            
            if(yfieldname=='eff')
                cmd=['yvls=shscr.combeff(shscr.subruns)'];
                eval(cmd);
            else
                cmd=['yvls=shscr.pct'];
                eval(cmd);
            end
             
          [interpvlstmp(dys(1):1:dys(end))]=interpvls(yvls,dys);
          end
            interpcomb=[interpcomb;interpvlstmp(1:numdays)']  
      end
          %need to calculate the mean column by column excluding zero
         
      
           [mnvl,stdvl]=calcmatmean(interpcomb,numdays,initval);  
            %loop through days and calculate the difference with previous
            %day
            %if diff>1, interpola
    %returns shs.combeff 
   function [shs]=combeffvls(shs);              
        for shin=1:length(shs)
            shscr=shs(shin);
            allnote=shscr.allnote;
            nmnote=length(allnote);
            shs(shin).combeff=mean(shscr.effvls(allnote,:),1)
            if (nmnote>1)
                shs(shin).stderref=std(shscr.effvls(allnote,:),1)/sqrt(nmnote);
            else
                shs(shin).stderref=0;
            end
        end
                
   function [dys]=calcxvls(shscr) 
                subrns=shscr.subruns
                flrtmvc=shscr.flrtmvec;
                ofst_tm=flrtmvc-flrtmvc(subrns(1));
                %this is to avoid any zeros
                dys=ofst_tm(subrns)+1;
   
   

       %loop through days and calculate the difference with previous
            %day
            %if diff>1, interpolate  
            %DO NOT INCLUDE -1000 values in mean
    function [mnvl,stderrvl]=calcmatmean(initmat,numdays,initval);  
        for ii=1:numdays
           initmatcol=initmat(:,ii);
           ind=find(initmatcol~=initval);
           mnvl(ii)=mean(initmatcol(ind));
     stderrvl(ii)=std(initmatcol(ind))/sqrt(length(ind));
        end

    %write this function
    %
    function [ydiffz,ydifferrz,ydiff,ydifferr]=getoff(avls,allind1);    
        for ii=1:length(allind1)
            ntind=allind1(ii);
            acz=avls.acz(ntind,:);
            muz=avls.muz(ntind,:)
            acerrz=avls.acerracz(ntind,:);
            muerrz=avls.mustderrz(ntind,:);
            
            acmean=avls.acmean(ntind,:);
            mumean=avls.mumean(ntind,:)
            acerr=avls.acstderr(ntind,:);
            mustderr=avls.mustderr(ntind,:);
        
            ydiffz(ntind,:)=-acz+muz;
            ydifferrz(ntind,:)=(acerrz+muerrz)/2;
            
            ydiff(ntind,:)=mumean-acmean;
            ydifferr(ntind,:)=(acerr+mustderr)/2;
            
        end
        
        
    %this will selected indices for reversion runs
    %and selected off values, pct values, and errors.
    function[shsrevind]=select_rev(shs,avls);
       global revstdlimit
       global revnumrunslimit
       
        shiftind=shs.shiftruns;
        acz=avls.acz
        ntind=shs.allnote(1);
        absacz=abs(acz(ntind,shiftind));
        ind=find(absacz>revstdlimit);
        if(length(ind)>1)
            if length(ind)>revnumrunslimit
                ind=ind(1:revnumrunslimit);
            else
                ind=ind;
            end
                shsrevind=shiftind(ind);
          
        elseif ind==1
            shsrevind=shiftind(ind(1));
                
        else
            shsrevind=[]
        end

   function [sumbs]=calcwnoff(sumbs)
        
       for ii=1:length(sumbs)
         shiftrns=sumbs(ii).shiftruns;
         
         revruns=sumbs(ii).revruns;
         asympruns=sumbs(ii).asympruns;
         ntind=sumbs(ii).ntind;   
         for jj=1:length(shiftrns)
                runs=shiftrns{jj};
                tms=sumbs(ii).flrtmvec(runs);
%                 [out_tms]=calc_exact_tms(sumbs(ii).tmvec(runs));
                    [out_tms]=sumbs(ii).tmvec(runs)
                
                
%                 su
                baswntime=sumbs(ii).flr_wnon{jj}(1);
                %the plus one is so that if inactivation is same day as wn,
                %then that is listed as day 1.
                sumbs(ii).adjshifttms{jj}=tms-baswntime+1;
                sumbs(ii).exactshifttms{jj}=out_tms-baswntime;
                sumbs(ii).baswntime{jj}=baswntime;
               
         end
         for jj=1:length(revruns)
             runs=revruns{jj};
             tms=sumbs(ii).flrtmvec(runs);
%              [out_tms]=calc_exact_tms(sumbs(ii).tmvec(runs));
            [out_tms]=calc_exact_tms(sumbs(ii).tmvec(runs))
             baswntime=sumbs(ii).revflron{jj};
             sumbs(ii).revshifttms{jj}=tms-baswntime+1;
              sumbs(ii).exactrevtms{jj}=out_tms-baswntime+1;
         end
        if(isfield(sumbs(ii),'asympruns'))
            if(~isempty(sumbs(ii).asympruns))
                for jj=1:length(asympruns)
            runs=asympruns{jj}
            tms=sumbs(ii).flrtmvec(runs);
%             [out_tms]=calc_exact_tms(sumbs(ii).tmvec(runs));
                [out_tms]=calc_exact_tms(sumbs(ii).tmvec(runs))
                baswntime=sumbs(ii).flr_wnon{jj}(1);
                %the plus one is so that if inactivation is same day as wn,
                %then that is listed as day 1.
                sumbs(ii).asympshifttms{jj}=tms-baswntime;
                sumbs(ii).exactasymptms{jj}=out_tms-baswntime;
                end
            end
         end 


       end
  
       
 function [recenter_tms]=calc_exact_tms(intms)
      
                modtms=mod(intms,floor(intms));
                recenter_tms=(modtms*24-7)/24+floor(intms);
     

     function [sumbs]=overalleff(sumbs)  
       for ii=1:length(sumbs)
         crbs=sumbs(ii);
         
             ind=find(crbs.combeff>0&isnan(crbs.combeff)==0)
             sumbs(ii).mneff=mean(crbs.combeff(ind));
             sumbs(ii).stdeff=std(crbs.combeff(ind))
             
        end

%      function [asympind,asympvl]=calcasympind(avls,aczvls, indin)
%         
%          
%          %sdnet is how many standard deviations out to calculate the mean.
%          sd_dist=1.2;
%          %sd pass is distance from mean to include as part of asympvks
%          sdlist=aczvls(indin);
%          
%          sd_difflist=sdlist(2:end)-sdlist(1:end-1);
% %          tmdifflist=tmlist(2:end)-tmlist(1:end-1);
%          
%          
%          ind_belowdiff=find(abs(sd_difflist)<sd_dist);
%          
%           if(~isempty(ind_belowdiff))
%             lstasympind=ind_belowdiff(end)+1
%             asympvl=sdlist(lstasympind);
%             allasympind=find(abs(asympvl-sdlist)<sd_dist)
%             allasympind=indin(allasympind);
%             avls.tmvc=avls.adjtimes;
%             init_tm=floor(avls.tmvc(allasympind(1),1));
%             end_tm=ceil(avls.tmvc(allasympind(end),1));
%             
%             %asympindall are all runs within these time bnds.
%             asympindall=find(avls.tmvc(:,1)>=init_tm&avls.tmvc(:,1)<=end_tm);
%             [sortout,ind]=sort(avls.tmvc(asympindall,1));
%             asympind=asympindall(ind);
%             %so asympind are all mu runs within these time bnds
% %             asympind=find(ismember(avls.mulist,asympindall));
% %             asympind=avls.mulist(asympind);
% %          
% %             
%             
%             %asympindall are all runs within these time bnds
%             
%             
%          else
%              asympind=[];
%              asympindall=[];
%              asympvl=sdlist(end);
%          end
%          
% %             if (mxshift<0)
% %                 vls=-aczvls(ind)
% %                 mxshift=-mxshift;
% %             else
% %                 vls=aczvls(ind)
% %             end
% %             
%             %HACK
% %              if(bs.skipasymp)
% %                  vls=aczvls
% %                  ind=1:length(aczvls)
% %                  mxshift=vls
% %              end
%          
% %          
% %           if isfield(bs,'asympvl')
% %              mnvl=bs.asympvl
% %              indcheck=1:length(aczvls(ind))
% %           else
% %             indcheck=find(abs(mxshift-vls)<sdnet)
% %             mnvl=mean(vls(indcheck))
% %           end
% %          
% %          indpass=find(abs(vls(indcheck)-mnvl)<sdpass&abs(vls(indcheck))>1.5);
% %         
% %          asympind=ind(indcheck(indpass));
% %          asympvl=mean(aczvls(ind(indcheck(indpass))))
% %          muasympdist=asympvl-muzvls(ind(indcheck(indpass)));
% %          acasympdist=asympvl-aczvls(ind(indcheck(indpass)));
% %          if(asympvl<0)
% %              muasympdist=-muasympdist
% %              acasympdist=-acasympdist
% %          end
%          
%       function [asympind,asympvl]=calcrevasympind(aczvls, muzvls,ind,bs)
%         
%          %start off with sdpass fixed to one
%          %i.e. calling an asymptote any set of consecutive days,
%          %at which <1sd from baseline.
%          sdpass=1;
%        
%           if ~isempty(bs.revasympvl)
%              mnvl=bs.revasympvl;
%              indcheck=1:length(aczvls(ind))
%           else
% %             indcheck=find(abs(mxshift-vls)<sdnet)
% %             indcheckall=
%             mnvl=0;
%             indcheck=1:length(aczvls(ind))
%           end
%           
%           vls=aczvls(ind);
%          
%          indpass=find(abs(vls(indcheck)-mnvl)<sdpass);
%         
%          asympind=ind(indcheck(indpass));
%          asympvl=mean(aczvls(ind(indcheck(indpass))))     
%6.10.08  This preps inactivation data for further analysis and plotting,
%used with inactivanal, requires structure avls, which has many necessary
%inputs
%acmucompar.m, computes inactivation ratios.
%This fxn is different from pitchsyntaxanal2 in that it call pitchalign,
%which re-aligns pitch values based on template.

function pitchsyntaxanal3(avls);

%this loads in all the data paths, and variables for analysis.
strcmd=['cd ' avls.sumpath 'datasum']
eval(strcmd)
% strcmd=['load ' avls.mtflnm '.mat'];
% eval(strcmd);

if (avls.mkfv)
    for indvl=1:length(avls.mkfv)
       
        ii=avls.mkfv(indvl);
        if(~isempty(avls.pvls{ii}))
            fvnote={};
            for jj=1:length(avls.NT)
                if(avls.pitchalign{jj})
                    strcmd=['cd ' avls.sumpath 'datasum']
                    eval(strcmd)
                    load pitchtemp.mat
                end
                    

                strcmd=['cd '  avls.pvls{ii}];
                eval(strcmd);
                fvnam{jj}=['fv' avls.NT{jj}];
                bt=avls.cvl{ii};          
%                 if(avls.usex(ii))
%                     strcmd1=['fv{jj}=findwnote4(bt,avls.NT{jj},avls.PRENT{jj},avls.PSTNT{jj},avls.tshft{jj},avls.fbins{jj},avls.NFFT(jj),1,''obs0'',1);'];

                if avls.pitchalign{jj}
                     
                    strcmd1=['fv{jj}=findwnote5(bt,avls.NT{jj},avls.PRENT{jj},avls.PSTNT{jj},avls.tshft{jj},avls.fbins{jj},avls.NFFT(jj),1,''obs0'',0,pitchtemp{jj});'];
                else
                    strcmd1=['fv{jj}=findwnote5(bt,avls.NT{jj},avls.PRENT{jj},avls.PSTNT{jj},avls.tshft{jj},avls.fbins{jj},avls.NFFT(jj),1,''obs0'',0);'];
                end
                    %strcmd2=['[valstrigs,trigs{jj}]=triglabel(bt,NT{jj},1,1,0,0);']
%                 end
            
            eval(strcmd1);

%             if(avls.repeatanal(jj))
%                 fv{jj}=repeatanal(fv{jj});
%             end

        fvnote{jj}=avls.NT{jj};
            end
         if(~isempty(avls.exclude))
            if(avls.exclude(jj))
                fv{jj}=exclude_outlrs(fv{jj},2);
            end
         end

            strcmd=['save  ' bt '.mat ' 'fv '] ;
          eval(strcmd);
        end
    end
            
end


%THIS MAKES FVCOMB WHICH COMBINES ALL DATA INTO A STRUCT
for jj=1:length(avls.NT)
    fvcomb{jj}=[];
    fvcombdir{jj}=[];
end
    for btind=1:length(avls.pvls);
      
        if(~isempty(avls.pvls{btind}))
           
            strcmd=['load ' avls.pvls{btind} avls.cvl{btind} '.mat'];
            eval(strcmd);
            for jj=1:length(avls.NT)
                %do not include directed songs in this master structure.
                ind=find(btind==avls.diron);
                if isempty(ind)
                    fvtmp=fv{jj};
                    btind
                    fvcomb{jj}=[fvcomb{jj} fvtmp];    
                else
                    fvtmp=fv{jj};
                    valstmp=getvals(fv{jj},1,'trig');
                    fvcombdir{jj}=[fvcombdir{jj} fvtmp];
                    avls.dirvls{jj}{btind}=valstmp;
                end
              end
        end
end


%first make a time vector with list of times
[avls.tmvc]=maketimevec(avls);

%now pull out rawtimevals, with dead time adjustment
[avls.rawtimes]=timeadj(avls.tmvc,avls.deadtm, [1:length(avls.pvls)],0);
%chop off dirtimes
if(~isempty(avls.diron))
    for ii=1:length(avls.diron)
        indvl=avls.diron(ii);
        avls.dirtimes(ii,:)=avls.rawtimes(indvl,:);
        avls.rawtimes(indvl,:)=[0 0];
    end
end

% [avls.dirtimes]=get_dirtimes(avls);
%now pull out timevals, with adjustment for lag offset
%idea here is actually chop off time if necessary
[avls.adjtimes]=timeadj(avls.rawtimes,avls.acoffset, avls.acon,1);
[avls.adjtimes]=timeadj(avls.adjtimes,avls.muoffset, avls.muon,1);
[avls.aclist,avls.mulist]=groupadj(avls.adjtimes,avls.acon, avls.muon)
[avls.adjtimes]=timeadj_pretm(avls.acon,avls);

strcmd=['cd ' avls.sumpath 'datasum'];
eval(strcmd);
avls.fvcomb=fvcomb;
avls.fvcombdir=fvcombdir;

strcmd=['save ' avls.mtflnm '-analdata.mat avls'];
    eval(strcmd);

% 
% if avls.supanal
%     for ii=1:length(avls.bnds)
%         switchdts(ii)=datenum(avls.bnds{ii},'yyyy-mm-dd HH:MM:SS');
%         matind{ii}=avls.bnds{ii}(1:10)
%     end
% 
% 
%     for ii=1:length(avls.pitchind)
%         pitchind=avls.pitchind(ii);
%         [outvls.mnvl{pitchind},outvls.stdv{pitchind},outvls.htrt{pitchind},outvls.vlot{pitchind}]=freqanal(fvcomb{pitchind})
%     end
%     for ii=1:length(avls.synind)
%         synind=avls.synind(ii);
%         fvcomb{1}=transval(fvcomb{1},1);
%         outvls.synstruct=syntaxanal(fvcomb{1},avls.translist);
%     end
% 
% 
%     avls.fvcomb=fvcomb
% strcmd=['cd ' avls.sumpath 'datasum']
% eval(strcmd)
%     strcmd=['save ' avls.datfile '-analdata.mat  outvls avls'];
%     eval(strcmd);
% end
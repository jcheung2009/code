

pathvl{1}='/doyale/twarren/r95pk42/templteste2/';
catchvl{1}='batch1920comb'
pathvl{2}='/doyale/twarren/r95pk42/templteste3/'
catchvl{2}='batch.catch.keep'
pathvl{3}='/doyale/twarren/r95pk42/wnon2/'
catchvl{3}='batch2223'
pathvl{4}='/doyale/twarren/r95pk42/wnon2/'
catchvl{4}='batch24.catch.keep'
pathvl{5}=pathvl{4}
catchvl{5}='batch25.catch.keep'
pathvl{6}='/doyale/twarren/r95pk42/wnon3/'
catchvl{6}='batch26.keep.catch'
pathvl{7}='/doyale/twarren/r95pk42/wnon3/'
catchvl{7}='batch27.keep.catch.rand'

clear NT;

fvcomb=[];
makefv=1;
calc_prop_note=0;
%stimstart 1/30 12pm



cntrng(1).MIN=1;
cntrng(1).MAX=3;
cntrng(1).NOT=0;
cntrng(1).MODE=1;
cntrng(1).TH=3;

%example if you has a second template
cntrng(2).MIN=1;
cntrng(2).MAX=3;
cntrng(2).NOT=0;
cntrng(2).MODE=1;
cntrng(2).TH=3;

cntrng(3).MIN=2
cntrng(3).MAX=3
cntrng(3).NOT=0
cntrng(3).MODE=1
cntrng(3).TH=3.5

NT{1}='e'

if (makefv)
    for ii=1:length(pathvl)
       for jj=1:length(NT) 
        fvnote={};
        
            
            PRENT='';PSTNT='';
            tbinshft=0.005;
            strcmd=['cd '  pathvl{ii}];
            eval(strcmd);
           
            bt=catchvl{ii}
            NFFT=1024;%number of data points to FFTstrcmd=strcat('!cd ' dir{i})
            fvnam{jj}=['fv' NT{jj}]
            bt=catchvl{ii}
            NFFT=1024;%number of data points to FFTstrcmd=strcat('!cd ' dir{i})
            fbins=[2000,4000];
            strcmd=['fv{jj}=findwnote4(bt,NT{jj},PRENT,PSTNT,tbinshft,fbins,NFFT,1,''obs0'', 1);']
            eval(strcmd);
           fvnote{jj}=NT{jj};
%             mk_tempf(bt,templ,2,'obs0');
%             get_trigt(bt,cntrng,0.06,128,1,1,1);

%             [vals{ii},trigs]=triglabel(bt,'e',1,1,0,1);
       end
   
    
    strcmd=['save  ' bt '.mat ' 'fv fvnote tbinshft fbins']
        
           
       
            eval(strcmd)
    end
end

valscomb=[]
clear fvcomb
fvcomb{1}=[];

%now go back and combine the vals structs, and the f

for ii=1:length(pathvl)
  
    %valscomb=[valscomb vals{ii}]
    
    strcmd=['load ' pathvl{ii} catchvl{ii} '.mat']
    eval(strcmd);
        for jj=1:1%length(NT)
            fvtmp=fv{jj};
            fvcomb{1}=[fvcomb{1} fvtmp];
            
        end
end



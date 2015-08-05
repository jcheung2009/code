%script spikesort directories
%given a list of directories will run a spike sorter on every .ncs file in
%those directories and save the intermediate output. Then, you can later go
%back and do selection on each waveform. Currently it does not support
%restarting searches, however, this function should be added later

%a file with one directory to sort per line
directoriesList = 'dirstosort'; 
%a file with one sorted directory per line
sortLog = 'BSsortLog';
%verbose
verbose = 1;
%Directory location of AUTOCLASS.EXE, KLUSTAKWIK.EXE, and CYGWIN1.DLL
exeDir = 'c:\Jonathan\Physiology\BSspikesorter\';
%the base name for the files created by executables
baseFilename = 'spikes';
%do KlustaKwik (1) or AutoClass (0)
doKlustaKwik = 1;

runTag = '1';
continueRun = 1;

fhr = fopen(directoriesList);
fhw = fopen(sortLog,'w');

a = pwd;
addpath(a);

while(~feof(fhr)) 
    dirPath = fgetl(fhr); 
    if(feof(fhr) || isempty(dirPath) || dirPath(1) == '#') %skip comments
        continue;
    end
    fprintf(fhw,'Beginning Directory: %s\n', dirPath);
    cd(dirPath);
    ncss = dir('*.ncs');
    if(verbose)
        fprintf(1,'Beginning Directory: %s\n', dirPath);
    end
        
    for i = 1:length(ncss)
        if(verbose)
            fprintf(1,'Beginning file: %s\n',ncss(i).name);
        end
        %handle trigger files explicitly
        if(strcmpi(ncss(i).name,'trig.ncs'))
            [snippets,samplenums,firstTimeStamp,fs] = collectThresholdNCS(ncss(i).name,-5000,[-20 120],25);
            savefile = ['BSS' ncss(i).name runTag 'threshed'];
            %save output
            save(savefile,'snippets','samplenums','firstTimeStamp','fs');
            fprintf(fhw,'File: %s Completed. Saved as %s\n',ncss(i).name,savefile);     
            continue;
        end
        
        %figure out the save file name and if it already exists
        if(doKlustaKwik)
            savefile = ['BSS' ncss(i).name runTag 'KlustaKwik']; 
        else
            savefile = ['BSS' ncss(i).name runTag 'AutoClass'];
        end
        
        if(continueRun & ~isempty(dir(savefile)))
            continue;
        end
        
        %find 4*data standard deviation
        samplesForStd = 100000;
        sstd = collectSTDncs(ncss(i).name,samplesForStd);
        %try to pull out the threshold crossing for every .ncs file
        [snippets,samplenums,firstTimeStamp,fs] = collectThresholdNCS(ncss(i).name,4*sstd,[-30 120],30);
        if(size(snippets,1)<100)  %skip files without much to sort
            continue;
        end
        %do preprocessing
        %run some pca,some ICA, and some features
        colsWeCareFor = 20:45; %will slice from 10 samples before to 15 samples after peak
        [comp,snippetsToSort] = princomp(snippets(:,colsWeCareFor));
        numOfComponents = 6;
        unmixed = fastica(snippets(:,colsWeCareFor)','approach','symm','epsilon',0.1,'displayMode','off','numOfIC',numOfComponents,'verbose','off')';
        snippetsToSort = [snippetsToSort(:,2),min(snippets(:,colsWeCareFor),[],2),max(snippets(:,colsWeCareFor),[],2),unmixed];
        if(verbose)
            fprintf(1,'Beginning Clustering');
            tic
        end
        %doClustering
        if(doKlustaKwik)
            klustakwikfile = baseFilename; 
            klustakwikpath = exeDir;
            numStarts = 3;
            idx = KlustaKwik(klustakwikfile,klustakwikpath,snippetsToSort,numStarts,0);   
        else
            autoclassfile = baseFilename;
            autoclassPath = exeDir;
            numTries = 10;
            cyclesPerTry = 50;
            [idx,probs] = AutoClass(autoclassfile,autoclassPath,snippetsToSort,numTries,cyclesPerTry,verbose);
        end
        
        %save output
        save(savefile,'idx','snippets','snippetsToSort','samplenums','firstTimeStamp','sstd','fs');
        fprintf(fhw,'File: %s Completed. Saved as %s\n',ncss(i).name,savefile);
        
        clear snippets snippetsToSort
        if(verbose)
            toc
            fprintf(1,'File: %s completed and saved\n',ncss(i).name);
        end
    end
    fprintf(fhw,'Finished Directory: %s\n',dirPath);
    if(verbose)
        fprintf(1,'Finished Directory: %s\n',dirPath);
    end
end
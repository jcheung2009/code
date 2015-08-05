function idx = KlustaKwik(klustakwikfile,klustakwikpath,snippets,numStarts,verbose)

if(~exist('verbose','var'))
    verbose = 1;
end
if(~exist('numStarts','var'))
    numStarts = 3;
end

%these variable cannot be changed without changing ohter files on disk
% klustakwikfile = 'spikes'; 
% klustakwikpath = 'C:\Users\Bryan\Documents\MATLAB\BryanSpikeSort\CurrentSorter\'; %needs to be connected to cygwin1.dll


%prepare for klustakwik
fname = [klustakwikfile '.fet.1'];
numFeatures = size(snippets,2);
featureString = sprintf('%d',ones(1,numFeatures));
dlmwrite(fname,numFeatures); %write number of features
dlmwrite(fname,snippets,'-append','delimiter',' '); %write data

%run the klustakwik program via dos
dos([klustakwikpath 'KlustaKwik ' klustakwikfile ' 1 -MinClusters 3 -MaxClusters 5 -MaxPossibleClusters 10 -Verbose 0 -nStarts ',num2str(numStarts),' -UseFeatures ',featureString,' -Screen ',num2str(verbose),' -echo' ]);

%read klustakwik output
idx = uint8(dlmread([klustakwikfile '.clu.1'])); %read cluster file 
numClusters = idx(1); %first value is number of clusters
idx = idx(2:end); %all other values are clusterings

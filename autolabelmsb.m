function autolabelmsb(feats)

% AUTOLABEL()
%
% Automatically labels the syllables of a birdsong. This program prompts the user for a batch file with the names
% of hand labeled songs as well a batch file with the names of the songs to be labeled. The hand labeled songs should 
% have at least 30 examples of every syllable type in a .not.mat file of the same name. If a syllable type has less 
% than 30 examples it will be ignored and this program will not attempt to give any syllables that label. That means
% that all syllables of that type will be mislabeled or left blank. This program also ignores any syllbles marked 
% '0' or 'x'. 
%
% Syllables that cannot be confidently labeled are left blank (given the label '-'). After labeling is done AUTOLABEL 
% will optionally run LABELBLANKS, an interface for quickly hand labeling syllbels with the label '-'.
% LABELBLANKS can be run seperately and will prompt the user for a batch file of songs with '-' labeled syllables.
% That will be the same batch file of songs given to AUTOLABEL.
%
% This program WILL make mistakes in addition to leaving syllables blank, so don't trust it too much. 
%
% optional argument feats; if specified, will attempt to lad rather than calculate...


global labelIndex %array of the letters of labels in use
global filetype

load_feat_flag=0;
if nargin==1
    load_feat_flag=1;
end    
    
filetype = get_filetype;

% Get bactchfiles. training_fid is labeled batchfile, songs_fid is unlabeled batchfile
[training_fid, songs_fid] = get_batchfiles;
pause(.1); % to let popup menu clear

% Read info from labeled files. labelIndex is an array of the labels that will be used. Their position in 
% the array is their numerical equivalent. 
[templateSylls, index, labelIndex] = read_training(training_fid);

% Splits labeled syllables into two groups for the purpose of finding optimal feature detectors
[trainingSylls, testSylls, trainingIndex, testIndex] = splitSylls(templateSylls, index);

if load_feat_flag
  load(feats)    
else    
% Gets the best features for getting the testSylls right using the templateSylls
[feats, confidenceThresh] = get_feats(trainingSylls, testSylls, trainingIndex, testIndex);
end


% Calculate feature vectors of templateSylls with feature detectors
templates = make_templates(templateSylls, feats);

frewind(songs_fid);
% Label each song in songs batchfile
while 1
   %get songfile name
     songfile = fscanf(songs_fid,'%s',1);
     
     if isempty(songfile)
        disp('End of songfile.')
        break
     end

     label(songfile, feats, templates, index, confidenceThresh); 
     
 end

% Display some stats about what the program has done 
countblanks(songs_fid);
        
% Optionally run labelblanks.
while 1
    disp('Would you like to label the syllables that were left blank now? (y/n) [y]');
    tmp = input(' ', 's');
    if strcmp(tmp, 'y') | strcmp(tmp, 'Y') | strcmp(tmp, 'yes') | isempty(tmp)
        labelblanks(songs_fid);
        break;
    elseif strcmp(tmp, 'n') | strcmp(tmp, 'N') | strcmp(tmp, 'no')

        break
    end
end

fclose(training_fid);
fclose(songs_fid);

%-------------------------------------------------------------------------------

function filetype = get_filetype

global filetype

disp('What is type of sound file? [w]')
disp(' b = binary from mac')
disp(' w = wavefile (i.e. cbs)')
disp(' d = dcpfile')
disp(' f = foosong/gogo')
disp(' o = observer file (last/song channel)')
disp(' o1r = observer file (second to last)')


filetype = 'null';
while strcmp(filetype,'null')
  temp=input(' ','s');
  if (strcmp(temp,'b') | strcmp(temp,'B') | strcmp(temp,'bin') | strcmp (temp, 'binary'));
     filetype = 'b';
  elseif strcmp(temp,'w')  | strcmp(temp,'wav') | strcmp(temp,'W') | isempty(temp)
     filetype = 'w';
  elseif strcmp(temp,'d')  | strcmp(temp,'dcp') | strcmp(temp,'D')
     filetype = 'd';  
  elseif strcmp(temp,'f')  | strcmp(temp,'F')
     filetype = 'f';  
  elseif strcmp(temp,'o')  | strcmp(temp,'O')
     filetype = 'obs0r';
  elseif strcmp(temp,'o1r')  | strcmp(temp,'O1r')
     filetype = 'obs1r';  else
     disp('Unacceptable! Pick again')
  end
end

%-------------------------------------------------------------------------------

function [training_fid, songs_fid] = get_batchfiles

% Prompts user for training and song batchfiles

global pathname

training_fid = -1;
trainingfile = 0;
   disp('Select Training Batchfile');
   [trainingfile, pathname]=uigetfile('*','Select Training Batchfile');
   training_fid=fopen([pathname, trainingfile]);
   if training_fid == -1 | trainingfile == 0
        error(['Cannot open file: ' trainingfile]);
   end

songs_fid = -1;
songsfile = 0;
   disp('Select Batchfile of Songs to be Labeled');
   [songsfile, pathname]=uigetfile('*','Select Batchfile of Songs to be Labeled');
   songs_fid=fopen([pathname, songsfile]);
   if songs_fid == -1 | songsfile == 0
        error(['Cannot open file: ' songsfile]);
   end
   

%-------------------------------------------------------------------------------

function [sylls, index, labelIndex] = read_training(training_fid)

% Gets syllables and labels from training batchfile

global pathname

sylls = [];
index =[];
labelIndex = [];

while 1
   %get soundfile name
     soundfile = fscanf(training_fid,'%s',1);
   %end when there are no more notefiles 
     if isempty(soundfile)
        break
     end
   
     
   notefile=[soundfile, '.not.mat'];
   filtfile=[soundfile, '.filt'];
     
   % Skip file if it doesn't exist or has no .not.mat file
    if ~(exist(soundfile) & exist(notefile))   
        disp(['Skipping ', soundfile, ' (file or .not.mat file does not exist)'])
        continue
    end
    
    % Read filt file if it exists, otherwise read and filter raw song, saving a copy
    if exist(filtfile)
       [filtsong, fs]=read_filt(filtfile);
    else
        [song,fs]=soundin(pathname, soundfile, filetype);
        filtsong=bandpass(song,fs,300,8000);
        write_filt(filtfile, filtsong, fs);
    end
    
    load(notefile);
        
    %make sure labels is a column vector
    [x,y]=size(labels);
    if y > x
        labels=labels';
    end 
    
    disp(['Processing ' soundfile ' . . .']); 
    
    % convert onsets and offsets from ms to samples
    on = fix(onsets.*fs/1000);
    off = fix(offsets.*fs/1000);
    
    % normalize the amplitude of the syllables
    %filtsong=normalize_sylls(filtsong, on, off);
    
    % For each syllable in the song file
    for i = 1:size(labels,1)
        
        % Skip certain labels
        if labels(i)=='0' | labels(i)=='x'
            continue
        end
           
        % Add syll
        sylls = [sylls; {filtsong(on(i):off(i))}];
        % Add label to index if it isn't there already
        if isempty(labelIndex) | isempty(find(labelIndex == labels(i)))
            labelIndex = [labelIndex; labels(i)];
        end
        % add label to index of sylls, in numerical form
        index = [index; find(labelIndex == labels(i))];
        
    end 
end

% Count number of examples and report results
counts = zeros(size(labelIndex));
for i = 1:size(labelIndex, 1)
    counts(i) = size(find(index == i),1);
    disp(['Found ' int2str(counts(i)) ' examples of ' labelIndex(i)]);
end
% Remove label if it has less than 40 examples
i = 1;
while i <= size(labelIndex,1)
    if counts(i) < 40
        disp(['Removing ' labelIndex(i)]);
        labelIndex = labelIndex(find(labelIndex ~= labelIndex(i)));
        sylls = sylls(find(index ~= i));
        index = index(find(index ~= i));
        for k = i:size(labelIndex,1)+1
            index(find(index == k)) = k - 1;
        end
        i = i - 1;
    end
    i = i + 1;
end

%-------------------------------------------------------------------------------

function [trainingSylls, testSylls, trainingIndex, testIndex] = splitSylls(sylls, index)

% Splits sylls into two groups, one for training template and one for testing. Training group must have at least
% 30 of examples of each type. 

global labelIndex

% decision vector, whether or not a syllable will be used for training
forTraining = zeros(size(index));

% how many of each type have been selected for training
counts = zeros(size(labelIndex));

disp('Splitting labeled syllables.');

while ~all(counts == 30)

    % choose randomly, so as not to get biased examples
    spot = ceil(rand*size(index,1));
    
    if forTraining(spot) 
        continue
    elseif counts(index(spot)) == 30
        continue
    else
        forTraining(spot) = 1;
        counts(index(spot)) = counts(index(spot)) + 1;
    end

end

% split syllables and index
trainingSylls = sylls(find(forTraining == 1));
trainingIndex = index(find(forTraining == 1));
testSylls = sylls(find(forTraining == 0));
testIndex = index(find(forTraining == 0));

%-------------------------------------------------------------------------------

function [feats, confidenceThresh]=get_feats(trainingSylls, testSylls, trainingIndex, testIndex)

% Uses a bit of brute force to find a good set of feature detectors. Pulls them from training syllables 
% which are then used as templates for labeling the test syllables. If a new random feature detector
% improves the accuracy it is kept, replacing an old feature in whose place it improves accuracy the most.
%
% confidenceThresh is a threshold with regards to the confidence rating of each syllable, below which 
% syllables are left blank. There ought to be some fancy way of calculating the optimal threshold for 
% each particular set of songs (optimal being a balance of avoiding mistakes and not leaving too many blank)
% but I haven't thought of that yet. When I do it should go here, I think. 

ReadFeats = 0;

confidenceThresh = 15;
num = 9; % number of feature detectors to get
cycles = 40; % number of random features to screen - this is the slowest part of the program

if ReadFeats
    disp('Reading feature detectors from feats.mat');
    load feats.mat
else

% feature vectors for the templates and test syllables - twice the number of features for two windows
templateFV = zeros(size(trainingSylls,1),2*num);
testFV = zeros(size(testSylls,1),2*num);

% random initial feats
feats = randfeat(trainingSylls,num);

disp('Getting good features');
disp('  Calculating initial feature vectors');

% calculate feature vectors, making sure each feature is in a known place
for i = 1:num
    for k = 1:size(trainingSylls,1)
        trainingFV(k,(2*i)-1:2*i) = feature_vect(trainingSylls{k}, feats(i,:),0);
    end
    for k = 1:size(testSylls,1)
        testFV(k,(2*i)-1:2*i) = feature_vect(testSylls{k}, feats(i,:),0);
    end
end
       
% score of initial random feature detectors
currentScore = score(testFV, trainingFV, trainingIndex, testIndex);

disp(['Initial Score: ' int2str(currentScore) ' out of ' int2str(size(testIndex,1))]);

for n = 1:cycles

    disp(['Cycle ' int2str(n) ' of ' int2str(cycles)]);
    
    feat = randfeat(trainingSylls);
    
    replace = 0;  % whether or not a this feature will replace an old one, and if so where
    newScore = 0; % if a feature dector does better than before, this is its new score
    
    
    tmFV =[]; % single pair of feature values for this feature on template sylls
    for k = 1:size(trainingSylls,1)
        tmFV = [tmFV; feature_vect(trainingSylls{k}, feat, 0)];
    end
    tsFV = []; % ditto on test sylls
    for k = 1:size(testSylls,1)
        tsFV = [tsFV; feature_vect(testSylls{k}, feat, 0)];
    end
    
    % try using the new feature detector in each location
    for i = 1:num

        ntestFV = testFV;
        ntrainingFV = trainingFV;
        ntestFV(:,(2*i)-1:2*i) = tsFV;
        ntrainingFV(:,(2*i)-1:2*i) = tmFV;
                
        thisScore = score(ntestFV, ntrainingFV, trainingIndex, testIndex);
        if thisScore > currentScore & thisScore > newScore
            newScore = thisScore;
            replace = i; % replace at this location
        end
        
    end
    
    if replace
        currentScore = newScore;
        feats(replace,:) = feat;
        testFV(:,(2*replace)-1:2*replace) = tsFV;
        trainingFV(:,(2*replace)-1:2*replace) = tmFV;
        disp(['Replacing Feature. Current Score is ' int2str(currentScore) ' out of ' int2str(size(testIndex,1))]);
    end
    
end

disp('Saving features to feats.mat.');

save feats.mat feats;

end

%-------------------------------------------------------------------------------

function numRight = score(testFV, trainingFV, trainingIndex, testIndex)

% classifies test set and returns the number labeled correctly

class = classify(testFV, trainingFV, trainingIndex);

numRight = size(find(class == testIndex),1);

%-------------------------------------------------------------------------------

function feats = randfeat(sylls,num)

% Randomly choose a 100 sample feature dector, or a set of them, from the cell array of syllables.

if nargin == 1
    num = 1;
end

feats = [];

for i = 1:num
    syllnum = ceil(rand(1)*size(sylls,1));
    spot = ceil(rand(1)*(size(sylls{syllnum},1)-100));
    
    feat = sylls{syllnum}(spot:spot+99)';
    feats = [feats; feat];
end
    
%-------------------------------------------------------------------------------

function templates = make_templates(templateSylls, feats)

% Calculates feature vectors for all example syllables and the set of feature detectors which will be used.

disp('Making templates.');

templates = [];

for i = 1:size(templateSylls,1)
    templates = [templates; feature_vect(templateSylls{i}, feats, 0)]; % last arg is the durflag which tells
                                                                       % feature_vect whether or not to use
end                                                                    % duration as the last feature

%-------------------------------------------------------------------------------

function label(songfile, feats, templates, index, confidenceThresh)

% Labels a song and saves the labels in a .not.mat file. 

global labelIndex
global filetype
global pathname

disp(['Labeling ' songfile]);

filtfile = [songfile, '.filt'];
notefile = [songfile, '.not.mat'];

% If filtfile exists, read it, otherwise filter rawsong and save
if exist(filtfile)
    [filtsong, fs]=read_filt(filtfile);
else
    [song,fs]=soundin(pathname, songfile, filetype);
    filtsong=bandpass(song,fs,300,8000);
    write_filt(filtfile, filtsong, fs);
end

% if notefile exists use its segmentation boundries
if exist(notefile)
    load(notefile);
    % save old notefile 
    oldNotefile = [notefile, '.old'];
    save(oldNotefile);
    on = fix(onsets.*fs/1000);
    off = fix(offsets.*fs/1000);
    if off(end) > length(filtsong)
        off(end) = length(filtsong);
    end
else
    % segment song
    [on, off] = segm(filtsong,fs,5,20);
    onsets = on./(fs*1000);
    offsets = off./(fs*1000);
    % other variables in a .not.mat file
    Fs = fs;
    threshold = 31515;
    min_int = 5;
    min_dur = 20;
    sm_win = 2;
end

% filtsong=normalize_sylls(filtsong, on, off);

% calculate feature vectors
featvect = [];
for i = 1:size(on,1)
    start = on(i);
    stop = off(i);
    featvect = [featvect; feature_vect(filtsong(start:stop), feats, 0)];
end

nlabels=zeros(size(featvect,1), 1); % labels as numerical index to templates array

% size of featvect, number of unknowns
sfv=size(featvect,1);
% number of elements in index, number of syllable labels 
maxi=max(index);

% calculate mahalonobis distance to each group
% this is the core code from the matlab function 'classify'. that function isn't used so that some information
% can be saved for the confidence measure.
d = zeros(sfv,maxi);
for k = 1:maxi
    templatek = templates(find(index == k),:);
    d(:,k) = mahal(featvect,templatek);
end

% class is the group to which the mahal distance is smallest
[tmp, class] = min(d');
class = class';

% confidence measure of each label
confidence = zeros(size(class));

sortd=sort(d');
for i=1:sfv
    % confidence is simply the difference between the winner and the runner up
    % i.e., if it was a close race then maybe the winner shouldn't have won
    confidence(i) = sortd(2,i) - sortd(1,i);
end



labels=[];

% Turn number into letter label
for i = 1:size(featvect,1)    
    labels=[labels; labelIndex(class(i,1))];
end

% set the confidence threshold such that ~20% of syllables will be left blank
%sortc = sort(confidence);
%confidenceThresh = sortc(ceil(size(sortc,1)/5));
%labels(find(confidence < confidenceThresh)) = '-';

% save results
eval(['save ', notefile,...
       ' Fs',' onsets',' offsets',' labels',...
       ' threshold',' min_int',' min_dur',' sm_win',' confidence']);


%------------------------------------------------------------------------------

function countblanks(songs_fid)

% Gives some concluding remarks. 

labeledCount = 0;
blankCount = 0;
numSongs = 0;

frewind(songs_fid);

while 1
   %get soundfile name
     songfile = fscanf(songs_fid,'%s',1);
   %end when there are no more notefiles 
     if isempty(songfile)
        break
     end

    numSongs = numSongs + 1; 
    notefile = [songfile '.not.mat'];
    load(notefile);

    for i = 1:size(labels,1)
        if labels(i) == '-'
            blankCount = blankCount + 1;
        else
            labeledCount = labeledCount + 1;
        end
    end
end

disp(['Labeled ' int2str(numSongs) ' songs.']);
disp(['Gave labels to ' int2str(labeledCount) ' syllables.']);
disp(['Left ' int2str(blankCount) ' blank.']);

percentLabeled = fix(100*(labeledCount / (labeledCount + blankCount)));

disp([int2str(percentLabeled) ' percent of syllables labeled.']);
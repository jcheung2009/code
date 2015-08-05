function [classes, probabilities] = AutoClass(autoclassfile,autoclassPath,snippets,numTries,cyclesPerTry,verbose)
%[classes, probabilities] = AutoClass(snippets)
% Generates the autoclass files necessary to classify a complete,
% non-independent set of real values into groups. Will return both the
% classes and the probabilities. Options are described in the AutoClass
% documentation.

if(~exist('verbose','var'))
    verbose = 1;
end
if(~exist('numTries','var'))
    numTries = 5;
end
if(~exist('cyclesPerTry','var'))
    cyclesPerTry = 50;
end

%set some constansts, need to use version compiled with msvc. Cygwin binary
%does not produce results file unless run with cygwin. [UNTESTED: Or change
%"G_safe_file_writing_p" to false in globals.c]
% autoclassfile = 'spikes';
% autoclassPath = 'C:\Users\Bryan\Documents\MATLAB\BryanSpikeSort\CurrentSorter\'; %needs to be connected to cygwin1.dll

numFeatures = size(snippets,2);

%prepare for autoclass
%delete previous results file (will generate unskippable warning 
if(exist([autoclassfile '.results'],'file'))
    delete([autoclassfile '.results']);
end
%generate header file (.hd2)
generateAutoClassHeader([autoclassfile '.hd2'],numFeatures);
%generate model file (.model)
generateAutoClassModel([autoclassfile '.model'],numFeatures);
%generate search file (.s-params)
generateAutoClassSearch([autoclassfile '.s-params'],verbose,numTries,cyclesPerTry);
%generate reports file (.r-params)
generateAutoClassReports([autoclassfile '.r-params'],verbose);
%generate data file (.db2)
generateAutoClassDatabase([autoclassfile '.db2'],snippets);


    
%run autoclass program via dos (require cygwin1.dll in directory)
%run search
dos([autoclassPath 'AutoClass -search ' autoclassfile '.db2 ' autoclassfile '.hd2 ' autoclassfile '.model ' autoclassfile '.s-params ']);

%run report
dos([autoclassPath 'AutoClass -reports ' autoclassfile '.results ' autoclassfile '.search ' autoclassfile '.r-params ']);


%read autoclass output
[classes, probabilities] = parseAutoClassText([autoclassfile '.class-text-1']);



function generateAutoClassHeader(filename,numFeatures)
%writes an autoclass header file.

%an error Value Constant, use STD deviation?
errorVal = 0.1;

fh = fopen(filename,'w');
fprintf(fh,'num_db2_format_defs 1\n'); %write this file's format
fprintf(fh,'number_of_attributes %d\n',numFeatures); %write number of features

for i = 0:numFeatures-1  %write a description of each feature
    fprintf(fh,'%d real location "Feature %d" error %f\n',i,i,errorVal);
end
fclose(fh);

function generateAutoClassModel(filename,numFeatures)
%write an autoclass model file.
%has two possible styles, will test both hopefully remove one
fh = fopen(filename,'w');

% fprintf(fh,'model_index 0 1\n');
% fprintf(fh,'multi_normal_cn default');

fprintf(fh,'model_index 0 2\n');
fprintf(fh,'multi_normal_cn '); %no line break
for i = 0:numFeatures-1
    fprintf(fh,'%d ',i);
end
fprintf(fh,'\nmulti_normal_cn default');
fclose(fh);

function generateAutoClassSearch(filename,verbose,numTries,cyclesPerTry)
%write an autoclass search file.

fh = fopen(filename,'w');
fprintf(fh,'max_n_tries = %d\n',numTries); %end condition is number of searches
fprintf(fh,'save_compact_p = %s\n','false'); %whether to save in .bin format
fprintf(fh,'break_on_warnings_p = %s\n','false'); %whether it asks about warnings
fprintf(fh,'max_cycles = %d\n',cyclesPerTry); %

%I found that this pattern of base searches worked well for my data
fprintf(fh,'start_j_list = 1,2,5,3,5\n'); %start searches with these group sizes
%I found that "converge" worked better than "converge_search_3" or "..4"
fprintf(fh,'try_fn_type = "converge"\n');%an alternative search technique

if(~verbose)
    fprintf(fh,'screen_output_p = %s\n','false'); %default is true
end
fclose(fh);

function generateAutoClassReports(filename,verbose)
%write an autoclass report file

fh = fopen(filename,'w');
fprintf(fh,'report_mode = "%s"\n','text'); %alternative is data format
fprintf(fh,'report_type = "%s"\n','xref_class');%could do 'all' as well
fprintf(fh,'break_on_warnings_p = %s\n','false');
fclose(fh);

function generateAutoClassDatabase(filename,snippets)
%write data file
dlmwrite(filename,snippets,'delimiter',' ');


function [classes, probabilities] = parseAutoClassText(filename)
    %[classes, probabilities] = parseAutoClassText(filename)
    %opens a .class.text.n file created by AutoClass and returns the most
    %probable spike assignmens for each class. Not returned, but present, are 
    %probabilities of other class assignments. Data points not assigned to
    %classes are assigned to class -1. This function will be inaccurate if the
    %file outputs class alternatives on new lines (they overwrite actual data
    %in this version). An alternative data format may actually be more
    %parsable.
    %INPUT:
    %   filename - the .class.text.n filename and path
    %OUTPUT:
    %   classes - the most probable class assignments
    %   probabilities - the probability of the most likely clas

    fh = fopen(filename);
    %use states to manage current operations. No class is -1.
    currentClass = -1;

    %create large default arrays of size 
    defaultSize = 100000;
    classes = {};
    probabilities = {};


    tline = fgetl(fh);
    while(~feof(fh))
        [token, remains] = strtok(tline);
        if(strcmp(token,'CLASS')) %we've reached a new class line if it starts with CLASS X
            [token, remains] = strtok(remains); %gets equals sign
            [token, remains] = strtok(remains); %gets number
            if(currentClass == str2double(token)) %sometimes it continues
                %this classs is continuing do nothing
            else
                if(currentClass ~= -1)
                    classes{end} = classes{end}(1:assignCount);
                    probabilities{end} = probabilities{end}(1:assignCount);
                end
                currentClass = str2double(token); %read the number of the class
                classes{end+1} = nan(defaultSize,1);
                probabilities{end+1} = nan(defaultSize,1);
                assignCount = 0;
            end
        elseif(~sum(isletter(token)) && ~isempty(token) && token(1) ~= '-') %we're at a class assignment if there are no letters
            assignCount = assignCount+1;
            classes{end}(assignCount) = str2double(token); %read assignment
        %DEBUG
            if(isnan(str2double(token)))
                disp('here');
            end
        %-DEBUG
            [token, remains] = strtok(remains); %get the class probability
            probabilities{end}(assignCount) = str2double(token);
        else %otherwise just continue on, because the line doesn't matter
            %continue;
        end


        %read the next line and repeat
        tline = fgetl(fh);
    end

    %clean up last class
    classes{end} = classes{end}(1:assignCount);
    probabilities{end} = probabilities{end}(1:assignCount);

    %now that we're done with the parsing, reformat so it's prettier
    runningTotal = 0;
    for i = 1:length(classes); %figure out how many samples there are
        runningTotal = runningTotal + length(classes{i});
    end
    tempClasses = -1*ones(runningTotal,1);
    tempProbs = zeros(runningTotal,1);

    for i = 1:length(classes); %assign the samples their classes
        tempClasses(classes{i}) = i;
        tempProbs(classes{i}) = probabilities{i};
    end

    classes = tempClasses;
    probabilities = tempProbs;
    
    fclose(fh);
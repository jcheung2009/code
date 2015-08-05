function jc_changelabel(bt,regexpression,repsyl);
%change labels using regular expression to find variable target sequence


fid=fopen(bt,'r');
files=[];cnt=0;
while (1)
	fn=fgetl(fid);
	if (~ischar(fn))
		break;
	end
	cnt=cnt+1;
	files(cnt).fn=fn;
end
fclose(fid);
replace_all_syllables_in_repeat = input('replace all sylables in repeat?:','s');
if replace_all_syllables_in_repeat== 'y'
    for ii=1:length(files)
        fn=files(ii).fn;
        if (exist([fn,'.not.mat'],'file'))
            load([fn,'.not.mat']);
            [ind1 ind2] = regexp(labels,regexpression);
            labelind = 1:length(labels);
            for i = 1:length(ind1)
                indicestoreplace = labelind(labelind>ind1(i) & labelind<ind2(i));
                for jj = 1:length(indicestoreplace)
                    labels(indicestoreplace(jj))=repsyl;
                end
            end
            save([fn,'.not.mat'],'labels','-append');
        end
    end
end
replace_first_syllable = input('replace only the first syllable in the repeat?:','s');
if replace_first_syllable == 'y'
     for ii=1:length(files)
        fn=files(ii).fn;
        if (exist([fn,'.not.mat'],'file'))
            load([fn,'.not.mat']);
            ind = regexp(labels,regexpression);
            labels(ind) = repsyl;
            save([fn,'.not.mat'],'labels','-append');
        end
     end
end
     
     
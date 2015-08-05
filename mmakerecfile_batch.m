function mmakerefile_batch(batch)
%
%
% mmakerecfile_batch(batch)
% creates rec files for wav files in batch
%
%

files = load_batchf(batch);
for i=1:length(files);
    
    fn=files(i).name;
	if (~ischar(fn));
		break;
    end
    mmakerecfile(fn);
end
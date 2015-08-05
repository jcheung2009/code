% Right now all song files will be raw byte-swapped files
% Fixed sampling rate
SAMP_RATE = 44100
nchannels = 1
SAMP_SIZE = 2
SAMP_TYPE = 'int16'

bigfile = input(['Enter name of data file to split: '], 's')
batch_file = input(['Enter name of batch file listing output files: '], 's')
outfileprefix = bigfile;

fid = fopen(bigfile,'r','b');
fidb = fopen(batch_file,'wt');

fseek(fid,0,'eof');  
filesize = ftell(fid)
fseek(fid,0,'bof');  

disp(['File size is ', num2str(filesize), ' bytes.'])
data_length = filesize/(SAMP_SIZE*nchannels);
disp(['Length of data file: ', num2str(data_length*1000/SAMP_RATE), ...
    ' msec, ', num2str(data_length/(SAMP_RATE*60)), ' minutes.']);

nchunks = input(['Enter the number of files to split the data into: '])

chunk_size = fix(data_length/nchunks)

data_len_proc = 0;

for nc=1:nchunks
  if nc == nchunks
    chunk_size = data_length - (nc - 1)*chunk_size;
  end
  [data_chunk,num_read] = fread(fid,chunk_size,SAMP_TYPE);
  if num_read == chunk_size
    data_len_proc = data_len_proc + length(data_chunk);
    outfile = [outfileprefix,'.',num2str(nc)]
    fido = fopen(outfile, 'w', 'b')
    num_write = fwrite(fido,data_chunk,SAMP_TYPE)
    fclose(fido)
    fprintf(fidb,'%s\n',outfile);
    if num_write ~= num_read
      disp(['Num read: ' num2str(num_read)])
      disp(['Num written: ' num2str(num_write)])
      disp(['Chunk size: ' num2str(chunk_size)])
      error('Incorrect amount of data written.')
    end
  else
    disp(['Num read: ' num2str(num_read)])
    disp(['Chunk size: ' num2str(chunk_size)])
    error('Incorrect amount of data read.')
  end
 
end

fclose(fid)
fclose(fidb)

disp('Done.')


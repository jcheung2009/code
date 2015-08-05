function [dat,fs]=ReadEvTAFFile(filename,chan);
% ReadEvTAFFile(filename,chan);
% example : [dat,fs]=ReadEvTAFFile('o26bk80_081006_1627.6701.cbin',0);
%            dat - is the raw data from the first channel ('0' is first chan)
%	     fs  - sampling freq in Hz
% written by : 	Evren Tumer
%		Brainard lab
%		Univ. California, San Francisco
% adapted from code written by other lab members
%

fs=-1;
dat=[];
NChan=0;

if (~exist(filename,'file'))
	disp(['File does not exist : ',filename]);
	return;
end

pp=findstr(filename,'.cbin');
if (length(pp)==0)
	disp(['Needs to be a ''.cbin'' file : ',filename]);
	return;
end

if (~exist([filename(1:pp(end)),'rec'],'file'))
	disp(['Rec file does not exist : ',filename(1:pp(end)),'rec']);
	disp(['Assumming 32 kHz with 1 channel!!']);
	NChan=1;
	fs=32e3;
else
	rd=readrecf(filename,0);
	fs    = rd.adfreq;
	NChan = rd.nchan;
end

if (chan<0)|(chan>=NChan)
	disp(['Channel needs to be a number between 0 and NChan-1 [',...
				num2str(NChan-1),']']);
	return;
end

fid=fopen(filename, 'r','b');
if ~isnumeric(fid)
        error(['Could not open file ' filename]);
end

[skipdata, count] = fread(fid,chan,'short');
if (count~=chan),
	fclose(fid);
   	error(['Could not read from datafile: ',filename]);
end
skip=(NChan-1)*2;
[dat,cnt] = fread(fid,inf,'short',skip);
fclose(fid);

if (cnt~=rd.nsamp)
	disp(['Warning number of samples read [',...
		num2str(length(dat)),'] does not match rec file [',...
		num2str(rd.nsamp),']!']);
end
return;

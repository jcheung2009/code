
clear;

Savedir='Ctrl/';

keyboard

if Savedir(end)~='/'
    Savedir=[Savedir '/'];
end;

mkdir(Savedir);
mkdir('NoSong');

SylA=load('C:\Hamish\Data\2013\Screen\Pur42Bwn2\SylA_Control_CircShifts.dat');


template=SylA(:,1);


fid=fopen('batch','r');
files=[];cnt=0;

%Load Batch File;

while (1)
	fn=fgetl(fid);
	if (~ischar(fn))
		break;
	end
	cnt=cnt+1;
	files(cnt).fn=fn;
end
fclose(fid);

GoodFiles=zeros(length(files),1);


for i=1:length(files);
    
    disp(files(i).fn)

    [dat,fs]=evsoundin(files(i).fn,'obs');
    [sm,sp,t,f]=evsmooth(dat,fs,10,255,0.8,2);    
    sp=abs(sp);  
    sp(1:6,:)=0;    
    
% 
%     test=sum(sqrt(((sp(:,j)-template).^2)));
    C = sp-diag(template)*ones(size(sp));
    C=sum(sqrt(C.^2));
    test=min(C);

    if min(test) < 75000
        disp(test);
        GoodFiles(i)=1;                    
    else
        GoodFiles(i)=0;          
    end;                    
    
end;
        

for i=2:length(GoodFiles)    
    if GoodFiles(i)==1        
        movefile(files(i).fn,['./' Savedir])
        movefile([files(i).fn(1:end-4) 'rec'],['./' Savedir]);
        movefile([files(i).fn(1:end-4) 'tmp'],['./' Savedir]);        
    elseif GoodFiles(i)==0
        movefile(files(i).fn,'./NoSong')
        movefile([files(i).fn(1:end-4) 'rec'],'./NoSong');
        movefile([files(i).fn(1:end-4) 'tmp'],'./NoSong');    
     end;
end;
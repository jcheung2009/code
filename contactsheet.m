function [out] = contactsheet(optional_batch)

out = 0;

disp_size = 9; % number of cbins / wavs to preview at once
scrsz = get(0,'ScreenSize');


if nargin==1
    path='';
    batch=optional_batch;
else
    [batch,path] = uigetfile('*','Select Batch file');
    pause(.1);
end
ff = load_batchf(batch);

% fin=fopen([path,batch]); % batch file ID
% file = fscanf(fin,'%s',1);

fighandle = figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);
set(fighandle,'Color','white');
numcells = ceil(sqrt(disp_size));

cnt = 1;
while cnt < length(ff)
    thecell = 1;
    disp('working...');
    figure(fighandle);
    for ii = 1:1:disp_size
        subhandle = subplot(numcells,numcells,thecell);cla reset;
        mplotcbin_fast(ff(cnt).name,[]);
        title(ff(cnt).name(5:end-5),'interpreter','none');
        set(gca,'yTickLabel','');
        thecell = thecell +1;
        cnt = cnt+1;
    end
    disp('paused');
    figure(fighandle);
    zoom xon;
    pause
    clf(fighandle,'reset');
    %close(fighandle);
    out = out+1;
end

% while ~isempty(file); % each file in batch
%     thecell = 1;
%     disp('working...');
%     figure(fighandle);
%     for(i=1:1:disp_size);
%         fullfile=file;
%         if ~(file(1)=='/')
%             fullfile=[path,file];
%         end
% 
%         if (fullfile(end-7:end)=='.not.mat')
%             fullfile=fullfile(1:end-8);
%         end
% 
% %         if (fullfile(end-4:end)=='.cbin')
% %             titlestr = '';
% %             type='obs0r';
% %         else
% %             type='w';
% %         end
% 
% %         [rawsong fs] = evsoundin(path,file,type);
% %         rawsong = rawsong((1.5*fs):length(rawsong));
% %         timebase = maketimebase(length(rawsong),fs);
%         subhandle = subplot(numcells,numcells,thecell);cla reset;
%         %disp('before mplotcbin()')
%         mplotcbin_fast(file,[]);
%         %disp('after mplotcbin()')
%         title(file(5:end-5),'interpreter','none');
%         set(gca,'yTickLabel','');
% 
%         %disp(fullfile);
%         thecell = thecell +1;
%         file = fscanf(fin,'%s',1); % advances to the next line in batch
% 
%     end
%     disp('paused');
%     figure(fighandle);
%     zoom xon;
%     pause
%     clf(fighandle,'reset');
%     %close(fighandle);
%     out = out+1;
% end




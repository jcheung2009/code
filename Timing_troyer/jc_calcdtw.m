function  jc_calcdtw(batch,template,specparams)
% [warp,range,Dcum] = calcdtw(varargin)
% calculate DTW maps for clips in a labeled bookmark file 
% varargin can be used to set the following parameter/value pairs
% mlim - specifies bounds on dtw in terms of deviation from uniform timing
%   if 0<=mlim<1, mlim specifies fraction of template length
%   otherwise, mlim specifies number of bins 
%   default is mlim = .25
% boundary - specifies extent and cost along edges that terminate path
%    default is boundary = zeros(mlim,1);
% interpolate - flags whether to interpolate exmplar values to match length
%   of template (cubic spline interpolation, default = 1)
%batch = list of spec.mats in specs_for_note folder

%% set defaults
caldtw.thresh = .75;
caldtw.metric = @mnsqrdev2;
caldtw.mlim = .25;
caldtw.boundary = [];
caldtw.interpolate = 1;
caldtw.savespecs = 1;
caldtw.freqrange = [0 16]; % frequency range to use for DTW (in kHz)

ff = load_batchf(batch);
% find frequency indices
caldtw.freqinds = find(specparams.f>=caldtw.freqrange(1) & specparams.f<=caldtw.freqrange(2));

%% warp all note specs 
fulltemp = abs(template);
% tempamp = ftr_amp(fulltemp,specparams.f,'freqrange',caldtw.freqrange);
% figure; hold on;plot(tempamp,'k');
% result = input('threshold? (0-1):');
% caldtw.thresh = result;
% abovethreshinds = find(tempamp>caldtw.thresh);
% tempedges = [min(abovethreshinds) max(abovethreshinds)];
% temp = fulltemp(:,tempedges(1):tempedges(2));
temp = fulltemp;
%% set mlim in units of time bins and find frequency indices
if caldtw.mlim>0 & caldtw.mlim<1
    caldtw.mlim = ceil(caldtw.mlim*size(temp,2));
end
if isempty(caldtw.boundary)
    caldtw.boundary = zeros(caldtw.mlim,1);
    %caldtw.boundary = zeros(ceil(caldtw.mlim/10),1);
end

wb = waitbar(0,'Calculating DTW maps');
for i = 1:length(ff)
    fn = ff(i).name;
    load(fn);
    dtwspecs = struct();
    for ii = 1:length(notespecs)
        if specparams.tds == 1
            exemplar = abs(notespecs(ii).spectds);
        else
            exemplar = abs(notespecs(ii).spec);
        end
        [warp range M Dpath Dcum mv] = dtw(temp,exemplar,...
            'freqinds',caldtw.freqinds,'metric',caldtw.metric,'mlim',caldtw.mlim,'boundary',caldtw.boundary);
        %[warp range M Dpath Dcum mv] = dtw(temp,exemplar(:,notespecs(ii).specedges(1):notespecs(ii).specedges(2)),...
         %   'freqinds',freqinds,'metric',caldtw.metric,'mlim',caldtw.mlim,'boundary',caldtw.boundary);
        
        dtwspecs(ii).warp = warp;
        dtwspecs(ii).range = range;
        dtwspecs(ii).diffmatrix = M;
        dtwspecs(ii).Dpath = Dpath;
        dtwspecs(ii).Dcum = Dcum;
        dtwspecs(ii).move = mv;
        
        if caldtw.savespecs
            dtwspecs(ii).warpspec = warpinterp(exemplar,...
                warp,'pad',zeros(size(exemplar,1),1));
            %dtwspecs(ii).warpspec = warpinterp(exemplar(:,notespecs(ii).specedges(1):notespecs(ii).specedges(2)),...
               % warp,'pad',zeros(size(exemplar,1),1));
        end
    end
    save(fn,'dtwspecs','-append');
    waitbar(i/length(ff),wb);
end
save('calcdtwparams.mat','caldtw');
save('template.mat','temp','-append');
close(wb)


 
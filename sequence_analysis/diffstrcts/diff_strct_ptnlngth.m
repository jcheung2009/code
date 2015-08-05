function [diff_ptnstrct,mtched_ptnstrct] = diff_strct_ptnlngth(strct1,patterns,lngth)

% function diff_ptnstrct = diffstrct(strct1,pattern)
% finds the set difference of the patterns that are in strct1 that do not match pattern
% <strct1>: a ptnstrct from get_pattern
% <pattern>: a string containing specific pattern of syllables to be
% searched for.  Each pattern must conclude with '$', the terminal marker.
%   eg. 'abcd$ccc$oplk$' can be used to search for 'abcd', 'ccc', and 'oplk'...
%        and thus diff_ptnstrct will not contain any of those patterns
% 
% <diff_ptnstrct>: the pattern struct of patterns that are in strct1 but
% do not match pattern

    
transleng = size(strct1);
for i = 1:transleng(2)
    diff_ptnstrct(i).ptnsngindx = strct1(i).ptnsngindx;
    diff_ptnstrct(i).ptnlblindx = strct1(i).ptnlblindx;  
    diff_ptnstrct(i).ptnlbls = strct1(i).ptnlbls;
    diff_ptnstrct(i).ptnons = strct1(i).ptnons;
    diff_ptnstrct(i).ptnoffs = strct1(i).ptnoffs;
    diff_ptnstrct(i).nxtonset = strct1(i).nxtonset;
    diff_ptnstrct(i).totptnsng = strct1(i).totptnsng;
    diff_ptnstrct(i).fname = strct1(i).fname;
    diff_ptnstrct(i).ptntot = strct1(i).ptntot;
end
     

breaks = strfind(patterns,'$');
strtindx = 1;
szdiffstrct = size(diff_ptnstrct);
for k = 1:length(breaks)
    ptntotntfnd = 0;
    ptntotfnd = 0;
    pattern = patterns(strtindx:breaks(k)-1);
    strtindx = breaks(k)+1;
	for i = 1:szdiffstrct(2) -1
        nmbptnsng = diff_ptnstrct(i).totptnsng;
        mtchedptnindx = [];
        if ~isempty(nmbptnsng)
            diffindx = [1:nmbptnsng];
            for j = 1:nmbptnsng
                cntlbl = char(diff_ptnstrct(i).ptnlbls(j));
                for g = 1:lngth
                    cntlbl2 = cntlbl(1:g);
                    if ~isempty(pattern)
                        if strcmp(char(cntlbl2),char(pattern(1:g)))
                           mtchedptnindx = [mtchedptnindx j];
                        end
                    end
                end
            end
            
            if ~isempty(mtchedptnindx)
                mtched_ptnstrct(i).ptnsngindx = diff_ptnstrct(i).ptnsngindx(:,mtchedptnindx);
                mtched_ptnstrct(i).ptnlblindx = diff_ptnstrct(i).ptnlblindx(:,mtchedptnindx); 
                mtched_ptnstrct(i).ptnlbls = diff_ptnstrct(i).ptnlbls(:,mtchedptnindx); 
                mtched_ptnstrct(i).ptnons = diff_ptnstrct(i).ptnons(:,mtchedptnindx); 
                mtched_ptnstrct(i).ptnoffs = diff_ptnstrct(i).ptnoffs(:,mtchedptnindx); 
                mtched_ptnstrct(i).nxtonset = diff_ptnstrct(i).nxtonset(:,mtchedptnindx);
                mtched_ptnstrct(i).totptnsng = length(mtchedptnindx);
                mtched_ptnstrct(i).fname = diff_ptnstrct(i).fname;
                mtched_ptnstrct(i).ptntot = [];
                ptntotntfnd = ptntotntfnd + length(mtchedptnindx);
            else
                mtched_ptnstrct(i).ptnsngindx = [];
                mtched_ptnstrct(i).ptnlblindx = [];
                mtched_ptnstrct(i).ptnlbls = []; 
                mtched_ptnstrct(i).ptnons = []; 
                mtched_ptnstrct(i).ptnoffs = []; 
                mtched_ptnstrct(i).nxtonset = [];
                mtched_ptnstrct(i).ptnlblindx = [];
                mtched_ptnstrct(i).ptnlblindx = diff_ptnstrct(i).fname;
                mtched_ptnstrct(i).ptntot = [];
                ptntotntfnd = ptntotntfnd + length(mtchedptnindx);
            end
            
            diffindx = setdiff(diffindx,mtchedptnindx);
            
            if ~isempty(diffindx)
                diff_ptnstrct(i).ptnsngindx = diff_ptnstrct(i).ptnsngindx(:,diffindx);
                diff_ptnstrct(i).ptnlblindx = diff_ptnstrct(i).ptnlblindx(:,diffindx);  
                diff_ptnstrct(i).ptnlbls = diff_ptnstrct(i).ptnlbls(:,diffindx);
                diff_ptnstrct(i).ptnons = diff_ptnstrct(i).ptnons(:,diffindx);
                diff_ptnstrct(i).ptnoffs = diff_ptnstrct(i).ptnoffs(:,diffindx);
                diff_ptnstrct(i).nxtonset = diff_ptnstrct(i).nxtonset(:,diffindx);
                diff_ptnstrct(i).totptnsng = length(diffindx);
                diff_ptnstrct(i).fname = diff_ptnstrct(i).fname;
                diff_ptnstrct(i).ptntot = [];
                ptntotfnd = ptntotfnd +length(diffindx); 
            else
                diff_ptnstrct(i).ptnsngindx = [];
                diff_ptnstrct(i).ptnlblindx = [];
                diff_ptnstrct(i).ptnlbls = [];
                diff_ptnstrct(i).ptnons = [];
                diff_ptnstrct(i).ptnoffs = [];
                diff_ptnstrct(i).nxtonset = [];
                diff_ptnstrct(i).totptnsng = [];
                diff_ptnstrct(i).fname = strct1(i).fname;
                diff_ptnstrct(i).ptntot = [];
                ptntotfnd = ptntotfnd +length(diffindx);
            end 
        end
     end
  
    diff_ptnstrct(szdiffstrct(2)).ptnsngindx = [];
    diff_ptnstrct(szdiffstrct(2)).ptnlblindx = [];
    diff_ptnstrct(szdiffstrct(2)).ptnlbls = [];
    diff_ptnstrct(szdiffstrct(2)).ptnons = [];
    diff_ptnstrct(szdiffstrct(2)).ptnoffs = [];
    diff_ptnstrct(szdiffstrct(2)).nxtonset = [];
    diff_ptnstrct(szdiffstrct(2)).totptnsng = [];
    diff_ptnstrct(szdiffstrct(2)).fname = [];
    diff_ptnstrct(szdiffstrct(2)).ptntot = ptntotfnd;
 
    mtched_ptnstrct(szdiffstrct(2)).ptnsngindx = [];
    mtched_ptnstrct(szdiffstrct(2)).ptnlblindx = [];
    mtched_ptnstrct(szdiffstrct(2)).ptnlbls = []; 
    mtched_ptnstrct(szdiffstrct(2)).ptnons = []; 
    mtched_ptnstrct(szdiffstrct(2)).ptnoffs = [];
    mtched_ptnstrct(szdiffstrct(2)).nxtonset = [];
    mtched_ptnstrct(szdiffstrct(2)).ptnlblindx = [];
    mtched_ptnstrct(szdiffstrct(2)).ptnlblindx = [];
    mtched_ptnstrct(szdiffstrct(2)).ptntot = ptntotntfnd; 
 
end
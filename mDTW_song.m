function [outvect idvect] = mDTW_song(cbin,templates)
%
%
% [outvect idvect] = mDTW_song(cbin,templates)
%
% uses Dynamic Time Warping to compute distance between auto-segmented
% syllables in cbin and template syllables in Templates. Cbin is a cbin or
% wav song file, and templates is a struct of template syllables 
%
%
%

[ons offs segments] = mplotsegments(cbin,0); % segment song

[filepath,filename,fileext] = fileparts(cbin); % load raw song
if(strcmpi(fileext,'.cbin'))
    [plainsong,fs] = ReadCbinFile(cbin);
elseif(strcmpi(fileext,'.wav'))
    [plainsong,fs] = wavread(cbin);
    %plainsong = plainsong *10e3; % boost amplitude to cbin levels
end

outvect = zeros(length(ons),1); % initialize output vectors
idvect = outvect;

templateNames = fieldnames(templates);

for i=1:length(ons) % each segmented syllable in song file
    theSyll = plainsong(ons(i):plainsong(offs(i)));
    theD = 0;
    for t=1:length(templates) % each template syllable
        theTemplateName = templateNames(t);
        theTemplate = templates.(theTemplateName);
        [dist,accDist,normFactor,optPath,rawWarp,tempWarp] = dtw(theSyll,theTemplate,0);
        if(t == 1)
            theD = dist * normFactor;
            idvect = t;
        else
            if((dist *normFactor) < theD) % if pathlength is shorter than previous warp, set outs to current template
                theD = dist * normFactor;
                idvect(i) = t;
            end
        end
    end
    
    
end




end
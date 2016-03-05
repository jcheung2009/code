function [pitchgapcorr] = jc_pitchgapcorr(motif_sal,motif_cond,syllind,durind,...
    numgapsfor,numgapsback,excludewashin,startpt,matchtm)
%pairwise trial by trial correlation of pitch and serial gaps 


tb_sal = jc_tb([motif_sal(:).datenm]',7,0);
tb_cond = jc_tb([motif_cond(:).datenm]',7,0);

if excludewashin == 1 & ~isempty(startpt)
    ind = find(tb_cond < startpt);
    motif_cond(ind) = [];
elseif excludewashin == 1
    ind = find(tb_cond<tb_sal(end)+1800); %exclude first half hour of wash in 
    motif_cond(ind) = [];
end

if ~isempty(matchtm)
    indsal = find(tb_sal>=tb_cond(1) & tb_sal <= tb_cond(end)); 
    motif_sal = motif_sal(indsal);
end 

tb_sal = jc_tb([motif_sal(:).datenm]',7,0);
tb_cond = jc_tb([motif_cond(:).datenm]',7,0);

pitch_sal = arrayfun(@(x) x.syllpitch(syllind),motif_sal,'unif',1)';
pitch = arrayfun(@(x) x.syllpitch(syllind),motif_cond,'unif',1)';
if numgapsback ~= 0
   gapsback_sal = cell2mat(arrayfun(@(x) x.gaps(durind-1:-1:1)',motif_sal,'unif',0)'); 
   gapsback = cell2mat(arrayfun(@(x) x.gaps(durind-1:-1:1)',motif_cond,'unif',0)'); 
else
    gapsback_sal = [];
    gapsback = [];
end

if numgapsfor ~= 0
    gapsfor_sal = cell2mat(arrayfun(@(x) x.gaps(durind:end)',motif_sal,'unif',0)');
    gapsfor = cell2mat(arrayfun(@(x) x.gaps(durind:end)',motif_cond,'unif',0)');
else
    gapsfor_sal = [];
    gapsfor = [];
end


pitchgapcorr.sal.pitch = pitch_sal;
pitchgapcorr.sal.gapsfor = gapsfor_sal;
pitchgapcorr.sal.gapsback = gapsback_sal;

pitchgapcorr.cond.pitch = pitch;
pitchgapcorr.cond.gapsfor = gapsfor;
pitchgapcorr.cond.gapsback = gapsback;

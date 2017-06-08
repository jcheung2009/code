function changelabel(batch,orignote, PRENT, PSTNT, newstr,maxgap);
%maxgap is time in ms for greatest gap between PRENT and PSTNT from orignote 
%length of newstr needs to equal [PRENT orignote PSTNT]

prentln=length(PRENT);
if length(PSTNT) > 0
    postln = 1;
else
    postln = 0;
end
newstrlen=length(newstr);
origstr=[PRENT orignote PSTNT];

ff = load_batchf(batch);
for ii=1:length(ff)
	fn=ff(ii).name;
	if (exist([fn,'.not.mat'],'file'))
		load([fn,'.not.mat']);
        ind=findstr(labels,origstr);
        
        for jj=1:length(ind)
             if length(labels)>=ind(jj)+newstrlen-1
                 if ~isempty(maxgap)
                     if(onsets(ind(jj)+prentln)-offsets(ind(jj)+prentln-1))<maxgap...
                             & (onsets(ind(jj)+prentln+postln)-offsets(ind(jj)+prentln))<maxgap%gap between orig note and offset of prent
                        labels(ind(jj):ind(jj)+newstrlen-1)=newstr;
                     end
                 else
                     labels(ind(jj):ind(jj)+newstrlen-1)=newstr;
                 end
             end
        end
    
    save([fn,'.not.mat'],'labels','-append');
    
    end
end
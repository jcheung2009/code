figure
osnum=[1:6]
osnum=[2 3 5 6 7 9 12]
% osnum=1
colvec={'k' 'r' 'c'}
for ii=1:length(osnum)
    osvl=osnum(ii);
    ax(ii)=subplot(7,1,ii);
    for jj=1:length(outstr(osvl).mndiff)
        diffvls=[];
        ervls=[]
        tmvls=[];
        for kk=1:length(outstr(osvl).mndiff{jj})
        
            diffvls=[diffvls -outstr(osvl).mndiff{jj}{kk}]
            ervls=[ervls outstr(osvl).mner{jj}{kk}]
            tmvls=[tmvls outstr(osvl).tm{jj}{kk}]
        end
%         plot(tmvls,diffvls,'k','Linewidth',2);
        hold on;
        for zz=1:length(diffvls)
            plot([tmvls(zz) tmvls(zz)],[diffvls(zz)-ervls(zz) diffvls(zz)+ervls(zz)],'Color',colvec{jj},'Linewidth',2)
        end
    end
end
 linkaxes(ax);   
% 
% for ii=1:8
% plot(outstr(9).tm{3}{ii},outstr(9).mndiff{3}{ii},'c.')
% hold on;
% end
% 
%     
% 
% diffvls=[];
%     ervls=[]
%     tmvls=[];
%     for ii=1:length(outstr.mndiff)
%         diffvls=[diffvls -outstr.mndiff{ii}]
%         ervls=[ervls outstr.mner{ii}]
%         tmvls=[tmvls outstr.tm{ii}]
%     end
%     plot(tmvls,diffvls,'k','Linewidth',2);
%     hold on;
%     for ii=1:length(outstr.mndiff)
%         plot([tmvls(ii) tmvls(ii)],[diffvls(ii)-ervls(ii) diffvls(ii)+ervls(ii)],'k','Linewidth',2)
%     end
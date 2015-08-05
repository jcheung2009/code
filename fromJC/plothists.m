%plothists
%very general histogram plotting fxn.  takes histogram struct.
%with fields of edges, Color, Linestyle, 
%created 8.29.08 for purposes of inactivation plots.
function [ax] = plothists(hs);
    
    for hnm=1:length(hs)
        axes(hs(hnm).ax);
        edg=hs(hnm).edges;
%         vls=hs(hnm).hst;
        col=hs(hnm).col;
        ls=hs(hnm).ls;
        wid=hs(hnm).wid'
        
        %redimension edges
        for ii=1:length(edg)-1
            edgred(ii)=(edg(ii)+edg(ii+1))/2;
        end
%         vlsred=vls(1:1:end-1);
        if(hs(hnm).plothist)
            if (hs(hnm).orient=='norm')
                stairs(edgred,vlsred,'Color',col,'Linestyle',ls,'Linewidth',wid);
                hold on;
            else
                stairs(vlsred,edgred,'Color',col,'Linestyle',ls,'Linewidth',wid);
                hold on;
            end
        end
        if(hs(hnm).plotline)
            
            wid=hs(hnm).lw
%             pts=hs(hnm).pts;
            marked=hs(hnm).marked;
            markx=hs(hnm).markx;
            marklnht=hs(hnm).marklnht;
            markht=hs(hnm).markht;
            
            if(hs(hnm).orient=='flip')
                plot([marklnht marklnht], [marked],'Color',col,'Linewidth',wid);
                hold on;
%                 plot(marklnht,markx,'Marker',hs(hnm).mark,'Color',col)
            
            else
                plot([marked],[marklnht marklnht] ,'Color',col,'Linewidth',wid);
                hold on;
%                 plot(markx,marklnht,'Marker',hs(hnm).mark,'Color',col)
            end   
        end
    end


%rewritten 9.16.08 in order to change plotting to nyt style lines.
%also now make it so it only plots the line, another program plots which
%lines to call.
% %This program plots lines as defined by ls (linesize) and ms (markersize) struct.  Originally designed
% 
% % %fields are ls(lineind).pts([x y x y])
% %             ls(lineind).color
% % %             ls(lineind).width
% % %             ms(markind).marksize[w1]
% % %             ms(markind).markcolor[col1]
% %               ms(markind).markpts([x y])  
%                  (linind).markertype   
function []=lineplot(ls,ms)
% axes(ls.ax);
%first plot lines
for linind=1:length(ls)
    ln=ls(linind);
    x1=ln.pts(1);
    x2=ln.pts(3);
    y1=ln.pts(2);
    y2=ln.pts(4);
    wid=ln.wid
    col=ln.col;
    plot([x1 x2],[y1 y2], 'Color', col, 'Linewidth', wid)
    hold on;
end

%now plot markers
if(~isempty(ms))
    for markind=1:length(ms)
        mk=ms(markind);
        if ~isempty(mk.markpts);
            x=mk.markpts(1);
            y=mk.markpts(2);
            sz=mk.marksize;
            tp=mk.markertype;
            col=mk.markcolor;
            plot(x,y,tp,'MarkerFaceColor', col,'MarkerEdgeColor',col,'MarkerSize',sz);
        end
    end
end
    
end
    

    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make graphics fit on screen
function fitOnScreen(fig)
units=get(0,'units');
set(0,'units','pixels');
scrsize=get(0,'screensize');
set(0,'units',units);
set(fig,'units','pixels');
set(fig,'Position',(scrsize+[4 34 -8 -111]));
end

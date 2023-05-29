function GetGrain() ;
  function GetData(obj,init = false)
    h = guidata(obj) ;
    switch (gcbo)
      case {h.Save}
        setappdata(0,'Index',str2num(get(h.Index,'string'))) ;
        close(h.F)
    endswitch
  end

  R.F = figure("toolbar", "none",'uicontextmenu',[],'menubar','none','name',"Input Index",'NumberTitle','off','resize','off','units','normalized',"Position", [0.35 0.4 0.25 0.2]) ;
  R.Text1 = uicontrol(R.F,'style','text','units','normalized','string','Index Number:','position',[0.20 0.70 0.25 0.15],'callback','','backgroundcolor',get(R.F,"Color")) ;
  R.Index = uicontrol(R.F,'style','edit','units','normalized','string','1','position',[0.5 0.70 0.25 0.15],'callback','') ;
  R.Save = uicontrol(R.F,'style','pushbutton','units','normalized','string','Save...','position',[0.35 0.25 0.35 0.2],'callback',@GetData) ;

  guidata (R.F, R) ;
  GetData(R.F,true)
end

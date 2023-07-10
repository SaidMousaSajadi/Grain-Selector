close all ; clear all ; clc ;

graphics_toolkit qt % or fltk(PLC/old) , qt(apps) , gnuplot(sites)
pkg load image % images
##pkg load statistics % pdist
##pkg load ltfat % normalize

%%%%%%%%%
function Processing(STR,obj)
  switch lower(STR)
    case {'e'}
      set(obj,'string',' Error Occurred')
      set(obj,'backgroundcolor',[1 0.785 0.785])
    case {'p'}
      set(obj,'string',' In Processing')
      set(obj,'backgroundcolor',[1 0.863 0.666])
    case {'r'}
      set(obj,'string',' Ready')
      set(obj,'backgroundcolor',[0.785 1 0.785])
    otherwise
      set(obj,'string',[' ' STR])
      set(obj,'backgroundcolor',[0.785 1 0.785])
  end
end
%%%%%%%%%
root.FlagIM = 0 ;
root.FlagLabel = 0 ;

function Update_UI(obj,init = false)
  h = guidata(obj) ; % get handles
  switch (gcbo)

    case {h.Open}
      Processing('p',h.Process)
      [h.FileName, h.FilePath, h.FileIndex] = uigetfile({"*.jpeg;*.jpg;*.tiff;*.tif;*.png", "Supported Picture Formats";"*.png", "Portable Network Graphics";"*.jpeg ; *.jpg", "Joint Photographic Experts Group";"*.tif ; *.tiff", "Tagged Image File Format"}) ;
      if (h.FileIndex) ~= 0
        NameSpl = strsplit(h.FileName,".") ;
        switch lower(NameSpl{1,end})
          case {'png','jpg','jpeg','tiff','tif'}
            [h.IM , h.Map]= imread([h.FilePath h.FileName]) ;
            [h.IM_G , ~] = Image2Gray(h.IM,h.Map) ; % h.IM_G = double(rgb2gray(h.IM))/255 ;
            axes(h.Ax_Hist);
            imhist(h.IM_G) ;
            axes(h.Ax);
            if ~islogical(h.IM)
              imshow(h.IM,h.Map) ;
            else
              imshow(h.IM(:,:,1)) ;
            end
            h.Base_axis = axis(h.Ax) ;
            h.Cust_axis = axis(h.Ax) ;            
            h.FlagIM = 1 ;
            guidata(gcf,h) % update handles
        end
      end
      Processing('r',h.Process)

    case {h.Home}
      axis(h.Base_axis)
      zoom off
    case {h.ZoomModeOn}
      zoom on
    case {h.ZoomModeOff}
      zoom off
    case {h.ZoomIn}
      zoom(1.1) ;
      zoom off
    case {h.ZoomOut}
      zoom(0.9) ;
      zoom off
    case {h.CustomZoom}
      axis(h.Cust_axis)
      zoom off
    case {h.SetZoom}
      h.Cust_axis = axis(h.Ax) ;
      zoom off
      guidata(gcf,h) % update handles

    case {h.Label}
      if h.FlagIM == 1
        Processing('p',h.Process)
        IM_G = h.IM_G ;
        if ~islogical(IM_G)
          if get(h.Radio0,'Value') %%%%%% Dark
            IM_BW = im2bw(1-IM_G,1-get(h.Bar,'Value')) ;
          else %%%%%% Light
            IM_BW = im2bw(IM_G,get(h.Bar,'Value')) ;
          end
        else
          if get(h.Radio0,'Value') %%%%%% Dark
            IM_BW = IM_G ;
          else %%%%%% Light
            IM_BW = ~IM_G ;
          end
        end
        % denoise / morphology / filling
        IM_DE = bwareaopen(IM_BW,30);
        se = strel('disk',2,0);
        IM_MO = imclose(IM_DE,se);
        IM_Fill = imfill(IM_MO,'holes');
        Bound = bwboundaries(IM_Fill) ;
        axes(h.Ax);
        if ~islogical(h.IM)
          imshow(h.IM,h.Map) ;
        else
          imshow(h.IM(:,:,1)) ;
        end
        hold(h.Ax,'on')
        for m = 1:length(Bound)
          B = Bound{m,1};
          plot(B(:,2),B(:,1),'b','LineWidth',1) ;
          text(mean(B(:,2)),mean(B(:,1)),num2str(m),'clipping', 'on') ;
        end
        hold(h.Ax,'off')
        h.Bound = Bound ;
        h.FlagLabel = 1 ;
        guidata(gcf,h) % update handles
        Processing('r',h.Process)
      end

    case {h.Save}
      if h.FlagLabel == 1
        Processing('p',h.Process)
        [FileName, FilePath, FileIndex] = uiputfile({"*.jpeg;*.jpg;*.png", "Supported Picture Formats";"*.png", "Portable Network Graphics";"*.jpeg ; *.jpg", "Joint Photographic Experts Group"}) ;
        if (FileIndex) ~= 0
          GetGrain ;
          uiwait ;
          Index = getappdata(0,'Index') ;
          Fo = figure('name',"Saved Image",'NumberTitle','off','resize','off',"toolbar", "none",'uicontextmenu',[],'menubar','none') ;
          Ax = axes("Units",'Normalized',"Position",[0.01 0.01 0.99 0.99]) ;
          Bi = h.Bound{Index,1} ;
          patch(Ax,Bi(:,2),Bi(:,1),'k')
          set(gca,'YDir','reverse') ; set(Ax,'XColor','none') ; set(Ax,'YColor','none')
          axis equal
          F = getframe(Ax);
          Image = frame2im(F);
          imwrite(Image, [FilePath ,  FileName])
        end
        Processing('r',h.Process)
      end


    case {h.Bar}
      Processing('p',h.Process)
      set(h.Text,'string',['GrayScale To Labeling: ' num2str(get(h.Bar,'value'))])
      Processing('r',h.Process)

    case {h.Radio0}
      Processing('p',h.Process)
      set (h.Radio0, "value", 1);
      set (h.Radio1, "value", 0);
      Processing('r',h.Process)

    case {h.Radio1}
      Processing('p',h.Process)
      set (h.Radio0, "value", 0);
      set (h.Radio1, "value", 1);
      Processing('r',h.Process)

  end
end

root.Fig = figure("toolbar", "none",'uicontextmenu',[],'menubar','none','name',"Grain Selector",'NumberTitle','off','units','normalized',"Position", [2.1962e-03 6.2500e-02 9.9414e-01 8.6979e-01],"CloseRequestFcn",'exit') ;
root.F = uimenu("label", "&File", "accelerator", "f");
root.E = uimenu("label", "&Edit", "accelerator", "e");
root.H = uimenu("label", "&Help", "accelerator", "h");

# Subs
root.Open = uimenu(root.F, "label", "&Open Image", "accelerator", "O", "callback", @Update_UI);
root.Ex = uimenu(root.F, "label", "E&xit", "accelerator", "X","callback", 'close(root.Fig) ; exit');

root.Label = uimenu(root.E, "label", "&Labeling", "accelerator", "L", "callback", @Update_UI);
root.Save = uimenu(root.E, "label", "&Save Image by Index Number", "accelerator", "S", "callback", @Update_UI);

uimenu(root.H, "label", "&Documentation", "accelerator", "D","callback", "system(['start ./Manual.pdf']) ;"); %
uimenu(root.H, "label", "About Me", "accelerator", "","callback", "web('https://www.linkedin.com/in/seyed-mousa-sajadi-8284b1124/','-new')"); %

# In Window
root.P = uipanel(root.Fig,'units','normalized','Position',[0.01 0.91 0.20 0.07],'visible','on','backgroundcolor',get(root.Fig,'Color'));
root.Text = uicontrol(root.P,'style','text','units','normalized','position',[0.1 0.55 0.80 0.4],'string','GrayScale To Labeling: 0.89','backgroundcolor',get(root.Fig,'Color'),'fontsize',9);
root.Bar = uicontrol(root.P,'style','slider','units','normalized','position',[0.01 0.10 0.97 0.3],'sliderstep',[0.010000 0.100000],'min',0,'max',1,'Value',0.89,'callback',@Update_UI);

root.Ax = axes(root.Fig,'units','normalized',"position", [0.01 0.0325 0.98 0.84],'box','on','xtick',[],'ytick',[]);
root.Ax_Hist = axes(root.Fig,'units','normalized',"position", [0.32 0.91 0.20 0.07],'box','on','xtick',[],'ytick',[]);
root.Radio0 = uicontrol (root.Fig, "style", "radiobutton", "string","Dark" ,"units","normalized","position", [0.23 0.90 0.04 0.05],'fontsize',7,'backgroundcolor',get(root.Fig,"Color"),'value' , 0,'callback',@Update_UI);
root.Radio1 = uicontrol (root.Fig, "style", "radiobutton", "string","Light","units","normalized","position", [0.53 0.90 0.04 0.05],'fontsize',7,'backgroundcolor',get(root.Fig,"Color"),'value' , 1,'callback',@Update_UI);

root.Home = uicontrol(root.Fig,"string", "🏠",'units','normalized','Position',[0.635 0.91 0.05 0.035],'fontsize',8,'callback',@Update_UI); %
root.ZoomModeOn = uicontrol(root.Fig,"string", "🔎",'units','normalized','Position',[0.695 0.91 0.05 0.035],'fontsize',8,'callback',@Update_UI); %
root.ZoomModeOff = uicontrol(root.Fig,"string", "🔎⛔",'units','normalized','Position',[0.755 0.91 0.05 0.035],'fontsize',8,'callback',@Update_UI); %
root.ZoomIn = uicontrol(root.Fig,"string", "🔎+",'units','normalized','Position',[0.815 0.91 0.025 0.035],'fontsize',8,'callback',@Update_UI); %
root.ZoomOut = uicontrol(root.Fig,"string", "🔎-",'units','normalized','Position',[0.845 0.91 0.025 0.035],'fontsize',8,'callback',@Update_UI); %
root.CustomZoom = uicontrol(root.Fig,"string", "🏠📌🔁",'units','normalized','Position',[0.88 0.91 0.05 0.035],'fontsize',8,'callback',@Update_UI); %
root.SetZoom = uicontrol(root.Fig,"string", "📌",'units','normalized','Position',[0.94 0.91 0.05 0.035],'fontsize',7,'callback',@Update_UI); %

root.Process = uicontrol(root.Fig,'style','text','units','normalized','position',[0.0 0.0 0.05 0.025],'string',' Ready','backgroundcolor',[0.785 1 0.785],"horizontalalignment",'left','fontsize',7);

guidata(gcf,root) ;
Update_UI(gcf,true)
pause

# cd D:\Full_Codes\Octave\GrainSelector
# cls ; octave .\Main.m

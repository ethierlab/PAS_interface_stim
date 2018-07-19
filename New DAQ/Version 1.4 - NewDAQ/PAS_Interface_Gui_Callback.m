function hGui = PAS_Interface_Gui_Callback(s)
%DataCaptureUI_PAS Create a graphical user interface for data capture.
%   HGUI = DataCaptureUI_PAS(S) returns a structure of graphics
%   components handles (HGUI) and creates a graphical user interface, by
%   programmatically creating a figure and adding required graphics
%   components for visualization of data acquired from a DAQ session (S).

% position:[pixels from left, pixels from bottom, pixels across, pixels high]

% Create a figure and configure a callback function (executes on window close)
Fig = figure('Name','PAS Experiment Interface 1.3', ...
    'NumberTitle', 'off', 'Resize', 'on', 'Position', [45 65 1350 730]);
set(Fig, 'DeleteFcn', {@endDAQ, s});
uiBackgroundColor = get(Fig, 'Color');
hGui = guihandles(Fig); 
hGui.DataResponseSingle = {};
hGui.DataResponseProbe = {};
hGui.DataResponseProbeEMG = {};
hGui.DataTableContents = {}; 
hGui.NumPushTimeSingleTrain = 0;
hGui.NumPushTimeProbeTrain = 0;
hGui.NumPushTimeProbeEMGTrain = 0;
hGui.NumPushTimeTotal = 0;
hGui.SourceRate = s.Rate;
hGui.databufferCapture = {};

% Defaults parameters of the edit text box
hGui.BeforeStim_Var = '500';
hGui.AfterStim_Var = '500';
hGui.PulseProbe_Var = '30';
hGui.MinProbeTime_Var = '1';
hGui.MaxProbeTime_Var = '3';
hGui.InterProbe_Var = '1';
hGui.EMGTime_Var = '50';
hGui.EMGWindowLow_Var = '10';
hGui.EMGWindowHigh_Var = '25';
hGui.PulsePAS_Var = '1000';
hGui.InterPAS_Var = '1';
hGui.MinPAS_Var = '1';
hGui.MaxPAS_Var = '3';

% Create the continuous data plot axes with legend
% Premier plot : les EMGs
hGui.Axes1 = axes;
hGui.LivePlotEMG = plot(0, zeros(1,4));  %numel(s.Channels(1:3)
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Continious acquisition data (EMG)');
legend({'EMG', 'Filtre EMG','Trig Cortex', 'Trig Muscle'},'Units', 'Pixels', 'Position', [1190 650 120 70]); %get(s.Channels(1:4), 'ID')
set(hGui.Axes1, 'Units', 'Pixels', 'Position',  [490 450 820 190]);
set(hGui.LivePlotEMG(2,1),'LineWidth',1.3); %'Color',[1 0 0]
%set(hGui.Axes1, 'YAxisLocation', 'origin');

% Deuxi�me plot : les trigger envoy�s
hGui.Axes2 = axes;
hGui.LivePlotTrig = plot(0, zeros(1, numel(s.Channels(2:3))));
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Continious acquisition data (trigger)');
hGui.LivePlotTrig(1,1).Color = [0.9290 0.6940 0.1250]; % SelectionState dependent
hGui.LivePlotTrig(2,1).Color = [0.4940 0.1840 0.5560];
set(hGui.Axes2, 'Units', 'Pixels', 'Position',  [490 300 820 90]);
linkaxes([hGui.Axes1,hGui.Axes2],'x');

% Create the captured data plot axes (one line per acquisition channel)
hGui.Axes3 = axes('Units', 'Pixels', 'Position', [490 50 820 190]);
hGui.CapturePlot = plot(NaN, NaN(1,4));
xlabel('Time (s)');
ylabel('Voltage (V)');
title('EMG response');

% --------------------------------------------------

% Titre de l'interface
uicontrol('style', 'text', 'string', 'PAS Experiment Interface 1.3','FontSize',...
    20, 'FontName', 'Yu Gothic UI' , 'FontWeight', 'bold', 'ForegroundColor', [0 0.8 0.4],...
    'HorizontalAlignment', 'Center', 'units', 'pixels', 'position', [425 670 500 40]);

% Section pour Probe
uicontrol('style', 'text', 'string', 'Probe Section', 'FontSize', 13,...
    'FontName', 'Yu Gothic UI' , 'FontWeight', 'bold', 'ForegroundColor', [0 0.5 1],...
    'HorizontalAlignment', 'Center', 'units', 'pixels', 'position', [60 673 320 30]);

% Create an editable text field for the Before Stim recording
hGui.BeforeStim = uicontrol('style', 'edit', 'string', hGui.BeforeStim_Var,...
    'units', 'pixels', 'position', [190 575 50 25]); %[60 465 50 25]);

% Le texte au-dessus de hGui.BeforeStim
uicontrol('style', 'text', 'string', 'Before Stim (ms) ',...
    'units', 'pixels', 'position', [189 602 54 28]); %[57 492 60 25]);

% Create an editable text field for the After Stim recording
hGui.AfterStim = uicontrol('style', 'edit', 'string', hGui.AfterStim_Var,...
    'units', 'pixels', 'position', [255 575 50 25]); %[125 465 50 25]);
 
% Le texte au-dessus de hGui.AfterStim
uicontrol('style', 'text', 'string', 'After Stim (ms) ',...
    'units', 'pixels', 'position', [255 602 54 28]); %[126 492 50 25]);

% Create an editable text field for the number of pulses for Probe
hGui.PulseProbe = uicontrol('style', 'edit', 'string', hGui.PulseProbe_Var,... 
    'units', 'pixels', 'position', [60 575 50 25]);

% Le texte au-dessus de hGui.PulseProbe
uicontrol('style', 'text', 'string', 'Trains','HorizontalAlignment', 'Center', ...
    'units', 'pixels', 'position', [60 600 50 20]);

% % Create an editable text field for the minimun time between each probe
% hGui.MinProbeTime = uicontrol('style', 'edit', 'string', hGui.MinProbeTime_Var,...
%     'units', 'pixels', 'position', [190 575 50 25]);
% 
% % Le texte au-dessus de hGui.MinProbeTime
% uicontrol('style', 'text', 'string', 'Min Probe Time (s) ',...
%     'units', 'pixels', 'position', [189 600 54 30]);
% 
% % Create an editable text field for the maximun time between each probe
% hGui.MaxProbeTime = uicontrol('style', 'edit', 'string', hGui.MaxProbeTime_Var,...
%     'units', 'pixels', 'position', [255 575 50 25]);
% 
% % Le texte au-dessus de hGui.MaxProbeTime
% uicontrol('style', 'text', 'string', 'Max Probe Time (s) ',...
%     'units', 'pixels', 'position', [254 600 54 30]);

% Create an editable text field for time to wait between each pulse for PAS
hGui.InterProbe = uicontrol('style', 'edit', 'string', hGui.InterProbe_Var,...
    'units', 'pixels', 'position', [125 575 50 25]);

% Le texte au-dessus de hGui.InterProbe
uicontrol('style', 'text', 'string', 'Inter-Train time (s)', 'HorizontalAlignment', 'Center',...
    'units', 'pixels', 'position', [123 600 54 28]);

% Create an editable text field for time to wait for a good EMG level
hGui.EMGTime = uicontrol('style', 'edit', 'string', hGui.EMGTime_Var,...
    'units', 'pixels', 'position', [60 520 50 25]);

% Le texte au-dessus de hGui.EMGTime
uicontrol('style', 'text', 'string', 'EMG wait time (ms) ', 'HorizontalAlignment', 'Center',...
    'units', 'pixels', 'position', [58 545 54 28]);

% Create an editable text field for time to wait for a good EMG level
hGui.EMGWindowHigh = uicontrol('style', 'edit', 'string', hGui.EMGWindowHigh_Var,...
    'units', 'pixels', 'position', [190 520 50 25]);

% Le texte au-dessus de hGui.EMGWindowHigh
uicontrol('style', 'text', 'string', 'High limit (mV) ', 'HorizontalAlignment', 'Center',...
    'units', 'pixels', 'position', [188 545 54 28]);

% Create an editable text field for time to wait for a good EMG level
hGui.EMGWindowLow = uicontrol('style', 'edit', 'string', hGui.EMGWindowLow_Var,...
    'units', 'pixels', 'position', [125 520 50 25]);

% Le texte au-dessus de hGui.EMGWindowLow
uicontrol('style', 'text', 'string', 'Low limit (mV) ', 'HorizontalAlignment', 'Center',...
    'units', 'pixels', 'position', [123 545 54 28]);

% Create an editable text field for time to wait for a good EMG level
hGui.FlagDisplay = uicontrol('style', 'edit', 'string','...',...
    'units', 'pixels', 'position', [60 465 80 25]);

% Le texte au-dessus de hGui.FlagDisplay
uicontrol('style', 'text', 'string', 'Current EMG Condition', 'HorizontalAlignment', 'Center',...
    'units', 'pixels', 'position', [56 490 88 28]);

% -------------------------------------------------

% Create a checkbox to stimulate the cortex 
hGui.CheckCortexStim = uicontrol('style', 'checkbox', 'string', 'Cortex Stim.',...
    'units', 'pixels', 'position', [230 640 80 15]);
set(hGui.CheckCortexStim, 'Value', 1)

% Create a checkbox to stimulate the muscle 
hGui.CheckMuscleStim = uicontrol('style', 'checkbox', 'string', 'Muscle Stim.',...
    'units', 'pixels', 'position', [310 640 80 15]);

% Create a checkbox to keep the data in the live plot the same
hGui.StopTimeAxis = uicontrol('style', 'checkbox', 'string', 'Stop Time Axis',...
    'units', 'pixels', 'position', [210 470 100 15]);

% Create a checkbox to stop the probe EMG or the PAS without closing the UI
hGui.StopWhileLoop = uicontrol('style', 'checkbox', 'string', 'Stop Process',...
    'units', 'pixels', 'position', [210 490 100 15]);

% % Create a checkbox to allow an random spacing for the Probe EMG Stim
% hGui.RandomProbe = uicontrol('style', 'checkbox', 'string', 'Random Spacing',...
%     'units', 'pixels', 'position', [190 490 105 15]);

% Create a checkbox to use the rising emg signal
hGui.RisingOption = uicontrol('style', 'checkbox', 'string', 'Rising',...
    'units', 'pixels', 'position', [255 542 50 15]);

% Create a checkbox to use the rising emg signal
hGui.FallingOption = uicontrol('style', 'checkbox', 'string', 'Falling',...
    'units', 'pixels', 'position', [255 522 50 15]);

% % Create a checkbox to use the rising emg signal
% hGui.STDOption = uicontrol('style', 'checkbox', 'string', 'STD Limits',...
%     'units', 'pixels', 'position', [180 440 105 15]);

% --------------------------------------------------

% Section pour les PAS
uicontrol('style', 'text', 'string', 'PAS Experiment Section', 'FontSize',13,...
    'FontName', 'Yu Gothic UI' , 'FontWeight', 'bold', 'ForegroundColor', [1 0.6 0.2],...
    'HorizontalAlignment', 'Center', 'units', 'pixels', 'position', [60 410 320 30]);

% Create an editable text field for the number of pulses for PAS
hGui.PulsePAS = uicontrol('style', 'edit', 'string', hGui.PulsePAS_Var,...
    'units', 'pixels', 'position', [60 350 50 25]);

% Le texte au-dessus de hGui.PulsePAS
uicontrol('style', 'text', 'string', 'Trains','HorizontalAlignment', 'Center', ...
    'units', 'pixels', 'position', [60 375 50 20]);

% Create an editable text field for time to wait between each pulse for PAS
hGui.InterPAS = uicontrol('style', 'edit', 'string', hGui.InterPAS_Var,...
    'units', 'pixels', 'position', [125 350 50 25]);

% Le texte au-dessus de hGui.InterPAS
uicontrol('style', 'text', 'string', 'Inter-Train time (s)', 'HorizontalAlignment', 'Center',...
    'units', 'pixels', 'position', [123 375 54 30]);

% Create an editable text field for the minimun time to wait for PAS
hGui.MinPAS = uicontrol('style', 'edit', 'string', hGui.MinPAS_Var,...
    'units', 'pixels', 'position', [190 350 50 25]);

% Le texte au-dessus de hGui.MinPAS
uicontrol('style', 'text', 'string', 'Min time (s) (random) ', 'HorizontalAlignment', 'Center',...
    'units', 'pixels', 'position', [187 375 58 30]);

% Create an editable text field for the maximun time to wait for PAS
hGui.MaxPAS = uicontrol('style', 'edit', 'string', hGui.MaxPAS_Var,...
    'units', 'pixels', 'position', [255 350 50 25]);

% Le texte au-dessus de hGui.MaxPAS
uicontrol('style', 'text', 'string', 'Max time (s) (random) ', 'HorizontalAlignment', 'Center',...
    'units', 'pixels', 'position', [251 375 60 30]);

% Create a checkbox to allow an random spacing for the PAS Stim
hGui.RandomPAS = uicontrol('style', 'checkbox', 'string', 'Random Spacing',...
    'units', 'pixels', 'position', [60 320 125 25]);

% --------------------------------------------------

% Section pour les donn�es (display et save)
uicontrol('style', 'text', 'string', 'Data Section', 'FontSize',13,...
    'FontName', 'Yu Gothic UI' , 'FontWeight', 'bold', 'ForegroundColor', [1 0.1 0.1],...
    'HorizontalAlignment', 'Center', 'units', 'pixels', 'position', [60 295 320 30]);

hGui.DataTable = uitable(Fig,'ColumnWidth',{55 55 69.3 53},'ColumnName',...
    {'Single','Probe','ProbeEMG','Display'},'Position',[52 60 255 220]);
hGui.DataTable.Data = {};
hGui.DataTable.ColumnEditable = true;

% Create a checkbox to allow an average response of the EMG
hGui.Average = uicontrol('style', 'checkbox', 'string', 'Average',...
    'units', 'pixels', 'position', [320 190 75 15]);

% Create a checkbox to allow a reticfication in capture
hGui.ZeroRectification = uicontrol('style', 'checkbox', 'string', 'Zero Rectification',...
    'units', 'pixels', 'position', [320 170 100 15]);

% --------------------------------------------------

% Creation des boutons et autres

% Create a status text field
hGui.StatusText = uicontrol('style', 'text', 'string', '',...
    'units', 'pixels', 'position', [60 25 225 25],...
    'HorizontalAlignment', 'left', 'BackgroundColor', uiBackgroundColor);

% Create a popup menu to select the channel to display in continuous axes
% hGui.ContSelect = uicontrol('Style', 'popup','String',...
%     {'Cortex+Trig (AI0+AI2)','Muscle+Trig (AI1+AI3)','Cortex (AI0)','Muscle (AI1)','Trig Cortex(AI2)','Trig Muscle (AI3)','ALL'},'Position',[60 606 130 50]);

% Create a popup menu to select the channel to display in continuous axes
hGui.ContSelect = uicontrol('Style', 'popup','String',...
    {'EMG + Trig Cortex + Filtre','EMG + Trig Cortex','EMG + Trig Muscle + Filtre','EMG + Trig Muscle'},'Position',[60 606 150 50]);

% Le texte au-dessus de hGui.ContSelect
uicontrol('style', 'text', 'string', 'Measurement Selection','HorizontalAlignment', 'Center', ...
    'units', 'pixels', 'position', [60 660 150 15]);

% Create a manual stim button (muscle) and configure a callback function
hGui.GuideUtile = uicontrol('style', 'pushbutton', 'string', 'Guide Interface',...
    'units', 'pixels', 'position', [890 667 80 40]);
set(hGui.GuideUtile, 'callback', {@endDAQ, s}); %{@messageGuide, hGui});

% Create a load parameters button
hGui.LoadEditParams = uicontrol('style', 'pushbutton', 'string', 'Load Params',...
    'units', 'pixels', 'position', [990 667 80 40]);
set(hGui.LoadEditParams, 'callback', {@loadParams, hGui});

% Create a save parameters button
hGui.SaveEditParams = uicontrol('style', 'pushbutton', 'string', 'Save Params',...
    'units', 'pixels', 'position', [1090 667 80 40]);
set(hGui.SaveEditParams, 'callback', {@saveParams, hGui});

% Create a probe stim button and configure a callback function
hGui.BaselineButton = uicontrol('style', 'pushbutton', 'string', 'Set Baseline',...
    'units', 'pixels', 'position', [320 575 80 40]);
set(hGui.BaselineButton, 'callback', {@BaselineEMG, hGui}); %{@startProbe, hGui});

% Create a manual single stim button and configure a callback function
hGui.ManualButton = uicontrol('style', 'pushbutton', 'string', 'Single Train',...
    'units', 'pixels', 'position', [320 520 80 40]);
set(hGui.ManualButton, 'callback', {@startManual, hGui});

% % Create a probe stim button and configure a callback function
% hGui.ProbeButton = uicontrol('style', 'pushbutton', 'string', 'Probe Start',...
%     'units', 'pixels', 'position', [320 520 80 40]);
% set(hGui.ProbeButton, 'callback', {@startProbe, hGui});

% Create a probe stim button and dependant for the EMG and configure a callback function
hGui.ProbeEMGButton = uicontrol('style', 'pushbutton', 'string', 'Probe EMG Start',...
    'units', 'pixels', 'position', [320 465 80 40]);
set(hGui.ProbeEMGButton, 'callback', {@startProbeEMG, hGui});

% Create a PAS button and configure a callback function
hGui.PASButton = uicontrol('style', 'pushbutton', 'string', 'Start PAS',...
    'units', 'pixels', 'position', [320 350 80 40]);
set(hGui.PASButton, 'callback', {@startPAS, hGui});

% Create a Display button and configure a callback function
hGui.DisplayButton = uicontrol('style', 'pushbutton', 'string', 'Display EMG',...
    'units', 'pixels', 'position', [320 60 80 40]);
set(hGui.DisplayButton, 'callback', {@displayCapture, hGui});

% Create a Save button and configure a callback function
hGui.SaveButton = uicontrol('style', 'pushbutton', 'string', 'Save Data',...
    'units', 'pixels', 'position', [320 115 80 40]);
set(hGui.SaveButton, 'callback', {@SaveData, hGui});

 


guidata(Fig,hGui);
end

function messageGuide(hObject,~,~)
if get(hObject, 'value')
    GuideFig = {};
    GuideFig{1,1} = 'Guide de l''utilisation du PAS Experiment Interface 1.1';
    GuideFig{2,1} = '';
    GuideFig{3,1} = 'Pour stimuler le cortex :';
    GuideFig{4,1} = '1. Cocher la case �Cortex Stim� et choisir la s�lection �Cortex+Trig (AI0+AI2)�.';
    GuideFig{5,1} = '2. Choisir les param�tres qui vont servir � la capture (avant/apr�s stim) et Probe time si on chosit de l''option �Probe�.';
    GuideFig{6,1} = '3. Cliquer sur le bouton �Manual� pour produire un pulse unique ou �Probe� pour produire plusieurs pulses (d�finir le nombre de pulses dans la case correspondante).';
    GuideFig{7,1} = '4. La stimulation devrait avoir lieu et la derni�re r�ponse EMG devrait �tre affich� dans le graphique du dessous.';
    GuideFig{8,1} = 'Note :';
    GuideFig{9,1} = '- L''option �average� sert � moyenner les r�ponses EMG.';
    GuideFig{10,1} = '- L''option �Zero Rect� sert � rectifier les donn�es lors des captures � z�ros lors du trigger.';
    GuideFig{11,1} = '';
    GuideFig{12,1} = 'Pour stimuler les muscles :';
    GuideFig{13,1} = '1. Cocher la case �Muscle Stim� et choisir la s�lection �Muscle+Trig (AI1+AI3)�.';
    GuideFig{14,1} = '2. La proc�dure est pareil aux �tapes 2. � 4. de la stimulation du cortex.';
    GuideFig{15,1} = '';
    GuideFig{16,1} = 'Pour stimuler le cortex et les muscles :';
    GuideFig{17,1} = '1. Cocher la case �Cortex Stim� et la case �Muscle Stim� et choisir la s�lection �ALL�.';
    GuideFig{18,1} = '2. La proc�dure est pareil aux �tapes 2. � 4. de la stimulation du cortex.';
    GuideFig{19,1} = '';
    GuideFig{20,1} = 'Exp�rience de PAS';
    GuideFig{21,1} = '1. Choisir les param�tres d�sir�s dans la section PAS Experiment (nombre de pulses, inter-pulse time, etc.).';
    GuideFig{22,1} = '2. Cliquer le bouton �Start PAS� pour d�buter';
    GuideFig{23,1} = 'Note :';
    GuideFig{24,1} = '- L''option �Random Spacing� consiste � r�gler un espacement al�atoire entre les impulsions d''une dur�e d�pendament du contenu dans les cases �Min Time� et �Max Time�.';
    GuideFig{25,1} = '';
    GuideFig{26,1} = 'IMPORTANT : Il faut s''assurer de choisir le bon parton de stimulation de pouvoir stimulion! D�cocher les cases de stimultions non n�cessaires sinon une erreur se produira.';
    msgbox(GuideFig,'Guide de l''utilisateur');
end
end


function startManual(hObject,~,~)

if get(hObject, 'value')
    hGui = guidata(gcbo);
    set(hGui.StatusText, 'String', 'Manual cortex stimulation in progress.');
    persistent AllDataCollected WindowEMG
    global BufferSelect SelectionState FlagEMG
    
    % Initialisation de la session selon la s�lection choisie, les checkbox
    % choisie pour faire la stimulation. On pr�pare aussi le signal de
    % trigger selon les param�tres choisis.
    
    sManual = daq.createSession('ni');
    addDigitalChannel(sManual,'Dev2', 'Port0/Line0', 'OutputOnly');
    addDigitalChannel(sManual,'Dev2', 'Port0/Line1', 'OutputOnly');
    set(hGui.StatusText, 'String', 'Determination of the threshold for Max MEP');
    
    % Comptage du nombre de fois que le bouton est pouss�
    hGui.NumPushTimeSingleTrain = hGui.NumPushTimeSingleTrain + 1;
    hGui.NumPushTimeTotal = hGui.NumPushTimeSingleTrain + hGui.NumPushTimeProbeTrain + hGui.NumPushTimeProbeEMGTrain;
    
    % Prend les donn�es dans les cases correspondantes (avant, apr�s stim)
    BStim = str2double(hGui.BeforeStim.String)/1000;
    AStim = str2double(hGui.AfterStim.String)/1000;
    
    % D�pendance au niveau EMG
    EMG_Window_Low = str2double(hGui.EMGWindowLow.String)/1000;
    EMG_Window_High = str2double(hGui.EMGWindowHigh.String)/1000;
    WindowEMGFirst = length(BufferSelect(:,1));
    WindowEMGLast = round(length(BufferSelect(:,1)) - str2double(hGui.EMGTime.String)*hGui.SourceRate/1000);

    % Boucle while pour �valuer le EMG moyen
    if SelectionState == 1 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 0
        pulse_sent = false;
        while pulse_sent == false || get(hGui.StopWhileLoop,'value') == 0 % Ajouter la condition de fermeture fen�tre
            WindowEMG = BufferSelect(WindowEMGLast:WindowEMGFirst,3);
            OvershootLimit = sum(WindowEMG>=EMG_Window_High)+sum(WindowEMG<=EMG_Window_Low);
            if OvershootLimit < 1 && FlagEMG == true
                pulse_sent = true;
                outputSingleScan(sManual,[1,0]);
                pause(0.05);
                outputSingleScan(sManual,[0,0]);
                stop(sManual);
                set(hGui.StatusText, 'String', 'Manual stimulation of the cortex done!');
            else
                pause(0.1);
                set(hGui.StatusText, 'String', 'Waiting for the proper EMG conditions');
            end
        end
    elseif SelectionState == 2 && get(hGui.CheckCortexStim,'value') == 0 && get(hGui.CheckMuscleStim,'value') == 1
        outputSingleScan(sManual,[0,1]);
        pause(0.05);
        outputSingleScan(sManual,[0,0]);
        stop(sManual);
        set(hGui.StatusText, 'String', 'Manual stimulation of the muscle done!');
    elseif SelectionState == 7 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 1
        outputSingleScan(sManual,[1,1]);
        pause(0.05);
        outputSingleScan(sManual,[0,0]);
        stop(sManual);
        set(hGui.StatusText, 'String', 'Manual stimulation of the cortex and the muscle done!');
    else
        error('Choose the appropriate selection that corresponds with the stimulation patern')
    end
    
    % Pause afin d'acqu�rir toutes les donn�es n�cessaires � la capture
    pause(AStim+BStim);
    
    % On enregistre les donn�es dans une matrice persistente, afin de faire
    % des analsyes et d'obtenir une matrice de l'EMG avec les param�tres voulues
    AllDataCollected = BufferSelect(:,:);
    
    % D�termination de certains temps pr�cis
    if SelectionState == 1 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 0
        
        MomentStimTrigFall = find(AllDataCollected(:,4)>2,1,'last');
        WindowTrigCheck = MomentStimTrigFall - round(hGui.SourceRate);
        HighTrainTrig = sum(AllDataCollected(WindowTrigCheck:MomentStimTrigFall,4)>2);
        MomentStimTrigRise = find(AllDataCollected(:,4)>2,1,'last')-HighTrainTrig;
        
    elseif SelectionState == 2 && get(hGui.CheckCortexStim,'value') == 0 && get(hGui.CheckMuscleStim,'value') == 1 
        HighTrainTrig = sum(BufferSelect(1:length(BufferSelect(:,1)),5)>4);
        MomentStimTrigRise = find(BufferSelect(:,5)>4,1,'last')-HighTrainTrig;
    elseif SelectionState == 7 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 1
        HighTrainTrig = sum(BufferSelect(1:length(BufferSelect(:,1)),4)>4);
        MomentStimTrigRise = find(BufferSelect(:,4)>4,1,'last')-HighTrainTrig;
    end
    
    % D�terminer la valeur en temps o� le trigger s'est produit
    MomentStimTimeRise = BufferSelect(MomentStimTrigRise,1);
    
    % Param�tres de dataEMG pour enregistrer les donn�es selon les specs
    % voulues
    FirstEMG = round(MomentStimTrigRise - BStim*hGui.SourceRate);
    LastEMG = round(MomentStimTrigRise + AStim*hGui.SourceRate);
    dataEMG = AllDataCollected(FirstEMG:LastEMG,:);
    
    % Applique la rectification temporel de la capture
    if get(hGui.ZeroRectification,'value')
        dataEMG(:,1) = dataEMG(:,1) - MomentStimTimeRise;
    end
    
    % Sauvegarder les donn�es dans un cell array qui incr�mente selon le
    % nombre de fois que le bouton est press�
    hGui.DataResponseSingle{hGui.NumPushTimeSingleTrain,1} = dataEMG;
    SinglePushTimeString = num2str(hGui.NumPushTimeSingleTrain);
    hGui.DataTable.Data(hGui.NumPushTimeTotal,1) = cellstr(strcat('Single ',SinglePushTimeString));
    hGui.DataTable.Data(:,4) = {false};
    hGui.DataTable.Data(hGui.NumPushTimeTotal,4) = {true};
    
    % On plot les derni�res donn�es du cell array
    CaptureData = hGui.DataResponseSingle{hGui.NumPushTimeSingleTrain,1};
    for jj = 1:2
        yyaxis left
        set(hGui.CapturePlot(jj), 'XData', CaptureData(:,1), ...
            'YData', CaptureData(:,1+jj))
        yyaxis right
        set(hGui.CapturePlot(jj), 'XData', CaptureData(:,1), ...
            'YData', CaptureData(:,3+jj))
        drawnow limitrate
    end
    
    % Reset du bouton et mise � jour des donn�es gui
    set(hObject, 'value', 0);
    set(hGui.StatusText, 'String', 'Last Capture taken from last stimulation!');
    guidata(gcbo,hGui);
end
end

function BaselineEMG(hObject,~,~)
% Cette fonction calcule la moyenne de l'enveloppe de l'EMG et son ecart 
% type de la derni�re seconde du buffer afin de pouvoir d�terminer les
% limites EMG pour les probes
if get(hObject, 'value')
    hGui = guidata(gcbo);
    global BufferSelect
    persistent dataBaseline
    Duree_Baseline = 1;
    NombreFoisSTD_HAut = 6;
    dataBaseline = BufferSelect(round(0.9*length(BufferSelect(:,1))):end,3);
    moyenne_baseline = mean(dataBaseline);
    ecart_type = std(dataBaseline);
    EMG_Window_Low_STD = round((moyenne_baseline+3*ecart_type)*1000,4);
    EMG_Window_High_STD = round((moyenne_baseline+6*ecart_type)*1000,4);
    set(hGui.EMGWindowLow, 'string', EMG_Window_Low_STD);
    set(hGui.EMGWindowHigh, 'string',EMG_Window_High_STD);
    guidata(gcbo,hGui);
end
end

function startProbeEMG(hObject,~,~)

if get(hObject, 'value')
    hGui = guidata(gcbo);
    set(hGui.StatusText, 'String', 'Probe stimulation in progress.');
    persistent WindowEMG AllDataCollected
    global BufferSelect SelectionState FlagEMG
    
    % Enregistrement dans des variables le contenu des cases de la
    % section Probe
    InterPulseProbe = str2double(hGui.InterProbe.String);
    LMinProbe = str2double(hGui.MinProbeTime.String);
    LMaxProbe = str2double(hGui.MaxProbeTime.String);
    nb_pulsesProbe = round(str2double(hGui.PulseProbe.String));
    BeforeCapture = str2double(hGui.BeforeStim.String)/1000;
    AfterCapture = str2double(hGui.AfterStim.String)/1000;
    WindowEMGFirst = length(BufferSelect(:,1));
    WindowEMGLast = round(length(BufferSelect(:,1)) - str2double(hGui.EMGTime.String)*hGui.SourceRate/1000);
    
    % V�rification des temps s'ils sont r�alistes ou pas
    if get(hGui.RandomProbe,'value')
        if LMinProbe < (BeforeCapture + AfterCapture)
            err('La valeur minimale des trains al�atoire est plus petite que la f�netre captur�e (avant et apr�s capture)')
        end
    else
        if InterPulseProbe < (BeforeCapture + AfterCapture)
            err('La dur�e de inter-train est plus petite que la f�netre captur�e (avant et apr�s capture)')
        end
    end
    
    % Initialisation d'une sesion pour ajouter les sorties digitales
    sProbeEMG = daq.createSession('ni');
    addDigitalChannel(sProbeEMG,'Dev2', 'Port0/Line0', 'OutputOnly');
    addDigitalChannel(sProbeEMG,'Dev2', 'Port0/Line1', 'OutputOnly');
    
    % Boucle while afin de calculer en continue le code s'il atteint les
    % conditions ou pas
    tic
    nb_pulsesDone = 0;
    
    while nb_pulsesDone < nb_pulsesProbe
        EMGProbe_StartTime = toc;
        nb_pulsesDone = nb_pulsesDone + 1;
        EMG_Window_Low = str2double(hGui.EMGWindowLow.String)/1000;
        EMG_Window_High = str2double(hGui.EMGWindowHigh.String)/1000;
        pulse_sent = false;
        pause(0.2);
        if SelectionState == 1 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 0
            hGui.NumPushTimeProbeEMGTrain = hGui.NumPushTimeProbeEMGTrain + 1;
            hGui.NumPushTimeTotal = hGui.NumPushTimeSingleTrain + hGui.NumPushTimeProbeTrain + hGui.NumPushTimeProbeEMGTrain;
            %TimeLimitEMG = toc - EMGProbe_StartTime;
            if get(hGui.RisingOption,'value') == 0 && get(hGui.FallingOption,'value') == 0
                while pulse_sent == false
                    set(hGui.StatusText, 'String', sprintf('Cortical stimulation dependant of the EMG. Probe %d in progress.',nb_pulsesDone));
                    WindowEMG = BufferSelect(WindowEMGLast:WindowEMGFirst,3);
                    OvershootLimit = sum(WindowEMG>=EMG_Window_High)+sum(WindowEMG<=EMG_Window_Low);
                    if OvershootLimit < 1
                        outputSingleScan(sProbeEMG,[1,0]);
                        drawnow
                        pause(0.05);
                        outputSingleScan(sProbeEMG,[0,0]);
                        pulse_sent = true;
                        set(hGui.StatusText, 'String', sprintf('Cortical stimulation dependant of the EMG. Probe %d done.',nb_pulsesDone));
                        stop(sProbeEMG);
                    else
                        pause(0.05);
                    end
                end
            elseif get(hGui.RisingOption,'value') == 1 && get(hGui.FallingOption,'value') == 0
                while pulse_sent == false
                    set(hGui.StatusText, 'String', sprintf('Cortical stimulation dependant of the EMG rising. Probe %d in progress.',nb_pulsesDone));
                    WindowEMG = BufferSelect(WindowEMGLast:WindowEMGFirst,3);
                    OvershootLimit = sum(WindowEMG>=EMG_Window_High)+sum(WindowEMG<=EMG_Window_Low);
                    if OvershootLimit < 1 && FlagEMG == 1
                        outputSingleScan(sProbeEMG,[1,0]);
                        drawnow
                        pause(0.05);
                        outputSingleScan(sProbeEMG,[0,0]);
                        pulse_sent = true;
                        set(hGui.StatusText, 'String', sprintf('Cortical stimulation dependant of the EMG rising. Probe %d done.',nb_pulsesDone));
                        stop(sProbeEMG);
                    else
                        pause(0.05);
                    end
                end
            elseif get(hGui.RisingOption,'value') == 0 && get(hGui.FallingOption,'value') == 1
                while pulse_sent == false
                    set(hGui.StatusText, 'String', sprintf('Cortical stimulation dependant of the EMG falling. Probe %d in progress.',nb_pulsesDone));
                    WindowEMG = BufferSelect(WindowEMGLast:WindowEMGFirst,3);
                    OvershootLimit = sum(WindowEMG>=EMG_Window_High)+sum(WindowEMG<=EMG_Window_Low);
                    if OvershootLimit < 1 && FlagEMG == 0
                        outputSingleScan(sProbeEMG,[1,0]);
                        drawnow
                        pause(0.05);
                        outputSingleScan(sProbeEMG,[0,0]);
                        pulse_sent = true;
                        set(hGui.StatusText, 'String', sprintf('Cortical stimulation dependant of the EMG falling. Probe %d done.',nb_pulsesDone));
                        stop(sProbeEMG);
                    else
                        pause(0.05);
                    end
                end
            else
                err('Be sure to select rising or falling or neither of them')
            end
        else
            error('Choose the appropriate selection that corresponds with the stimulation patern')
        end
        
        % Pause afin d'acqu�rir toutes les donn�es n�cessaires � la capture
        TimeSpentStimulating = toc - EMGProbe_StartTime;
        
        if get(hGui.RandomProbe,'value')
            if TimeSpentStimulating > LMinProbe
                pause(AfterCapture);
            else
                ecart_stim = round((LMinProbe+(LMaxProbe-LMinProbe).*rand(1))) - TimeSpentStimulating;
                pause(ecart_stim);
            end
        else
            if TimeSpentStimulating > InterPulseProbe
                pause(AfterCapture);
            else
                pause(InterPulseProbe-TimeSpentStimulating);
            end
        end
        
        AllDataCollected = BufferSelect(:,:);
        
        %             HighTrainTrig_LastTime = round((toc - EMGProbe_StartTime)*hGui.SourceRate);
        %             % D�terminer le moment o� la premi�re valeur de trigger a lieu
        %             HighTrainTrig = sum(AllDataCollected(HighTrainTrig_LastTime:length(AllDataCollected(:,1)),4)>2);
        %             MomentStimTrig = find(AllDataCollected(:,4)>2,1,'last')-HighTrainTrig;
        
        MomentStimTrigFall = find(AllDataCollected(:,4)>2,1,'last');
        WindowTrigCheck = MomentStimTrigFall - round(hGui.SourceRate);
        HighTrainTrigVerify = sum(AllDataCollected(WindowTrigCheck:MomentStimTrigFall,4)>2);
        MomentStimTrigRise = find(AllDataCollected(:,4)>2,1,'last')-HighTrainTrigVerify;
        
        % D�terminer la valeur en temps o� le trigger s'est produit
        MomentStimTime = AllDataCollected(MomentStimTrigRise,1);
        
        % Param�tres de dataEMG pour enregistrer la capture voulue
        FirstEMG = round(MomentStimTrigRise - BeforeCapture*hGui.SourceRate);
        LastEMG = round(MomentStimTrigRise + AfterCapture*hGui.SourceRate);
        
        % V�rification si le dernier EMG de la capture est plus grand ou
        % non que la matrice AllDataCollected, sinon, c'est sp�cifier
        % sans signaler d'erreur.
        if LastEMG > length(AllDataCollected(:,1))
            EMGOverCount = LastEMG - length(AllDataCollected(:,1));
            fprintf('Probl�me de calcul au train %d. La capture apr�s le train est couper de %d donn�es \n',nb_pulsesDone,EMGOverCount)
            dataEMGProbeEMG = AllDataCollected(FirstEMG:length(AllDataCollected(:,1)),:);
        else
            dataEMGProbeEMG = AllDataCollected(FirstEMG:LastEMG,:);
        end
        
        % Applique la rectification temporel de la capture
        if get(hGui.ZeroRectification,'value')
            dataEMGProbeEMG(:,1) = dataEMGProbeEMG(:,1) - MomentStimTime;
        end
        
        % Sauvegarder les donn�es dans un cell array qui incr�mente selon le
        % nombre de capture g�n�r�s
        hGui.DataResponseProbeEMG{hGui.NumPushTimeProbeEMGTrain,2} = dataEMGProbeEMG;
        ProbePushTimeString = num2str(hGui.NumPushTimeProbeEMGTrain);
        hGui.DataTable.Data(hGui.NumPushTimeTotal,3) = cellstr(strcat('ProbeEMG %',ProbePushTimeString));
        hGui.DataTable.Data(:,4) = {false};
        hGui.DataTable.Data(hGui.NumPushTimeTotal,4) = {true};
        
        TimeProcessOneBurst = toc - EMGProbe_StartTime;
        
        if TimeProcessOneBurst <= InterPulseProbe
            pause(InterPulseProbe - TimeProcessOneBurst)
        else
            TimeAfterLimit = TimeProcessOneBurst - InterPulseProbe;
            fprintf('Time after the inter pulse limit is %.3f for probe %d \n',TimeAfterLimit,nb_pulsesDone);
        end
    end
    % Faire le code des deux autres s�lections par la suite.
    
    % Reset du bouton et mise � jour des donn�es gui
    set(hObject, 'value', 0);
    set(hGui.StatusText, 'String', 'Last Capture taken from Manual Stimulation!');
    guidata(gcbo,hGui);
end
end

function startPAS(hObject,~,~)
if get(hObject, 'value')
    % Initialisation d'une nouvelle session et des param�tres utiles
    hGui = guidata(gcbo);
    set(hGui.StatusText, 'String', 'PAS Experiment in progress.');
    sPAS = daq.createSession('ni');
    addDigitalChannel(sPAS,'Dev2', 'Port0/Line0', 'OutputOnly');
    addDigitalChannel(sPAS,'Dev2', 'Port0/Line1', 'OutputOnly');
    
    InterPulsePAS = str2double(hGui.InterPAS.String);
    LMinPAS = str2double(hGui.MinPAS.String);
    LMaxPAS = str2double(hGui.MaxPAS.String);
    nb_burstPAS = round(str2double(hGui.PulsePAS.String));
    burst_sent = 0;
    
    % Mise � z�ro des canaux digitaux et initialisation du tic pour
    % r�aliser des op�rations dans la boucle while
    tic
    outputSingleScan(sPAS,[0,0]);
    pause(0.1);
    % La boucle while qui va permettre 
    while burst_sent < nb_burstPAS % || temps allou� || fermeture du daq/fen�tre
        
        Start_Time = toc;
        burst_sent = burst_sent + 1;
        set(hGui.StatusText, 'String', sprintf('PAS Experiment in progress (Train %d sent)',burst_sent));
        % Envoi du trigger au AM-Systems
        outputSingleScan(sPAS,[1,1]);
        pause(0.1);
        outputSingleScan(sPAS,[0,0]);
        Process_Time = toc - Start_Time;
        
        % Choix Random ou pas, et pause d'une dur�e pr�cise afin
        % d'atteindre l'�cart de inter train ou une valeur al�atoire
        % pr�cise
        
        if get(hGui.RandomPAS,'value')
            if Process_Time < LMinPAS
                Time_Random_Left = LMinPAS+(LMaxPAS-LMinPAS).*rand(1);
                Random_Process_time = toc - Start_Time;
                Random_time = Time_Random_Left - Random_Process_time;
                pause(Random_time);
            else
                err('Please review the value of the Minimun Random Time of the PAS edit box');
            end
        else
            if Process_Time < InterPulsePAS
                Inter_Process_time = toc - Start_Time;
                pause(InterPulsePAS - Inter_Process_time - 0.017); %Ajustement pour "normalis�" le temps, n�cessaire?
            else
                err('Please review the value of the Inter-Train Time of the PAS edit box');
            end
        end
    end
    
    set(hGui.StatusText, 'String', 'PAS Experiment is done!');
    stop(sPAS);
    delete(sPAS);
    guidata(gcbo,hGui);
end
end

function displayCapture(hObject,~,~)
if get(hObject, 'value')
    hGui = guidata(gcbo);
    if sum(cell2mat(hGui.DataTable.Data(:,4))) == 0
        err('There''s no data selected to display, please select some data to plot')
    else
        DisplaySelect = find(cell2mat(hGui.DataTable.Data(:,4)));
        for m = 1:length(DisplaySelect)
            String2PlotSingle = iscellstr(hGui.DataTable.Data(DisplaySelect(m),1));
            String2PlotProbe = iscellstr(hGui.DataTable.Data(DisplaySelect(m),2));
            String2PlotProbeEMG = iscellstr(hGui.DataTable.Data(DisplaySelect(m),3));
            if String2PlotSingle == true && String2PlotProbe == false && String2PlotProbeEMG == false
                Row2Plot = sum(iscellstr(hGui.DataTable.Data(1:DisplaySelect(m),1)));
                CaptureDataDisplay = hGui.DataResponseSingle{Row2Plot,1};
                for jj = 1:numel(hGui.CapturePlot)
                    set(hGui.CapturePlot(jj), 'XData', CaptureDataDisplay(:,1), ...
                                              'YData', CaptureDataDisplay(:,1+jj))
                    drawnow limitrate
                end
            elseif String2PlotSingle == false && String2PlotProbe == true && String2PlotProbeEMG == false
                Row2Plot = sum(iscellstr(hGui.DataTable.Data(1:DisplaySelect(m),2)));
                CaptureDataDisplay = hGui.DataResponseProbe{Row2Plot,1};
                for jj = 1:numel(hGui.CapturePlot)
                    set(hGui.CapturePlot(jj), 'XData', CaptureDataDisplay(:,1), ...
                                              'YData', CaptureDataDisplay(:,1+jj))
                    drawnow limitrate
                end
            elseif String2PlotSingle == false && String2PlotProbe == false && String2PlotProbeEMG == true
                Row2Plot = sum(iscellstr(hGui.DataTable.Data(1:DisplaySelect(m),3)));
                CaptureDataDisplay = hGui.DataResponseProbeEMG{Row2Plot,1};
                for jj = 1:numel(hGui.CapturePlot)
                    set(hGui.CapturePlot(jj), 'XData', CaptureDataDisplay(:,1), ...
                                              'YData', CaptureDataDisplay(:,1+jj))
                    drawnow limitrate
                end
            else
                err('There''s multiple strings in a row')
            end
        end
    end
    guidata(gcbo,hGui);
end
end

function SaveData(hObject,~,~)
if get(hObject, 'value')
    hGui = guidata(gcbo);
    set(hGui.StatusText, 'String', 'Select the folder to save the data');
    SingleData = hGui.DataResponseSingle;
    ProbeData = hGui.DataResponseProbe;
    ProbeEMGData = hGui.DataResponseProbeEMG;
    uisave({'SingleData ','ProbeData','ProbeEMGData'},'');
    guidata(gcbo,hGui);
end
end

function loadParams(hObject,~,~)
if get(hObject, 'value')
    hGui = guidata(gcbo);
    uiopen
    set(hGui.BeforeStim, 'string', params.BeforeStim_Var);
    set(hGui.AfterStim, 'string', params.AfterStim_Var);
    set(hGui.PulseProbe, 'string', params.PulseProbe_Var);
    set(hGui.MinProbeTime, 'string', params.MinProbeTime_Var);
    set(hGui.MaxProbeTime, 'string', params.MaxProbeTime_Var);
    set(hGui.InterProbe, 'string', params.InterProbe_Var);
    set(hGui.EMGTime, 'string', params.EMGTime_Var);
    set(hGui.EMGWindowLow, 'string', params.EMGWindowLow_Var);
    set(hGui.EMGWindowHigh, 'string', params.EMGWindowHigh_Var);
    set(hGui.PulsePAS, 'string', params.PulsePAS_Var);
    set(hGui.InterPAS, 'string', params.InterPAS_Var);
    set(hGui.MinPAS, 'string', params.MinPAS_Var);
    set(hGui.MaxPAS, 'string', params.MaxPAS_Var);
    guidata(gcbo,hGui);
end
end

function saveParams(hObject,~,~)
if get(hObject, 'value')
    hGui = guidata(gcbo);
    set(hGui.StatusText, 'String', 'Select the folder to save the parameters');
    params.BeforeStim_Var = hGui.BeforeStim.String;
    params.AfterStim_Var = hGui.AfterStim.String;
    params.PulseProbe_Var = hGui.PulseProbe.String;
    params.MinProbeTime_Var = hGui.MinProbeTime.String;
    params.MaxProbeTime_Var = hGui.MaxProbeTime.String;
    params.InterProbe_Var = hGui.InterProbe.String;
    params.EMGTime_Var = hGui.EMGTime.String;
    params.EMGWindowLow_Var = hGui.EMGWindowLow.String;
    params.EMGWindowHigh_Var = hGui.EMGWindowHigh.String;
    params.PulsePAS_Var = hGui.PulsePAS.String;
    params.InterPAS_Var = hGui.InterPAS.String;
    params.MinPAS_Var = hGui.MinPAS.String;
    params.MaxPAS_Var = hGui.MaxPAS.String;
    uisave({'params'},'');
    guidata(gcbo,hGui);
end
end

function endDAQ(~, ~, s)
if isvalid(s)
    if s.IsRunning
        stop(s); 
        disp('La session d''enregistrement est ferm�e')
    end
end
end

% Callback de l'ancien bouton Probe, fonctionnait � des cycles pr�cis et un
% timing pr�cis, mais de conditions d'�pendantes du EMG et utilisation des
% analog output pour construire le signal de trigger. Utilisation non
% recommand�.

function startProbe(hObject,~,~)

if get(hObject, 'value')
    hGui = guidata(gcbo);
    set(hGui.StatusText, 'String', 'Probe stimulation in progress.');
    persistent MomentStimTime MomentStimTrig dataEMGProbe
    global BufferSelectProbe SelectionState
    
    % Enregistrement dans des vraibales le contenu des cases de la
    % section Probe
    InterPulseProbe = str2double(hGui.InterProbe.String);
    LMinProbe = str2double(hGui.MinProbeTime.String);
    LMaxProbe = str2double(hGui.MaxProbeTime.String);
    BeforeCapture = str2double(hGui.BeforeStim.String)/1000;
    AfterCapture = str2double(hGui.AfterStim.String)/1000;
    nb_pulsesProbe = round(str2double(hGui.PulseProbe.String));
    
    % Compatage du nombre de fois que le bouton est pouss�
    hGui.NumPushTimeProbeTrain = hGui.NumPushTimeProbeTrain + 1;
    hGui.NumPushTimeTotal = hGui.NumPushTimeSingleTrain + hGui.NumPushTimeProbeTrain + hGui.NumPushTimeProbeEMGTrain;
    
    % Creation d'une nouvelle session de analog output servant pour la
    % section Probe
    sProbe = daq.createSession('ni');
    sProbe.Rate = 1000;
    
    % Code d'erreur pour v�rifier si les param�tres de stimulation sont
    % coh�rentes avec les param�tres de capture choisis. On d�finit aussi
    % la dur�e d'un "pulse" (time_single_pulse) qui va �tre r�p�t�e selon
    % le nombre de pulse d�sir� dans Probe.
    esp_time = 1/sProbe.Rate;
    if get(hGui.RandomProbe,'value')
        if LMinProbe < (BeforeCapture + AfterCapture)
            err('La valeur minimale des trains al�atoire est plus petite que la f�netre captur�e (avant et apr�s capture)')
        else
            time_single_pulse = [0:esp_time:LMaxProbe]';
        end
    else
        if InterPulseProbe < (BeforeCapture + AfterCapture) % Ajouter Le esp_time? Qui correspond � la 0 si on fait -BeforeCapture � +AfterCapture (2001 de longueur si 500 ms et 1500 ms apr�s)
            err('La dur�e de inter-train est plus petite que la f�netre captur�e (avant et apr�s capture)')
        else
            time_single_pulse = [0:esp_time:InterPulseProbe]';
        end
    end
    
%----- Pr�paration de Analog Out en fonction de param�tres choisis -----
    
    if SelectionState == 1 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 0
        % Update du status 
        disp('Stimulation du cortex en processus et AI0 et AI2 est enregistr� (Probe)')
        set(hGui.StatusText, 'String', 'Stimulation du cortex en processus et AI0 et AI2 est enregistr� (Probe)');
        
        % G�n�ration du signal de trigger
        addAnalogOutputChannel(sProbe,'Dev1','ao0','Voltage');
        n = 0;
        pulse_cortex_tot_Probe = {};
        while n <= nb_pulsesProbe
            n=n+1;
            if get(hGui.RandomProbe,'value')
                ecart_stim = round((LMinProbe+(LMaxProbe-LMinProbe).*rand(1))/esp_time);
            else
                ecart_stim = round(InterPulseProbe/(esp_time*1.5));
            end
            pulse_cortex_Probe = cat(1,(0*time_single_pulse(1:ecart_stim)),(5+0*time_single_pulse(ecart_stim+1:length(time_single_pulse))));
            pulse_cortex_tot_Probe{n,1} = pulse_cortex_Probe;
        end
        
        % Remise � z�ro des output
        pulse_cortex_tot_Probe{n+1,1} = 0*[0:esp_time:1]';
        
        % Pr�paration du signal � envoyer
        Output_Cortex = cell2mat(pulse_cortex_tot_Probe);
        queueOutputData(sProbe,Output_Cortex)
        
    elseif SelectionState == 2 && get(hGui.CheckCortexStim,'value') == 0 && get(hGui.CheckMuscleStim,'value') == 1
        % Update du status 
        disp('Stimulation du muscle en processus et AI1 est enregistr� (Probe)')
        set(hGui.StatusText, 'String', 'Muscle stimulation selected. (Probe)');
        
        % G�n�ration du signal de trigger
        addAnalogOutputChannel(sProbe,'Dev1','ao1','Voltage');
        n = 0;
        pulse_muscle_tot_Probe = {};
        while n <= nb_pulsesProbe 
            n=n+1;
            if get(hGui.RandomProbe,'value')
                ecart_stim = round((LMinProbe+(LMaxProbe-LMinProbe).*rand(1))/esp_time);
            else
                ecart_stim = round(InterPulseProbe/(esp_time*1.5));
            end
            pulse_muscle_Probe = cat(1,(0*time_single_pulse(1:ecart_stim)),(5+0*time_single_pulse(ecart_stim+1:length(time_single_pulse))));
            pulse_muscle_tot_Probe{n,1} = pulse_muscle_Probe;
        end
        
        % Remise � z�ro des output
        pulse_muscle_tot_Probe{n+1,1} = 0*[0:esp_time:1]';
        
        % Pr�paration du signal de trigger pour le muscle � envoy�
        Output_Muscle = cell2mat(pulse_muscle_tot_Probe);
        queueOutputData(sProbe,Output_Muscle)
   
    elseif SelectionState == 7 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 1
        % Update du status
        disp('Stimulation du cortex et des muscles en processus et AI0 � AI3 est enregistr� (Probe)')
        set(hGui.StatusText, 'String', 'Probe cortex and muscle stimulations selected.');
        
        % G�n�ration du signal
        addAnalogOutputChannel(sProbe,'Dev1','ao0','Voltage');
        addAnalogOutputChannel(sProbe,'Dev1','ao1','Voltage');
        n = 0;
        pulse_cortex_tot_Probe = {};
        pulse_muscle_tot_Probe = {};
        while n <= nb_pulsesProbe
            n=n+1;
            if get(hGui.RandomProbe,'value')
                ecart_stim = round((LMinProbe+(LMaxProbe-LMinProbe).*rand(1))/esp_time);
            else
                ecart_stim = round(InterPulseProbe/(esp_time*1.5));
            end
            pulse_cortex_Probe = cat(1,(0*time_single_pulse(1:ecart_stim)),(5+0*time_single_pulse(ecart_stim+1:length(time_single_pulse))));
            pulse_muscle_Probe = cat(1,(0*time_single_pulse(1:ecart_stim)),(5+0*time_single_pulse(ecart_stim+1:length(time_single_pulse))));
            pulse_cortex_tot_Probe{n,1} = pulse_cortex_Probe;
            pulse_muscle_tot_Probe{n,1} = pulse_muscle_Probe;
        end
        
        % Remise � z�ro des output
        pulse_cortex_tot_Probe{n+1,1} = 0*[0:esp_time:1]';
        pulse_muscle_tot_Probe{n+1,1} = 0*[0:esp_time:1]';
        
        % Pr�paration des signals � envoy�s
        Output_Cortex = cell2mat(pulse_cortex_tot_Probe);
        Output_Muscle = cell2mat(pulse_muscle_tot_Probe);
        queueOutputData(sProbe,[Output_Cortex Output_Muscle]);
    else
        error('Choose the appropriate selection that corresponds with the stimulation patern')
    end
    
 % ----- Envoi du Output et pr�paration � l'enregitrement -----
 
    tic
    % Envoi du trigger vers le AM systems
    startBackground(sProbe);
    TimeProbeProcessStart = toc;
    disp(TimeProbeProcessStart);
    set(hGui.StatusText, 'String', 'Le rat devrait bouger ahhahahah');
    wait(sProbe);
    set(hGui.StatusText, 'String', 'Manual cortex stimulation is done!');
    stop(sProbe);
    
    % Pause afin d'acqu�rir toutes les donn�es n�cessaires � la capture
    pause(TimeProbeProcessStart + InterPulseProbe);
    
    % D�terminer le moment o� la premi�re valeur de trigger a lieu
    if SelectionState == 1 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 0
        MomentStimTrig = find(BufferSelectProbe(:,4)>4,1,'first');
    elseif SelectionState == 2 && get(hGui.CheckCortexStim,'value') == 0 && get(hGui.CheckMuscleStim,'value') == 1 
        MomentStimTrig = find(BufferSelectProbe(:,5)>4,1,'first');
    elseif SelectionState == 7 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 1
        MomentStimTrig = find(BufferSelectProbe(:,4)>4,1,'first');
    end
    
    % D�terminer la valeur en temps o� le trigger s'est produit
    MomentStimTime = BufferSelectProbe(MomentStimTrig,1);
    
    % Param�tres de dataEMG pour enregistrer les donn�es selon les specs
    % voulues
    FirstEMG = round(MomentStimTrig - BeforeCapture*hGui.SourceRate);
    LastEMG = round(MomentStimTrig - BeforeCapture*hGui.SourceRate + (AfterCapture+BeforeCapture)*nb_pulsesProbe*hGui.SourceRate);
    dataEMGProbe = BufferSelectProbe(FirstEMG:LastEMG,:);
    
    % Applique la rectification temporel de la capture
    if get(hGui.ZeroRectification,'value')
       dataEMGProbe(:,1) = dataEMGProbe(:,1) - MomentStimTime;
    end
   
    % Sauvegarder les donn�es dans un cell array qui incr�mente selon le
    % nombre de fois que le bouton est press�
    hGui.DataResponseProbe{hGui.NumPushTimeProbeTrain,1} = dataEMGProbe;
    ProbePushTimeString = num2str(hGui.NumPushTimeProbeTrain);
    hGui.DataTable.Data(hGui.NumPushTimeTotal,2) = cellstr(strcat('Probe ',ProbePushTimeString));
    hGui.DataTable.Data(:,4) = {false};
    hGui.DataTable.Data(hGui.NumPushTimeTotal,4) = {true};
 
    % On plot les derni�res donn�es du cell array
    CaptureData = hGui.DataResponseSingle{hGui.NumPushTimeProbeTrain,1};
    for jj = 1:numel(hGui.CapturePlot)
    set(hGui.CapturePlot(jj), 'XData', CaptureData(:,1), ...
                              'YData', CaptureData(:,1+jj))
    drawnow limitrate
    end
    
    % Reset du bouton et mise � jour des donn�es gui
    set(hObject, 'value', 0);
    set(hGui.StatusText, 'String', 'Last Capture taken from Manual Stimulation!');
    guidata(gcbo,hGui);
end
end

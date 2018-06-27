function hGui = DataCaptureUI_PAS(s)
%DataCaptureUI_PAS Create a graphical user interface for data capture.
%   HGUI = DataCaptureUI_PAS(S) returns a structure of graphics
%   components handles (HGUI) and creates a graphical user interface, by
%   programmatically creating a figure and adding required graphics
%   components for visualization of data acquired from a DAQ session (S).

% position:[pixels from left, pixels from bottom, pixels across, pixels high]

% Create a figure and configure a callback function (executes on window close)
Fig = figure('Name','PAS Experiment Interface 1.1', ...
    'NumberTitle', 'off', 'Resize', 'off', 'Position', [45 70 1350 720]);
set(Fig, 'DeleteFcn', {@endDAQ, s});
uiBackgroundColor = get(Fig, 'Color');
hGui = guihandles(Fig); 
hGui.DataResponseSingle = {};
hGui.DataResponseProbe = {};
hGui.DataTableContents = {};
hGui.NumPushTimeSingleTrain = 0;
hGui.NumPushTimeProbeTrain = 0;
hGui.NumPushTimeTotal = 0;
hGui.SourceRate = s.Rate;
hGui.databufferCapture = {};
%hGui.Params = {hGui.data, hGui.NumPushTimeSingleTrain, hGui.SourceRate, hGui.databufferCapture};

% Create the continuous data plot axes with legend
% (one line per acquisition channel)
hGui.Axes1 = axes;
hGui.LivePlot = plot(0, zeros(1, numel(s.Channels(1:4))));
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Continious acquisition data');
% hGui.LivePlot(1,1).Color = [1 0.6 0.2];
% hGui.LivePlot(2,1).Color = [0.2 0.6 1];
% hGui.LivePlot(3,1).Color = [1 0.2 0.2];
% hGui.LivePlot(4,1).Color = [0.2 0.2 1];
legend({'Cortex', 'Muscle', 'Trig Cortex', 'Trig Muscle'},'Units', 'Pixels', 'Position', [1190 636 120 70]); %get(s.Channels(1:4), 'ID')
set(hGui.Axes1, 'Units', 'Pixels', 'Position',  [490 370 820 250]);


% Create the captured data plot axes (one line per acquisition channel)
hGui.Axes2 = axes('Units', 'Pixels', 'Position', [490 50 820 250]);
hGui.CapturePlot = plot(NaN, NaN(1, numel(s.Channels(1:4))));
xlabel('Time (s)');
ylabel('Voltage (V)');
title('EMG response');

% --------------------------------------------------

% Titre de l'interface
uicontrol('style', 'text', 'string', 'PAS Experiment Interface 1.1','FontSize',...
    20, 'FontName', 'Yu Gothic UI' , 'FontWeight', 'bold', 'ForegroundColor', [0 0.8 0.4],...
    'HorizontalAlignment', 'Center', 'units', 'pixels', 'position', [425 660 500 40]);

% Section pour Probe
uicontrol('style', 'text', 'string', 'Probe Section', 'FontSize', 13,...
    'FontName', 'Yu Gothic UI' , 'FontWeight', 'bold', 'ForegroundColor', [0 0.5 1],...
    'HorizontalAlignment', 'Center', 'units', 'pixels', 'position', [60 625 320 30]);

% Create an editable text field for the Before Stim recording
hGui.BeforeStim = uicontrol('style', 'edit', 'string', '500',...
    'units', 'pixels', 'position', [60 465 50 25]);

% Le texte au-dessus de hGui.BeforeStim
uicontrol('style', 'text', 'string', 'Before Stim (ms) ',...
    'units', 'pixels', 'position', [57 492 60 25]);

% Create an editable text field for the After Stim recording
hGui.AfterStim = uicontrol('style', 'edit', 'string', '1500',...
    'units', 'pixels', 'position', [125 465 50 25]);

% Le texte au-dessus de hGui.AfterStim
uicontrol('style', 'text', 'string', 'After Stim (ms) ',...
    'units', 'pixels', 'position', [126 492 50 25]);

% Create an editable text field for the number of pulses for Probe
hGui.PulseProbe = uicontrol('style', 'edit', 'string', '20',...
    'units', 'pixels', 'position', [60 520 50 25]);

% Le texte au-dessus de hGui.PulseProbe
uicontrol('style', 'text', 'string', 'Trains','HorizontalAlignment', 'Center', ...
    'units', 'pixels', 'position', [60 545 50 20]);

% Create an editable text field for the minimun time between each probe
hGui.MinProbeTime = uicontrol('style', 'edit', 'string', '1',...
    'units', 'pixels', 'position', [190 520 50 25]);

% Le texte au-dessus de hGui.MinProbeTime
uicontrol('style', 'text', 'string', 'Min Probe Time (s) ',...
    'units', 'pixels', 'position', [189 545 54 30]);

% Create an editable text field for the maximun time between each probe
hGui.MaxProbeTime = uicontrol('style', 'edit', 'string', '5',...
    'units', 'pixels', 'position', [255 520 50 25]);

% Le texte au-dessus de hGui.MaxProbeTime
uicontrol('style', 'text', 'string', 'Max Probe Time (s) ',...
    'units', 'pixels', 'position', [254 545 54 30]);

% Create an editable text field for time to wait between each pulse for PAS
hGui.InterProbe = uicontrol('style', 'edit', 'string', '1',...
    'units', 'pixels', 'position', [125 520 50 25]);

% Le texte au-dessus de hGui.InterProbe
uicontrol('style', 'text', 'string', 'Inter-Train time (s)', 'HorizontalAlignment', 'Center',...
    'units', 'pixels', 'position', [123 545 54 30]);

% % Create an editable text field for the maximun time between each probe
% hGui.TrainLenghtProbe = uicontrol('style', 'edit', 'string', '20',...
%     'units', 'pixels', 'position', [190 400 50 25]);
% 
% % Le texte au-dessus de hGui.TrainLenghtProbe
% uicontrol('style', 'text', 'string', 'Train Duration',...
%     'units', 'pixels', 'position', [188 425 54 30]);

% -------------------------------------------------

% Create a checkbox to stimulate the cortex 
hGui.CheckCortexStim = uicontrol('style', 'checkbox', 'string', 'Cortex Stim.',...
    'units', 'pixels', 'position', [210 581 80 30]);

% Create a checkbox to stimulate the muscle 
hGui.CheckMuscleStim = uicontrol('style', 'checkbox', 'string', 'Muscle Stim.',...
    'units', 'pixels', 'position', [305 581 80 30]);

% Create a checkbox to allow a reticfication in capture
hGui.ZeroRectification = uicontrol('style', 'checkbox', 'string', 'Zero Rectification',...
    'units', 'pixels', 'position', [190 465 105 15]);

% Create a checkbox to allow an random spacing for the PAS Stim
hGui.RandomProbe = uicontrol('style', 'checkbox', 'string', 'Random Spacing',...
    'units', 'pixels', 'position', [190 490 105 15]);

% --------------------------------------------------

% Section pour les PAS
uicontrol('style', 'text', 'string', 'PAS Experiment Section', 'FontSize',13,...
    'FontName', 'Yu Gothic UI' , 'FontWeight', 'bold', 'ForegroundColor', [1 0.6 0.2],...
    'HorizontalAlignment', 'Center', 'units', 'pixels', 'position', [60 410 320 30]);

% Create an editable text field for the number of pulses for PAS
hGui.PulsePAS = uicontrol('style', 'edit', 'string', '100',...
    'units', 'pixels', 'position', [60 350 50 25]);

% Le texte au-dessus de hGui.PulsePAS
uicontrol('style', 'text', 'string', 'Trains','HorizontalAlignment', 'Center', ...
    'units', 'pixels', 'position', [60 375 50 20]);

% Create an editable text field for time to wait between each pulse for PAS
hGui.InterPAS = uicontrol('style', 'edit', 'string', '1',...
    'units', 'pixels', 'position', [125 350 50 25]);

% Le texte au-dessus de hGui.InterPAS
uicontrol('style', 'text', 'string', 'Inter-Train time (s)', 'HorizontalAlignment', 'Center',...
    'units', 'pixels', 'position', [123 375 54 30]);

% Create an editable text field for the minimun time to wait for PAS
hGui.MinPAS = uicontrol('style', 'edit', 'string', '1',...
    'units', 'pixels', 'position', [190 350 50 25]);

% Le texte au-dessus de hGui.MinPAS
uicontrol('style', 'text', 'string', 'Min time (s) (random) ', 'HorizontalAlignment', 'Center',...
    'units', 'pixels', 'position', [187 375 58 30]);

% Create an editable text field for the maximun time to wait for PAS
hGui.MaxPAS = uicontrol('style', 'edit', 'string', '3',...
    'units', 'pixels', 'position', [255 350 50 25]);

% Le texte au-dessus de hGui.MaxPAS
uicontrol('style', 'text', 'string', 'Max time (s) (random) ', 'HorizontalAlignment', 'Center',...
    'units', 'pixels', 'position', [251 375 60 30]);

% Create a checkbox to allow an random spacing for the PAS Stim
hGui.RandomPAS = uicontrol('style', 'checkbox', 'string', 'Random Spacing',...
    'units', 'pixels', 'position', [60 320 125 25]);

% --------------------------------------------------

% Section pour les PAS
uicontrol('style', 'text', 'string', 'Data Section', 'FontSize',13,...
    'FontName', 'Yu Gothic UI' , 'FontWeight', 'bold', 'ForegroundColor', [1 0.1 0.1],...
    'HorizontalAlignment', 'Center', 'units', 'pixels', 'position', [60 295 320 30]);

hGui.DataTable = uitable(Fig,'ColumnWidth',{76 76 70.5},'ColumnName',...
    {'Single','Probe','Display'},'Position',[60 60 245 220]);
hGui.DataTable.Data = {};
hGui.DataTable.ColumnEditable = true;

% hGui.DataTable.ColumnName = {'Single Stim','Probe Stim','Display'};
% hGui.DataTable.ColumnEditable = true;

% Create a checkbox to allow an average response of the EMG
hGui.Average = uicontrol('style', 'checkbox', 'string', 'Average',...
    'units', 'pixels', 'position', [320 120 75 15]);

% --------------------------------------------------

% Creation des boutons et autres

% Create a status text field
hGui.StatusText = uicontrol('style', 'text', 'string', '',...
    'units', 'pixels', 'position', [60 25 225 25],...
    'HorizontalAlignment', 'left', 'BackgroundColor', uiBackgroundColor);

% Create a popup menu to select the channel to display in continuous axes
hGui.ContSelect = uicontrol('Style', 'popup','String',...
    {'Cortex+Trig (AI0+AI2)','Muscle+Trig (AI1+AI3)','Cortex (AI0)','Muscle (AI1)','Trig Cortex(AI2)','Trig Muscle (AI3)','ALL'},'Position',[60 555 130 50]);

% Le texte au-dessus de hGui.ContSelect
uicontrol('style', 'text', 'string', 'Data Selection','HorizontalAlignment', 'Center', ...
    'units', 'pixels', 'position', [60 605 130 20]);

% Create a manual stim button (muscle) and configure a callback function
hGui.GuideUtile = uicontrol('style', 'pushbutton', 'string', 'Guide Interface',...
    'units', 'pixels', 'position', [990 650 80 40]);
set(hGui.GuideUtile, 'callback', {@messageGuide, hGui});

% Create a stop acquisition button and configure a callback function
hGui.DAQButton = uicontrol('style', 'pushbutton', 'string', 'Stop DAQ',...
    'units', 'pixels', 'position', [1090 650 80 40]);
set(hGui.DAQButton, 'callback', {@endDAQ, s});

% Create a manual single stim button and configure a callback function
hGui.ManualButton = uicontrol('style', 'pushbutton', 'string', 'Single Train',...
    'units', 'pixels', 'position', [320 520 80 40]);
set(hGui.ManualButton, 'callback', {@startManual, hGui});

% Create a probe stim button (muscle) and configure a callback function
hGui.ProbeButton = uicontrol('style', 'pushbutton', 'string', 'Probe Start',...
    'units', 'pixels', 'position', [320 465 80 40]);
set(hGui.ProbeButton, 'callback', {@startProbe, hGui});

% Create a PAS button and configure a callback function
hGui.PASButton = uicontrol('style', 'pushbutton', 'string', 'Start PAS',...
    'units', 'pixels', 'position', [320 350 80 40]);
set(hGui.PASButton, 'callback', {@startPAS, hGui});

% Create a PAS button and configure a callback function
hGui.DisplayButton = uicontrol('style', 'pushbutton', 'string', 'Display EMG',...
    'units', 'pixels', 'position', [320 60 80 40]);
set(hGui.DisplayButton, 'callback', {@displayCapture, hGui});

guidata(Fig,hGui);
end

function messageGuide(hObject,~,~)
if get(hObject, 'value')
    GuideFig = {};
    GuideFig{1,1} = 'Guide de l''utilisation du PAS Experiment Interface 1.1';
    GuideFig{2,1} = '';
    GuideFig{3,1} = 'Pour stimuler le cortex :';
    GuideFig{4,1} = '1. Cocher la case «Cortex Stim» et choisir la sélection «Cortex+Trig (AI0+AI2)».';
    GuideFig{5,1} = '2. Choisir les paramètres qui vont servir à la capture (avant/après stim) et Probe time si on chosit de l''option «Probe».';
    GuideFig{6,1} = '3. Cliquer sur le bouton «Manual» pour produire un pulse unique ou «Probe» pour produire plusieurs pulses (définir le nombre de pulses dans la case correspondante).';
    GuideFig{7,1} = '4. La stimulation devrait avoir lieu et la dernière réponse EMG devrait être affiché dans le graphique du dessous.';
    GuideFig{8,1} = 'Note :';
    GuideFig{9,1} = '- L''option «average» sert à moyenner les réponses EMG.';
    GuideFig{10,1} = '- L''option «Zero Rect» sert à rectifier les données lors des captures à zéros lors du trigger.';
    GuideFig{11,1} = '';
    GuideFig{12,1} = 'Pour stimuler les muscles :';
    GuideFig{13,1} = '1. Cocher la case «Muscle Stim» et choisir la sélection «Muscle+Trig (AI1+AI3)».';
    GuideFig{14,1} = '2. La procédure est pareil aux étapes 2. à 4. de la stimulation du cortex.';
    GuideFig{15,1} = '';
    GuideFig{16,1} = 'Pour stimuler le cortex et les muscles :';
    GuideFig{17,1} = '1. Cocher la case «Cortex Stim» et la case «Muscle Stim» et choisir la sélection «ALL».';
    GuideFig{18,1} = '2. La procédure est pareil aux étapes 2. à 4. de la stimulation du cortex.';
    GuideFig{19,1} = '';
    GuideFig{20,1} = 'Expérience de PAS';
    GuideFig{21,1} = '1. Choisir les paramètres désirés dans la section PAS Experiment (nombre de pulses, inter-pulse time, etc.).';
    GuideFig{22,1} = '2. Cliquer le bouton «Start PAS» pour débuter';
    GuideFig{23,1} = 'Note :';
    GuideFig{24,1} = '- L''option «Random Spacing» consiste à régler un espacement aléatoire entre les impulsions d''une durée dépendament du contenu dans les cases «Min Time» et «Max Time».';
    GuideFig{25,1} = '';
    GuideFig{26,1} = 'IMPORTANT : Il faut s''assurer de choisir le bon parton de stimulation de pouvoir stimulion! Décocher les cases de stimultions non nécessaires sinon une erreur se produira.';
    msgbox(GuideFig,'Guide de l''utilisateur');
end
end


function startManual(hObject,~,~)

if get(hObject, 'value')
    hGui = guidata(gcbo);
    set(hGui.StatusText, 'String', 'Manual cortex stimulation in progress.');
    persistent MomentStimTime MomentStimTrig HighTrainTrig dataEMG
    global BufferSelect SelectionState
    
    % Initialisation de la session selon la sélection choisie, les checkbox
    % choisie pour faire la stimulation. On prépare aussi le signal de
    % trigger selon les paramètres choisis
    if SelectionState == 1 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 0
        disp('Stimulation du cortex en processus et AI0 est enregistré')
        set(hGui.StatusText, 'String', 'Manual cortex stimulation selected.');
        sManual = daq.createSession('ni');
        addAnalogOutputChannel(sManual,'Dev1','ao0','Voltage');
        sManual.Rate = 4000;
        espManual_time = 1/sManual.Rate;
        time_Manual = [0:espManual_time:1]';
        Output_Manual = cat(1,(0*time_Manual(1:400)),(5+0*time_Manual(401:800)),(0.001*time_Manual(801:length(time_Manual))));
        queueOutputData(sManual,Output_Manual);
    elseif SelectionState == 2 && get(hGui.CheckCortexStim,'value') == 0 && get(hGui.CheckMuscleStim,'value') == 1
        disp('Stimulation du muscle en processus et AI1 est enregistré')
        set(hGui.StatusText, 'String', 'Manual muscle stimulation selected.');
        sManual = daq.createSession('ni');
        addAnalogOutputChannel(sManual,'Dev1','ao1','Voltage');
        sManual.Rate = 4000;
        espManual_time = 1/sManual.Rate;
        time_Manual = [0:espManual_time:1]';
        Output_Manual = cat(1,(0*time_Manual(1:400)),(5+0*time_Manual(401:800)),(0.001*time_Manual(801:length(time_Manual))));
        queueOutputData(sManual,Output_Manual);
    elseif SelectionState == 7 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 1
        disp('Stimulation du cortex et des muscles en processus et AI0 à AI3 est enregistré')
        set(hGui.StatusText, 'String', 'Manual cortex and muscle stimulations selected.');
        sManual = daq.createSession('ni');
        addAnalogOutputChannel(sManual,'Dev1','ao0','Voltage');
        addAnalogOutputChannel(sManual,'Dev1','ao1','Voltage');
        sManual.Rate = 4000;
        espManual_time = 1/sManual.Rate;
        time_Manual = [0:espManual_time:1]';
        Output_ManualCortex = cat(1,(0*time_Manual(1:400)),(5+0*time_Manual(401:800)),(0.001*time_Manual(801:length(time_Manual))));
        Output_ManualMuscle = Output_ManualCortex;
        queueOutputData(sManual,[Output_ManualCortex,Output_ManualMuscle]);
    else
        error('Choose the appropriate selection that corresponds with the stimulation patern')
    end
       
    % Compatage du nombre de fois que le bouton est poussé
    hGui.NumPushTimeSingleTrain = hGui.NumPushTimeSingleTrain + 1;
    hGui.NumPushTimeTotal = hGui.NumPushTimeSingleTrain + hGui.NumPushTimeProbeTrain;
    
    % Prend les données dans les cases correspondantes (avant, après stim)
    BStim = str2double(hGui.BeforeStim.String)/1000;
    AStim = str2double(hGui.AfterStim.String)/1000;
    %LenghtCorrection = str2double(hGui.TrainLenghtProbe.String)*hGui.SourceRate/1000;
    maxEMGbuffer = round(hGui.SourceRate*(AStim+BStim));
    
    % Initialisation du buffer pour enregistrer les données
    dataEMG = zeros(maxEMGbuffer,length(BufferSelect(1,:)));
    
    % Envoi du trigger vers le AM systems
    startBackground(sManual);
    set(hGui.StatusText, 'String', 'Le rat devrait bouger ahhahahah');
    wait(sManual);
    set(hGui.StatusText, 'String', 'Manual cortex stimulation is done!');
    stop(sManual);
    
    % Pause afin d'acquérir toutes les données nécessaires à la capture
    pause(0.5+(maxEMGbuffer/hGui.SourceRate));
    
    % Déterminer le moment où la première valeur de trigger a lieu
    if SelectionState == 1 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 0
        HighTrainTrig = sum(BufferSelect(1:length(BufferSelect(:,1)),4)>4);
        MomentStimTrig = find(BufferSelect(:,4)>4,1,'last')-HighTrainTrig;
    elseif SelectionState == 2 && get(hGui.CheckCortexStim,'value') == 0 && get(hGui.CheckMuscleStim,'value') == 1 
        HighTrainTrig = sum(BufferSelect(1:length(BufferSelect(:,1)),5)>4);
        MomentStimTrig = find(BufferSelect(:,5)>4,1,'last')-HighTrainTrig;
    elseif SelectionState == 7 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 1
        HighTrainTrig = sum(BufferSelect(1:length(BufferSelect(:,1)),4)>4);
        MomentStimTrig = find(BufferSelect(:,4)>4,1,'last')-HighTrainTrig;
    end
    
    % Déterminer la valeur en temps où le trigger s'est produit
    MomentStimTime = BufferSelect(MomentStimTrig,1);
    
    % Paramètres de dataEMG pour enregistrer les données selon les specs
    % voulues
    FistEMG = round(MomentStimTrig - BStim*hGui.SourceRate);
    LastEMG = round(MomentStimTrig + AStim*hGui.SourceRate);
    dataEMG = BufferSelect(FistEMG:LastEMG,:);
    
    % Applique la rectification temporel de la capture
    if get(hGui.ZeroRectification,'value')
       dataEMG(:,1) = dataEMG(:,1) - MomentStimTime;
    end
   
    % Sauvegarder les données dans un cell array qui incrémente selon le
    % nombre de fois que le bouton est pressé
    hGui.DataResponseSingle{hGui.NumPushTimeSingleTrain,1} = dataEMG;
    SinglePushTimeString = num2str(hGui.NumPushTimeSingleTrain);
    hGui.DataTable.Data(hGui.NumPushTimeTotal,1) = cellstr(strcat('Single_',SinglePushTimeString));
    hGui.DataTable.Data(:,3) = {false};
    hGui.DataTable.Data(hGui.NumPushTimeTotal,3) = {true};
 
    % On plot les dernières données du cell array
    CaptureData = hGui.DataResponseSingle{hGui.NumPushTimeSingleTrain,1};
    for jj = 1:numel(hGui.CapturePlot)
    set(hGui.CapturePlot(jj), 'XData', CaptureData(:,1), ...
                              'YData', CaptureData(:,1+jj))
    drawnow limitrate
    end
    
    % Reset du bouton et mise à jour des données gui
    set(hObject, 'value', 0);
    set(hGui.StatusText, 'String', 'Last Capture taken from Manual Stimulation!');
    guidata(gcbo,hGui);
end
end

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
    
    % Compatage du nombre de fois que le bouton est poussé
    hGui.NumPushTimeProbeTrain = hGui.NumPushTimeProbeTrain + 1;
    hGui.NumPushTimeTotal = hGui.NumPushTimeSingleTrain + hGui.NumPushTimeProbeTrain;
    
    % Creation d'une nouvelle session de analog output servant pour la
    % section Probe
    sProbe = daq.createSession('ni');
    sProbe.Rate = 1000;
    
    % Code d'erreur pour vérifier si les paramètres de stimulation sont
    % cohérentes avec les paramètres de capture choisis. On définit aussi
    % la durée d'un "pulse" (time_single_pulse) qui va être répétée selon
    % le nombre de pulse désiré dans Probe.
    esp_time = 1/sProbe.Rate;
    if get(hGui.RandomProbe,'value')
        if LMinProbe < (BeforeCapture + AfterCapture)
            err('La valeur minimale des trains aléatoire est plus petite que la fênetre capturée (avant et après capture)')
        else
            time_single_pulse = [0:esp_time:LMaxProbe]';
        end
    else
        if InterPulseProbe < (BeforeCapture + AfterCapture) % Ajouter Le esp_time? Qui correspond à la 0 si on fait -BeforeCapture à +AfterCapture (2001 de longueur si 500 ms et 1500 ms après)
            err('La durée de inter-train est plus petite que la fênetre capturée (avant et après capture)')
        else
            time_single_pulse = [0:esp_time:InterPulseProbe]';
        end
    end
    
%----- Préparation de Analog Out en fonction de paramètres choisis -----
    
    if SelectionState == 1 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 0
        % Update du status 
        disp('Stimulation du cortex en processus et AI0 et AI2 est enregistré (Probe)')
        set(hGui.StatusText, 'String', 'Stimulation du cortex en processus et AI0 et AI2 est enregistré (Probe)');
        
        % Génération du signal de trigger
        addAnalogOutputChannel(sProbe,'Dev1','ao0','Voltage');
        n = 0;
        pulse_cortex_tot_Probe = {};
        while n < nb_pulsesProbe
            n=n+1;
            if get(hGui.RandomProbe,'value')
                ecart_stim = round((LMinProbe+(LMaxProbe-LMinProbe).*rand(1))/esp_time);
            else
                ecart_stim = round(InterPulseProbe/(esp_time*1.5));
            end
            pulse_cortex_Probe = cat(1,(0*time_single_pulse(1:ecart_stim)),(5+0*time_single_pulse(ecart_stim+1:length(time_single_pulse))));
            pulse_cortex_tot_Probe{n,1} = pulse_cortex_Probe;
        end
        
        % Remise à zéro des output
        pulse_cortex_tot_Probe{n+1,1} = 0*[0:esp_time:1]';
        
        % Préparation du signal à envoyer
        Output_Cortex = cell2mat(pulse_cortex_tot_Probe);
        queueOutputData(sProbe,Output_Cortex)
        
    elseif SelectionState == 2 && get(hGui.CheckCortexStim,'value') == 0 && get(hGui.CheckMuscleStim,'value') == 1
        % Update du status 
        disp('Stimulation du muscle en processus et AI1 est enregistré (Probe)')
        set(hGui.StatusText, 'String', 'Muscle stimulation selected. (Probe)');
        
        % Génération du signal de trigger
        addAnalogOutputChannel(sProbe,'Dev1','ao1','Voltage');
        n = 0;
        pulse_muscle_tot_Probe = {};
        while n < nb_pulsesProbe 
            n=n+1;
            if get(hGui.RandomProbe,'value')
                ecart_stim = round((LMinProbe+(LMaxProbe-LMinProbe).*rand(1))/esp_time);
            else
                ecart_stim = round(InterPulseProbe/(esp_time*1.5));
            end
            pulse_muscle_Probe = cat(1,(0*time_single_pulse(1:ecart_stim)),(5+0*time_single_pulse(ecart_stim+1:length(time_single_pulse))));
            pulse_muscle_tot_Probe{n,1} = pulse_muscle_Probe;
        end
        
        % Remise à zéro des output
        pulse_muscle_tot_Probe{n+1,1} = 0*[0:esp_time:1]';
        
        % Préparation du signal de trigger pour le muscle à envoyé
        Output_Muscle = cell2mat(pulse_muscle_tot_Probe);
        queueOutputData(sProbe,Output_Muscle)
   
    elseif SelectionState == 7 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 1
        % Update du status
        disp('Stimulation du cortex et des muscles en processus et AI0 à AI3 est enregistré (Probe)')
        set(hGui.StatusText, 'String', 'Probe cortex and muscle stimulations selected.');
        
        % Génération du signal
        addAnalogOutputChannel(sProbe,'Dev1','ao0','Voltage');
        addAnalogOutputChannel(sProbe,'Dev1','ao1','Voltage');
        n = 0;
        pulse_cortex_tot_Probe = {};
        pulse_muscle_tot_Probe = {};
        while n < nb_pulsesProbe
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
        
        % Remise à zéro des output
        pulse_cortex_tot_Probe{n+1,1} = 0*[0:esp_time:1]';
        pulse_muscle_tot_Probe{n+1,1} = 0*[0:esp_time:1]';
        
        % Préparation des signals à envoyés
        Output_Cortex = cell2mat(pulse_cortex_tot_Probe);
        Output_Muscle = cell2mat(pulse_muscle_tot_Probe);
        queueOutputData(sProbe,[Output_Cortex Output_Muscle]);
    else
        error('Choose the appropriate selection that corresponds with the stimulation patern')
    end
    
 % ----- Envoi du Output et préparation à l'enregitrement -----
    tic
    
    
    
    
    % Envoi du trigger vers le AM systems
    startBackground(sProbe);
    TimeProbeProcessStart = toc;
    disp(TimeProbeProcessStart);
    set(hGui.StatusText, 'String', 'Le rat devrait bouger ahhahahah');
    wait(sProbe);
    set(hGui.StatusText, 'String', 'Manual cortex stimulation is done!');
    stop(sProbe);
    
    % Pause afin d'acquérir toutes les données nécessaires à la capture
    pause(TimeProbeProcessStart + InterPulseProbe);
    
    % Déterminer le moment où la première valeur de trigger a lieu
    if SelectionState == 1 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 0
        MomentStimTrig = find(BufferSelectProbe(:,4)>4,1,'first');
    elseif SelectionState == 2 && get(hGui.CheckCortexStim,'value') == 0 && get(hGui.CheckMuscleStim,'value') == 1 
        MomentStimTrig = find(BufferSelectProbe(:,5)>4,1,'first');
    elseif SelectionState == 7 && get(hGui.CheckCortexStim,'value') == 1 && get(hGui.CheckMuscleStim,'value') == 1
        MomentStimTrig = find(BufferSelectProbe(:,4)>4,1,'first');
    end
    
    % Déterminer la valeur en temps où le trigger s'est produit
    MomentStimTime = BufferSelectProbe(MomentStimTrig,1);
    
    % Paramètres de dataEMG pour enregistrer les données selon les specs
    % voulues
    FirstEMG = round(MomentStimTrig - BeforeCapture*hGui.SourceRate);
    LastEMG = round(MomentStimTrig - BeforeCapture*hGui.SourceRate + (AfterCapture+BeforeCapture)*nb_pulsesProbe*hGui.SourceRate);
    dataEMGProbe = BufferSelectProbe(FirstEMG:LastEMG,:);
    
    % Applique la rectification temporel de la capture
    if get(hGui.ZeroRectification,'value')
       dataEMGProbe(:,1) = dataEMGProbe(:,1) - MomentStimTime;
    end
   
    % Sauvegarder les données dans un cell array qui incrémente selon le
    % nombre de fois que le bouton est pressé
    hGui.DataResponseSingle{hGui.NumPushTimeProbeTrain,1} = dataEMGProbe;
    ProbePushTimeString = num2str(hGui.NumPushTimeProbeTrain);
    hGui.DataTable.Data(hGui.NumPushTimeTotal,2) = cellstr(strcat('Probe_',ProbePushTimeString));
    hGui.DataTable.Data(:,3) = {false};
    hGui.DataTable.Data(hGui.NumPushTimeTotal,3) = {true};
 
    % On plot les dernières données du cell array
    CaptureData = hGui.DataResponseSingle{hGui.NumPushTimeProbeTrain,1};
    for jj = 1:numel(hGui.CapturePlot)
    set(hGui.CapturePlot(jj), 'XData', CaptureData(:,1), ...
                              'YData', CaptureData(:,1+jj))
    drawnow limitrate
    end
    
    % Reset du bouton et mise à jour des données gui
    set(hObject, 'value', 0);
    set(hGui.StatusText, 'String', 'Last Capture taken from Manual Stimulation!');
    guidata(gcbo,hGui);
end
end

function displayCapture(hObject,~,~)
if get(hObject, 'value')
    hGui = guidata(gcbo);
    set(hGui.StatusText, 'String', 'Le bouton n''est pas configuré encore');
    guidata(gcbo,hGui);
end
end
    
    
function startPAS(hObject,~,hGui)
if get(hObject, 'value')
    % Initialisation d'une nouvelle session et des paramètres utiles
    global sPAS
    sPAS = daq.createSession('ni');
    addAnalogOutputChannel(sPAS,'Dev1','ao0','Voltage');
    addAnalogOutputChannel(sPAS,'Dev1','ao1','Voltage');
    InterPulsePAS = str2double(hGui.InterPAS.String);
    LMinPAS = str2double(hGui.MinPAS.String);
    LMaxPAS = str2double(hGui.MaxPAS.String);
    nb_pulsesPAS = round(str2double(hGui.PulsePAS.String));
    
    sPAS.Rate = 1000;
    esp_time = 1/sPAS.Rate;

    if get(hGui.RandomPAS,'value')
        time_single_pulse = [0:esp_time:LMaxPAS]';
    else
        time_single_pulse = [0:esp_time:InterPulsePAS]';
    end
    
    % Il faut calculer ces 3 params selon le nombre de pulses, mettre des
    % cells array pour enregistrer les conditions
    n = 0;
    pulse_cortex_tot_PAS = {};
    pulse_muscle_tot_PAS = {};
    while n < nb_pulsesPAS % || temps maximun || stop daq est appeler
        n=n+1;
        if get(hGui.RandomPAS,'value')
            ecart_stim = round((LMinPAS+(LMaxPAS-LMinPAS).*rand(1))/esp_time);
        else
            ecart_stim = round(InterPulsePAS/(esp_time*1.5));
        end
        pulse_cortex_PAS = cat(1,(0*time_single_pulse(1:ecart_stim)),(5+0*time_single_pulse(ecart_stim+1:length(time_single_pulse))));
        pulse_muscle_PAS = cat(1,(0*time_single_pulse(1:ecart_stim)),(5+0*time_single_pulse(ecart_stim+1:length(time_single_pulse))));
        pulse_cortex_tot_PAS{n,1} = pulse_cortex_PAS;
        pulse_muscle_tot_PAS{n,1} = pulse_muscle_PAS;
    end
    
    % Remise à zéro des output
    pulse_cortex_tot_PAS{n+1,1} = 0*[0:esp_time:1]';
    pulse_muscle_tot_PAS{n+1,1} = 0*[0:esp_time:1]';
    
    % Préparation des signals à envoyés
    Output_Cortex = cell2mat(pulse_cortex_tot_PAS);
    Output_Muscle = cell2mat(pulse_muscle_tot_PAS);
    queueOutputData(sPAS,[Output_Cortex Output_Muscle]);
    
    startBackground(sPAS);
    set(hGui.StatusText, 'String', 'PAS Experiment in progress.');
    wait(sPAS);
    set(hGui.StatusText, 'String', 'PAS Experiment is done!');
    stop(sPAS);
    delete(sPAS);
end
end

function endDAQ(~, ~, s)
if isvalid(s)
    global sPAS
    if s.IsRunning
        stop(s);
        disp('La session d''enregistrement est fermée');
        if isempty(sPAS)
            disp('La session PAS est déjà fermée (ou n''existe pas)');
        else
            stop(sPAS);
            disp('La session PAS a été fermée lors d''une expérinece de stimulation ');
        end
    end
end
end

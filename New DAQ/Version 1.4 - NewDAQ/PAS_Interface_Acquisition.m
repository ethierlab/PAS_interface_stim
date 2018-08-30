function PAS_Interface_Acquisition(src, event, c)

% Declaration de variable persistentes
persistent dataBuffer dataBufferSelect %dataBufferProbe dataBufferSelectProbe
global LiveBuffer

% If dataCapture is running for the first time, initialize persistent vars
hGui = guidata(gca);
if event.TimeStamps(1) == 0
    dataBuffer = [];          % data buffer
    dataBufferSelect = [];    % data buffer with selected colums to display
    enddr

% Store continuous acquisition data in persistent FIFO buffer dataBuffer
% (display and single scan)
latestData = [event.TimeStamps, event.Data];
dataBuffer = [dataBuffer; latestData];
numSamplesToDiscard = size(dataBuffer,1) - c.bufferSize;
if (numSamplesToDiscard > 0)
    dataBuffer(1:numSamplesToDiscard, :) = [];
end

% Donn�es filtr�es.
[b,a] = butter(4,2*50/src.Rate,'high'); % High pass avec une freq de coupure � 50 Hz
dataFiltered = filter(b,a,dataBuffer(:,2));
dataDCRemove = dataBuffer(:,2)-mean(dataBuffer(:,2)); % Signal pas filtrer et on enl�ve le DC (baseline)

% Display selection code for the live plot. This selection as an impact on
% how the emg probe and single stim button work
AIContSelect = get(hGui.ContSelect,'value'); %Sert � obtenir la valeur de la s�lection, ce qui permet de changer les options
switch AIContSelect % Le switch case est c'est qui permet le changement dans les menus d�filants. Il doit avoir le m�me nombre de cases que d'options
    case 1 % EMG High Pass 50 Hz + Trig Cortex
        [dataEnveloppe,~] = envelope(dataFiltered,16,'peak'); % Enveloppe du signal
        dataBufferSelect = [dataBuffer(:,1),dataFiltered,dataEnveloppe,dataBuffer(:,3),NaN(length(dataBuffer(:,1)),1)]; % Buffer sp�cifique � la s�lection
        max_ylimit_value = max([max(abs(dataBufferSelect(round(0.1*src.Rate):end,2))),max(hGui.HighLine.YData)]); % Limite maximun de l'axe y (positive), on compare la valeur max du buffer avec la valeur de la ligne haute 
        min_ylimit_value = -max_ylimit_value; % La limite minimun (n�gative) correspond � l'inverse due la limite max
    case 2 % EMG DC Remove + Trig Cortex
        [dataEnveloppe,~] = envelope(dataDCRemove,16,'peak'); % Enveloppe du signal
        dataBufferSelect = [dataBuffer(:,1),dataDCRemove,dataEnveloppe,dataBuffer(:,3),NaN(length(dataBuffer(:,1)),1)]; % Buffer sp�cifique � la s�lection
        max_ylimit_value = max(dataBufferSelect(round(0.1*src.Rate):end,2)); % Limite maximun de l'axe y (positive) correspond � la valeur max du buffer
        min_ylimit_value = min(dataBufferSelect(round(0.1*src.Rate):end,2)); % Limite minimun de l'axe y (positive) correspond � la valeur min du buffer
    case 3 % EMG High Pass 50 Hz + Trig Muscle
        [dataEnveloppe,~] = envelope(dataFiltered,16,'peak'); % Enveloppe du signal
        dataBufferSelect = [dataBuffer(:,1),dataFiltered,dataEnveloppe,NaN(length(dataBuffer(:,1)),1),dataBuffer(:,4)]; % Buffer sp�cifique � la s�lection 
        max_ylimit_value = max([max(abs(dataBufferSelect(round(0.1*src.Rate):end,2))),max(hGui.HighLine.YData)]); % Limite maximun de l'axe y (positive), on compare la valeur max du buffer avec la valeur de la ligne haute
        min_ylimit_value = -max_ylimit_value; % La limite minimun (n�gative) correspond � l'inverse due la limite max
    case 4 % EMG DC Remove + Trig Muscle
        [dataEnveloppe,~] = envelope(dataDCRemove,16,'peak'); % Enveloppe du signal
        dataBufferSelect = [dataBuffer(:,1),dataDCRemove,dataEnveloppe,NaN(length(dataBuffer(:,1)),1),dataBuffer(:,4)]; % Buffer sp�cifique � la s�lection
        max_ylimit_value = max(dataBufferSelect(round(0.1*src.Rate):end,2)); % Limite maximun de l'axe y (positive) correspond � la valeur max du buffer
        min_ylimit_value = min(dataBufferSelect(round(0.1*src.Rate):end,2)); % Limite minimun de l'axe y (positive) correspond � la valeur min du buffer
end

% Cette partie d�finit le fonction du rising ou du falling
if dataEnveloppe(end) < str2double(hGui.EMGWindowLow.String)/1000 % Si data enveloppe passe en dessous de la limite emg minimale, le text est mis � 'Rising'
    set(hGui.FlagDisplay, 'string', 'Rising'); % Si la condition est atteinte, on set le text dans l'edit text du GUI
elseif dataEnveloppe(end) > str2double(hGui.EMGWindowHigh.String)/1000  % Si data enveloppe passe au dessus de la limite emg maximale, le text est mis � 'Falling'
    set(hGui.FlagDisplay, 'string', 'Falling'); % Si la condition est atteinte, on set le text dans l'edit text du GUI
end

hGui.SelectionState = AIContSelect; % On convertie la valeur du menu dans une variable handle hGui, afin de pouvoir la lire dans les codes de callbacks
hGui.BufferSelect = dataBufferSelect; % Une fois guidata est call�, cet variable ne s'update plus en live. Utile pour avoir des informations sur la taille des donn�es
LiveBuffer = dataBufferSelect; %Par le global, le buffer est updater couramment. Utile pour avoir des donn�es qui changenet dans le temps, mais p�s le plus efficace. 
% Donc, on utilise le hGui.BufferSelect pour des questions d'informations de taille des �l�ments et LiveBuffer pour les donn�es explicitement (�valuer le niveau EMG)
% On peut tout faire avec LiveBuffer mais il s'agit du variable de type global, ce qui n'est pas la m�thode la plus efficace et peut diminuer les performaces du script

% � cet instant, on actualise les �l�ments graphiques par des valeurs plus actuels
if get(hGui.StopTimeAxis,'value') % Cet option sert � �viter d'actualiser l'axe des X, on a alors un graphique statique (semblable � Labchart)
    set(hGui.StatusText, 'String', 'Live plot is stop!');
else
    % Update live data plot
    % Plot latest plotTimeSpan seconds of data in dataBuffer
    samplesToPlot = min([round(c.plotTimeSpan * src.Rate), size(dataBufferSelect,1)]);
    firstPoint = size(dataBufferSelect, 1) - samplesToPlot + 1;
    % Update x-axis limits
    xlim(hGui.Axes1, [dataBufferSelect(firstPoint,1), dataBufferSelect(end,1)]);
    xlim(hGui.Axes2, [dataBufferSelect(firstPoint,1), dataBufferSelect(end,1)]);
    % Keep y-axis center to origin or between the max and min value of the
    % DC signal
    ylim(hGui.Axes1, [min_ylimit_value,max_ylimit_value]);
    % D�termine les valeurs des lignes max et min 
    Low_Limit = str2double(hGui.EMGWindowLow.String)/1000;
    High_Limit = str2double(hGui.EMGWindowHigh.String)/1000;
    EMG_Low_Limit = [Low_Limit Low_Limit]; % On trace la ligne min � partir de deux points, donc on cr�e un array 1x2 pour les valeurs en y
    EMG_High_Limit = [High_Limit High_Limit]; % On trace la ligne max � partir de deux points, donc on cr�e un array 1x2 pour les valeurs en y
    EMG_Width_Line_X = [dataBufferSelect(firstPoint,1) dataBufferSelect(end,1)]; % Les deux autres points correspond aux extr�mit�s graphiques en x
    % On set tous les valeurs � des �l�ments graphique ici
    set(hGui.LivePlotEMG(1), 'XData', dataBufferSelect(firstPoint:end, 1), ...
        'YData', dataBufferSelect(firstPoint:end, 2)); % EMG
    set(hGui.LivePlotEMG(2), 'XData', dataBufferSelect(firstPoint:end, 1), ...
        'YData', dataBufferSelect(firstPoint:end, 3)); % Enveloppe
    set(hGui.LowLine,'XData', EMG_Width_Line_X, 'YData', EMG_Low_Limit); % Limite Min
    set(hGui.HighLine,'XData', EMG_Width_Line_X, 'YData', EMG_High_Limit); % Limite Max
    set(hGui.LivePlotTrig(1), 'XData', dataBufferSelect(firstPoint:end, 1), ...
        'YData', dataBufferSelect(firstPoint:end, 4)); % Trig Cortex
    set(hGui.LivePlotTrig(2), 'XData', dataBufferSelect(firstPoint:end, 1), ...
        'YData', dataBufferSelect(firstPoint:end, 5)); % Trig Muscle
    drawnow limitrate % �vite de trop ralentir les processus ici, pour avoir une acquisition en temps r�el
end
guidata(gca,hGui);
end
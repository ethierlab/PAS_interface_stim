function PAS_Interface_Acquisition(src, event, c)

% Declaration de variable persistentes
persistent dataBuffer dataBufferSelect %dataBufferProbe dataBufferSelectProbe
global LiveBuffer

% If dataCapture is running for the first time, initialize persistent vars
hGui = guidata(gca);
if event.TimeStamps(1) == 0
    dataBuffer = [];          % data buffer
    dataBufferSelect = [];    % data buffer with selected colums to display
end
        
% if get(hGui.RandomProbe,'value')
%     BufferSizeProbe = (round(str2double(hGui.MaxProbeTime.String)*str2double(hGui.PulseProbe.String)+5)*src.Rate);
% else
%     BufferSizeProbe = (round(str2double(hGui.InterProbe.String)*str2double(hGui.PulseProbe.String)+5)*src.Rate);
% end

% Store continuous acquisition data in persistent FIFO buffer dataBuffer
% (display and single scan)
latestData = [event.TimeStamps, event.Data];
dataBuffer = [dataBuffer; latestData];
numSamplesToDiscard = size(dataBuffer,1) - c.bufferSize;
if (numSamplesToDiscard > 0)
    dataBuffer(1:numSamplesToDiscard, :) = [];
end

% Données filtrées.
[b,a] = butter(4,2*50/src.Rate,'high'); % High pass avec une freq de coupure à 50 Hz
dataFiltered = filter(b,a,dataBuffer(:,2));
dataDCRemove = dataBuffer(:,2)-mean(dataBuffer(:,2)); % Signal pas filtrer et on enlève le DC (baseline)

% Display selection code for the live plot
AIContSelect = get(hGui.ContSelect,'value');
switch AIContSelect
    case 1 % EMG + Trig Cortex + Enveloppe
        [dataEnveloppe,~] = envelope(dataFiltered,16,'peak'); % Enveloppe du signal
        dataBufferSelect = [dataBuffer(:,1),dataFiltered,dataEnveloppe,dataBuffer(:,3),NaN(length(dataBuffer(:,1)),1)];
        max_ylimit_value = max([max(abs(dataBufferSelect(round(0.1*src.Rate):end,2))),max(hGui.HighLine.YData)]);
        min_ylimit_value = -max_ylimit_value;
    case 2 % EMG + Trig Cortex
        [dataEnveloppe,~] = envelope(dataDCRemove,16,'peak'); % Enveloppe du signal
        dataBufferSelect = [dataBuffer(:,1),dataDCRemove,dataEnveloppe,dataBuffer(:,3),NaN(length(dataBuffer(:,1)),1)];
        max_ylimit_value = max(dataBufferSelect(round(0.1*src.Rate):end,2));
        min_ylimit_value = min(dataBufferSelect(round(0.1*src.Rate):end,2));
    case 3 % EMG + Trig Muscle + Enveloppe
        [dataEnveloppe,~] = envelope(dataFiltered,16,'peak'); % Enveloppe du signal
        dataBufferSelect = [dataBuffer(:,1),dataFiltered,dataEnveloppe,NaN(length(dataBuffer(:,1)),1),dataBuffer(:,4)];
        max_ylimit_value = max([max(abs(dataBufferSelect(round(0.1*src.Rate):end,2))),max(hGui.HighLine.YData)]);
        min_ylimit_value = -max_ylimit_value;
    case 4 % EMG + Trig Muscle
        [dataEnveloppe,~] = envelope(dataDCRemove,16,'peak'); % Enveloppe du signal
        dataBufferSelect = [dataBuffer(:,1),dataDCRemove,dataEnveloppe,NaN(length(dataBuffer(:,1)),1),dataBuffer(:,4)];
        max_ylimit_value = max(abs(dataBufferSelect(round(0.1*src.Rate):end,2)));
        min_ylimit_value = min(dataBufferSelect(round(0.1*src.Rate):end,2));
end

if dataEnveloppe(end) < str2double(hGui.EMGWindowLow.String)/1000
    set(hGui.FlagDisplay, 'string', 'Rising');
elseif dataEnveloppe(end) > str2double(hGui.EMGWindowHigh.String)/1000
    set(hGui.FlagDisplay, 'string', 'Falling');
end

hGui.SelectionState = AIContSelect;
hGui.BufferSelect = dataBufferSelect; % Une fois guidata est callé, cet variable ne s'update plus en live. Utile pour avoir des informations sur la taille des données
LiveBuffer = dataBufferSelect; %Par le global, le buffer est updater couramment. Utile pour avoir des données qui changenet dans le temps, mais pâs le plus efficace. 
% Donc, on utilise le hGui.BufferSelect et LiveBuffer si c'est nécessaire (évaluer le niveau EMG)

% Live plot has one line for each acquisition channel

if get(hGui.StopTimeAxis,'value')
    set(hGui.StatusText, 'String', 'Live plot is stop!');
else
    % Update live data plot
    % Plot latest plotTimeSpan seconds of data in dataBuffer
    samplesToPlot = min([round(c.plotTimeSpan * src.Rate), size(dataBufferSelect,1)]);
    firstPoint = size(dataBufferSelect, 1) - samplesToPlot + 1;
    % Update x-axis limits
    xlim(hGui.Axes1, [dataBufferSelect(firstPoint,1), dataBufferSelect(end,1)]);
    xlim(hGui.Axes2, [dataBufferSelect(firstPoint,1), dataBufferSelect(end,1)]);
    % Keep y-axis center to origin
    ylim(hGui.Axes1, [min_ylimit_value,max_ylimit_value]);
    % Calculate the rectangle properties
    Low_Limit = str2double(hGui.EMGWindowLow.String)/1000;
    High_Limit = str2double(hGui.EMGWindowHigh.String)/1000;
    EMG_Low_Limit = [Low_Limit Low_Limit];
    EMG_High_Limit = [High_Limit High_Limit];
    EMG_Width_Line_X = [dataBufferSelect(firstPoint,1) dataBufferSelect(end,1)];
    %EMG_Width = dataBufferSelect(end,1)-dataBufferSelect(firstPoint,1);
    %EMG_Height = abs(High_Limit-Low_Limit);
    
    for ii = 1:2
        set(hGui.LivePlotEMG(ii), 'XData', dataBufferSelect(firstPoint:end, 1), ...
            'YData', dataBufferSelect(firstPoint:end, 1+ii));
        set(hGui.LowLine,'XData', EMG_Width_Line_X, 'YData', EMG_Low_Limit);
        set(hGui.HighLine,'XData', EMG_Width_Line_X, 'YData', EMG_High_Limit);
        %set(hGui.Rectangle, 'Position', [dataBufferSelect(firstPoint,1),Low_Limit,EMG_Width,EMG_Height]);
        set(hGui.LivePlotTrig(ii), 'XData', dataBufferSelect(firstPoint:end, 1), ...
            'YData', dataBufferSelect(firstPoint:end, 3+ii));
        drawnow limitrate
    end
end
guidata(gca,hGui);
end
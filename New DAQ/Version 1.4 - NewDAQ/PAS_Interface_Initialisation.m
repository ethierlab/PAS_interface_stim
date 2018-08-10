% Configure data acquisition session and add analog input channels, this is
% the script to run the code and generate the GUI.
clear all
s = daq.createSession('ni'); % Première session qui sert acquérir les signaux analogiques des EMGs et des triggers.
s_out = daq.createSession('ni'); % Une deuxième session est créée les digitals outputs du DAQ. Une erreur de fréquence d'acquisition survient si on les configure `la session principale.

% On stipule quelles chaînes on veut utiliser ici
Daq_Name = 'Dev2'; % Le Dev2 est le nom du daq
Ch_ai0=addAnalogInputChannel(s,Daq_Name,'ai0','Voltage'); % EMG
Ch_ai2=addAnalogInputChannel(s,Daq_Name,'ai2','Voltage'); % Trigger Cortex
Ch_ai3=addAnalogInputChannel(s,Daq_Name,'ai3','Voltage'); % Trigger Muscle
addDigitalChannel(s_out,Daq_Name,'Port0/Line0','OutputOnly'); % Output Trigger Cortex
addDigitalChannel(s_out,Daq_Name,'Port0/Line1','OutputOnly'); % Output Trigger Muscle

% On spécifie que l'on est en single ended et non en différentiel.
Ch_ai0.TerminalConfig = 'SingleEnded';
Ch_ai2.TerminalConfig = 'SingleEnded';
Ch_ai3.TerminalConfig = 'SingleEnded';

% Le range d'acquisition est configuré ici sur chaque chaîne. Il est mis à
% [-1,1] pour les EMGs afin d'avoir une plus grande précision sur les
% données (précision = 2V/(2^16bits))
Ch_ai0.Range = [-1,1];
Ch_ai2.Range = [-10,10];
Ch_ai3.Range = [-10,10];

% Paramètres de captures et de controles
s.Rate = 6000; % Fréquence d'échantillonnage 

% La structure «capture» contient les informations reliées au buffer

% Longueur du display du plot, qui va alors déterminer la taille du buffer.
capture.plotTimeSpan = 10; % en secondes

% Afin d'éviter de manquer des données lorsqu'on veut une taille de buffer
% (capture.plotTimeSpan) très petite (de l'ordre du 0.1 seconde), on
% désigne un buffer avec la taille minimale à partir du temps de callback 
% afin d'éviter les pertes de données, et ainsi les erreurs. Je sais pas si
% c'est vraiment nécessaire mais c'est pour être safe.
callbackTimeSpan = double(s.NotifyWhenDataAvailableExceeds)/s.Rate;

% On détermine la taille du buffer en temps en prenant la valeur maximale
% des deux variables définies ci-dessus.
capture.bufferTimeSpan = max([capture.plotTimeSpan, callbackTimeSpan*3]);

% On détermine la taille du buffer en échanbtillons, à partir de s.Rate
capture.bufferSize = round(capture.bufferTimeSpan * s.Rate);

% Display graphical user interface, voir PAS_Interface_Gui_Callback pour la
% création des calback des boutons et de la création de tout éléments
% graphiques reliés à l'interface.
hGui = PAS_Interface_Gui_Callback(s,s_out);

% Add a listener for DataAvailable events and specify the callback function
% The specified data capture parameters and the handles to the UI graphics
% elements are passed as additional arguments to the callback function.
dataListener = addlistener(s, 'DataAvailable', @(src,event) PAS_Interface_Acquisition(src, event, capture)); % PAS_Interface_Acquisition est le callback du listener
% Add a listener for acquisition error events which might occur during background acquisition
errorListener = addlistener(s, 'ErrorOccurred', @(src,event) disp(getReport(event.Error)));

% Start continuous background data acquisition 
s.IsContinuous = true;
startBackground(s);

% Wait until session s is stopped from the UI
while s.IsRunning
    pause(0.1);
end

delete(dataListener);
delete(errorListener);
delete(s_out);
delete(s);

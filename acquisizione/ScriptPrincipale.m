clear workspace; clear m;
close all;
clc;

% Variabili e funzioni
data = struct();
filename = 'sensor_data.mat';

disp('Caricamento in corso...')

% Se il file esiste già, carica i dati precedenti. Altrimenti inizializza una struttura vuota.
if exist(filename, 'file') == 2
    load(filename, 'allData', 'saveNumber');
else
    save(filename);
    allData = struct();  % Inizializza la struttura vuota
    saveNumber = 0;
end

if ~exist('saveNumber', 'var') || isempty(saveNumber)
        saveNumber = 0; % Valore iniziale se mancante
end

% Configurazione acquisizione
samplingRate = 100;
duration = 2.5;
samples = samplingRate * duration;

% Collegamento al dispositivo
m = mobiledev;
m.SampleRate = samplingRate;
mobileName = mobileDevName();

% Richiamare la funzione GUI per avviare l'interfaccia grafica
appFig = GUI(m, duration, samples, mobileName, filename, allData, saveNumber); 
uiwait(appFig) % Metto in pausa l'esecuzione dello script finché non termina la funzione GUI

% Creo un alert che informa che è stata terminata la raccolta dati
warn = uifigure;
uialert(warn, {'La raccolta dati è terminata.'; ...
    'Avvio filtraggio...'}, ...
    'Attenzione','Icon','info','CloseFcn','uiresume(warn)')
uiwait(warn);

% Chiamata alla funzione filtro per estrarre le feature dai dati registrati
filtro('sensor_data.mat', 'features_data.mat');
function [] = filtro(inputFilename, outputFilename)
    % Filtro e calcolo delle feature dai dati sensoriali.

    % Verifica l'esistenza del file di input
    if exist(inputFilename, 'file') ~= 2
        error('Il file %s non esiste.', inputFilename);
    end

    % Carica i dati
    load(inputFilename, 'allData');
    if ~exist('allData', 'var') || isempty(allData)
        error('La variabile allData è vuota o mancante.');
    end

    % Parametri della media mobile
    windowSize = 5; % Dimensione della finestra per movmean

    % Struttura per le feature estratte
    featuresData = struct();

    try
        % Ciclo su tutte le acquisizioni in allData
        acquisitionNames = fieldnames(allData); % Prendi i nomi delle acquisizioni

        for i = 1:length(acquisitionNames)
            acquisition = acquisitionNames{i}; % Nome dell'acquisizione
            data = allData.(acquisition); % Dati dell'acquisizione

            % Applicazione della media mobile sui dati dell'accelerometro
            if isfield(data, 'accelData')
                accelX = movmean(data.accelData.x, windowSize);
                accelY = movmean(data.accelData.y, windowSize);
                accelZ = movmean(data.accelData.z, windowSize);

                % Calcolo della magnitudine dei dati di accelerazione smussati
                accelMagnitude = sqrt(accelX.^2 + accelY.^2 + accelZ.^2);

                % Normalizzazione delle componenti dei dati di accelerazione
                accelX = accelX ./ accelMagnitude;
                accelY = accelY ./ accelMagnitude;
                accelZ = accelZ ./ accelMagnitude;

                % Normalizzazione dei valori nell'intervallo [-1, 1]
                accelX = normalize(accelX, 'range', [-1 1]);
                accelY = normalize(accelY, 'range', [-1 1]);
                accelZ = normalize(accelZ, 'range', [-1 1]);

                % Salvataggio dei dati filtrati e normalizzati in una struttura
                featuresData.(acquisition).accel = struct('x', accelX, 'y', accelY, 'z', accelZ, 'magnitude', accelMagnitude);
            end

            % Applicazione della media mobile sui dati di giroscopio
            if isfield(data, 'gyroData')
                gyroX = movmean(data.gyroData.x, windowSize);
                gyroY = movmean(data.gyroData.y, windowSize);
                gyroZ = movmean(data.gyroData.z, windowSize);

                % Normalizzazione dei dati del giroscopio
                gyroX = normalize(gyroX, 'range', [-1 1]);
                gyroY = normalize(gyroY, 'range', [-1 1]);
                gyroZ = normalize(gyroZ, 'range', [-1 1]);

                % Salvataggio dei dati smussati e normalizzati del giroscopio
                featuresData.(acquisition).gyro = struct('x', gyroX, 'y', gyroY, 'z', gyroZ);
            end

            % Applicazione della media mobile sui dati di orientamento
            if isfield(data, 'orientData')
                orientX = movmean(data.orientData.x, windowSize);
                orientY = movmean(data.orientData.y, windowSize);
                orientZ = movmean(data.orientData.z, windowSize);

                % Normalizzazione dei dati di orientamento
                orientX = normalize(orientX, 'range', [-1 1]);
                orientY = normalize(orientY, 'range', [-1 1]);
                orientZ = normalize(orientZ, 'range', [-1 1]);

                % Salvataggio dei dati smussati e normalizzati di orientamento
                featuresData.(acquisition).orient = struct('x', orientX, 'y', orientY, 'z', orientZ);
            end

            % Applicazione della media mobile sui dati del magnetometro
            if isfield(data, 'magfieldData')
                magfieldX = movmean(data.magfieldData.x, windowSize);
                magfieldY = movmean(data.magfieldData.y, windowSize);
                magfieldZ = movmean(data.magfieldData.z, windowSize);

                % Normalizzazione dei dati del magnetometro
                magfieldX = normalize(magfieldX, 'range', [-1 1]);
                magfieldY = normalize(magfieldY, 'range', [-1 1]);
                magfieldZ = normalize(magfieldZ, 'range', [-1 1]);

                % Salvataggio dei dati smussati e normalizzati del magnetometro
                featuresData.(acquisition).mag = struct('x', magfieldX, 'y', magfieldY, 'z', magfieldZ);
            end
        end
    catch ME
        disp(['Errore durante l''elaborazione: ', ME.message]);
    end

     save(outputFilename, 'featuresData');
        disp(['Feature salvate in ', outputFilename]);
   
        % Salvataggio delle feature
    if isempty(fieldnames(featuresData))
        warning('Nessuna feature estratta.');
    end

    % Creo un alert che informa che è stato terminato il filtraggio
    warn = uifigure;
    uialert(warn, {'Filtraggio terminato.'; ...
        'Chiudere il programma.'}, ...
        'Attenzione','Icon','success','CloseFcn','uiresume(warn)')
    uiwait(warn)
end

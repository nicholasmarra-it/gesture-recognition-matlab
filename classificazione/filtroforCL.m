function [] = filtroforCL(inputFilename)
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
    featureTable = table();

    % Ciclo su tutte le acquisizioni in allData
    acquisitionNames = fieldnames(allData); % Prendi i nomi delle acquisizioni

    for i = 1:length(acquisitionNames)
        acquisition = acquisitionNames{i}; % Nome dell'acquisizione
        data = allData.(acquisition); % Dati dell'acquisizione

        % Feature temporanee per questa acquisizione
        tempFeatures = struct();
        tempFeatures.Acquisition = {acquisition};
        tempFeatures.Index = data.index;

        % Elaborazione dati dell'accelerometro
        if isfield(data, 'accelData')
            accelX = movmean(data.accelData.x, windowSize);
            accelY = movmean(data.accelData.y, windowSize);
            accelZ = movmean(data.accelData.z, windowSize);

            % Calcolo della magnitudo
            accelMagnitude = sqrt(accelX.^2 + accelY.^2 + accelZ.^2);

            % Calcolo della deviazione standard mobile
            movStdAccelX = movstd(data.accelData.x, windowSize);
            movStdAccelY = movstd(data.accelData.y, windowSize);
            movStdAccelZ = movstd(data.accelData.z, windowSize);

            % Aggiunta delle feature di movestd
            tempFeatures = addMovingStdFeatures(movStdAccelX, 'Accel_X', tempFeatures);
            tempFeatures = addMovingStdFeatures(movStdAccelY, 'Accel_Y', tempFeatures);
            tempFeatures = addMovingStdFeatures(movStdAccelZ, 'Accel_Z', tempFeatures);

            % Calcolo delle feature statistiche
            tempFeatures = calculateFeatures(accelX, 'Accel_X', tempFeatures);
            tempFeatures = calculateFeatures(accelY, 'Accel_Y', tempFeatures);
            tempFeatures = calculateFeatures(accelZ, 'Accel_Z', tempFeatures);
            tempFeatures = calculateFeatures(accelMagnitude, 'Accel_Mag', tempFeatures);
        end

        % Elaborazione dati del giroscopio
        if isfield(data, 'gyroData')
            gyroX = movmean(data.gyroData.x, windowSize);
            gyroY = movmean(data.gyroData.y, windowSize);
            gyroZ = movmean(data.gyroData.z, windowSize);

            % Calcolo della deviazione standard mobile
            movStdGyroX = movstd(data.gyroData.x, windowSize);
            movStdGyroY = movstd(data.gyroData.y, windowSize);
            movStdGyroZ = movstd(data.gyroData.z, windowSize);

            % Aggiunta delle feature di movestd
            tempFeatures = addMovingStdFeatures(movStdGyroX, 'Gyro_X', tempFeatures);
            tempFeatures = addMovingStdFeatures(movStdGyroY, 'Gyro_Y', tempFeatures);
            tempFeatures = addMovingStdFeatures(movStdGyroZ, 'Gyro_Z', tempFeatures);

            tempFeatures = calculateFeatures(gyroX, 'Gyro_X', tempFeatures);
            tempFeatures = calculateFeatures(gyroY, 'Gyro_Y', tempFeatures);
            tempFeatures = calculateFeatures(gyroZ, 'Gyro_Z', tempFeatures);
        end

        % Elaborazione dati del magnetometro
        if isfield(data, 'magfieldData')
            magfieldX = movmean(data.magfieldData.x, windowSize);
            magfieldY = movmean(data.magfieldData.y, windowSize);
            magfieldZ = movmean(data.magfieldData.z, windowSize);

            % Calcolo della deviazione standard mobile
            movStdMagX = movstd(data.magfieldData.x, windowSize);
            movStdMagY = movstd(data.magfieldData.y, windowSize);
            movStdMagZ = movstd(data.magfieldData.z, windowSize);

            % Aggiunta delle feature di movestd
            tempFeatures = addMovingStdFeatures(movStdMagX, 'Mag_X', tempFeatures);
            tempFeatures = addMovingStdFeatures(movStdMagY, 'Mag_Y', tempFeatures);
            tempFeatures = addMovingStdFeatures(movStdMagZ, 'Mag_Z', tempFeatures);

            tempFeatures = calculateFeatures(magfieldX, 'Mag_X', tempFeatures);
            tempFeatures = calculateFeatures(magfieldY, 'Mag_Y', tempFeatures);
            tempFeatures = calculateFeatures(magfieldZ, 'Mag_Z', tempFeatures);
        end

        % Conversione delle feature in tabella e aggiunta alla tabella principale
        featureTable = [featureTable; struct2table(tempFeatures, "AsArray", true)]; %#ok<AGROW>
    end

    % Salvataggio su file CSV
    outputFilename = 'features_CL.csv';
    writetable(featureTable, outputFilename);
    disp(['Feature salvate in ', outputFilename]);

    % Creo un alert che informa che è stato terminato il filtraggio
    warn = uifigure;
    uialert(warn, {'Filtraggio terminato.'; ...
        'Chiudere il programma.'}, ...
        'Attenzione','Icon','success','CloseFcn','uiresume(warn)')
    uiwait(warn)
end

function tempFeatures = calculateFeatures(signal, prefix, tempFeatures)
    % Calcolo delle feature statistiche per un segnale
    tempFeatures.([prefix, '_Mean']) = mean(signal);
    tempFeatures.([prefix, '_Std']) = std(signal);
    tempFeatures.([prefix, '_MAD']) = mad(signal);
    tempFeatures.([prefix, '_Min']) = min(signal);
    tempFeatures.([prefix, '_Max']) = max(signal);
    tempFeatures.([prefix, '_Range']) = range(signal);
    tempFeatures.([prefix, '_Median']) = median(signal);
    tempFeatures.([prefix, '_IQR']) = iqr(signal);
    tempFeatures.([prefix, '_NegCount']) = sum(signal < 0);
    tempFeatures.([prefix, '_PosCount']) = sum(signal > 0);
    tempFeatures.([prefix, '_AboveMean']) = sum(signal > mean(signal));
    tempFeatures.([prefix, '_Peaks']) = numel(findpeaks(signal));
    tempFeatures.([prefix, '_Skewness']) = skewness(signal);
    tempFeatures.([prefix, '_Kurtosis']) = kurtosis(signal);
    tempFeatures.([prefix, '_Energy']) = sum(signal.^2);
    tempFeatures.([prefix, '_SMA']) = sum(abs(signal));
end

function tempFeatures = addMovingStdFeatures(movStdSignal, prefix, tempFeatures)
    % Aggiunta della deviazione standard mobile come feature
    tempFeatures.([prefix, '_MovStd_Mean']) = mean(movStdSignal);
    tempFeatures.([prefix, '_MovStd_Max']) = max(movStdSignal);
    tempFeatures.([prefix, '_MovStd_Min']) = min(movStdSignal);
    tempFeatures.([prefix, '_MovStd_Std']) = std(movStdSignal);
end

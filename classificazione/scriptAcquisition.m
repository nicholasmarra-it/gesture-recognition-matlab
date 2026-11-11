clear workspace; clear m;
clc;

% Crea una figura per l'interfaccia
    appFig = uifigure('Name', 'Registrazione Gesti', 'Position', [100, 100, 300, 300]);

    % Configurazione acquisizione
    samplingRate = 100;
    duration = 2.5;
    samples = samplingRate * duration;
    
    % Collegamento al dispositivo
    m = mobiledev;
    m.SampleRate = samplingRate;

    %Etichetta per i messaggi di stato
    statusLabel = uilabel(appFig, 'Text', 'Pronto per la registrazione.', ...
        'Position', [50, 220, 200, 60], 'HorizontalAlignment', 'center', "WordWrap", "on");

    % Pulsante per avviare l'acquisizione
    uibutton(appFig, 'push', 'Text', 'AVVIO', ...
         'Position', [100, 110, 100, 50], ...
         'ButtonPushedFcn', @(btn, event) startAcquisition(m, duration, samples, statusLabel));
 
   
        % Funzione per avviare l'acquisizione
        function startAcquisition(m, duration, samples, statusLabel)
            
            % Inizializzo data
            data = struct();
        
            % Abilita i sensori
            m.AccelerationSensorEnabled = true;
            m.AngularVelocitySensorEnabled = true;
            m.OrientationSensorEnabled = true;
            m.MagneticSensorEnabled = true;

            % Acquisizione
            for i = 3:-1:1
                statusLabel.Text = ['Inizio acquisizione tra ', num2str(i), '...'];
                drawnow;
                pause(1)
            end
            statusLabel.Text = 'Acquisizione in corso...';
            drawnow;
            m.Logging = 1;
            pause(duration);
            m.Logging = 0;

            % Disabilita i sensori
            m.AccelerationSensorEnabled = false;
            m.AngularVelocitySensorEnabled = false;
            m.OrientationSensorEnabled = false;
            m.MagneticSensorEnabled = false;

            statusLabel.Text = {'Acquisizione terminata';
                'Chiudere la schermata per iniziare il filtraggio dei dati.'};
            drawnow;

            % Estrai i dati
            [accelData, accelTime] = accellog(m);
            [gyroData, gyroTime] = angvellog(m);
            [orientData, orientTime] = orientlog(m);
            [magfieldData, magfieldTime] = magfieldlog(m);

            % Dati accelerazione
            data.accelTime = accelTime(1:samples);
            data.accelData.x = accelData(1:samples, 1);
            data.accelData.y = accelData(1:samples, 2);
            data.accelData.z = accelData(1:samples, 3);
            data.accelData.tot = sqrt(sum(data.accelData.x.^2 + data.accelData.y.^2 + data.accelData.z.^2, 2));
                
            % Dati giroscopio
            data.gyroTime = gyroTime(1:samples);
            data.gyroData.x = gyroData(1:samples, 1);
            data.gyroData.y = gyroData(1:samples, 2);
            data.gyroData.z = gyroData(1:samples, 3);
            data.gyroData.tot = sqrt(sum(data.gyroData.x.^2 + data.gyroData.y.^2 + data.gyroData.z.^2, 2));
                
            % Dati orientazione
            data.orientTime = orientTime(1:samples);
            data.orientData.x = orientData(1:samples, 1);
            data.orientData.y = orientData(1:samples, 2);
            data.orientData.z = orientData(1:samples, 3);
            data.orientData.tot = sqrt(sum(data.orientData.x.^2 + data.orientData.y.^2 + data.orientData.z.^2, 2));

            % Dati magnetometro
            data.magfieldTime = magfieldTime(1:samples);
            data.magfieldData.x = magfieldData(1:samples, 1);
            data.magfieldData.y = magfieldData(1:samples, 2);
            data.magfieldData.z = magfieldData(1:samples, 3);
            data.magfieldData.tot = sqrt(sum(data.magfieldData.x.^2 + data.magfieldData.y.^2 + data.magfieldData.z.^2, 2));

            % Grafico dei dati dell'Accelerometro (X, Y, Z)
            subplot(4, 1, 1);
            plot(data.accelTime, data.accelData.x, "r", ...
                 data.accelTime, data.accelData.y, "g", ...
                 data.accelTime, data.accelData.z, "b", ...
                 data.accelTime, data.accelData.tot, "y");
            xlabel('Tempo (s)');
            ylabel('Accelerazione (m/s^2)');
            title('Dati Accelerometro');
            legend('X', 'Y', 'Z', 'Spazio');
            
            % Grafico dei dati del Giroscopio (X, Y, Z)
            subplot(4, 1, 2);
            plot(data.gyroTime, data.gyroData.x, "r", ...
                 data.gyroTime, data.gyroData.y, "g", ...
                 data.gyroTime, data.gyroData.z, "b", ...
                 data.gyroTime, data.gyroData.tot, "y");
            xlabel('Tempo (s)');
            ylabel('Velocità Angolare (rad/s)');
            title('Dati Velocità Angolare');
            legend('X', 'Y', 'Z', 'Spazio');
            
            % Grafico dei dati di Orientamento (Angoli di Eulero o Quaternioni)
            subplot(4, 1, 3);
            plot(data.orientTime, data.orientData.x, "r", ...
                 data.orientTime, data.orientData.y, "g", ...
                 data.orientTime, data.orientData.z, "b", ...
                 data.orientTime, data.orientData.tot, "y");
            xlabel('Tempo (s)');
            ylabel('Angoli (gradi o radianti)');
            legend('Pitch', 'Roll', 'Yaw', 'Spazio');
            title('Dati di Orientamento (Angoli di Eulero)');

             % Grafico dei dati del magnetometro
            subplot(4, 1, 4);
            plot(data.magfieldTime, data.magfieldData.x, "r", ...
                 data.magfieldTime, data.magfieldData.y, "g", ...
                 data.magfieldTime, data.magfieldData.z, "b", ...
                 data.magfieldTime, data.magfieldData.tot, "y");
            xlabel('μT');
            ylabel('μT');
            title('Dati del magnetometro');
            legend('X', 'Y', 'Z', 'Spazio');

            % Salvo data come file mat
            save("data.mat", "data");
       end    

% Chiedo conferma all'utente se si vuole chiudere l'applicazione
appFig.CloseRequestFcn = @(src,event)closefig(src);

    function closefig(appFig)
        selection = uiconfirm(appFig,"Chiudere l'applicazione?",...
            "Confirmation", "Options", ["Si", "No"], ...
            "DefaultOption", 2);        
        switch selection
            case "Si"
                delete(appFig)
            case "No"
                return
        end
    end

    uiwait(appFig)


    %% Elaboro i dati
    % Feature temporanee per questa acquisizione
        tempFeatures = struct();
        windowSize = 5;

    % Carico data
    load("data.mat");

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
        featureTable = struct2table(tempFeatures, "AsArray", true);
        % Salvo la tabella
        save("table.mat", "featureTable")

        % Cancello il save data
        delete("data.mat")

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

% Creo un alert che informa che è stato terminato il filtraggio
    warn = uifigure;
    uialert(warn, {'Filtraggio terminato.'; ...
        'Chiudere il programma.'}, ...
        'Attenzione','Icon','success','CloseFcn','uiresume(warn)')
    uiwait(warn)

%% Predizione del modello
% Carico il modello e la tabella
load("table.mat")
load("SVMmodel.mat")

% Uso la funzione predittiva del modello
[yfit,scores] = SVMmodel.predictFcn(featureTable);

% Cancello la tabella
delete("table.mat")

warn = uifigure;
text = sprintf('%s %s %s %s', 'Risultati:', num2str(yfit), '-', nameGestureforCL(yfit));
uialert(warn, text, ...
    'Riconoscimento terminato','Icon','info','CloseFcn','uiresume(warn)')
uiwait(warn);
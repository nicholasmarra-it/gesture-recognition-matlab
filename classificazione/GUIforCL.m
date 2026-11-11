% App per registrare dati da dispositivi mobili
function [appFig] = GUIforCL(m, duration, samples, filename, allData, saveNumber)


  % Verifica se esiste un file salvato
    if exist(filename, 'file')
        loadedData = load(filename); % Carica i dati dal file .mat
        if isfield(loadedData, 'saveNumber') && isfield(loadedData, 'allData')
            saveNumber = loadedData.saveNumber; % Aggiorna saveNumber
            allData = loadedData.allData;       % Aggiorna allData
        else
            warning("Il file salvato non contiene 'saveNumber' o 'allData'.");
        end
    else
        warning("Nessun file salvato trovato. Inizializzo da zero.");
        saveNumber = 0;
        allData = struct();
    end


  
    % Crea una figura per l'interfaccia
    appFig = uifigure('Name', 'Registrazione Gesti', 'Position', [100, 100, 500, 500]);

    % Input per il nome utente
    uilabel(appFig, 'Text', 'Nome Utente:', 'Position', [50, 470, 100, 20]);
    userNameField = uieditfield(appFig, 'Text', 'Position', [150, 470, 200, 22]);

    % Dropdown per selezionare l'indice
    uilabel(appFig, 'Text', 'Indice Azione (0-3):', 'Position', [50, 420, 150, 20]);
    indexDropdown = uidropdown(appFig, 'Items', arrayfun(@num2str, 0:3, 'UniformOutput', false), ...
        'Position', [200, 420, 150, 22]);


    % Pulsante per avviare l'acquisizione
    uibutton(appFig, 'push', 'Text', 'AVVIO', ...
         'Position', [150, 280, 200, 50], ...
         'ButtonPushedFcn', @(btn, event) startAcquisition(userNameField.Value, ...
                                                            str2double(indexDropdown.Value), ...
                                                            saveNumber));
    %Etichetta per i messaggi di stato
    statusLabel = uilabel(appFig, 'Text', 'Pronto per la registrazione.', ...
        'Position', [50, 220, 400, 20], 'HorizontalAlignment', 'center');
    
    % rea un'area di testo per mostrare i dati inseriti
    dataLabel = uilabel(appFig, "Text", "In attesa di dati...", 'Position', [50, 100, 250, 100]);


        % Funzione per avviare l'acquisizione
    function startAcquisition(userName, actionIndex, saveNumber)
        
        % Controlla i campi
        if isempty(userName)
            statusLabel.Text = 'Errore: Compilare campo del nome.';
            return;
        end

        if isnan(actionIndex) || actionIndex < 0 || actionIndex > 3
            statusLabel.Text = 'Errore: Indice azione non valido.';
            return;
        end
        
        % Nel caso ci siano già delle variabili allData e saveNumber nel
        % file salvato le aggiorno nuovamente
         if exist(filename, 'file')
            loadedData = load(filename); % Carica i dati dal file .mat
            if isfield(loadedData, 'saveNumber') && isfield(loadedData, 'allData')
                saveNumber = loadedData.saveNumber; % Aggiorna saveNumber
                allData = loadedData.allData;       % Aggiorna allData
            end
         end

        stop = saveNumber + 5;
        while saveNumber < stop
            discardlogs(m);

            % Abilita i sensori
            m.AccelerationSensorEnabled = true;
            m.AngularVelocitySensorEnabled = true;
            m.OrientationSensorEnabled = true;
            m.MagneticSensorEnabled = true;

            % Acquisizione
            for i = 3:-1:1
                statusLabel.Text = ['Inizio acquisizione ', num2str(saveNumber + 1), ' tra ', num2str(i), '...'];
                drawnow;
                pause(1)
            end
            statusLabel.Text = ['Inizio acquisizione ', num2str(saveNumber + 1), '...'];
            drawnow;
            m.Logging = 1;
            pause(duration);
            m.Logging = 0;

            % Disabilita i sensori
            m.AccelerationSensorEnabled = false;
            m.AngularVelocitySensorEnabled = false;
            m.OrientationSensorEnabled = false;
            m.MagneticSensorEnabled = false;

            statusLabel.Text = 'Acquisizione terminata. Elaborazione dati...';
            drawnow;

            % Estrai i dati
            [accelData, accelTime] = accellog(m);
            [gyroData, gyroTime] = angvellog(m);
            [orientData, orientTime] = orientlog(m);
            [magfieldData, magfieldTime] = magfieldlog(m);

            % Verifica se ci sono abbastanza campioni
            % if length(accelTime) < samples || length(gyroTime) < samples || length(orientTime) < samples
               % statusLabel.Text = 'Errore: Dati insufficienti.';
               % return;
            %end

            % Memorizza i dati
            data.name = ['acquisizione_', num2str(saveNumber + 1)];
            
            % Mostro i dati inseriti nella variabile data

            dataLabelText = sprintf('%s: %s\n%s: %s\n%s: %s\n%s: %s', ...
                'Nome Utente', userName, ...
                'Acquisizione', num2str(saveNumber + 1), ...
                'Indice', num2str(actionIndex), ...
                'Nome Gesto', nameGestureforCL(actionIndex));

            % Salvo l'indice del gesto nella struct data
            data.index = num2str(actionIndex);
        
            dataLabel.Text = dataLabelText;
            dataLabel.WordWrap = 'on';
            drawnow;

            % Dati accelerazione
            data.accelTime = accelTime(1:samples);
            data.accelData.x = accelData(1:samples, 1);
            data.accelData.y = accelData(1:samples, 2);
            data.accelData.z = accelData(1:samples, 3);
            data.accelData.RSM = sqrt(sum(data.accelData.x.^2 + data.accelData.y.^2 + data.accelData.z.^2, 2));
                
            % Dati giroscopio
            data.gyroTime = gyroTime(1:samples);
            data.gyroData.x = gyroData(1:samples, 1);
            data.gyroData.y = gyroData(1:samples, 2);
            data.gyroData.z = gyroData(1:samples, 3);
            data.gyroData.RSM = sqrt(sum(data.gyroData.x.^2 + data.gyroData.y.^2 + data.gyroData.z.^2, 2));
                
            % Dati orientazione
            data.orientTime = orientTime(1:samples);
            data.orientData.x = orientData(1:samples, 1);
            data.orientData.y = orientData(1:samples, 2);
            data.orientData.z = orientData(1:samples, 3);

            % Dati magnetometro
            data.magfieldTime = magfieldTime(1:samples);
            data.magfieldData.x = magfieldData(1:samples, 1);
            data.magfieldData.y = magfieldData(1:samples, 2);
            data.magfieldData.z = magfieldData(1:samples, 3);
            data.magfieldData.RSM = sqrt(sum(data.magfieldData.x.^2 + data.magfieldData.y.^2 + data.magfieldData.z.^2, 2));

            % Crea la cartella per salvare le immagini se non esiste
            plotFolderName = 'plot_images'; 
            if ~exist(plotFolderName, 'dir')
                mkdir(plotFolderName);
            end

            % Grafico dei dati dell'Accelerometro (X, Y, Z)
            subplot(4, 1, 1);
            plot(data.accelTime, data.accelData.x, "r", ...
                 data.accelTime, data.accelData.y, "g", ...
                 data.accelTime, data.accelData.z, "b", ...
                 data.accelTime, data.accelData.RSM, "y");
            xlabel('Tempo (s)');
            ylabel('Accelerazione (m/s^2)');
            title('Dati Accelerometro');
            legend('X', 'Y', 'Z', 'RSM');
            
            % Grafico dei dati del Giroscopio (X, Y, Z)
            subplot(4, 1, 2);
            plot(data.gyroTime, data.gyroData.x, "r", ...
                 data.gyroTime, data.gyroData.y, "g", ...
                 data.gyroTime, data.gyroData.z, "b", ...
                 data.gyroTime, data.gyroData.RSM, "y");
            xlabel('Tempo (s)');
            ylabel('Velocità Angolare (rad/s)');
            title('Dati Velocità Angolare');
            legend('X', 'Y', 'Z', 'RSM');
            
            % Grafico dei dati di Orientamento (Angoli di Eulero o Quaternioni)
            subplot(4, 1, 3);
            plot(data.orientTime, data.orientData.x, "r", ...
                 data.orientTime, data.orientData.y, "g", ...
                 data.orientTime, data.orientData.z, "b");
            xlabel('Tempo (s)');
            ylabel('Angoli (gradi o radianti)');
            legend('Pitch', 'Roll', 'Yaw');
            title('Dati di Orientamento (Angoli di Eulero)');

             % Grafico dei dati del magnetometro
            subplot(4, 1, 4);
            plot(data.magfieldTime, data.magfieldData.x, "r", ...
                 data.magfieldTime, data.magfieldData.y, "g", ...
                 data.magfieldTime, data.magfieldData.z, "b", ...
                 data.magfieldTime, data.magfieldData.RSM, "y");
            xlabel('μT');
            ylabel('μT');
            title('Dati del magnetometro');
            legend('X', 'Y', 'Z', 'RSM');


            % Salva la figura come immagine PNG
            plotFilename = ['acquisizione_', num2str(saveNumber+1), '.png'];
            saveas(gcf, fullfile(plotFolderName, plotFilename));  % Salva la figura come PNG
            
            % Memorizza il nome del file nell'interno della struttura
            data.plot = plotFilename;

            % Salva nella struttura
            actionKey = ['acquisizione_', num2str(saveNumber + 1)];
            if ~isfield(allData, actionKey)
                allData.(actionKey) = struct();
            end

            allData.(actionKey) = data;

            % Chiedi conferma all'utente per salvare i dati dell'acquisizione
            selection = uiconfirm(appFig, "Salvare l'acquisizione?", "Acquisizione terminata",...
                "Options", ["Salva", "Riprova"], ...
                "DefaultOption", 1);
            if selection == "Salva"
                   % Incrementa saveNumber solo se i dati vengono salvati
                saveNumber = saveNumber + 1;
                % Salva i dati aggiornati nel file .mat
                save(filename, 'allData', 'saveNumber', '-append');
                % Aggiorna lo stato
                statusLabel.Text = ['Acquisizione ', num2str(saveNumber), ' completata e salvata.'];
            else
                % Non incrementare saveNumber se i dati vengono scartati
                statusLabel.Text = ['Acquisizione ', num2str(saveNumber + 1), ' scartata.'];
            end
       end    
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


end

inputFilename = 'sensor_data.mat';
csvAnnotations = 'dati_acquisiti.csv'; % Nome del file CSV

% Controllo se il file esiste
if exist(inputFilename, 'file') ~= 2
    error('Il file %s non esiste.', inputFilename);
end

% Controllo se il file CSV delle annotazioni esiste
if exist(csvAnnotations, 'file') ~= 2
    error('Il file %s non esiste.', csvAnnotations);
end

% Carica i dati
load(inputFilename, 'allData');
if ~exist('allData', 'var') || isempty(allData)
    error('La variabile allData è vuota o mancante.');
end

% Leggi le annotazioni dal file CSV
annotationsTable = readtable(csvAnnotations);

% Estrai i nomi delle acquisizioni
acquisitionNames = fieldnames(allData);

% Crea una finestra GUI per selezionare l'acquisizione
appFig = uifigure('Name', 'Visualizzazione Gesti', 'Position', [100, 100, 600, 700]);

% Dropdown per selezione singola
uilabel(appFig, 'Text', 'Seleziona una singola acquisizione:', 'Position', [50, 630, 200, 22]);
singleAcquisitionDropdown = uidropdown(appFig, 'Items', acquisitionNames, 'Position', [300, 630, 200, 22]);

% Lista per selezione multipla
uilabel(appFig, 'Text', 'Seleziona un gruppo di acquisizioni:', 'Position', [50, 570, 200, 22]);
groupAcqusitionList = uilistbox(appFig, 'Items', acquisitionNames, 'Position', [300, 510, 200, 80], 'Multiselect', 'on');

% Label che mostra le annotazioni estratte dal csv
statusLabel = uilabel(appFig, 'Text', 'In attesa di dati...', ...
    'Position', [50, 250, 500, 200]);

% Pulsante per visualizzare singola acquisizione
uibutton(appFig, 'Text', 'Visualizza Singola', 'Position', [50, 120, 200, 40], ...
    'ButtonPushedFcn', @(btn, event) plotSingleAcquisition(singleAcquisitionDropdown.Value, allData, annotationsTable, statusLabel));

% Pulsante per visualizzare gruppo di acquisizioni
uibutton(appFig, 'Text', 'Visualizza Gruppo', 'Position', [300, 120, 200, 40], ...
    'ButtonPushedFcn', @(btn, event) plotGroupAcquisitions(groupAcqusitionList.Value, allData, annotationsTable, statusLabel));



% Funzione per visualizzare una singola acquisizione
function plotSingleAcquisition(selectedAcquisition, allData, annotationsTable, statusLabel)
    if isempty(selectedAcquisition)
        uialert(appFig, 'Seleziona un'' acquisizione valida.', 'Errore');
        return;
    end
    % Estrai i dati e visualizzali
    data = allData.(selectedAcquisition);

    % Converto acquisitionName in numero
    acqNum = extractAfter(selectedAcquisition,"acquisizione_");

    % Trova annotazioni corrispondenti
    rows = matches(string(annotationsTable.Idx_Acquisition), acqNum);
    annotationRow = annotationsTable(rows, :);
        
    if ~isempty(annotationRow)
        statusLabel.Text = {['Annotazioni per ', selectedAcquisition, ':']; ...
            sprintf('%s: %s\n%s: %s\n%s: %s\n%s: %s\n%s: %s\n%s: %s\n%s: %s\n%s: %s\n', ...
            'Nome Utente', string(annotationRow.ID_Subject), ...
            'Indice', string(annotationRow.ID_Gesture), ...
            'Acquisizione', string(annotationRow.Idx_Acquisition), ...
            'Acquisizione per utente', string(annotationRow.Idx_Acquisition_Subject), ...
            'Dispositivo', string(annotationRow.Smartphone_model), ...
            'Gesto', string(annotationRow.Name_Gesture), ...
            'Sensori disponibili', string(annotationRow.Available_Sensor), ...
            'Mano utilizzata', string(annotationRow.Hand))};
        statusLabel.WordWrap = "on";
        drawnow;

    else
        statusLabel.Text = ['Nessuna annotazione trovata per ', selectedAcquisition, '.'];
        drawnow;
    end

    plotAcquisition(data, selectedAcquisition);
end

% Funzione per visualizzare un gruppo di acquisizioni
function plotGroupAcquisitions(selectedAcquisitions, allData, annotationsTable, statusLabel)
    if isempty(selectedAcquisitions)
        uialert(appFig, 'Seleziona almeno un''acquisizione valida.', 'Errore');
        return;
    end
    % Crea una finestra combinata per il gruppo
    figure('Name', 'Visualizzazione Gruppo', 'Position', [100, 100, 1400, 800]);
    % Cancello il contenuto di statusLabel
    statusLabel.Text = '';

    % Visualizza ogni acquisizione selezionata
    for i = 1:length(selectedAcquisitions)
        acquisitionName = selectedAcquisitions{i};
        data = allData.(acquisitionName);

        % Converto acquisitionName in numero
        acqNum = extractAfter(acquisitionName, "acquisizione_");
    
        % Trova annotazioni corrispondenti
        rows = matches(string(annotationsTable.Idx_Acquisition), acqNum);
        annotationRow = annotationsTable(rows, :);
            
        if ~isempty(annotationRow)
            text = {['Annotazioni per ', acquisitionName, ':']; ...
                sprintf('%s: %s - %s: %s - %s: %s - %s: %s - %s: %s - %s: %s - %s: %s - %s: %s', ...
                'Nome Utente', string(annotationRow.ID_Subject), ...
                'Indice', string(annotationRow.ID_Gesture), ...
                'Acquisizione', string(annotationRow.Idx_Acquisition), ...
                'Acquisizione per utente', string(annotationRow.Idx_Acquisition_Subject), ...
                'Dispositivo', string(annotationRow.Smartphone_model), ...
                'Gesto', string(annotationRow.Name_Gesture), ...
                'Sensori disponibili', string(annotationRow.Available_Sensor), ...
                'Mano utilizzata', string(annotationRow.Hand))};
            statusLabel.Text = [string(statusLabel.Text); ...
                string(text)];
            statusLabel.WordWrap = "on";
            drawnow;

        else
            statusLabel.Text = ['Nessuna annotazione trovata per ', acquisitionName, '.'];
            drawnow;
        end

        % Grafico Accelerometro
        subplot(length(selectedAcquisitions), 4, (i-1)*4+1);
        plot(data.accelTime, data.accelData.x, 'r', ...
             data.accelTime, data.accelData.y, 'g', ...
             data.accelTime, data.accelData.z, 'b', ...
             data.accelTime, data.accelData.tot, 'k');       % Per le nuove acquisizioni usare suffisso .RMS
        title(['Accelerometro - ', acquisitionName]);
        xlabel('Tempo (s)');
        ylabel('Accelerazione (m/s^2)');
        legend('X', 'Y', 'Z', 'RMS');

        % Grafico Giroscopio
        subplot(length(selectedAcquisitions), 4, (i-1)*4+2);
        plot(data.gyroTime, data.gyroData.x, 'r', ...
             data.gyroTime, data.gyroData.y, 'g', ...
             data.gyroTime, data.gyroData.z, 'b', ...
             data.gyroTime, data.gyroData.tot, 'k');        % Per le nuove acquisizioni usare suffisso .RMS
        title(['Giroscopio - ', acquisitionName]);
        xlabel('Tempo (s)');
        ylabel('Velocit\`a Angolare (rad/s)');
        legend('X', 'Y', 'Z', 'RMS');

        % Grafico Orientamento
        subplot(length(selectedAcquisitions), 4, (i-1)*4+3);
        plot(data.orientTime, data.orientData.x, 'r', ...
             data.orientTime, data.orientData.y, 'g', ...
             data.orientTime, data.orientData.z, 'b');
        title(['Orientamento - ', acquisitionName]);
        xlabel('Tempo (s)');
        ylabel('Angoli (gradi o radianti)');
        legend('Pitch', 'Roll', 'Yaw');

        % Grafico Magnetometro
        subplot(length(selectedAcquisitions), 4, (i-1)*4+4);
        plot(data.magfieldTime, data.magfieldData.x, 'r', ...
             data.magfieldTime, data.magfieldData.y, 'g', ...
             data.magfieldTime, data.magfieldData.z, 'b', ...
             data.magfieldTime, data.magfieldData.tot, 'k');        % Per le nuove acquisizioni usare suffisso .RMS
        title(['Magnetometro - ', acquisitionName]);
        xlabel('Tempo (s)');
        ylabel('Intensit\`a (\muT)');
        legend('X', 'Y', 'Z', 'RMS');
    end
end

% Funzione per visualizzare i dati di una singola acquisizione
function plotAcquisition(data, acquisitionName)
    % Crea una nuova finestra per i grafici
    figure('Name', ['Visualizzazione - ', acquisitionName], 'Position', [100, 100, 1200, 800]);

    % Grafico Accelerometro
    subplot(4, 1, 1);
    plot(data.accelTime, data.accelData.x, 'r', ...
         data.accelTime, data.accelData.y, 'g', ...
         data.accelTime, data.accelData.z, 'b', ...
         data.accelTime, data.accelData.tot, 'k');      % Per le nuove acquisizioni usare suffisso .RMS
    title(['Accelerometro - ', acquisitionName]);
    xlabel('Tempo (s)');
    ylabel('Accelerazione (m/s^2)');
    legend('X', 'Y', 'Z', 'RMS');

    % Grafico Giroscopio
    subplot(4, 1, 2);
    plot(data.gyroTime, data.gyroData.x, 'r', ...
         data.gyroTime, data.gyroData.y, 'g', ...
         data.gyroTime, data.gyroData.z, 'b', ...
         data.gyroTime, data.gyroData.tot, 'k');        % Per le nuove acquisizioni usare suffisso .RMS
    title(['Giroscopio - ', acquisitionName]);
    xlabel('Tempo (s)');
    ylabel('Velocit\`a Angolare (rad/s)');
    legend('X', 'Y', 'Z', 'RMS');

    % Grafico Orientamento
    subplot(4, 1, 3);
    plot(data.orientTime, data.orientData.x, 'r', ...
         data.orientTime, data.orientData.y, 'g', ...
         data.orientTime, data.orientData.z, 'b');         
    title(['Orientamento - ', acquisitionName]);
    xlabel('Tempo (s)');
    ylabel('Angoli (gradi o radianti)');
    legend('Pitch', 'Roll', 'Yaw');

    % Grafico Magnetometro
    subplot(4, 1, 4);
    plot(data.magfieldTime, data.magfieldData.x, 'r', ...
         data.magfieldTime, data.magfieldData.y, 'g', ...
         data.magfieldTime, data.magfieldData.z, 'b', ...
         data.magfieldTime, data.magfieldData.tot, 'k');        % Per le nuove acquisizioni usare suffisso .RMS
    title(['Magnetometro - ', acquisitionName]);
    xlabel('Tempo (s)');
    ylabel('Intensit\`a (\muT)');
    legend('X', 'Y', 'Z', 'RMS');
end
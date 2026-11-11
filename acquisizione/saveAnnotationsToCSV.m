function saveAnnotationsToCSV(userName, acquisitionIndex, usedHand, mobileName, sensorMessage, gestureIndex, gestureName)
    % saveAnnotationsToCSV - Salva le annotazioni in un file CSV
    
    % INPUT:
    %   userName: nome dell'utente (stringa)
    %   acquisitionIndex: indice dell'acquisizione (numero intero positivo)
    %   usedHand: mano utilizzata ('dx' o 'sx')
    %   mobileName: modello dello smartphone (stringa)
    %   sensorMessage: sensori abilitati (stringa)
    %   gestureIndex: indice del gesto (numero intero)
    %   gestureName: nome del gesto (stringa)
    
    % OUTPUT:
    %   Nessuno. Il file CSV viene salvato/aggiornato.

    %% Validazione degli input
    if nargin < 7
        error('Tutti gli input sono obbligatori.');
    end
    %%
    
    csvFilename = 'dati_acquisiti.csv';

    % Controllo e lettura del file CSV esistente
    if exist(csvFilename, "file") == 2
        try
            readcell(csvFilename);
        catch
            error('Errore nella lettura del file CSV.')
        end
    else
        % Inizializza con l'intestazione se il file non esiste
        caption = {"ID_Subject", "Idx_Acquisition", "Idx_Acquisition_Subject", "Hand", ...
                        "Smartphone_model", "Available_Sensor", "ID_Gesture", "Name_Gesture"};
        writecell(caption, csvFilename);
    end

    % Calcolo il numero di acquisizione per l'utente in corso
    % Diamo per assunto che le acquisizioni vengano effettuate in ordine
    n = floor(acquisitionIndex/5);
    if n>0
        acqForSubject = acquisitionIndex - n*5 + 1;
    else 
        acqForSubject = acquisitionIndex;
    end
    
    % Se le acquisizioni non vengono effettuate in ordine
    % T = readtable("dati_acquisiti.csv");
    % acqForSubject = 0;
    % [row, ~] = size(T)
    % for i = 1:row
    % if T.ID_Subject(i) == userName && T.ID_Gesture == gestureIndex
    %     acqForSUbject = acqForSubject + 1;
    % end

    % Aggiungi una nuova riga con i dati forniti
    newRow = {userName, acquisitionIndex, acqForSubject, usedHand, mobileName, sensorMessage, gestureIndex, gestureName};

    % Scrivi i dati aggiornati nel file CSV
    try
        writecell(newRow, csvFilename,'WriteMode','append')
    catch
        error('Errore nella scrittura del file CSV.')
    end
end

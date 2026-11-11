T = readtable("dati_acquisiti.csv");
[row, column] = size(T);
i = 1;
while i < row + 1
    for j = 1:5
        T.Idx_Acquisition_Subject(i) = j;
        i = i + 1;
    end
end
writetable(T, "dati_acq.csv")

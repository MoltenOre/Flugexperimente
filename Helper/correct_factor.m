dataFolder = './Daten/cut_out';

files = dir(fullfile(dataFolder, '*.csv'));

for i = 1:length(files)

    filename = fullfile(files(i).folder, files(i).name);

    fprintf('Processing: %s\n', filename);

    % Read CSV
    T = readtable(filename, 'TextType', 'string');

    % UID is column 3
    uid = T{:,3};

    % Value is column 5c
    value = T{:,5};

    % UIDs to modify
    rowsToModify = uid == "29oL" | uid == "y";

    % Divide values by 10
    value(rowsToModify) = value(rowsToModify) / 10;

    % Put modified values back
    T{:,5} = value;

    % Save to same file
    writetable(T, filename);

end
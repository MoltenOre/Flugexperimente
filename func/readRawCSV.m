function data = readRawCSV(filename)
    fid = fopen(filename, 'r');
    hdr = fgetl(fid);
    fclose(fid);
    if count(hdr, ';') > count(hdr, ',')
        d = ';';
    else
        d = ',';
    end

    opts = delimitedTextImportOptions('NumVariables', 6, ...
        'Delimiter', d, 'DataLines', [2 Inf], 'Encoding', 'UTF-8');
    opts.VariableNames = ["TIME","NAME","UID","VAR","RAW","UNIT"];
    opts.VariableTypes = ["string","string","string","string","string","string"];
    opts.ExtraColumnsRule = 'ignore';
    opts.EmptyLineRule    = 'skip';

    data = readtable(filename, opts);
    data.RAW  = str2double(data.RAW);   % 'N', 'E', 'NaN' become NaN
    data.TIME = datetime(data.TIME, 'InputFormat', 'MM/dd/yyyy HH:mm:ss.SSS');
end
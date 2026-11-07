function s = flightStatsLatex(T, options)
%FLIGHTSTATSLATEX LaTeX-Tabelle (booktabs + siunitx) aus der Tabelle von flightStats.
%   flightStatsLatex(T)
%   flightStatsLatex(T, 'Caption', 'Wind-Up Turn rechts', 'Label', 'tab:windup-r')
%   s = flightStatsLatex(T, 'Bank', false, 'Clipboard', true)
%
%   Optionen:
%     Caption   - Tabellenunterschrift
%     Label     - \label der Tabelle
%     Bank      - true: Spalten Lastvielfaches und Querneigung (Standard true)
%     Clipboard - true: Code in die Zwischenablage kopieren (Standard false)
    arguments
        T table
        options.Caption   (1,1) string  = "Steuerknüppelkräfte"
        options.Label     (1,1) string  = "tab:flightstats"
        options.Bank      (1,1) logical = true
        options.Clipboard (1,1) logical = false
    end

    f1 = @(v) fmt(v, '%.1f');
    f2 = @(v) fmt(v, '%.2f');

    % Spaltenformat
    colSpec = "@{}l S[table-format=3.1] S[table-format=3.1] S[table-format=3.1]" + ...
              " S[table-format=-2.1] S[table-format=2.1] S[table-format=2.1]";
    head1   = " & \multicolumn{3}{c}{Pitch (X) [N]} & \multicolumn{3}{c}{Roll (Y) [N]}";
    cmid    = "\cmidrule(lr){2-4}\cmidrule(lr){5-7}";
    head2   = "Manöver & {Mittel} & {P95} & {Max} & {Mittel} & {Mittel $|F|$} & {Max $|F|$}";
    if options.Bank
        colSpec = colSpec + " S[table-format=1.2] S[table-format=2.1] S[table-format=2.1]";
        head1   = head1 + " & \multicolumn{3}{c}{Querneigung}";
        cmid    = cmid + "\cmidrule(lr){8-10}";
        head2   = head2 + " & {$n$} & {aus $|a|$ [\si{\degree}]} & {IMU [\si{\degree}]}";
    end
    colSpec = colSpec + "@{}";

    L = strings(0,1);
    L(end+1) = "\begin{table}[htbp]";
    L(end+1) = "    \centering";
    L(end+1) = "    \caption{" + options.Caption + "}";
    L(end+1) = "    \label{" + options.Label + "}";
    L(end+1) = "    \begin{tabular}{" + colSpec + "}";
    L(end+1) = "        \toprule";
    L(end+1) = "        " + head1 + " \\";
    L(end+1) = "        " + cmid;
    L(end+1) = "        " + head2 + " \\";
    L(end+1) = "        \midrule";

    for k = 1:height(T)
        row = escapeTex(T.Name(k)) + " & " + f1(T.PitchMittel(k)) + " & " + f1(T.PitchP95(k)) ...
            + " & " + f1(T.PitchMax(k)) + " & " + f1(T.RollMittel(k)) ...
            + " & " + f1(T.RollMittelAbs(k)) + " & " + f1(T.RollMaxAbs(k));
        if options.Bank
            row = row + " & " + f2(T.Lastvielfaches(k)) + " & " + f1(T.BankAccel(k)) ...
                      + " & " + f1(T.BankIMU(k));
        end
        L(end+1) = "        " + row + " \\";
    end

    L(end+1) = "        \bottomrule";
    L(end+1) = "    \end{tabular}";
    L(end+1) = "\end{table}";

    s = strjoin(L, newline);
    fprintf('%s\n', s);
    if options.Clipboard, clipboard('copy', char(s)); end
end

function out = fmt(v, spec)
    if isnan(v), out = "{--}";
    else,        out = string(sprintf(spec, v)); end
end

function out = escapeTex(str)
    out = replace(string(str), ["_" "%" "&" "#"], ["\_" "\%" "\&" "\#"]);
    out = replace(out, "°", "\ang{}");        % ersetzt nur das Zeichen
    out = replace(out, "\ang{}", "$^\circ$");
end
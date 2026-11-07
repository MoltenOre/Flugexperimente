function saveFigure(fig, outputFolder, fileName, widthCm, heightCm)
%SAVEFIGURE Speichert eine Figure als SVG (Vektorgrafik) in outputFolder.
%   saveFigure(fig, "./Plots/Stall", "Stall_FFT", 15, 11)
%
%   fig          - Figure-Handle
%   outputFolder - Zielordner (wird angelegt, falls er fehlt)
%   fileName     - Dateiname ohne Endung (Sonderzeichen werden durch _ ersetzt)
%   widthCm      - Breite der Figure in cm
%   heightCm     - Hoehe der Figure in cm

    outputFolder = char(outputFolder);
    if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end
    fileName = regexprep(char(fileName), '[^\w\-]', '_');

    drawnow;
    set(fig, 'PaperUnits', 'centimeters', ...
             'PaperSize',  [widthCm heightCm], ...
             'PaperPosition', [0 0 widthCm heightCm]);
    print(fig, fullfile(outputFolder, [fileName '.svg']), '-dsvg', '-vector');
end

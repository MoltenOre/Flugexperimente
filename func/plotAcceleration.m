function plotAcceleration(t, ax, ay, az, a, Name, options)
%PLOTACCELERATION Acceleration magnitude and X/Y/Z components (IMU).
%   Name-Value options:
%     SaveFig      - save as SVG                 (default false)
%     OutputFolder - target folder               (default "./Plots/")
%     AspectRatio  - width/height                (default 15/11)
%     WidthCm      - figure width in cm          (default 15)
%     Title        - char or cell array (2 lines)(default '')
%     InG          - show in g instead of m/s^2  (default false)
%     Smooth       - moving-average window [samples] (default 1 = off)
    arguments
        t, ax, ay, az, a, Name
        options.SaveFig      (1,1) logical = false
        options.OutputFolder (1,1) string  = "./Plots/"
        options.AspectRatio  (1,1) double  = 15/11
        options.WidthCm      (1,1) double  = 15
        options.Title                      = ''
        options.InG          (1,1) logical = false
        options.Smooth       (1,1) double  = 1
    end

    Name = erase(Name, ".csv");

    % ---- Unit and optional smoothing ----
    g = 9.81;
    if options.InG
        sc = 1/g;  unit = 'g';      ref = 1;
    else
        sc = 1;    unit = 'm/s^2';  ref = g;
    end
    sig = {a, ax, ay, az} ;
    for k = 1:4
        s = sig{k}(:) * sc;
        if options.Smooth > 1
            s = smoothdata(s, 'movmean', options.Smooth);
        end
        sig{k} = s;
    end
    [aP, axP, ayP, azP] = sig{:};

    % ---- Figure ----
    heightCm = options.WidthCm / options.AspectRatio;
    fig = figure('Name', Name + "_Accel", 'NumberTitle', 'off', 'Color', 'w', ...
                 'Units', 'centimeters', 'Position', [2 2 options.WidthCm heightCm]);
    tl = tiledlayout(fig, 4, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    if ~isempty(options.Title)
        title(tl, options.Title, 'FontWeight', 'bold', 'FontSize', 10);
    end

    colors = lines(3);
    axs = gobjects(4,1);

    % Magnitude
    axs(1) = nexttile(tl);
    drawAx(axs(1), t, aP, [1 0.5 0], 'Betrag', unit);
    yline(axs(1), ref, '--k', 'LineWidth', 0.8, 'HandleVisibility', 'off');
    title(axs(1), 'Beschleunigung (Betrag)');

    % Components
    comp   = {axP, ayP, azP};
    labels = {'X', 'Y', 'Z'};
    for k = 1:3
        axs(k+1) = nexttile(tl);
        drawAx(axs(k+1), t, comp{k}, colors(k,:), labels{k}, unit);
    end

    xlabel(axs(4), 'Time [s]');
    set(axs(1:3), 'XTickLabel', []);          % x labels only on the bottom plot
    linkaxes(axs, 'x');
    xlim(axs(4), [t(1) t(end)]);

    % ---- Save as SVG ----
    if options.SaveFig
        if ~exist(options.OutputFolder, 'dir'), mkdir(options.OutputFolder); end
        fileName = regexprep(Name, '[^\w\-]', '_') + "_Accel";
        drawnow;
        set(fig, 'PaperUnits', 'centimeters', ...
                 'PaperSize',  [options.WidthCm heightCm], ...
                 'PaperPosition', [0 0 options.WidthCm heightCm]);
        print(fig, fullfile(options.OutputFolder, fileName + ".svg"), '-dsvg', '-painters');
    end
end


function drawAx(ax, t, y, color, label, unit)
    plot(ax, t, y, 'LineWidth', 1.1, 'Color', color);
    grid(ax, 'on');  box(ax, 'on');
    ylabel(ax, sprintf('%s [%s]', label, unit));
    ax.FontSize = 9;
end
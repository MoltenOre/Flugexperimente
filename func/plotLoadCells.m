function plotLoadCells(t, xRaw, yRaw, xFiltered, yFiltered, ...
                       totalRaw, totalFiltered, plotRawData, Name, ...
                       saveFig, outputFolder, aspectRatio, widthCm, plotTitle)
%PLOTLOADCELLS Total force, pitch (X) and roll (Y) force of the stick.

    if nargin < 10 || isempty(saveFig),      saveFig = false;           end
    if nargin < 11 || isempty(outputFolder), outputFolder = './Plots/'; end
    if nargin < 12 || isempty(aspectRatio), aspectRatio = 15/11; end   % Breite/Höhe
    if nargin < 13 || isempty(widthCm),     widthCm     = 15;    end   % Breite in cm
     if nargin < 14, plotTitle = ''; end

    Name   = erase(Name, ".csv");
    orange = [1 0.5 0];

    % Figure size ~ text width of the report (reduces font scaling)
    heightCm = widthCm / aspectRatio;
    fig = figure('Name', Name, 'NumberTitle', 'off', 'Color', 'w', ...
                 'Units', 'centimeters', 'Position', [2 2 widthCm heightCm]);
    tl = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    if ~isempty(plotTitle)
        title(tl, plotTitle, 'FontWeight', 'bold', 'FontSize', 10);
    end

    % ---- Total force ----
    ax1 = nexttile(tl, 1, [1 2]);
    drawSignal(ax1, t, totalRaw, totalFiltered, plotRawData, orange, ...
               'Total Force on Stick');
    top = max(totalFiltered, [], 'omitnan');
    if plotRawData, top = max(top, max(totalRaw, [], 'omitnan')); end
    ylim(ax1, [0, 1.1*top]);
    xlabel(ax1, 'Time [s]');
    ylabel(ax1, 'Total Force [N]');
    title(ax1, 'Gesamte Kraft am Steuerknüppel');
    if plotRawData                      % legend only if there is more than one curve
        legend(ax1, 'Location', 'northwest', 'Box', 'off');
    end

    % ---- Pitch (X) ----
    ax2 = nexttile(tl, 3);
    drawSignal(ax2, t, xRaw, xFiltered, plotRawData, orange, 'Force in X');
    lim = plotMaxLimits(ax2, xFiltered, [267 334 44.5]);
    setSymmetricYLim(ax2, xFiltered, lim);
    xlabel(ax2, 'Time [s]');
    ylabel(ax2, 'Force in X [N]');
    title(ax2, 'Kraft um die Pitch-Achse');

    % ---- Roll (Y) ----
    ax3 = nexttile(tl, 4);
    drawSignal(ax3, t, yRaw, yFiltered, plotRawData, orange, 'Force in Y');
    lim = plotMaxLimits(ax3, yFiltered, [133 222 22]);
    setSymmetricYLim(ax3, yFiltered, lim);
    xlabel(ax3, 'Time [s]');
    ylabel(ax3, 'Force in Y [N]');
    title(ax3, 'Kraft um die Roll-Achse');

    

    % ---- Save as SVG ----
    if saveFig
        if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end
        fileName = regexprep(Name, '[^\w\-]', '_');
        drawnow;
        set(fig, 'PaperUnits', 'centimeters', ...
                 'PaperSize',  [widthCm heightCm], ...
                 'PaperPosition', [0 0 widthCm heightCm]);
        print(fig, fullfile(outputFolder, [fileName '.svg']), '-dsvg', '-vector');
    end
end


%% ---------- Helpers ----------
function drawSignal(ax, t, raw, filtered, showRaw, color, label)
    hold(ax, 'on');
    if showRaw
        plot(ax, t, raw, '--', 'LineWidth', 0.8, 'DisplayName', 'Raw');
    end
    plot(ax, t, filtered, 'LineWidth', 1.4, 'Color', color, 'DisplayName', label);
    grid(ax, 'on');
    box(ax, 'on');
    xlim(ax, [t(1) t(end)]);
    ax.FontSize = 9;
end

function setSymmetricYLim(ax, data, limitDrawn)
    % Symmetric y-axis with 15 % margin beyond data and the drawn limit lines
    m = 1.15 * max([max(abs(data), [], 'omitnan'), limitDrawn]);
    ylim(ax, [-m m]);
end

function drawn = plotMaxLimits(ax, data, limits)
    % Returns the largest limit that was drawn
    colors = {'r', 'b', 'k'};
    minVal = min(data);
    maxVal = max(data);
    [~, minIdx] = min(limits);
    drawn = 0;

    for k = 1:numel(limits)
        % Smallest limit is always drawn, others only when reached
        if k == minIdx || maxVal >= limits(k) || minVal <= -limits(k)
            yline(ax,  limits(k), ['--' colors{k}], sprintf('+%.1f N', limits(k)), ...
                  'LineWidth', 1.2, 'HandleVisibility', 'off', ...
                  'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
            yline(ax, -limits(k), ['--' colors{k}], sprintf('-%.1f N', limits(k)), ...
                  'LineWidth', 1.2, 'HandleVisibility', 'off', ...
                  'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
            drawn = max(drawn, limits(k));
        end
    end
end
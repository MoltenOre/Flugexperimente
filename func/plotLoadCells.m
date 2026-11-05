function plotLoadCells(t, xRaw, yRaw, xFiltered, yFiltered, ...
                       totalRaw, totalFiltered, plotRawData, Name)

    
    Name = erase(Name, ".csv");

    figure('Name',Name,'NumberTitle','off');

    % Total force
    subplot(2,2,[1 2]);

    if plotRawData
        plot(t,totalRaw,'--','LineWidth',0.8);
    end
        hold on;

    plot(t,totalFiltered,'LineWidth',1.4, 'Color', [1 0.5 0]);
   

    grid on;
    xlabel('Time [s]');
    ylabel('Total Force [N]');
    title('Gesamte Kraft am Steurknüppel');

    if plotRawData
        legend('Raw','Total Force on Stick','Location','best');
    else
        legend('Total Force on Stick','Location','best');
    end


    % X
    subplot(2,2,3);

    if plotRawData
        plot(t,xRaw,'--','LineWidth',0.8);
    end

    hold on;

%%==============================Pitch==========================================

    plot(t,xFiltered,'LineWidth',1.4, 'Color', [1 0.5 0]);
 
    plotMaxLimits(xFiltered, [267 334 44.5]);

    grid on;
    xlabel('Time [s]');
    ylabel('Force in X [N]');
    title('Kraft um die Pitch Aachse');
    %legend('Total Force on Stick','Location','best');
    yl = ylim;
    yticks(floor(yl(1)/25)*25 : 25 : ceil(yl(2)/25)*25);

%%==============================Roll==========================================
    subplot(2,2,4);

    if plotRawData
        plot(t,yRaw,'--','LineWidth',0.8);

    end
        hold on;
    plot(t,yFiltered,'LineWidth',1.4, 'Color', [1 0.5 0]);

    plotMaxLimits(yFiltered, [133 222 22]);

    grid on;
    xlabel('Time [s]');
    ylabel('Force in Y [N]');
    title('Kraft um die Roll Aachse');
    %legend('Total Force on Stick','Location','best');
    %sgtitle(Name);
    
    outputFolder = './Plots/';
    %exportgraphics(gcf, fullfile(outputFolder, [Name '.png']), ...
    %'Resolution', 300);

    function plotMaxLimits(data, limits)

        colors = {'r', 'b', 'k'};
    
        minVal = min(data);
        maxVal = max(data);
    
        [~, minIdx] = min(limits);
    
        for i = 1:length(limits)
    
            % Kleinstes Limit immer plotten
            % Andere Limits nur bei Erreichen plotten
            if i == minIdx || maxVal >= limits(i) || minVal <= -limits(i)
    
                yline(limits(i), ['--' colors{i}], ...
                    sprintf('+%.1f N', limits(i)), ...
                    'LineWidth', 1.2);
    
                yline(-limits(i), ['--' colors{i}], ...
                    sprintf('-%.1f N', limits(i)), ...
                    'LineWidth', 1.2);
            end
        end
    end

end


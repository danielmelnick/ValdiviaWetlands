function scatter_labels_nonoverlap(x, y, labels, varargin)
% scatter_labels_nonoverlap - Plot points with non-overlapping text labels
%
% Usage:
%   scatter_labels_nonoverlap(x, y, labels)
%   scatter_labels_nonoverlap(x, y, labels, Name, Value, ...)
%
% Inputs:
%   x, y - Coordinates of the points to plot
%   labels - Cell array of text labels for each point
%
% Optional Name-Value Pairs:
%   'MarkerSize' - Size of markers (default: 8)
%   'MarkerColor' - Color of markers (default: 'b')
%   'TextColor' - Color of text labels (default: 'k')
%   'FontSize' - Font size for labels (default: 10)
%   'MaxIterations' - Maximum iterations for overlap removal (default: 50)
%   'Padding' - Minimum distance between labels (default: 5)
%   'ShowLines' - Show connection lines between points and labels (default: true)
%   'LineStyle' - Style of connection lines (default: ':') 
%   'LineColor' - Color of connection lines (default: [0.7 0.7 0.7])
%   'PreserveAxisLimits' - Keep axis limits fixed (default: true)

% Parse input parameters
p = inputParser;
addParameter(p, 'MarkerSize', 8);
addParameter(p, 'MarkerColor', 'b');
addParameter(p, 'TextColor', 'k');
addParameter(p, 'FontSize', 10);
addParameter(p, 'MaxIterations', 50);
addParameter(p, 'Padding', 5);
addParameter(p, 'ShowLines', true);
addParameter(p, 'LineStyle', ':');
addParameter(p, 'LineColor', [0.7 0.7 0.7]);
addParameter(p, 'PreserveAxisLimits', true);
parse(p, varargin{:});

% Extract parameters
markerSize = p.Results.MarkerSize;
markerColor = p.Results.MarkerColor;
textColor = p.Results.TextColor;
fontSize = p.Results.FontSize;
maxIterations = p.Results.MaxIterations;
padding = p.Results.Padding;
showLines = p.Results.ShowLines;
lineStyle = p.Results.LineStyle;
lineColor = p.Results.LineColor;
preserveAxisLimits = p.Results.PreserveAxisLimits;

% Validate inputs
if length(x) ~= length(y) || length(x) ~= length(labels)
    error('The lengths of x, y, and labels must be the same');
end

numPoints = length(x);

% Create the scatter plot
scatter(x, y, markerSize, markerColor, 'filled');
hold on;

% Store original axis limits if preserving is enabled
if preserveAxisLimits
    originalXLim = xlim;
    originalYLim = ylim;
    % Set the 'XLimMode' and 'YLimMode' to manual to prevent auto-adjustment
    set(gca, 'XLimMode', 'manual', 'YLimMode', 'manual');
end

% Initial text placement (centered on points)
hText = zeros(numPoints, 1);
textPositions = zeros(numPoints, 2);

for i = 1:numPoints
    hText(i) = text(x(i), y(i), labels{i}, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'Color', textColor, ...
        'FontSize', fontSize);
    
    % Get initial text position
    extent = get(hText(i), 'Extent');
    textPositions(i, :) = [x(i), y(i) + extent(4)/2];
end

% Adjust labels to avoid overlaps
adjustLabels(hText, textPositions, x, y, maxIterations, padding);

% Draw connection lines between points and labels if requested
if showLines
    for i = 1:numPoints
        pos = get(hText(i), 'Position');
        plot([x(i), pos(1)], [y(i), pos(2)], lineStyle, 'Color', lineColor);
    end
end

% Restore original axis limits if preserving is enabled
if preserveAxisLimits
    xlim(originalXLim);
    ylim(originalYLim);
end

hold off;
end

function adjustLabels(hText, textPositions, x, y, maxIterations, padding)
% Adjust label positions to avoid overlaps

numLabels = length(hText);
textExtents = zeros(numLabels, 4);

% Store current axis limits to restore later (prevents axis from expanding)
axesHandle = get(hText(1), 'Parent');
currentXLim = get(axesHandle, 'XLim');
currentYLim = get(axesHandle, 'YLim');

% Get the initial text extents
for i = 1:numLabels
    textExtents(i, :) = get(hText(i), 'Extent');
end

% Width and height of each text box
textWidth = zeros(numLabels, 1);
textHeight = zeros(numLabels, 1);
for i = 1:numLabels
    textWidth(i) = textExtents(i, 3);
    textHeight(i) = textExtents(i, 4);
end

% Current position of each label (centered horizontally)
currPos = textPositions;

% Iteratively adjust positions to avoid overlaps
for iter = 1:maxIterations
    moved = false;
    
    % Check each pair of labels for overlaps
    for i = 1:numLabels
        for j = (i+1):numLabels
            % Calculate the extent of each text box with padding
            box1 = [currPos(i,1) - textWidth(i)/2 - padding, ...
                   currPos(i,2) - textHeight(i)/2 - padding, ...
                   textWidth(i) + 2*padding, ...
                   textHeight(i) + 2*padding];
            
            box2 = [currPos(j,1) - textWidth(j)/2 - padding, ...
                   currPos(j,2) - textHeight(j)/2 - padding, ...
                   textWidth(j) + 2*padding, ...
                   textHeight(j) + 2*padding];
            
            % Check if boxes overlap
            if boxesOverlap(box1, box2)
                % Calculate vector between the points
                vec = [currPos(i,1) - currPos(j,1), currPos(i,2) - currPos(j,2)];
                dist = norm(vec);
                
                if dist < 1e-10  % Avoid division by zero
                    % If boxes are almost at the same position, move in random direction
                    angle = 2 * pi * rand();
                    vec = [cos(angle), sin(angle)];
                    dist = 1;
                end
                
                % Normalize vector
                vec = vec / dist;
                
                % Calculate minimum distance needed to avoid overlap
                minDist = (textWidth(i) + textWidth(j))/2 + 2*padding;
                
                % Move both labels away from each other
                moveAmount = (minDist - dist) / 2;
                currPos(i,:) = currPos(i,:) + moveAmount * vec;
                currPos(j,:) = currPos(j,:) - moveAmount * vec;
                
                moved = true;
            end
        end
    end
    
    % Apply the new positions to the text objects
    for i = 1:numLabels
        set(hText(i), 'Position', [currPos(i,1), currPos(i,2), 0]);
    end
    
    % Keep the axes limits fixed (prevent automatic expansion)
    set(axesHandle, 'XLim', currentXLim, 'YLim', currentYLim);
    
    % Stop if no movement occurred
    if ~moved
        break;
    end
end

% Make sure labels don't get too far from their points by applying
% a spring force pulling back toward original points
for i = 1:numLabels
    originalPos = [x(i), y(i)];
    currLabelPos = currPos(i,:);
    
    % Vector from original point to current label
    vec = currLabelPos - originalPos;
    dist = norm(vec);
    
    % Calculate text height for minimum distance
    minDist = textHeight(i) / 2 + padding;
    
    if dist > 3 * minDist
        % Apply spring force to pull back
        newPos = originalPos + vec * (3 * minDist / dist);
        set(hText(i), 'Position', [newPos(1), newPos(2), 0]);
    end
end

% Final enforcement of axis limits
set(axesHandle, 'XLim', currentXLim, 'YLim', currentYLim);
end

function overlap = boxesOverlap(box1, box2)
% Check if two boxes overlap
% box format: [x, y, width, height] where (x,y) is the bottom-left corner

overlap = ~(box1(1) + box1(3) < box2(1) || ...  % box1 is to the left of box2
           box2(1) + box2(3) < box1(1) || ...  % box2 is to the left of box1
           box1(2) + box1(4) < box2(2) || ...  % box1 is below box2
           box2(2) + box2(4) < box1(2));       % box2 is below box1
end
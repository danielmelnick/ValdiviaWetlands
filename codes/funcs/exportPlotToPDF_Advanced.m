function exportPlotToPDF_Advanced(figureHandle, filename, rect, options)
% EXPORTPLOTTOPDF_ADVANCED Export MATLAB plot to vectorized PDF with advanced options
%
% Inputs:
%   figureHandle - Handle to the figure to export (can be empty for current figure)
%   filename     - String containing the output PDF filename
%   rect         - [left bottom width height] rectangle in centimeters
%   options      - Optional structure with fields:
%                  .Resolution - Output resolution (default: 600)
%                  .BackgroundColor - Background color (default: 'white')
%                  .ContentType - 'vector' or 'image' (default: 'vector')
%                  .Append - true/false to append to existing file (default: false)
%
% Example:
%   plot(rand(10,1));
%   opts.Resolution = 1200;
%   opts.BackgroundColor = 'none';
%   exportPlotToPDF_Advanced(gcf, 'myplot.pdf', [0 0 10 8], opts);
%
% Notes:
%   This function uses exportgraphics (MATLAB R2020a+) when available
%   for better control over the output. Falls back to print for earlier versions.

% Use current figure if no handle provided
if nargin < 1 || isempty(figureHandle)
    figureHandle = gcf;
end

% Default filename if not provided
if nargin < 2 || isempty(filename)
    filename = 'figure.pdf';
end

% Default size if rect not provided
if nargin < 3 || isempty(rect)
    rect = [0 0 10 8]; % Default: 10x8 cm
end

% Default options
if nargin < 4
    options = struct();
end

% Set default options if not provided
if ~isfield(options, 'Resolution')
    options.Resolution = 600;
end
if ~isfield(options, 'BackgroundColor')
    options.BackgroundColor = 'white';
end
if ~isfield(options, 'ContentType')
    options.ContentType = 'vector';
end
if ~isfield(options, 'Append')
    options.Append = false;
end

% Make sure figure is made current
figure(figureHandle);

% Store original figure position and units
originalUnits = get(figureHandle, 'Units');
originalPosition = get(figureHandle, 'Position');
originalPaperUnits = get(figureHandle, 'PaperUnits');
originalPaperPosition = get(figureHandle, 'PaperPosition');
originalPaperPositionMode = get(figureHandle, 'PaperPositionMode');

% Try to adjust the figure size and export
try
    % Set figure units to centimeters for consistent sizing
    set(figureHandle, 'Units', 'centimeters');
    
    % Set figure size to match the desired output size
    % This helps maintain consistent appearance between screen and PDF
    set(figureHandle, 'Position', [rect(1:2), rect(3:4)]);
    
    % Set paper properties for PDF export
    set(figureHandle, 'PaperUnits', 'centimeters');
    set(figureHandle, 'PaperSize', rect(3:4));
    set(figureHandle, 'PaperPosition', [0 0 rect(3:4)]);
    set(figureHandle, 'PaperPositionMode', 'manual');
    
    % Make sure figure has rendered fully
    drawnow;
    pause(0.1);
    
    % Check if exportgraphics is available (MATLAB R2020a+)
    if exist('exportgraphics', 'file') == 2
        % Use exportgraphics for better control
        exportgraphics(figureHandle, filename, ...
            'Resolution', options.Resolution, ...
            'BackgroundColor', options.BackgroundColor, ...
            'ContentType', options.ContentType, ...
            'Append', options.Append);
        
        fprintf('Successfully exported figure using exportgraphics to %s (%.1fx%.1f cm)\n', ...
            filename, rect(3), rect(4));
    else
        % Fall back to print for older MATLAB versions
        if strcmp(options.BackgroundColor, 'none')
            % For transparent background
            set(figureHandle, 'Color', 'none');
        end
        
        % Use painters renderer for vector graphics
        if strcmp(options.ContentType, 'vector')
            print(figureHandle, '-dpdf', '-painters', sprintf('-r%d', options.Resolution), filename);
        else
            print(figureHandle, '-dpdf', '-opengl', sprintf('-r%d', options.Resolution), filename);
        end
        
        fprintf('Successfully exported figure using print to %s (%.1fx%.1f cm)\n', ...
            filename, rect(3), rect(4));
    end
    
catch ME
    % Restore original settings and report error
    set(figureHandle, 'Units', originalUnits);
    set(figureHandle, 'Position', originalPosition);
    set(figureHandle, 'PaperUnits', originalPaperUnits);
    set(figureHandle, 'PaperPosition', originalPaperPosition);
    set(figureHandle, 'PaperPositionMode', originalPaperPositionMode);
    
    % Re-throw the error
    error('Error exporting figure: %s', ME.message);
end

% Restore original figure settings
set(figureHandle, 'Units', originalUnits);
set(figureHandle, 'Position', originalPosition);
set(figureHandle, 'PaperUnits', originalPaperUnits);
set(figureHandle, 'PaperPosition', originalPaperPosition);
set(figureHandle, 'PaperPositionMode', originalPaperPositionMode);

end
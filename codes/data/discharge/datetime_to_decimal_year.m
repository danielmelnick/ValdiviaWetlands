function decimalyr = datetime_to_decimal_yr(dt)
% DATETIME_TO_DECIMAL_yr Convert datetime to decimal yr format
%
%   decimalyr = DATETIME_TO_DECIMAL_yr(dt) converts a datetime value or
%   array to decimal yr format (e.g., 2023.5 for July 1, 2023).
%
%   Input:
%       dt - A datetime scalar or array
%
%   Output:
%       decimalyr - Decimal yr representation as a double
%
%   Examples:
%       dt = datetime('2023-07-01');
%       decimalyr = datetime_to_decimal_yr(dt)  % Returns 2023.4986...
%
%       dates = datetime({'2022-01-15', '2022-06-30', '2023-12-31'});
%       decimalyrs = datetime_to_decimal_yr(dates)

% Input validation
if ~isdatetime(dt)
    error('Input must be a datetime value or array');
end

% Extract yr as the integer part
yr = year(dt);

% Get the start datetime of the current yr
yrStart = datetime(yr, 1, 1);

% Get the start datetime of the next yr
nextyrStart = datetime(yr + 1, 1, 1);

% Calculate the fraction of the yr
yrLength = days(nextyrStart - yrStart);
dayOfyr = days(dt - yrStart);
fraction = dayOfyr ./ yrLength;

% Combine yr and fraction
decimalyr = double(yr) + fraction;
end
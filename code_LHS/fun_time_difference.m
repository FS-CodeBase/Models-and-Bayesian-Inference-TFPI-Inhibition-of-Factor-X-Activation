function minutesDiff = fun_time_difference(datetime1, datetime2)
    % This function calculates the difference in minutes between two times
    % provided as 'datetime' objects.
    %
    % Arguments:
    %   datetime1 - First datetime object
    %   datetime2 - Second datetime object
    %
    % Returns:
    %   minutesDiff - The difference between the two times in minutes

    % Calculate the duration between the two datetime objects
    durationDiff = abs(datetime1 - datetime2);

    % Convert the duration to minutes
    minutesDiff = minutes(durationDiff);
end

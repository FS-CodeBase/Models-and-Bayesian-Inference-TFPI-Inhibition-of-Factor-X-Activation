function labels = fun_custom_xtickformat(x)
    n = floor(log10(max(x)));
    m = floor(log10(median(x)));
    if m~= 0 && ~isinf(m) && m < n
        n = m;
    end
    if isinf(n)
        n = 0;
    end
    labels = cell(size(x)); % Initialize a cell array to store the labels
    for i = 1:length(x)
        if n < -1
            labels{i} = sprintf('%0.1fE$%d$', x(i) * 10^(-n),n); 
        end
        if n == -1
            labels{i} = sprintf('%0.2f', x(i));
        end
        if n >= 0 && n <= 1
            labels{i} = sprintf('%0.1f', x(i));
        end
        if n == 2
            labels{i} = sprintf('%0.0f', x(i));
        end
        if n > 2
            labels{i} = sprintf('%0.1fE$%d$', x(i) * 10^(-n),n); 
        end
    end
    if numel(labels) == 1
        labels = labels{1};
    end
end

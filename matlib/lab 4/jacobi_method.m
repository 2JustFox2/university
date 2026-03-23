% Метод Якоби
function [x, iter] = jacobi_method(A, b, x0, epsilon, max_iter)
    n = length(b);
    x = x0;
    x_prev = x0;
    
    for iter = 1:max_iter
        for i = 1:n
            sum = 0;
            for j = 1:n
                if j ~= i
                    sum = sum + A(i, j) * x_prev(j);
                end
            end
            x(i) = (b(i) - sum) / A(i, i);
        end
        
        % Проверка сходимости
        if norm(x - x_prev, inf) < epsilon
            return;
        end
        x_prev = x;
    end
    
    % Если не сошлись
    x = [];
    iter = max_iter;
end


% Метод Зейделя
function [x, iter] = seidel_method(A, b, x0, epsilon, max_iter)
    n = length(b);
    x = x0;
    
    for iter = 1:max_iter
        x_prev = x;
        
        for i = 1:n
            sum1 = 0;
            sum2 = 0;
            
            % Используем уже обновленные значения (j < i)
            for j = 1:i-1
                sum1 = sum1 + A(i, j) * x(j);
            end
            
            % Используем значения с предыдущей итерации (j > i)
            for j = i+1:n
                sum2 = sum2 + A(i, j) * x_prev(j);
            end
            
            x(i) = (b(i) - sum1 - sum2) / A(i, i);
        end
        
        % Проверка сходимости
        if norm(x - x_prev, inf) < epsilon
            return;
        end
    end
    
    % Если не сошлись
    x = [];
    iter = max_iter;
end


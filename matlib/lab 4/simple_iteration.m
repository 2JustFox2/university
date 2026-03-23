% Метод простой итерации (x_{k+1} = x_k - tau*(A*x_k - b))
function [x, iter] = simple_iteration(A, b, x0, epsilon, max_iter, tau)
    x = x0;
    
    for iter = 1:max_iter
        x_prev = x;
        
        % Итерационная формула
        x = x_prev - tau * (A * x_prev - b);
        
        % Проверка сходимости
        if norm(x - x_prev, inf) < epsilon
            return;
        end
    end
    
    % Если не сошлись
    x = [];
    iter = max_iter;
end
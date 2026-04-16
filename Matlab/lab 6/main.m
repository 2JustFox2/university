clear; clc; close all;

F = @(vars) [vars(2)^2 - cos(vars(1));           % f1 = y^2 - cos(x)
             vars(2)^2 - vars(2) + 2*vars(1)^3 - 2];  % f2 = y^2 - y + 2x^3 - 2

f1 = @(x,y) y^2 - cos(x);
f2 = @(x,y) y^2 - y + 2*x^3 - 2;

%% 2. Построение
figure('Position', [100 100 600 500]);
x_range = 0:0.05:2;
y_range = 0:0.05:2;
[X, Y] = meshgrid(x_range, y_range);
Z1 = arrayfun(@(x,y) f1(x,y), X, Y);
Z2 = arrayfun(@(x,y) f2(x,y), X, Y);

contour(X, Y, Z1, [0 0], 'r-', 'LineWidth', 2); hold on;
contour(X, Y, Z2, [0 0], 'b-', 'LineWidth', 2);
grid on; axis equal;
xlabel('x', 'FontSize', 12);
ylabel('y', 'FontSize', 12);
title('Линии уровня уравнений', 'FontSize', 14);
legend('y^2 = cos(x)', 'y^2 - y + 2x^3 = 2', 'Location', 'best');
xlim([0 2]);
ylim([0 1.5]);

%% 3. Локализация корней
x0_initial = [1; 0.8];  % Начальное приближение
fprintf('Локализация корня\n');
fprintf('Начальное приближение: x0 = %.1f, y0 = %.1f\n', x0_initial(1), x0_initial(2));

% Отметим начальную точку на графике
plot(x0_initial(1), x0_initial(2), 'bo', 'MarkerSize', 12, 'LineWidth', 2);
text(x0_initial(1)+0.15, x0_initial(2)+0.1, 'Начальная точка', 'FontSize', 10, 'Color', 'b');

%% 4. Решение с помощью fsolve (эталон)
tol = 1e-10;
options_fsolve = optimoptions('fsolve', 'Display', 'off', 'TolX', tol, 'TolFun', tol);
[x_fsolve, fval_fsolve, exitflag] = fsolve(F, x0_initial, options_fsolve);
fprintf('\nРешение через fsolve\n');
fprintf('x = %.10f, y = %.10f\n', x_fsolve(1), x_fsolve(2));

% Отметим корень на графике
plot(x_fsolve(1), x_fsolve(2), 'r*', 'MarkerSize', 15, 'LineWidth', 2);
text(x_fsolve(1)+0.15, x_fsolve(2)-0.1, 'Корень', 'FontSize', 10, 'Color', 'r');

%% 5. Решение с помощью символьной математики
syms x y real
eq1 = y^2 == cos(x);
eq2 = y^2 - y + 2*x^3 - 2 == 0;
fprintf('\nСимвольное решение\n');
try
    % Используем vpasolve для численного решения через символьную математику
    [x_sym, y_sym] = vpasolve([eq1, eq2], [x, y], [x0_initial(1), x0_initial(2)]);
    if ~isempty(x_sym)
        fprintf('Численное решение через символьную математику (vpasolve):\n');
        fprintf('x = %.10f, y = %.10f\n', double(x_sym), double(y_sym));
        fprintf('Невязка: f1 = %.2e, f2 = %.2e\n', ...
            f1(double(x_sym), double(y_sym)), f2(double(x_sym), double(y_sym)));
    else
        fprintf('Символьное решение не найдено\n');
    end
catch ME
    fprintf('Символьное решение не удалось: %s\n', ME.message);
end

%% 6. Метод простых итераций
fprintf('\nМетод простых итераций\n');

phi_y = @(x) sqrt(max(cos(x), 0));  % max для защиты от отрицательных значений
phi_x = @(y) sign(-y^2 + y + 2) * (abs(-y^2 + y + 2)/2)^(1/3);

G = @(x,y) [phi_x(y); phi_y(x)];

% Якобиан для проверки сходимости
J_simple = @(x,y) [0, (1/3) * ((-y^2+y+2)/2)^(-2/3) * (-2*y+1)/2;
                -sin(x)/(2*sqrt(max(cos(x), 1e-10))), 0];

max_iter = 100;
eps = 1e-8;
x_iter = x0_initial;
history_transform = x_iter';
iter_simple = 0;
norm_history = [];

for iter = 1:max_iter
    % Проверка условия сходимости
    J = J_simple(x_iter(1), x_iter(2));
    norm_J = norm(J, inf);
    norm_history = [norm_history; norm_J];
    fprintf(' Итерация %d: ||J|| = %.6f', iter, norm_J);
    
    if norm_J < 1
        fprintf('Сходимость обеспечена (||J|| < 1)\n');
    else
        fprintf('Условие сходимости не выполнено\n');
    end
    
    % Итерационный процесс
    x_new = G(x_iter(1), x_iter(2));
    history_transform = [history_transform; x_new'];
    iter_simple = iter;
    
    if norm(x_new - x_iter) < eps
        break;
    end
    x_iter = x_new;
end

x_simple = x_new;
fprintf('\nРезультат: x = %.10f, y = %.10f\n', x_simple(1), x_simple(2));
fprintf('Итераций: %d\n', iter_simple);
fprintf('Невязка: f1 = %.2e, f2 = %.2e\n', f1(x_simple(1), x_simple(2)), f2(x_simple(1), x_simple(2)));

%% 7. Метод Зейделя
fprintf('\nМетод зейделя\n');

x_zeidel = x0_initial;
history_zeidel = x_zeidel';
iter_zeidel = 0;
norm_history_zeidel = [];

for iter = 1:max_iter
    % Проверка условия сходимости
    J = J_simple(x_zeidel(1), x_zeidel(2));
    norm_J = norm(J, inf);
    norm_history_zeidel = [norm_history_zeidel; norm_J];
    fprintf('Итерация %d: ||J|| = %.6f', iter, norm_J);
    if norm_J >= 1
        fprintf(' Условие сходимости не выполнено\n');
    else
        fprintf(' Сходимость обеспечена\n');
    end
    
    x_new_val = phi_x(x_zeidel(2));
    y_new_val = phi_y(x_new_val);
    
    x_new = [x_new_val; y_new_val];
    history_zeidel = [history_zeidel; x_new'];
    iter_zeidel = iter;
    
    if norm(x_new - x_zeidel) < eps
        break;
    end
    x_zeidel = x_new;
end

x_zeidel_final = x_new;
fprintf('\nРезультат: x = %.10f, y = %.10f\n', x_zeidel_final(1), x_zeidel_final(2));
fprintf('Итераций: %d\n', iter_zeidel);
fprintf('Невязка: f1 = %.2e, f2 = %.2e\n', f1(x_zeidel_final(1), x_zeidel_final(2)), f2(x_zeidel_final(1), x_zeidel_final(2)));

%% 8. Метод Ньютона
fprintf('\nМетод Ньютона\n');

% Якобиан системы
J_newton = @(x,y) [sin(x), 2*y;
                   6*x^2, 2*y - 1];

x_newton = x0_initial;
history_newton = x_newton';
iter_newton = 0;
det_history = [];

for iter = 1:max_iter
    % Вычисляем якобиан и проверяем det
    J = J_newton(x_newton(1), x_newton(2));
    det_J = det(J);
    det_history = [det_history; det_J];
    fprintf('  Итерация %d: det(J) = %.6f', iter, det_J);
    
    if abs(det_J) < 1e-12
        fprintf(' et=0, метод останавливается!\n');
        break;
    else
        fprintf('\n');
    end
    
    % Вычисляем поправку
    F_val = F(x_newton);
    delta = -J \ F_val;
    x_new = x_newton + delta;
    history_newton = [history_newton; x_new'];
    iter_newton = iter;
    
    if norm(delta) < eps
        break;
    end
    x_newton = x_new;
end

x_newton_final = x_new;
fprintf('\nРезультат: x = %.10f, y = %.10f\n', x_newton_final(1), x_newton_final(2));
fprintf('Итераций: %d\n', iter_newton);
fprintf('Невязка: f1 = %.2e, f2 = %.2e\n', f1(x_newton_final(1), x_newton_final(2)), f2(x_newton_final(1), x_newton_final(2)));

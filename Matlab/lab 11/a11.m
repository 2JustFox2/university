clc; clear; close all;

V = 900;                          % объём емкости
c_sum = 0.77 + 0.84;              % суммарный коэффициент для дна и крышки



%% находим F минимизации площади и теплопотерь

% целевая функция тепловых потерь
F = @(d) (c_sum * pi * d.^2) / 4 + (4 * V) ./ d;

% первая производная целевой функции
dF = @(d) (c_sum * pi * d) / 2 - (4 * V) ./ d.^2;

% вторая производная целевой функции
d2F = @(d) (c_sum * pi) / 2 + (8 * V) ./ d.^3;

% вычисление высоты h по диаметру d
h_from_d = @(d) (4 * V) ./ (pi * d.^2);

% границы интервала поиска
a = 0.1;
b = 20;
eps_val = 1e-4;                   % точность остановки итерационных процессов

fprintf('Оптимизация размеров цилиндрической ёмкости (V = %g м3)\n\n', V);

%% метод золотого сечения

fprintf('Метод золотого сечения:\n');
% вызов функции, реализующей метод золотого сечения
[d_gold, F_gold, iter_gold, history_gold] = golden_section(F, a, b, eps_val);
h_gold = h_from_d(d_gold);        % вычисление оптимальной высоты

% вывод результатов метода золотого сечения
fprintf('  диаметр d = %.6f м\n', d_gold);
fprintf('  высота h   = %.6f м\n', h_gold);
fprintf('  значение F = %.6f\n', F_gold);
fprintf('  итераций   = %d\n\n', iter_gold);






%% метод парабол 2
fprintf('Метод парабол 2:\n');

% Начальное приближение - середина интервала
x0_par2 = (a + b) / 2;

% Начальный шаг h (обычно 1-5% от интервала)
h0 = (b - a) / 20;

% Вызов функции
[d_par2, F_par2, iter_par2, history_par2] = parabola_method_2(F, x0_par2, h0, eps_val);

h_par2 = h_from_d(d_par2);

fprintf('  диаметр d = %.6f м\n', d_par2);
fprintf('  высота h   = %.6f м\n', h_par2);
fprintf('  значение F = %.6f\n', F_par2);
fprintf('  итераций   = %d\n\n', iter_par2);


%% метод Ньютона
fprintf('Метод Ньютона:\n');
% начальное приближение — середина интервала
x0_newton = (a + b) / 2;
% вызов функции, реализующей метод Ньютона
[d_newt, F_newt, iter_newt, history_newt] = newton_method(F, dF, d2F, x0_newton, eps_val);
h_newt = h_from_d(d_newt);       % вычисление оптимальной высоты

% вывод результатов метода Ньютона
fprintf('  диаметр d = %.6f м\n', d_newt);
fprintf('  высота h   = %.6f м\n', h_newt);
fprintf('  значение F = %.6f\n', F_newt);
fprintf('  итераций   = %d\n\n', iter_newt);
%% Задача 1: минимизация площади поверхности (расхода материала)
fprintf('=== Задача 1: Минимизация площади поверхности ===\n\n');

% Целевая функция: площадь поверхности
S = @(d) (pi * d.^2) / 2 + (4 * V) ./ d;

% Первая производная
dS = @(d) pi * d - (4 * V) ./ d.^2;

% Вторая производная
d2S = @(d) pi + (8 * V) ./ d.^3;

% Золотое сечение
[d_S_gold, S_gold, iter_S_gold, ~] = golden_section(S, a, b, eps_val);
h_S_gold = h_from_d(d_S_gold);
fprintf('Метод золотого сечения:\n');
fprintf('  диаметр d = %.4f м, высота h = %.4f м, площадь S = %.4f м², итераций: %d\n\n', ...
        d_S_gold, h_S_gold, S_gold, iter_S_gold);

% Метод парабол
x0_S = (a + b) / 2;
h0_S = (b - a) / 20;
[d_S_par, S_par, iter_S_par, ~] = parabola_method_2(S, x0_S, h0_S, eps_val);
h_S_par = h_from_d(d_S_par);
fprintf('Метод парабол:\n');
fprintf('  диаметр d = %.4f м, высота h = %.4f м, площадь S = %.4f м², итераций: %d\n\n', ...
        d_S_par, h_S_par, S_par, iter_S_par);

% Метод Ньютона
[d_S_newt, S_newt, iter_S_newt, ~] = newton_method(S, dS, d2S, x0_S, eps_val);
h_S_newt = h_from_d(d_S_newt);
fprintf('Метод Ньютона:\n');
fprintf('  диаметр d = %.4f м, высота h = %.4f м, площадь S = %.4f м², итераций: %d\n\n', ...
        d_S_newt, h_S_newt, S_newt, iter_S_newt);

% общие точки для построения графика целевой функции
d_vals = linspace(a, b, 500);
F_vals = F(d_vals);

% --------------------------------------------------
% график для метода золотого сечения
% --------------------------------------------------
figure;
plot(d_vals, F_vals, 'b-', 'LineWidth', 1.5);
hold on; grid on;
xlabel('Диаметр d, м');
ylabel('Тепловые потери F(d)');
title('Метод золотого сечения');

% точки итераций
plot(history_gold(:,1), history_gold(:,2), 'r.', 'MarkerSize', 12);

% точка минимума
plot(d_gold, F_gold, 'k*', 'MarkerSize', 12, 'LineWidth', 1.5);

legend('F(d)', 'итерации', 'минимум', 'Location', 'northeast');
hold off;



% --------------------------------------------------
% график для метода парабол 2
% --------------------------------------------------
figure;
plot(d_vals, F_vals, 'b-', 'LineWidth', 1.5);
hold on; grid on;
xlabel('Диаметр d, м');
ylabel('Тепловые потери F(d)');
title('Метод парабол 2');

% точки итераций
plot(history_par2(:,1), history_par2(:,2), 'r.', 'MarkerSize', 12);

% точка минимума
plot(d_par2, F_par2, 'k*', 'MarkerSize', 12, 'LineWidth', 1.5);

legend('F(d)', 'итерации', 'минимум', 'Location', 'northeast');
hold off;

% --------------------------------------------------
% график для метода Ньютона
% --------------------------------------------------
figure;
plot(d_vals, F_vals, 'b-', 'LineWidth', 1.5);
hold on; grid on;
xlabel('Диаметр d, м');
ylabel('Тепловые потери F(d)');
title('Метод Ньютона');

% точки итераций
plot(history_newt(:,1), history_newt(:,2), 'r.', 'MarkerSize', 12);

% точка минимума
plot(d_newt, F_newt, 'k*', 'MarkerSize', 12, 'LineWidth', 1.5);

legend('F(d)', 'итерации', 'минимум', 'Location', 'northeast');
hold off;

% итоговая сравнительная таблица
fprintf('\n');
fprintf('   Сравнительная таблица результатов\n');
fprintf('   -----------------------------------\n');
fprintf('   %-18s %10s %10s %12s %10s\n', ...
        'Метод', 'd, м', 'h, м', 'F(d)', 'Итераций');
fprintf('   %-18s %10.4f %10.4f %12.4f %10d\n', ...
        'Золотое сечение', d_gold, h_gold, F_gold, iter_gold);
%fprintf('   %-18s %10.4f %10.4f %12.4f %10d\n', ...
%        'Параболы', d_par, h_par, F_par, iter_par);
fprintf('   %-18s %10.4f %10.4f %12.4f %10d\n', ...
        'Параболы 2', d_par2, h_par2, F_par2, iter_par2);
fprintf('   %-18s %10.4f %10.4f %12.4f %10d\n', ...
        'Ньютон', d_newt, h_newt, F_newt, iter_newt);
fprintf('   -----------------------------------\n');


% --------------------------------------------------
% графики для задачи 1 (минимизация площади поверхности)
% --------------------------------------------------

% общие точки для графика площади поверхности
d_vals_S = linspace(a, b, 500);
S_vals = S(d_vals_S);

% график для метода золотого сечения (задача 1)
figure;
plot(d_vals_S, S_vals, 'b-', 'LineWidth', 1.5);
hold on; grid on;
xlabel('Диаметр d, м');
ylabel('Площадь поверхности S(d), м²');
title('Задача 1: Метод золотого сечения (площадь поверхности)');

% точки итераций
[~, ~, ~, history_S_gold] = golden_section(S, a, b, eps_val);
plot(history_S_gold(:,1), history_S_gold(:,2), 'r.', 'MarkerSize', 12);

% точка минимума
plot(d_S_gold, S_gold, 'k*', 'MarkerSize', 12, 'LineWidth', 1.5);

legend('S(d)', 'итерации', 'минимум', 'Location', 'northeast');
hold off;

% график для метода парабол (задача 1)
figure;
plot(d_vals_S, S_vals, 'b-', 'LineWidth', 1.5);
hold on; grid on;
xlabel('Диаметр d, м');
ylabel('Площадь поверхности S(d), м²');
title('Задача 1: Метод парабол (площадь поверхности)');

% точки итераций
[~, ~, ~, history_S_par] = parabola_method_2(S, x0_S, h0_S, eps_val);
plot(history_S_par(:,1), history_S_par(:,2), 'r.', 'MarkerSize', 12);

% точка минимума
plot(d_S_par, S_par, 'k*', 'MarkerSize', 12, 'LineWidth', 1.5);

legend('S(d)', 'итерации', 'минимум', 'Location', 'northeast');
hold off;

% график для метода Ньютона (задача 1)
figure;
plot(d_vals_S, S_vals, 'b-', 'LineWidth', 1.5);
hold on; grid on;
xlabel('Диаметр d, м');
ylabel('Площадь поверхности S(d), м²');
title('Задача 1: Метод Ньютона (площадь поверхности)');

% точки итераций
[~, ~, ~, history_S_newt] = newton_method(S, dS, d2S, x0_S, eps_val);
plot(history_S_newt(:,1), history_S_newt(:,2), 'r.', 'MarkerSize', 12);

% точка минимума
plot(d_S_newt, S_newt, 'k*', 'MarkerSize', 12, 'LineWidth', 1.5);

legend('S(d)', 'итерации', 'минимум', 'Location', 'northeast');
hold off;

%% метод золотого сечения

function [x_opt, f_opt, iter, history] = golden_section(f, a, b, eps)
    % f      – целевая функция одной переменной
    % a, b   – границы начального интервала неопределённости
    % eps    – требуемая точность по длине интервала
    % x_opt  – найденная точка минимума
    % f_opt  – значение функции в точке минимума
    % iter   – число выполненных итераций
    % history – массив, в каждой строке [x, f(x)] для всех вычисленных точек

    tau = (sqrt(5) - 1) / 2;        % константа золотого сечения (=0.618)
    iter = 0;                       % счётчик итераций
    history = [];                   % инициализация истории вычислений

    % вычисление двух внутренних точек, делящих отрезок в пропорции золотого сечения
    x1 = b - tau * (b - a);
    x2 = a + tau * (b - a);
    f1 = f(x1);
    f2 = f(x2);

    % сохранение вычисленных точек в истории
    history = [history; x1, f1; x2, f2];

    % основной цикл: продолжаем, пока длина интервала больше заданной точности
    while (b - a) > eps
        iter = iter + 1;            % увеличение счётчика итераций
        if f1 < f2                  % минимум лежит левее x2
            b = x2;                 % сдвиг правой границы
            x2 = x1;                % старая левая точка становится новой правой
            f2 = f1;
            x1 = b - tau * (b - a); % новая левая точка
            f1 = f(x1);
            history = [history; x1, f1]; % запись в историю
        else                        % минимум лежит правее x1
            a = x1;                 % сдвиг левой границы
            x1 = x2;                % старая правая точка становится новой левой
            f1 = f2;
            x2 = a + tau * (b - a); % новая правая точка
            f2 = f(x2);
            history = [history; x2, f2]; % запись в историю
        end
    end
    % за приближённое значение минимума принимаем середину итогового интервала
    x_opt = (a + b) / 2;
    f_opt = f(x_opt);
    
    history = [history; x_opt, f_opt]; % запись финальной точки
end


%% метод парабол (квадратичная интерполяция по трём точкам)

function [x_opt, f_opt, iter, history] = parabola_method(f, x1, x2, x3, eps)
    % f      – целевая функция
    % x1,x2,x3 – начальные три точки (x1 < x2 < x3)
    % eps    – требуемая точность
    % x_opt  – точка минимума
    % f_opt  – значение функции в минимуме
    % iter   – количество итераций
    % history – история точек [x, f(x)]

    iter = 0;                       % счётчик итераций
    f1 = f(x1);                     % значение функции в левой точке
    f2 = f(x2);                     % значение функции в средней точке
    f3 = f(x3);                     % значение функции в правой точке
    history = [x1, f1; x2, f2; x3, f3]; % сохранение начальных точек

    % итерационный процесс, пока расстояние между крайними точками > eps
    while abs(x3 - x1) > eps
        iter = iter + 1;            % увеличение счётчика

        % вычисление вершины параболы, проходящей через три точки
        num = (x2 - x1)^2 * (f2 - f3) - (x2 - x3)^2 * (f2 - f1);
        den = 2 * ((x2 - x1) * (f2 - f3) - (x2 - x3) * (f2 - f1));

        % защита от деления на ноль (точки почти на одной прямой)
        if abs(den) < 1e-15
            x_new = (x1 + x3) / 2;  % откат к середине интервала
        else
            x_new = x2 - num / den; % аналитический минимум параболы
        end

        % если новая точка вышла за границы, помещаем её в середину интервала
        if x_new < x1 || x_new > x3
            x_new = (x1 + x3) / 2;
        end

        f_new = f(x_new);           % значение функции в новой точке
        history = [history; x_new, f_new]; % запись в историю

        % переопределение тройки точек для следующей итерации
        if x_new < x2               % новая точка левее средней
            if f_new < f2           % новое значение меньше старого среднего
                x3 = x2; f3 = f2;   % старая средняя становится правой
                x2 = x_new; f2 = f_new; % новая точка становится средней
            else
                x1 = x_new; f1 = f_new; % новая точка становится левой
            end
        else                        % новая точка правее средней
            if f_new < f2           % новое значение меньше старого среднего
                x1 = x2; f1 = f2;   % старая средняя становится левой
                x2 = x_new; f2 = f_new; % новая точка становится средней
            else
                x3 = x_new; f3 = f_new; % новая точка становится правой
            end
        end
    end
    % результат — средняя точка последней тройки
    x_opt = x2;
    f_opt = f(x_opt);
    history = [history; x_opt, f_opt]; % запись финальной точки
end

%% метод Ньютона 
function [x_opt, f_opt, iter, history] = newton_method(f, df, d2f, x0, eps)
    % f      – целевая функция
    % df     – первая производная f'(x)
    % d2f    – вторая производная f''(x)
    % x0     – начальное приближение
    % eps    – точность (остановка при |x_new - x| < eps)
    % x_opt  – точка минимума
    % f_opt  – значение функции в минимуме
    % iter   – число итераций
    % history – история приближений [x, f(x)]

    iter = 0;                       % счётчик итераций
    x = x0;                         % текущее приближение
    f_x = f(x);                     % значение функции в начальной точке
    history = [x, f_x];             % сохранение начальной точки
    max_iter = 100;                 % максимальное число итераций

    for iter = 1:max_iter
        % шаг метода Ньютона: x_new = x - f'(x) / f''(x)
        dx = df(x) / d2f(x);        % приращение
        x_new = x - dx;             % новое приближение
        f_new = f(x_new);           % значение функции в новой точке
        history = [history; x_new, f_new]; % запись в историю

        % проверка условия остановки по изменению координаты
         if abs(df(x_new)) < eps
            break;
        end
        x = x_new;                  % обновление текущей точки
    end
    % итоговые результаты
    x_opt = x_new;
    f_opt = f_new;
end
function [x_opt, f_opt, iter, history] = parabola_method_2(f, x0, h, eps)
    % Метод парабол по формуле (9) из методички
    % с контролем знаменателя, убывания функции и корректировкой шага h
    
    iter = 0;
    x = x0;
    f_x = f(x);
    history = [x, f_x];
    max_iter = 100;
    
    for iter = 1:max_iter
        % Вычисление значений в трёх точках
        f_plus  = f(x + h);
        f_minus = f(x - h);
        f_center = f_x;
        
        % Знаменатель формулы (9) — вторая конечная разность
        denom = f_plus - 2*f_center + f_minus;
        
        % === Условие 1: знаменатель должен быть положительным ===
        if denom <= 1e-15
            % По методичке: "сделать шаг в обратном направлении,
            % причём достаточно большой"
            % Увеличиваем h, чтобы знаменатель стал положительным
            h = h * 2;
            continue;  % повторяем итерацию с новым h, не меняя x
        end
        
        % Формула (9): вершина аппроксимирующей параболы
        x_new = x - (h / 2) * (f_plus - f_minus) / denom;
        
        % Ограничение: не уходим слишком далеко 
        % По методичке: h << |x_{k+1} - x_k|
        max_step = 5 * h;
        if abs(x_new - x) > max_step
            if x_new > x
                x_new = x + max_step;
            else
                x_new = x - max_step;
            end
        end
        
        % Защита от отрицательных значений (специфика задачи: d > 0)
        if x_new < 1e-6
            x_new = x / 2;
        end
        
        f_new = f(x_new);
        history = [history; x_new, f_new];
        
        % Условие 2: функция должна убывать
        if f_new >= f_x
            % По методичке: шаг в том же направлении с tau = 1/2
            tau = 1/2;
            x_new = x + tau * (x_new - x);
            if x_new < 1e-6
                x_new = x / 2;
            end
            f_new = f(x_new);
            history = [history; x_new, f_new];
            
            % Если опять не убывает - ещё уменьшаем tau
            if f_new >= f_x
                tau = 1/4;
                x_new = x + tau * (x_new - x);
                if x_new < 1e-6
                    x_new = x / 2;
                end
                f_new = f(x_new);
                history = [history; x_new, f_new];
            end
        end
        
        %  Корректировка h для повышения точности
        % расстояния между итерациями
        delta_x = abs(x_new - x);
        if delta_x > eps && delta_x < h
            h = delta_x / 3;   % уменьшаем h вслед за сходимостью
        end
        
        % Проверка сходимости
        if abs(x_new - x) < eps
            x = x_new;
            f_x = f_new;
            break;
        end
        
        %  Обновление текущей точки
        x = x_new;
        f_x = f_new;
    end
    
    x_opt = x;
    f_opt = f_x;
end

figure;
d_plot = linspace(a, b, 500);
plot(d_plot, S(d_plot), 'b-', 'LineWidth', 1.5);
hold on; grid on;
plot(d_plot, F(d_plot), 'r--', 'LineWidth', 1.5);
xlabel('Диаметр d, м');
ylabel('Значение функции');
title('Сравнение: площадь поверхности vs тепловые потери');
legend('S(d) - площадь', 'F(d) - теплопотери', 'Location', 'northeast');

% Отмечаем минимумы
plot(d_S_gold, S_gold, 'b*', 'MarkerSize', 14, 'LineWidth', 1.5);
plot(d_gold, F_gold, 'r*', 'MarkerSize', 14, 'LineWidth', 1.5);
text(d_S_gold + 0.5, S_gold + 5, ['S_{min} = ', num2str(round(S_gold,1))], 'Color', 'b', 'FontSize', 10);
text(d_gold + 0.5, F_gold - 5, ['F_{min} = ', num2str(round(F_gold,1))], 'Color', 'r', 'FontSize', 10);
hold off;



%% задача 2. градиентный спуск
fprintf('\n');
fprintf(' Задача 2: Метод градиентного спуска\n');
fprintf('Функция: f(x) = n + sum(x_i^2 - cos(18*x_i^2)), n=2, диапазон [-2,2]\n\n');

% Параметры задачи
n = 2;                          % размерность пространства
epsilon1 = 1e-4;                % точность по градиенту
epsilon2 = 1e-4;                % точность по аргументу и функции
M = 1000;                       % предельное число итераций
x0 = [1.5; 0.5];                % начальная точка

% Символьное определение функции и градиента
syms x1 x2 real

% Символьная функция
f_sym = 2 + (x1^2 - cos(18*x1^2)) + (x2^2 - cos(18*x2^2));

%  вычисление градиента
grad_sym = gradient(f_sym, [x1, x2]);

% Преобразование в анонимные функции
f = matlabFunction(f_sym, 'Vars', {[x1; x2]});
grad_f = matlabFunction(grad_sym, 'Vars', {[x1; x2]});

% Вывод для проверки
fprintf('Символьная функция:\n');
disp(f_sym);
fprintf('\nСимвольный градиент:\n');
disp(grad_sym);
fprintf('\n');

% Проверка градиента в начальной точке
fprintf('Начальная точка: x0 = [%.2f; %.2f]\n', x0(1), x0(2));
fprintf('Значение функции: f(x0) = %.6f\n', f(x0));
fprintf('Градиент в x0: [%.6f; %.6f]\n', grad_f(x0));
fprintf('Норма градиента: %.6f\n\n', norm(grad_f(x0)));

% Визуализация функции
[X, Y] = meshgrid(-2:0.05:2, -2:0.05:2);
Z = zeros(size(X));
for i = 1:size(X,1)
    for j = 1:size(X,2)
        Z(i,j) = f([X(i,j); Y(i,j)]);
    end
end

% Метод градиентного спуска
[x_opt, f_opt, iter_opt, history_gd, grad_norm_history] = gradient_descent(f, grad_f, x0, epsilon1, epsilon2, M);

fprintf('\nНайден минимум:\n');
fprintf('  x1 = %.6f\n', x_opt(1));
fprintf('  x2 = %.6f\n', x_opt(2));
fprintf('  f(x) = %.6f\n', f_opt);
fprintf('  итераций = %d\n', iter_opt);
fprintf('  норма градиента в конце = %.2e\n', grad_norm_history(end));

% Графики
figure('Position', [100, 100, 1200, 500]);

% 1. Поверхность с траекторией спуска
subplot(1,2,1);
surf(X, Y, Z, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
hold on;
plot3(history_gd(1,1), history_gd(1,2), f([history_gd(1,1); history_gd(1,2)]), ...
    'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot3(history_gd(end,1), history_gd(end,2), f([history_gd(end,1); history_gd(end,2)]), ...
    'r*', 'MarkerSize', 12, 'LineWidth', 2);
plot3(history_gd(:,1), history_gd(:,2), arrayfun(@(i) f([history_gd(i,1); history_gd(i,2)]), 1:size(history_gd,1)), ...
    'k-', 'LineWidth', 1.5);
plot3(history_gd(:,1), history_gd(:,2), arrayfun(@(i) f([history_gd(i,1); history_gd(i,2)]), 1:size(history_gd,1)), ...
    'b.', 'MarkerSize', 10);
xlabel('x_1'); ylabel('x_2'); zlabel('f(x)');
title('Метод градиентного спуска: поверхность и траектория');
legend('Поверхность', 'Начальная точка', 'Минимум', 'Траектория', 'Итерации');
grid on;
view(45, 30);
hold off;

% 2. Линии уровня
subplot(1,2,2);
contour(X, Y, Z, 20, 'LineWidth', 0.5);
hold on;
plot(history_gd(:,1), history_gd(:,2), 'k-', 'LineWidth', 1.5);
plot(history_gd(:,1), history_gd(:,2), 'b.', 'MarkerSize', 10);
plot(history_gd(1,1), history_gd(1,2), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot(history_gd(end,1), history_gd(end,2), 'r*', 'MarkerSize', 12, 'LineWidth', 2);
xlabel('x_1'); ylabel('x_2');
title('Метод градиентного спуска: линии уровня');
legend('Линии уровня', 'Траектория', 'Итерации', 'Начальная точка', 'Минимум');
grid on;
axis equal;
hold off;

% 3. Сходимость градиента
figure;
semilogy(1:length(grad_norm_history), grad_norm_history, 'b-', 'LineWidth', 1.5);
hold on;
yline(epsilon1, 'r--', 'LineWidth', 1.5);
xlabel('Номер итерации'); ylabel('||∇f(x)||');
title('Сходимость метода градиентного спуска');
legend('Норма градиента', ['\epsilon_1 = ', num2str(epsilon1)], 'Location', 'northeast');
grid on;
hold off;

% 4. Убывание функции вдоль траектории
figure;
f_trajectory = zeros(size(history_gd,1), 1);
for i = 1:size(history_gd,1)
    f_trajectory(i) = f([history_gd(i,1); history_gd(i,2)]);
end
plot(1:length(f_trajectory), f_trajectory, 'b-', 'LineWidth', 1.5);
xlabel('Номер итерации'); ylabel('f(x)');
title('Убывание функции на траектории спуска');
grid on;

%% Функция градиентного спуска
function [x_opt, f_opt, iter, history, grad_norm_history] = gradient_descent(f, grad_f, x0, epsilon1, epsilon2, M)
    % Алгоритм градиентного спуска с дроблением шага
    %
    % Вход:
    %   f        - целевая функция
    %   grad_f   - градиент функции
    %   x0       - начальная точка
    %   epsilon1 - точность по градиенту (шаг 4)
    %   epsilon2 - точность по аргументу и функции (шаг 9)
    %   M        - максимальное число итераций
    %
    % Выход:
    %   x_opt   - найденная точка минимума
    %   f_opt   - значение функции в минимуме
    %   iter    - число итераций
    %   history - история всех вычисленных точек
    %   grad_norm_history - история норм градиента
    
    x = x0(:);              % текущая точка (вектор-столбец)
    k = 0;                  % счётчик итераций
    history = x';           % история точек
    grad_norm_history = []; % история норм градиента
    
    for k = 1:M
        % Шаг 3: вычисляем градиент
        g = grad_f(x);
        grad_norm = norm(g);
        grad_norm_history = [grad_norm_history; grad_norm];
        
        % Шаг 4: проверка ||∇f(x^k)|| < ε₁
        if grad_norm < epsilon1
            fprintf('Остановка на итерации %d: норма градиента < ε₁ (%.2e < %.2e)\n', k, grad_norm, epsilon1);
            break;
        end
        
        % Шаг 6: задаём величину шага
        t = 0.1;            % начальный шаг
        
        % Шаги 7-8: спуск с дроблением шага
        while true
            x_new = x - t * g;          % шаг 7
            f_old = f(x);
            f_new = f(x_new);
            
            % Шаг 8: проверка f(x^{k+1}) - f(x^k) < 0
            if f_new - f_old < 0
                break;                  % условие выполнено, выходим
            else
                t = t / 2;              % дробим шаг
                if t < 1e-15
                    fprintf('Предупреждение на итерации %d: шаг стал слишком маленьким (t = %.2e)\n', k, t);
                    x_new = x;          % остаёмся на месте
                    break;
                end
            end
        end
        
        history = [history; x_new'];    % сохраняем новую точку
        
        % Шаг 9: проверка условий окончания
        delta_x = norm(x_new - x);
        delta_f = abs(f_new - f_old);
        
        if (delta_x < epsilon2) && (delta_f < epsilon2)
            fprintf('Остановка на итерации %d: ||Δx|| < ε₂ и |Δf| < ε₂ (%.2e, %.2e)\n', k, delta_x, delta_f);
            x = x_new;
            break;
        end
        
        % Подготовка к следующей итерации
        x = x_new;
    end
    
    iter = k;
    x_opt = x;
    f_opt = f(x_opt);
end

% Решение стандартными функциями MATLAB
fprintf('\nРешение стандартными функциями MATLAB\n\n');

% Задача 1: fminbnd для площади поверхности
fprintf('Задача 1 (площадь поверхности):\n');
[d_S_fminbnd, S_min_fminbnd, exitflag_S, output_S] = fminbnd(S, a, b);
h_S_fminbnd = h_from_d(d_S_fminbnd);
fprintf('  d = %.4f м, h = %.4f м, S = %.4f м²\n', d_S_fminbnd, h_S_fminbnd, S_min_fminbnd);
fprintf('  exitflag = %d, итераций = %d, вызовов функции = %d\n', ...
        exitflag_S, output_S.iterations, output_S.funcCount);
fprintf('  алгоритм: %s\n\n', output_S.algorithm);

% Задача 2: fminbnd для тепловых потерь
fprintf('Задача 2 (тепловые потери):\n');
[d_F_fminbnd, F_min_fminbnd, exitflag_F, output_F] = fminbnd(F, a, b);
h_F_fminbnd = h_from_d(d_F_fminbnd);
fprintf('  d = %.4f м, h = %.4f м, F = %.4f\n', d_F_fminbnd, h_F_fminbnd, F_min_fminbnd);
fprintf('  exitflag = %d, итераций = %d, вызовов функции = %d\n', ...
        exitflag_F, output_F.iterations, output_F.funcCount);
fprintf('  алгоритм: %s\n\n', output_F.algorithm);

% Задача 2б: fminunc для градиентного спуска
fprintf('Задача 2б (fminunc с градиентом):\n');
options = optimset('GradObj', 'on');
[x_fminunc, f_fminunc, exitflag_unc, output_unc] = fminunc(@(x) deal(f(x), grad_f(x)), x0, options);
fprintf('  x1 = %.6f, x2 = %.6f, f(x) = %.6f\n', x_fminunc(1), x_fminunc(2), f_fminunc);
fprintf('  exitflag = %d, итераций = %d, вызовов функции = %d\n', ...
        exitflag_unc, output_unc.iterations, output_unc.funcCount);
fprintf('  алгоритм: %s\n\n', output_unc.algorithm);

% Задача 2б: fminsearch (без градиента)
fprintf('Задача 2б (fminsearch без градиента):\n');
[x_fminsearch, f_fminsearch, exitflag_s, output_s] = fminsearch(f, x0);
fprintf('  x1 = %.6f, x2 = %.6f, f(x) = %.6f\n', x_fminsearch(1), x_fminsearch(2), f_fminsearch);
fprintf('  exitflag = %d, итераций = %d, вызовов функции = %d\n', ...
        exitflag_s, output_s.iterations, output_s.funcCount);
fprintf('  алгоритм: %s\n\n', output_s.algorithm);

% Сравнительная таблица
fprintf('Сравнительная таблица:\n');
fprintf('  %-20s %8s %8s %10s %8s %8s\n', 'Метод', 'd', 'h', 'F/S', 'Итер', 'exit');
fprintf('  Задача 2 (теплопотери):\n');
fprintf('  %-20s %8.4f %8.4f %10.4f %8d %8s\n', 'Золотое сечение', d_gold, h_gold, F_gold, iter_gold, '-');
fprintf('  %-20s %8.4f %8.4f %10.4f %8d %8s\n', 'Параболы', d_par2, h_par2, F_par2, iter_par2, '-');
fprintf('  %-20s %8.4f %8.4f %10.4f %8d %8s\n', 'Ньютон', d_newt, h_newt, F_newt, iter_newt, '-');
fprintf('  %-20s %8.4f %8.4f %10.4f %8d %8d\n', 'fminbnd', d_F_fminbnd, h_F_fminbnd, F_min_fminbnd, output_F.iterations, exitflag_F);
fprintf('\n  Задача 1 (площадь):\n');
fprintf('  %-20s %8.4f %8.4f %10.4f %8d %8s\n', 'Золотое сечение', d_S_gold, h_S_gold, S_gold, iter_S_gold, '-');
fprintf('  %-20s %8.4f %8.4f %10.4f %8d %8s\n', 'Параболы', d_S_par, h_S_par, S_par, iter_S_par, '-');
fprintf('  %-20s %8.4f %8.4f %10.4f %8d %8s\n', 'Ньютон', d_S_newt, h_S_newt, S_newt, iter_S_newt, '-');
fprintf('  %-20s %8.4f %8.4f %10.4f %8d %8d\n', 'fminbnd', d_S_fminbnd, h_S_fminbnd, S_min_fminbnd, output_S.iterations, exitflag_S);
fprintf('\n  Задача 2б (градиентный спуск):\n');
fprintf('  %-20s %8.4f %8.4f %10.4f %8d %8s\n', 'Град. спуск', x_opt(1), x_opt(2), f_opt, iter_opt, '-');
fprintf('  %-20s %8.4f %8.4f %10.4f %8d %8d\n', 'fminunc', x_fminunc(1), x_fminunc(2), f_fminunc, output_unc.iterations, exitflag_unc);
fprintf('  %-20s %8.4f %8.4f %10.4f %8d %8d\n', 'fminsearch', x_fminsearch(1), x_fminsearch(2), f_fminsearch, output_s.iterations, exitflag_s);
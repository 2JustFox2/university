%% Интерполяция экспериментальных данных
clear; clc; close all;

%% Исходные данные
t = [0, 2, 5, 9, 11, 16, 18, 21, 24];
h = [10.00, 918.4, 2222.5, 3448.9, 3550.9, 1736.4, 984.174, 436.146, 807.6];

% Точки для интерполяции
t1 = 3.5;
t2 = 6.7;
t3 = 12.4;
t_interp = [t1, t2, t3];

n = length(t) - 1; % степень полинома

%% 1. Построение канонического полинома через определитель Вандермонда
fprintf('1. Канонический полином через определитель Вандермонда\n');

% Матрица Вандермонда
V = vander(t); % Встроенная функция MATLAB
% Или вручную:
% V = zeros(n+1);
% for i = 1:n+1
%     for j = 1:n+1
%         V(i,j) = t(i)^(n+1-j);
%     end
% end

% Решение системы для нахождения коэффициентов полинома
coeffs = V \ h'; % коэффициенты от старшей степени к младшей
cond_number = cond(V);
fprintf('Проверка обусловленности: %d', cond_number)

if cond_number < 1e4
    fprintf('Статус: Хорошо обусловлена \n');
elseif cond_number < 1e8
    fprintf('Статус: Умеренно плохая обусловленность\n');
    fprintf('Рекомендация: возможна потеря до %d знаков точности\n', floor(log10(cond_number)));
else
    fprintf('Статус: Плохо обусловлена\n');
    fprintf('Ожидаемая потеря точности: до %d знаков\n', floor(log10(cond_number)));
end

% Вывод полинома
fprintf('Полином степени %d:\nP(x) = ', n);
for i = 1:n
    fprintf('%.6f*x^%d + ', coeffs(i), n+1-i);
end
fprintf('%.6f\n\n', coeffs(end));

%% 2. Функция полинома
P = @(x) polyval(coeffs, x);

% Вычисление значений в заданных точках
h_interp_poly = P(t_interp);
fprintf('Значения по каноническому полиному:\n');
fprintf('h(%.1f) = %.4f\n', [t_interp; h_interp_poly]);
fprintf('\n');

%% 3. Построение графика полиномиальной зависимости
figure('Position', [100, 100, 1500, 500]);

subplot(1,3,1);
t_plot = linspace(min(t), max(t), 500);
h_plot = P(t_plot);

plot(t_plot, h_plot, 'b-', 'LineWidth', 1.5); hold on;
plot(t, h, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
plot(t_interp, h_interp_poly, 'gs', 'MarkerSize', 10, 'MarkerFaceColor', 'g');

xlabel('t'); ylabel('h');
title('Интерполяция каноническим полиномом');
legend('Полином P_n(t)', 'Узловые точки', 'Интерполируемые точки', 'Location', 'best');
grid on;

%% 4. Оценка погрешности по формуле Рунге
fprintf('4. Оценка погрешности\n');

% Аппроксимация максимальной производной через конечные разности
% Используем 9-ю производную (n+1 = 9)
h_step = mean(diff(t));
% Для оценки используем центральные разности
f_n1_max = max(abs(diff(h, n+1))) / (h_step^(n+1));

% Функция для вычисления произведения (x - x_i)
prod_term = @(x) prod(x - t);

% Оценка погрешности для каждой точки
fprintf('Точка\t\tЗначение\tПогрешность (верхняя граница)\n');
for i = 1:length(t_interp)
    error_bound = (f_n1_max / factorial(n+1)) * abs(prod_term(t_interp(i)));
    fprintf('t=%.1f\t\t%.4f\t\t%.6e\n', t_interp(i), h_interp_poly(i), error_bound);
end

%% 5. Таблица конечных разностей
fprintf('\n5. Таблица конечных разностей\n');

% Создание таблицы конечных разностей
diff_table = zeros(n+1, n+2);
diff_table(:,1) = t';
diff_table(:,2) = h';

for j = 1:n
    for i = 1:(n+1-j)
        diff_table(i, j+2) = diff_table(i+1, j+1) - diff_table(i, j+1);
    end
end

% Определяем названия столбцов
colNames = {'t', 'h', 'd1', 'd2', 'd3', 'd4', 'd5', 'd6', 'd7', 'd8'};

diff_table(isnan(diff_table)) = 0; 
n_cols = size(diff_table, 2);
colNames = [{'t', 'h'}, arrayfun(@(x) sprintf('d%d', x), 1:n_cols-2, 'UniformOutput', false)];
T = array2table(diff_table, 'VariableNames', colNames);
T{:, isnan(T{:,:})} = 0;

% Вывод в командное окно
disp('Конечные разности:')
disp(T)
fprintf('\nИспльзуем степень полинома для сплайн-интерполяции 3\n');

%% 6. Сплайн-интерполяция
fprintf('6. Сплайн-интерполяция\n');

% Интерполяция кубическим сплайном
spline_obj = spline(t, h);

% Вычисление значений сплайна в заданных точках
h_interp_spline = ppval(spline_obj, t_interp);
fprintf('Значения по кубическому сплайну:\n');
fprintf('h_spline(%.1f) = %.4f\n', [t_interp; h_interp_spline]);

% Вычисление значений сплайна во всех точках для графика
h_spline_plot = ppval(spline_obj, t_plot);

%% 6. Сплайн-интерполяция 4-й степени
fprintf('6. Сплайн-интерполяция 4-й степени\n');

spline_obj_4 = spapi(5, t, h);  % порядок 5 = степень 4
h_interp_spline_4 = fnval(spline_obj_4, t_interp);
fprintf('h_spline_4(%.1f) = %.4f\n', [t_interp; h_interp_spline_4]);

% Для spapi (B-form) используем fnval, а не ppval
h_spline_plot_4 = fnval(spline_obj_4, t_plot);

%% 7. Построение графика со сплайном
subplot(1,3,2);
plot(t_plot, h_spline_plot, 'm-', 'LineWidth', 1.5); hold on;
plot(t, h, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
plot(t_interp, h_interp_spline, 'bs', 'MarkerSize', 10, 'MarkerFaceColor', 'b');

xlabel('t'); ylabel('h');
title('Интерполяция кубическим сплайном');
legend('Кубический сплайн', 'Узловые точки', 'Интерполируемые точки', 'Location', 'best');
grid on;

subplot(1,3,3);
plot(t_plot, h_spline_plot_4, 'm-', 'LineWidth', 1.5); hold on;
plot(t, h, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
plot(t_interp, h_interp_spline_4, 'bs', 'MarkerSize', 10, 'MarkerFaceColor', 'b');

xlabel('t'); ylabel('h');
title('Интерполяция сплайном 4-й степени');
legend('Сплайн 4-й степени', 'Узловые точки', 'Интерполируемые точки', 'Location', 'best');
grid on;

%% 8. Сравнение полинома и сплайна
figure('Position', [100, 100, 1200, 600]);

% Сравнительный график
plot(t_plot, h_plot, 'b-', 'LineWidth', 1.5); hold on;
plot(t_plot, h_spline_plot, 'm-', 'LineWidth', 1.5);
plot(t_plot, h_spline_plot_4, 'c-', 'LineWidth', 1.5);
plot(t, h, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
plot(t_interp, h_interp_poly, 'gs', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot(t_interp, h_interp_spline, 'bs', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
plot(t_interp, h_interp_spline_4, 'cs', 'MarkerSize', 10, 'MarkerFaceColor', 'c');

xlabel('t'); ylabel('h');
title('Сравнение полинома, кубического и 4-й степени сплайнов');
legend('Канонический полином (степень 8)', 'Кубический сплайн', ...
    'Сплайн 4-й степени', 'Узловые точки ', 'Полином в заданных точках', ...
    'Кубический сплайн в заданных точках', 'Сплайн 4-й степени в заданных точках', ...
    'Location', 'best');
grid on;

%% 9. Анализ погрешности сплайна
fprintf('\nСравнение результатов\n');
fprintf('Точка\t\tПолином\t\t\tСплайн\t\t\tРазница\n');
for i = 1:length(t_interp)
    fprintf('t=%.1f\t\t%.4f\t\t%.4f\t\t%.4f\n', ...
        t_interp(i), h_interp_poly(i), h_interp_spline(i), ...
        abs(h_interp_poly(i) - h_interp_spline(i)));
end

%% 10. Дополнительный анализ: проверка поведения на границах
fprintf('\nПоведение на границах\n');
t_boundary = [min(t)-1, max(t)+1];
h_boundary_poly = P(t_boundary);
h_boundary_spline = ppval(spline_obj, t_boundary);

fprintf('Экстраполяция за пределы интервала:\n');
fprintf('При t=%.0f: полином=%.2f, сплайн=%.2f\n', t_boundary(1), h_boundary_poly(1), h_boundary_spline(1));
fprintf('При t=%.0f: полином=%.2f, сплайн=%.2f\n', t_boundary(2), h_boundary_poly(2), h_boundary_spline(2));

% Данные (исправляем запятые на точки)
x_raw = [0.0, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7];
y_raw = [17.373, 22.50, 24.65, 27.24, 30.34, 34.01, 38.33, 41.28, 49.39];
p_raw = [0.8, 0.7, 0.5, 0.9, 1.0, 0.7, 0.5, 0.8, 0.3];

% Преобразуем в столбцы
x = x_raw(:);
y = y_raw(:);
p = p_raw(:);

n = length(x);
max_degree = n - 2; % максимальная степень по условию

%% 1. Определение степени полинома по конечным разностям
fprintf('Оценка степени полинома по конечным разностям\n');
delta_y = y;
for d = 1:max_degree
    delta_new = zeros(length(delta_y)-1, 1);
    for i = 1:length(delta_y)-1
        delta_new(i) = delta_y(i+1) - delta_y(i);
    end
    delta_y = delta_new;
    fprintf('Разность %d-го порядка: мин = %.4f, макс = %.4f, ср. модуль = %.4f\n', ...
        d, min(delta_y), max(delta_y), mean(abs(delta_y)));
    if max(abs(delta_y)) < 1e-3
        fprintf('Рекомендуемая степень = %d (разности почти нулевые)\n', d-1);
        suggested_deg = d-1;
        break;
    end
    if d == max_degree
        fprintf('Рекомендуемая степень = %d (по условию n-2)\n', max_degree);
        suggested_deg = max_degree;
    end
end

if ~exist('suggested_deg', 'var')
    suggested_deg = 3;
end
fprintf('Для дальнейшего построения возьмем степень m = %d\n', suggested_deg);
m = suggested_deg;

%% 2. Аппроксимация без весов: определитель Вандермонда (ручное построение)
fprintf('\nПолином через определитель Вандермонда\n');
% Ручное построение матрицы Вандермонда
V = zeros(n, m+1);
for i = 1:n
    for j = 0:m
        V(i, j+1) = x(i)^j;
    end
end
% Решение СЛАУ методом Гаусса
coeff_vand = zeros(m+1, 1);
Aug = [V, y];
for k = 1:m
    [~, max_row] = max(abs(Aug(k:n, k)));
    max_row = max_row + k - 1;
    if max_row ~= k
        Aug([k, max_row], :) = Aug([max_row, k], :);
    end
    for i = k+1:n
        factor = Aug(i, k) / Aug(k, k);
        Aug(i, k:m+2) = Aug(i, k:m+2) - factor * Aug(k, k:m+2);
    end
end
for i = m+1:-1:1
    sum_val = 0;
    for j = i+1:m+1
        sum_val = sum_val + Aug(i, j) * coeff_vand(j);
    end
    coeff_vand(i) = (Aug(i, m+2) - sum_val) / Aug(i, i);
end
fprintf('Коэффициенты (от младшей степени):\n');
disp(coeff_vand');

%% 3. Аппроксимация без весов: МНК (ручная реализация вместо polyfit)
fprintf('\nПолином через МНК (аналог polyfit)\n');
% Построение матрицы A
A = zeros(n, m+1);
for i = 1:n
    for j = 0:m
        A(i, j+1) = x(i)^j;
    end
end
% Решение нормальных уравнений
ATA = A' * A;
ATy = A' * y;
coeff_polyfit = zeros(m+1, 1);
Aug = [ATA, ATy];
for k = 1:m
    [~, max_row] = max(abs(Aug(k:m+1, k)));
    max_row = max_row + k - 1;
    if max_row ~= k
        Aug([k, max_row], :) = Aug([max_row, k], :);
    end
    for i = k+1:m+1
        factor = Aug(i, k) / Aug(k, k);
        Aug(i, k:m+2) = Aug(i, k:m+2) - factor * Aug(k, k:m+2);
    end
end
for i = m+1:-1:1
    sum_val = 0;
    for j = i+1:m+1
        sum_val = sum_val + Aug(i, j) * coeff_polyfit(j);
    end
    coeff_polyfit(i) = (Aug(i, m+2) - sum_val) / Aug(i, i);
end
fprintf('Коэффициенты (от младшей степени):\n');
disp(coeff_polyfit');

%% 4. С учётом весов: МНК с весами (вместо spap2)
fprintf('\nПолином с весами через МНК \n');
% Построение взвешенной матрицы
W_sqrt = zeros(n, n);
for i = 1:n
    W_sqrt(i, i) = sqrt(p(i));
end
Aw = W_sqrt * A;
yw = W_sqrt * y;
% Решение нормальных уравнений
AwTAw = Aw' * Aw;
AwTyw = Aw' * yw;
coeff_weighted = zeros(m+1, 1);
Aug = [AwTAw, AwTyw];
for k = 1:m
    [~, max_row] = max(abs(Aug(k:m+1, k)));
    max_row = max_row + k - 1;
    if max_row ~= k
        Aug([k, max_row], :) = Aug([max_row, k], :);
    end
    for i = k+1:m+1
        factor = Aug(i, k) / Aug(k, k);
        Aug(i, k:m+2) = Aug(i, k:m+2) - factor * Aug(k, k:m+2);
    end
end
for i = m+1:-1:1
    sum_val = 0;
    for j = i+1:m+1
        sum_val = sum_val + Aug(i, j) * coeff_weighted(j);
    end
    coeff_weighted(i) = (Aug(i, m+2) - sum_val) / Aug(i, i);
end
fprintf('Коэффициенты (от младшей степени) с весами:\n');
disp(coeff_weighted');

%% 5. С учётом весов: градиентный спуск (вместо fminsearch)
fprintf('\nПолином с весами через градиентный спуск\n');
% Начальное приближение (коэффициенты из МНК без весов)
coeff_init = coeff_polyfit;
learning_rate = 0.0001;
max_iter = 10000;
tol = 1e-8;
coeff_gd = coeff_init;
for iter = 1:max_iter
    % Вычисление градиента
    grad = zeros(m+1, 1);
    for j = 0:m
        grad_j = 0;
        for i = 1:n
            % Вычисление значения полинома
            poly_val = 0;
            for k = 0:m
                poly_val = poly_val + coeff_gd(k+1) * x(i)^k;
            end
            grad_j = grad_j + 2 * p(i) * (poly_val - y(i)) * x(i)^j;
        end
        grad(j+1) = grad_j;
    end
    % Обновление коэффициентов
    coeff_new = coeff_gd - learning_rate * grad;
    % Проверка сходимости
    if norm(coeff_new - coeff_gd) < tol
        coeff_gd = coeff_new;
        break;
    end
    coeff_gd = coeff_new;
end
fprintf('Коэффициенты (от младшей степени) после градиентного спуска:\n');
disp(coeff_gd');

%% 6. Оценка точности аппроксимации
fprintf('\nОценка точности\n');
% Вычисление предсказанных значений
y_pred_vand = zeros(n, 1);
y_pred_polyfit = zeros(n, 1);
y_pred_weighted = zeros(n, 1);
y_pred_gd = zeros(n, 1);
for i = 1:n
    for j = 0:m
        y_pred_vand(i) = y_pred_vand(i) + coeff_vand(j+1) * x(i)^j;
        y_pred_polyfit(i) = y_pred_polyfit(i) + coeff_polyfit(j+1) * x(i)^j;
        y_pred_weighted(i) = y_pred_weighted(i) + coeff_weighted(j+1) * x(i)^j;
        y_pred_gd(i) = y_pred_gd(i) + coeff_gd(j+1) * x(i)^j;
    end
end

% Взвешенная RMSE
RMSE_vand = sqrt(mean(p .* (y - y_pred_vand).^2));
RMSE_polyfit = sqrt(mean(p .* (y - y_pred_polyfit).^2));
RMSE_weighted = sqrt(mean(p .* (y - y_pred_weighted).^2));
RMSE_gd = sqrt(mean(p .* (y - y_pred_gd).^2));
fprintf('Взвешенная RMSE (Вандермонд): %.4f\n', RMSE_vand);
fprintf('Взвешенная RMSE (МНК без весов): %.4f\n', RMSE_polyfit);
fprintf('Взвешенная RMSE (МНК с весами): %.4f\n', RMSE_weighted);
fprintf('Взвешенная RMSE (градиентный спуск): %.4f\n', RMSE_gd);

%% 7. Построение одного графика со звёздочками и легендой
figure('Name', 'Аппроксимация полиномами');
hold on;
xx = linspace(min(x), max(x), 200);
yy_vand = zeros(size(xx));
yy_polyfit = zeros(size(xx));
yy_weighted = zeros(size(xx));
yy_gd = zeros(size(xx));
for ii = 1:length(xx)
    for j = 0:m
        yy_vand(ii) = yy_vand(ii) + coeff_vand(j+1) * xx(ii)^j;
        yy_polyfit(ii) = yy_polyfit(ii) + coeff_polyfit(j+1) * xx(ii)^j;
        yy_weighted(ii) = yy_weighted(ii) + coeff_weighted(j+1) * xx(ii)^j;
        yy_gd(ii) = yy_gd(ii) + coeff_gd(j+1) * xx(ii)^j;
    end
end
plot(xx, yy_vand, 'b-', 'LineWidth', 1.5);
plot(xx, yy_polyfit, 'g--', 'LineWidth', 1.5);
plot(xx, yy_weighted, 'r-.', 'LineWidth', 1.5);
plot(xx, yy_gd, 'm:', 'LineWidth', 1.5);
plot(x, y, 'k*', 'MarkerSize', 10, 'LineWidth', 1.5);
xlabel('x');
ylabel('y');
title('Аппроксимация полиномами');
legend('Вандермонд', 'МНК без весов', 'МНК с весами', 'Град. спуск (веса)', 'Узлы', 'Location', 'best');
grid on;
hold off;

%% 8. Не полином, а другая функция с весами через градиентный спуск
fprintf('\nНеполиномиальная аппроксимация с весами (градиентный спуск)\n');
% Экспоненциальная модель y = a*exp(b*x) + c
% Начальные приближения
a = 1; b = 0.5; c = 15;
learning_rate_exp = 0.0001;
max_iter_exp = 10000;
tol_exp = 1e-8;
for iter = 1:max_iter_exp
    % Вычисление градиентов
    grad_a = 0; grad_b = 0; grad_c = 0;
    for i = 1:n
        model_val = a * exp(b * x(i)) + c;
        residual = model_val - y(i);
        grad_a = grad_a + 2 * p(i) * residual * exp(b * x(i));
        grad_b = grad_b + 2 * p(i) * residual * a * x(i) * exp(b * x(i));
        grad_c = grad_c + 2 * p(i) * residual * 1;
    end
    % Обновление параметров
    a_new = a - learning_rate_exp * grad_a;
    b_new = b - learning_rate_exp * grad_b;
    c_new = c - learning_rate_exp * grad_c;
    % Проверка сходимости
    if norm([a_new - a, b_new - b, c_new - c]) < tol_exp
        a = a_new; b = b_new; c = c_new;
        break;
    end
    a = a_new; b = b_new; c = c_new;
end
fprintf('Коэффициенты модели a*exp(b*x)+c: a=%.4f, b=%.4f, c=%.4f\n', a, b, c);
% Оценка RMSE
y_pred_nonpoly = zeros(n, 1);
for i = 1:n
    y_pred_nonpoly(i) = a * exp(b * x(i)) + c;
end
RMSE_nonpoly = sqrt(mean(p .* (y - y_pred_nonpoly).^2));
fprintf('Взвешенная RMSE: %.4f\n', RMSE_nonpoly);

% График с неполиномиальной моделью
figure('Name', 'Неполиномиальная аппроксимация');
hold on;
yy_nonpoly = a * exp(b * xx) + c;
plot(xx, yy_nonpoly, 'c-', 'LineWidth', 2);
plot(x, y, 'k*', 'MarkerSize', 10);
xlabel('x'); ylabel('y');
title('Аппроксимация: a*exp(b*x)+c с весами');
legend('Модель', 'Узлы', 'Location', 'best');
grid on;
hold off;

%% 9. Полином Чебышева с весами через градиентный спуск
fprintf('\nПолином Чебышева с весами (градиентный спуск)\n');
% Приведение к отрезку [-1, 1]
x_min = min(x);
x_max = max(x);
t = zeros(n, 1);
for i = 1:n
    t(i) = 2 * (x(i) - x_min) / (x_max - x_min) - 1;
end
% Построение матрицы базиса Чебышева
T_mat = zeros(n, m+1);
for i = 1:n
    for k = 0:m
        if k == 0
            T_mat(i, k+1) = 1;
        elseif k == 1
            T_mat(i, k+1) = t(i);
        else
            T_prev2 = 1;
            T_prev1 = t(i);
            T_curr = 0;
            for deg = 2:k
                T_curr = 2 * t(i) * T_prev1 - T_prev2;
                T_prev2 = T_prev1;
                T_prev1 = T_curr;
            end
            T_mat(i, k+1) = T_curr;
        end
    end
end
% Решение взвешенной системы методом градиентного спуска
coeff_cheb = zeros(m+1, 1);
learning_rate_cheb = 0.001;
max_iter_cheb = 10000;
tol_cheb = 1e-8;
for iter = 1:max_iter_cheb
    % Вычисление градиента
    grad_cheb = zeros(m+1, 1);
    for k = 0:m
        grad_k = 0;
        for i = 1:n
            % Вычисление значения полинома Чебышева
            cheb_val = 0;
            for j = 0:m
                cheb_val = cheb_val + coeff_cheb(j+1) * T_mat(i, j+1);
            end
            grad_k = grad_k + 2 * p(i) * (cheb_val - y(i)) * T_mat(i, k+1);
        end
        grad_cheb(k+1) = grad_k;
    end
    % Обновление коэффициентов
    coeff_cheb_new = coeff_cheb - learning_rate_cheb * grad_cheb;
    % Проверка сходимости
    if norm(coeff_cheb_new - coeff_cheb) < tol_cheb
        coeff_cheb = coeff_cheb_new;
        break;
    end
    coeff_cheb = coeff_cheb_new;
end
fprintf('Коэффициенты разложения по Чебышёву (от T0 до T%d):\n', m);
disp(coeff_cheb');

% Оценка RMSE для полинома Чебышева
y_pred_cheb = zeros(n, 1);
for i = 1:n
    for j = 0:m
        y_pred_cheb(i) = y_pred_cheb(i) + coeff_cheb(j+1) * T_mat(i, j+1);
    end
end
RMSE_cheb = sqrt(mean(p .* (y - y_pred_cheb).^2));
fprintf('Взвешенная RMSE (Чебышёв): %.4f\n', RMSE_cheb);

% Вычисление значений для графика полинома Чебышева
tt_xx = zeros(size(xx));
yy_cheb = zeros(size(xx));
for ii = 1:length(xx)
    tt_xx(ii) = 2 * (xx(ii) - x_min) / (x_max - x_min) - 1;
    % Вычисление базиса Чебышева для текущей точки
    T_xx = zeros(1, m+1);
    for k = 0:m
        if k == 0
            T_xx(k+1) = 1;
        elseif k == 1
            T_xx(k+1) = tt_xx(ii);
        else
            T_prev2 = 1;
            T_prev1 = tt_xx(ii);
            T_curr = 0;
            for deg = 2:k
                T_curr = 2 * tt_xx(ii) * T_prev1 - T_prev2;
                T_prev2 = T_prev1;
                T_prev1 = T_curr;
            end
            T_xx(k+1) = T_curr;
        end
    end
    % Вычисление значения полинома
    for j = 0:m
        yy_cheb(ii) = yy_cheb(ii) + coeff_cheb(j+1) * T_xx(j+1);
    end
end

% График полинома Чебышёва
figure('Name', 'Полином Чебышёва с весами');
hold on;
plot(xx, yy_cheb, 'color', [0.5 0.2 0.8], 'LineWidth', 2);
plot(x, y, 'k*', 'MarkerSize', 10);
xlabel('x'); ylabel('y');
title('Полином Чебышёва (взвешенная аппроксимация)');
legend('Чебышёв', 'Узлы', 'Location', 'best');
grid on;
hold off;
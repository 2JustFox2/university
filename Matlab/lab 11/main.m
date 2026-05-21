clc; clear; close all;

V = 4;                           % объем емкости
c_sum = 0.35 + 0.55;             % суммарный коэффициент для дна и крышки

a = 0.1;
b = 20;
eps_val = 1e-4;                  % точность остановки итерационных процессов
max_iter = 1000;

fprintf('Оптимизация размеров цилиндрической емкости (V = %g м3)\n\n', V);

%% Общие функции для задачи 1
F = @(d) (c_sum * pi * d.^2) / 4 + (4 * V) ./ d;
dF = @(d) (c_sum * pi * d) / 2 - (4 * V) ./ d.^2;
d2F = @(d) (c_sum * pi) / 2 + (8 * V) ./ d.^3;
h_from_d = @(d) (4 * V) ./ (pi * d.^2);

%% Задача 1: минимизация площади поверхности
fprintf('Задача 1: Минимизация площади поверхности\n\n');

S = @(d) (pi * d.^2) / 2 + (4 * V) ./ d;
dS = @(d) pi * d - (4 * V) ./ d.^2;
d2S = @(d) pi + (8 * V) ./ d.^3;

%% Метод золотого сечения для площади поверхности
fprintf('Метод золотого сечения:\n');
tau = (sqrt(5) - 1) / 2;
a_S = a;
b_S = b;
x1 = b_S - tau * (b_S - a_S);
x2 = a_S + tau * (b_S - a_S);
f1 = S(x1);
f2 = S(x2);
history_S_gold = [x1, f1; x2, f2];
iter_S_gold = 0;

while (b_S - a_S) > eps_val
    iter_S_gold = iter_S_gold + 1;
    if f1 < f2
        b_S = x2;
        x2 = x1;
        f2 = f1;
        x1 = b_S - tau * (b_S - a_S);
        f1 = S(x1);
        history_S_gold = [history_S_gold; x1, f1];
    else
        a_S = x1;
        x1 = x2;
        f1 = f2;
        x2 = a_S + tau * (b_S - a_S);
        f2 = S(x2);
        history_S_gold = [history_S_gold; x2, f2];
    end
end

d_S_gold = (a_S + b_S) / 2;
S_gold = S(d_S_gold);
history_S_gold = [history_S_gold; d_S_gold, S_gold];
h_S_gold = h_from_d(d_S_gold);

fprintf('  диаметр d = %.4f м, высота h = %.4f м, площадь S = %.4f м^2, итераций: %d\n\n', ...
    d_S_gold, h_S_gold, S_gold, iter_S_gold);

%% Метод парабол 2 для площади поверхности
fprintf('Метод парабол 2:\n');
x_S_par = (a + b) / 2;
h_S_step = (b - a) / 20;
S_par_current = S(x_S_par);
history_S_par = [x_S_par, S_par_current];
iter_S_par = 0;

for iter_S_par = 1:max_iter
    f_plus = S(x_S_par + h_S_step);
    f_minus = S(x_S_par - h_S_step);
    f_center = S_par_current;

    denom = f_plus - 2 * f_center + f_minus;
    if denom <= 1e-15
        h_S_step = h_S_step * 2;
        continue;
    end

    x_new = x_S_par - (h_S_step / 2) * (f_plus - f_minus) / denom;

    max_step = 5 * h_S_step;
    if abs(x_new - x_S_par) > max_step
        if x_new > x_S_par
            x_new = x_S_par + max_step;
        else
            x_new = x_S_par - max_step;
        end
    end

    if x_new < 1e-6
        x_new = x_S_par / 2;
    end

    S_new = S(x_new);
    history_S_par = [history_S_par; x_new, S_new];

    if S_new >= S_par_current
        tau_step = 1 / 2;
        x_new = x_S_par + tau_step * (x_new - x_S_par);
        if x_new < 1e-6
            x_new = x_S_par / 2;
        end
        S_new = S(x_new);
        history_S_par = [history_S_par; x_new, S_new];

        if S_new >= S_par_current
            tau_step = 1 / 4;
            x_new = x_S_par + tau_step * (x_new - x_S_par);
            if x_new < 1e-6
                x_new = x_S_par / 2;
            end
            S_new = S(x_new);
            history_S_par = [history_S_par; x_new, S_new];
        end
    end

    delta_x = abs(x_new - x_S_par);
    if delta_x > eps_val && delta_x < h_S_step
        h_S_step = delta_x / 3;
    end

    if abs(x_new - x_S_par) < eps_val
        x_S_par = x_new;
        S_par_current = S_new;
        break;
    end

    x_S_par = x_new;
    S_par_current = S_new;
end

d_S_par = x_S_par;
S_par = S_par_current;
h_S_par = h_from_d(d_S_par);

fprintf('  диаметр d = %.4f м, высота h = %.4f м, площадь S = %.4f м^2, итераций: %d\n\n', ...
    d_S_par, h_S_par, S_par, iter_S_par);

%% Метод Ньютона для площади поверхности
fprintf('Метод Ньютона:\n');
x_S_newt = (a + b) / 2;
S_newt_current = S(x_S_newt);
history_S_newt = [x_S_newt, S_newt_current];
iter_S_newt = 0;

for iter_S_newt = 1:max_iter
    dx = dS(x_S_newt) / d2S(x_S_newt);
    x_next = x_S_newt - dx;
    S_next = S(x_next);
    history_S_newt = [history_S_newt; x_next, S_next];

    if abs(dS(x_next)) < eps_val
        x_S_newt = x_next;
        S_newt_current = S_next;
        break;
    end

    x_S_newt = x_next;
    S_newt_current = S_next;
end

d_S_newt = x_S_newt;
S_newt = S_newt_current;
h_S_newt = h_from_d(d_S_newt);

fprintf('  диаметр d = %.4f м, высота h = %.4f м, площадь S = %.4f м^2, итераций: %d\n\n', ...
    d_S_newt, h_S_newt, S_newt, iter_S_newt);

%% Задача 0: минимизация теплопотерь
fprintf('Задача 0: Минимизация теплопотерь\n\n');

fprintf('Метод золотого сечения:\n');
a_F = a;
b_F = b;
x1 = b_F - tau * (b_F - a_F);
x2 = a_F + tau * (b_F - a_F);
f1 = F(x1);
f2 = F(x2);
history_F_gold = [x1, f1; x2, f2];
iter_F_gold = 0;

while (b_F - a_F) > eps_val
    iter_F_gold = iter_F_gold + 1;
    if f1 < f2
        b_F = x2;
        x2 = x1;
        f2 = f1;
        x1 = b_F - tau * (b_F - a_F);
        f1 = F(x1);
        history_F_gold = [history_F_gold; x1, f1];
    else
        a_F = x1;
        x1 = x2;
        f1 = f2;
        x2 = a_F + tau * (b_F - a_F);
        f2 = F(x2);
        history_F_gold = [history_F_gold; x2, f2];
    end
end

d_gold = (a_F + b_F) / 2;
F_gold = F(d_gold);
history_gold = [history_F_gold; d_gold, F_gold];
h_gold = h_from_d(d_gold);

fprintf('  диаметр d = %.4f м, высота h = %.4f м, F = %.4f, итераций: %d\n\n', ...
    d_gold, h_gold, F_gold, iter_F_gold);

%% Графики задачи 1

figure;
d_vals_S = linspace(a, b, 500);
plot(d_vals_S, S(d_vals_S), 'b-', 'LineWidth', 1.5);
hold on; grid on;
plot(history_S_gold(:,1), history_S_gold(:,2), 'r.', 'MarkerSize', 12);
plot(d_S_gold, S_gold, 'k*', 'MarkerSize', 12, 'LineWidth', 1.5);
xlabel('Диаметр d, м');
ylabel('Площадь поверхности S(d), м^2');
title('Задача 1: Метод золотого сечения');
legend('S(d)', 'итерации', 'минимум', 'Location', 'northeast');
hold off;

figure;
plot(d_vals_S, S(d_vals_S), 'b-', 'LineWidth', 1.5);
hold on; grid on;
plot(history_S_par(:,1), history_S_par(:,2), 'r.', 'MarkerSize', 12);
plot(d_S_par, S_par, 'k*', 'MarkerSize', 12, 'LineWidth', 1.5);
xlabel('Диаметр d, м');
ylabel('Площадь поверхности S(d), м^2');
title('Задача 1: Метод парабол 2');
legend('S(d)', 'итерации', 'минимум', 'Location', 'northeast');
hold off;

figure;
plot(d_vals_S, S(d_vals_S), 'b-', 'LineWidth', 1.5);
hold on; grid on;
plot(history_S_newt(:,1), history_S_newt(:,2), 'r.', 'MarkerSize', 12);
plot(d_S_newt, S_newt, 'k*', 'MarkerSize', 12, 'LineWidth', 1.5);
xlabel('Диаметр d, м');
ylabel('Площадь поверхности S(d), м^2');
title('Задача 1: Метод Ньютона');
legend('S(d)', 'итерации', 'минимум', 'Location', 'northeast');
hold off;

%% Сравнение площади и теплопотерь
figure;
d_plot = linspace(a, b, 500);
plot(d_plot, S(d_plot), 'b-', 'LineWidth', 1.5);
hold on; grid on;
plot(d_plot, F(d_plot), 'r--', 'LineWidth', 1.5);
plot(d_S_gold, S_gold, 'b*', 'MarkerSize', 14, 'LineWidth', 1.5);
plot(d_gold, F_gold, 'r*', 'MarkerSize', 14, 'LineWidth', 1.5);
text(d_S_gold + 0.5, S_gold + 5, ['S_{min} = ', num2str(round(S_gold,1))], 'Color', 'b', 'FontSize', 10);
text(d_gold + 0.5, F_gold - 5, ['F_{min} = ', num2str(round(F_gold,1))], 'Color', 'r', 'FontSize', 10);
xlabel('Диаметр d, м');
ylabel('Значение функции');
title('Сравнение: площадь поверхности vs тепловые потери');
legend('S(d) - площадь', 'F(d) - теплопотери', 'Location', 'northeast');
hold off;

%% Решение стандартными функциями MATLAB для задачи 1
fprintf('\nРешение стандартными функциями MATLAB для задачи 1\n\n');

[d_S_fminbnd, S_min_fminbnd, exitflag_S, output_S] = fminbnd(S, a, b);
h_S_fminbnd = h_from_d(d_S_fminbnd);
fprintf('Задача 1 (площадь поверхности):\n');
fprintf('  d = %.4f м, h = %.4f м, S = %.4f м^2\n', d_S_fminbnd, h_S_fminbnd, S_min_fminbnd);
fprintf('  exitflag = %d, iterations = %d, funcCount = %d\n', exitflag_S, output_S.iterations, output_S.funcCount);
fprintf('  algorithm = %s\n\n', output_S.algorithm);

%% Задача 2: поиск максимума и минимума функции двух переменных
fprintf('Задача 2: Метод градиентного спуска\n');
fprintf('Функция: f(x) = exp(z1/1000) + exp(z2/1000) + 0.15*exp(z1) + 0.15*exp(z2)\n');
fprintf('z1 = -((x1 + 4)^2 + (x2 + 4)^2)^2\n');
fprintf('z2 = -((x1 - 4)^2 + (x2 - 4)^2)^2\n');
fprintf('Диапазон поиска по каждой координате: [-12, 12], точность 1e-4\n\n');

lb = [-12; -12];
ub = [12; 12];
x0_max = [3; 3];
x0_min = [0; 0];

r1 = @(x) (x(1) + 4).^2 + (x(2) + 4).^2;
r2 = @(x) (x(1) - 4).^2 + (x(2) - 4).^2;
z1 = @(x) -(r1(x)).^2;
z2 = @(x) -(r2(x)).^2;

f_obj = @(x) exp(z1(x) / 1000) + exp(z2(x) / 1000) + 0.15 * exp(z1(x)) + 0.15 * exp(z2(x));

dz1_dx1 = @(x) -4 * (x(1) + 4) * r1(x);
dz1_dx2 = @(x) -4 * (x(2) + 4) * r1(x);
dz2_dx1 = @(x) -4 * (x(1) - 4) * r2(x);
dz2_dx2 = @(x) -4 * (x(2) - 4) * r2(x);
df_dz = @(z) exp(z / 1000) / 1000 + 0.15 * exp(z);
grad_f_obj = @(x) [ ...
    df_dz(z1(x)) * dz1_dx1(x) + df_dz(z2(x)) * dz2_dx1(x); ...
    df_dz(z1(x)) * dz1_dx2(x) + df_dz(z2(x)) * dz2_dx2(x)];

proj = @(x) min(max(x, lb), ub);

fprintf('Начальная точка для максимума: x0 = [%.2f; %.2f]\n', x0_max(1), x0_max(2));
fprintf('Значение функции: f(x0) = %.6f\n', f_obj(x0_max));
fprintf('Норма градиента: %.6f\n\n', norm(grad_f_obj(x0_max)));

[X2, Y2] = meshgrid(-12:0.05:12, -12:0.05:12);
Z2 = zeros(size(X2));
for i = 1:size(X2,1)
    for j = 1:size(X2,2)
        Z2(i,j) = f_obj([X2(i,j); Y2(i,j)]);
    end
end

%% Максимум методом градиентного спуска через минимизацию -f
fprintf('Максимум функции методом градиентного спуска:\n');
obj_max = @(x) -f_obj(x);
grad_obj_max = @(x) -grad_f_obj(x);

x = x0_max(:);
history_max = x';
grad_norm_history_max = [];

for k = 1:max_iter
    g = grad_obj_max(x);
    grad_norm = norm(g);
    grad_norm_history_max = [grad_norm_history_max; grad_norm];

    if grad_norm < eps_val
        fprintf('  Остановка на итерации %d: норма градиента < 1e-4 (%.2e)\n', k, grad_norm);
        break;
    end

    t = 0.1;
    obj_old = obj_max(x);

    while true
        x_new = proj(x - t * g);
        obj_new = obj_max(x_new);
        if obj_new < obj_old
            break;
        end
        t = t / 2;
        if t < 1e-15
            x_new = x;
            obj_new = obj_old;
            break;
        end
    end

    history_max = [history_max; x_new'];
    delta_x = norm(x_new - x);
    delta_f = abs(f_obj(x_new) - f_obj(x));

    if (delta_x < eps_val) && (delta_f < eps_val)
        fprintf('  Остановка на итерации %d: ||dx|| < 1e-4 и |df| < 1e-4 (%.2e, %.2e)\n', k, delta_x, delta_f);
        x = x_new;
        break;
    end

    x = x_new;
end

x_max = x;
f_max = f_obj(x_max);
iter_max = k;

fprintf('  Найден максимум:\n');
fprintf('    x1 = %.6f\n', x_max(1));
fprintf('    x2 = %.6f\n', x_max(2));
fprintf('    f(x) = %.6f\n', f_max);
fprintf('    итераций = %d\n', iter_max);
fprintf('    норма градиента в конце = %.2e\n\n', grad_norm_history_max(end));

figure('Position', [100, 100, 1200, 500]);
subplot(1,2,1);
surf(X2, Y2, Z2, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
hold on;
plot3(history_max(1,1), history_max(1,2), f_obj(history_max(1,:)'), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot3(history_max(end,1), history_max(end,2), f_obj(history_max(end,:)'), 'r*', 'MarkerSize', 12, 'LineWidth', 2);
plot3(history_max(:,1), history_max(:,2), arrayfun(@(i) f_obj(history_max(i,:)'), 1:size(history_max,1))', 'k-', 'LineWidth', 1.5);
plot3(history_max(:,1), history_max(:,2), arrayfun(@(i) f_obj(history_max(i,:)'), 1:size(history_max,1))', 'b.', 'MarkerSize', 10);
xlabel('x_1'); ylabel('x_2'); zlabel('f(x)');
title('Максимум: поверхность и траектория');
legend('Поверхность', 'Начальная точка', 'Максимум', 'Траектория', 'Итерации');
grid on;
view(45, 30);
hold off;

subplot(1,2,2);
contour(X2, Y2, Z2, 20, 'LineWidth', 0.5);
hold on;
plot(history_max(:,1), history_max(:,2), 'k-', 'LineWidth', 1.5);
plot(history_max(:,1), history_max(:,2), 'b.', 'MarkerSize', 10);
plot(history_max(1,1), history_max(1,2), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot(history_max(end,1), history_max(end,2), 'r*', 'MarkerSize', 12, 'LineWidth', 2);
xlabel('x_1'); ylabel('x_2');
title('Максимум: линии уровня');
legend('Линии уровня', 'Траектория', 'Итерации', 'Начальная точка', 'Максимум');
grid on;
axis equal;
hold off;

figure;
semilogy(1:length(grad_norm_history_max), grad_norm_history_max, 'b-', 'LineWidth', 1.5);
hold on;
plot([1, length(grad_norm_history_max)], [eps_val eps_val], 'r--', 'LineWidth', 1.5);
xlabel('Номер итерации'); ylabel('||grad g(x)||');
title('Сходимость метода градиентного спуска для максимума');
legend('Норма антиградиента', '\epsilon = 1e-4', 'Location', 'northeast');
grid on;
hold off;

figure;
traj_max = zeros(size(history_max,1), 1);
for i = 1:size(history_max,1)
    traj_max(i) = f_obj(history_max(i,:)');
end
plot(1:length(traj_max), traj_max, 'b-', 'LineWidth', 1.5);
xlabel('Номер итерации'); ylabel('f(x)');
title('Изменение функции на траектории максимума');
grid on;

%% Минимум методом градиентного спуска
fprintf('\nМинимум функции методом градиентного спуска:\n');

x = x0_min(:);
history_min = x';
grad_norm_history_min = [];

for k = 1:max_iter
    g = grad_f_obj(x);
    grad_norm = norm(g);
    grad_norm_history_min = [grad_norm_history_min; grad_norm];

    if grad_norm < eps_val
        fprintf('  Остановка на итерации %d: норма градиента < 1e-4 (%.2e)\n', k, grad_norm);
        break;
    end

    t = 0.1;
    obj_old = f_obj(x);

    while true
        x_new = proj(x - t * g);
        obj_new = f_obj(x_new);
        if obj_new < obj_old
            break;
        end
        t = t / 2;
        if t < 1e-15
            x_new = x;
            obj_new = obj_old;
            break;
        end
    end

    history_min = [history_min; x_new'];
    delta_x = norm(x_new - x);
    delta_f = abs(f_obj(x_new) - f_obj(x));

    if (delta_x < eps_val) && (delta_f < eps_val)
        fprintf('  Остановка на итерации %d: ||dx|| < 1e-4 и |df| < 1e-4 (%.2e, %.2e)\n', k, delta_x, delta_f);
        x = x_new;
        break;
    end

    x = x_new;
end

x_min = x;
f_min = f_obj(x_min);
iter_min = k;

fprintf('  Найден минимум:\n');
fprintf('    x1 = %.6f\n', x_min(1));
fprintf('    x2 = %.6f\n', x_min(2));
fprintf('    f(x) = %.6f\n', f_min);
fprintf('    итераций = %d\n', iter_min);
fprintf('    норма градиента в конце = %.2e\n\n', grad_norm_history_min(end));

figure('Position', [100, 100, 1200, 500]);
subplot(1,2,1);
surf(X2, Y2, Z2, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
hold on;
plot3(history_min(1,1), history_min(1,2), f_obj(history_min(1,:)'), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot3(history_min(end,1), history_min(end,2), f_obj(history_min(end,:)'), 'r*', 'MarkerSize', 12, 'LineWidth', 2);
plot3(history_min(:,1), history_min(:,2), arrayfun(@(i) f_obj(history_min(i,:)'), 1:size(history_min,1))', 'k-', 'LineWidth', 1.5);
plot3(history_min(:,1), history_min(:,2), arrayfun(@(i) f_obj(history_min(i,:)'), 1:size(history_min,1))', 'b.', 'MarkerSize', 10);
xlabel('x_1'); ylabel('x_2'); zlabel('f(x)');
title('Минимум: поверхность и траектория');
legend('Поверхность', 'Начальная точка', 'Минимум', 'Траектория', 'Итерации');
grid on;
view(45, 30);
hold off;

subplot(1,2,2);
contour(X2, Y2, Z2, 20, 'LineWidth', 0.5);
hold on;
plot(history_min(:,1), history_min(:,2), 'k-', 'LineWidth', 1.5);
plot(history_min(:,1), history_min(:,2), 'b.', 'MarkerSize', 10);
plot(history_min(1,1), history_min(1,2), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot(history_min(end,1), history_min(end,2), 'r*', 'MarkerSize', 12, 'LineWidth', 2);
xlabel('x_1'); ylabel('x_2');
title('Минимум: линии уровня');
legend('Линии уровня', 'Траектория', 'Итерации', 'Начальная точка', 'Минимум');
grid on;
axis equal;
hold off;

figure;
semilogy(1:length(grad_norm_history_min), grad_norm_history_min, 'b-', 'LineWidth', 1.5);
hold on;
plot([1, length(grad_norm_history_min)], [eps_val eps_val], 'r--', 'LineWidth', 1.5);
xlabel('Номер итерации'); ylabel('||grad f(x)||');
title('Сходимость метода градиентного спуска для минимума');
legend('Норма градиента', '\epsilon = 1e-4', 'Location', 'northeast');
grid on;
hold off;

figure;
traj_min = zeros(size(history_min,1), 1);
for i = 1:size(history_min,1)
    traj_min(i) = f_obj(history_min(i,:)');
end
plot(1:length(traj_min), traj_min, 'b-', 'LineWidth', 1.5);
xlabel('Номер итерации'); ylabel('f(x)');
title('Изменение функции на траектории минимума');
grid on;

%% Стандартные функции MATLAB для задачи 2
fprintf('\nРешение стандартными функциями MATLAB для задачи 2\n\n');

options = optimset('Display', 'off');

[x_fmincon_max, g_fmincon_max, exitflag_max, output_max] = fmincon(@(x) -f_obj(x), x0_max, [], [], [], [], lb, ub, [], options);
f_fmincon_max = -g_fmincon_max;
fprintf('Максимум через fmincon:\n');
fprintf('  x1 = %.6f, x2 = %.6f, f(x) = %.6f\n', x_fmincon_max(1), x_fmincon_max(2), f_fmincon_max);
fprintf('  exitflag = %d, iterations = %d, funcCount = %d\n', exitflag_max, output_max.iterations, output_max.funcCount);
fprintf('  algorithm = %s\n\n', output_max.algorithm);

[x_fmincon_min, f_fmincon_min, exitflag_min, output_min] = fmincon(@(x) f_obj(x), x0_min, [], [], [], [], lb, ub, [], options);
fprintf('Минимум через fmincon:\n');
fprintf('  x1 = %.6f, x2 = %.6f, f(x) = %.6f\n', x_fmincon_min(1), x_fmincon_min(2), f_fmincon_min);
fprintf('  exitflag = %d, iterations = %d, funcCount = %d\n', exitflag_min, output_min.iterations, output_min.funcCount);
fprintf('  algorithm = %s\n\n', output_min.algorithm);

fprintf('Сравнение результатов:\n');
fprintf('  Максимум: градиентный спуск f = %.6f, fmincon f = %.6f\n', f_max, f_fmincon_max);
fprintf('  Минимум:  градиентный спуск f = %.6f, fmincon f = %.6f\n', f_min, f_fmincon_min);

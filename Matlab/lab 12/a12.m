clear;
clc;
close all;

%% 1. Проверка, является ли функция решением ДУ
fprintf('========== ЗАДАНИЕ 1 ==========\n');
syms y(x) c
% заданное ДУ
ode = diff(y,x) - y == exp(2*x);
% предложенное решение
y_sol = c*exp(x) + exp(2*x);
% подставляем c=8
c_val = 8;
y_sol_val = subs(y_sol, c, c_val);

% проверка подстановкой
left = diff(y_sol_val, x) - y_sol_val;
right = exp(2*x);
is_solution = simplify(left - right);

fprintf('Функция: y = %s\n', char(y_sol_val));
fprintf('Подстановка в ДУ: %s\n', char(is_solution));
fprintf('Результат: %s (0 - значит является решением)\n', char(is_solution));
fprintf('\n');

%% 2. Решение задачи Коши y' = 1 + x*sin(y), y(pi) = 2*pi

fprintf('========== ЗАДАНИЕ 2 ==========\n');

% правая часть уравнения
f = @(x,y) 1 + x.*sin(y);

% начальные условия
x0 = pi;
y0 = 2*pi;
xn = pi + 1;

%% Аналитическое решение (если существует - в данном случае его нет в явном виде)
% Для данной задачи аналитического решения в элементарных функциях нет,
% поэтому для сравнения будем использовать очень точное численное решение
% (ode45 с высокой точностью)

% эталонное решение (очень точное)
opts = odeset('RelTol', 1e-12, 'AbsTol', 1e-14);
[x_exact, y_exact] = ode45(f, [x0, xn], y0, opts);
y_exact_fn = @(xq) interp1(x_exact, y_exact, xq, 'pchip');

%% Метод Эйлера с шагом h=0.2
h1 = 0.2;
x_euler_02 = x0:h1:xn;
n1 = length(x_euler_02);
y_euler_02 = zeros(1, n1);
y_euler_02(1) = y0;

for i = 1:n1-1
    y_euler_02(i+1) = y_euler_02(i) + h1 * f(x_euler_02(i), y_euler_02(i));
end

%% Метод Эйлера с шагом h=0.05
h2 = 0.05;
x_euler_005 = x0:h2:xn;
n2 = length(x_euler_005);
y_euler_005 = zeros(1, n2);
y_euler_005(1) = y0;

for i = 1:n2-1
    y_euler_005(i+1) = y_euler_005(i) + h2 * f(x_euler_005(i), y_euler_005(i));
end

%% Метод Рунге-Кутта 4 порядка с шагом h=0.2
x_rk4_02 = x0:h1:xn;
n3 = length(x_rk4_02);
y_rk4_02 = zeros(1, n3);
y_rk4_02(1) = y0;

for i = 1:n3-1
    k1 = f(x_rk4_02(i), y_rk4_02(i));
    k2 = f(x_rk4_02(i) + h1/2, y_rk4_02(i) + h1*k1/2);
    k3 = f(x_rk4_02(i) + h1/2, y_rk4_02(i) + h1*k2/2);
    k4 = f(x_rk4_02(i) + h1, y_rk4_02(i) + h1*k3);
    y_rk4_02(i+1) = y_rk4_02(i) + h1*(k1 + 2*k2 + 2*k3 + k4)/6;
end

%% Метод Рунге-Кутта 4 порядка с шагом h=0.05
x_rk4_005 = x0:h2:xn;
n4 = length(x_rk4_005);
y_rk4_005 = zeros(1, n4);
y_rk4_005(1) = y0;

for i = 1:n4-1
    k1 = f(x_rk4_005(i), y_rk4_005(i));
    k2 = f(x_rk4_005(i) + h2/2, y_rk4_005(i) + h2*k1/2);
    k3 = f(x_rk4_005(i) + h2/2, y_rk4_005(i) + h2*k2/2);
    k4 = f(x_rk4_005(i) + h2, y_rk4_005(i) + h2*k3);
    y_rk4_005(i+1) = y_rk4_005(i) + h2*(k1 + 2*k2 + 2*k3 + k4)/6;
end

%% Вычисление погрешностей (сравнение с эталонным решением)
y_exact_02 = y_exact_fn(x_rk4_02);
y_exact_005 = y_exact_fn(x_rk4_005);

% абсолютная погрешность
err_euler_02 = abs(y_exact_02 - y_euler_02);
err_euler_005 = abs(y_exact_005 - y_euler_005);
err_rk4_02 = abs(y_exact_02 - y_rk4_02);
err_rk4_005 = abs(y_exact_005 - y_rk4_005);

% относительная погрешность
rel_err_euler_02 = err_euler_02 ./ abs(y_exact_02);
rel_err_euler_005 = err_euler_005 ./ abs(y_exact_005);
rel_err_rk4_02 = err_rk4_02 ./ abs(y_exact_02);
rel_err_rk4_005 = err_rk4_005 ./ abs(y_exact_005);

%% Оценка погрешности по правилу Рунге
% для метода Эйлера (порядок p=1)
p1 = 1;
% для метода Рунге-Кутта 4 порядка (порядок p=4)
p2 = 4;

% оценка по Рунге на общих узлах (каждый 4-й для h=0.05)
runge_euler = abs(y_euler_02 - y_euler_005(1:4:end)) / (2^p1 - 1);
runge_rk4 = abs(y_rk4_02 - y_rk4_005(1:4:end)) / (2^p2 - 1);

%% Вывод результатов
fprintf('\n========== ПОГРЕШНОСТИ ==========\n');
fprintf('В конце интервала x = %.4f:\n', xn);
fprintf('----------------------------------------\n');
fprintf('Метод Эйлера h=0.2   : абс.погр = %.2e\n', err_euler_02(end));
fprintf('Метод Эйлера h=0.05  : абс.погр = %.2e\n', err_euler_005(end));
fprintf('Метод РК4 h=0.2      : абс.погр = %.2e\n', err_rk4_02(end));
fprintf('Метод РК4 h=0.05     : абс.погр = %.2e\n', err_rk4_005(end));
fprintf('----------------------------------------\n');
fprintf('Метод Эйлера h=0.2   : отн.погр = %.2e\n', rel_err_euler_02(end));
fprintf('Метод Эйлера h=0.05  : отн.погр = %.2e\n', rel_err_euler_005(end));
fprintf('Метод РК4 h=0.2      : отн.погр = %.2e\n', rel_err_rk4_02(end));
fprintf('Метод РК4 h=0.05     : отн.погр = %.2e\n', rel_err_rk4_005(end));

fprintf('\n========== ОЦЕНКА ПОГРЕШНОСТИ ПО РУНГЕ ==========\n');
fprintf('Метод Эйлера (p=1):\n');
for i = 1:length(runge_euler)
    fprintf('  x=%.2f: %.2e\n', x_rk4_02(i), runge_euler(i));
end
fprintf('Метод Рунге-Кутта 4 (p=4):\n');
for i = 1:length(runge_rk4)
    fprintf('  x=%.2f: %.2e\n', x_rk4_02(i), runge_rk4(i));
end

%% Решение стандартными методами MATLAB
fprintf('\n========== РЕШЕНИЕ MATLAB ==========\n');
interval = [x0, xn];

% ode45 (Рунге-Кутта 4-5 порядка)
[x45, y45] = ode45(f, interval, y0);

% ode23 (Рунге-Кутта 2-3 порядка)
[x23, y23] = ode23(f, interval, y0);

% ode113 (метод Адамса)
[x113, y113] = ode113(f, interval, y0);

% ode15s (метод Гира для жестких систем)
[x15s, y15s] = ode15s(f, interval, y0);

% ode23s (метод Розенброка)
[x23s, y23s] = ode23s(f, interval, y0);

% ode23t (метод трапеций)
[x23t, y23t] = ode23t(f, interval, y0);

% ode23tb (метод TR-BDF2)
[x23tb, y23tb] = ode23tb(f, interval, y0);

fprintf('Решения получены методами: ode45, ode23, ode113, ode15s, ode23s, ode23t, ode23tb\n');

%% График 1: Сравнение всех решений
figure('Position', [100, 100, 1200, 800]);
hold on;

% численные методы с разными шагами
plot(x_euler_02, y_euler_02, 'r-o', 'LineWidth', 1.5, 'MarkerSize', 6);
plot(x_euler_005, y_euler_005, 'b--o', 'LineWidth', 1.5, 'MarkerSize', 4);
plot(x_rk4_02, y_rk4_02, 'k-*', 'LineWidth', 1.5, 'MarkerSize', 8);
plot(x_rk4_005, y_rk4_005, 'm-.', 'LineWidth', 1.5);

% эталонное решение (очень точное)
plot(x_exact, y_exact, 'g-', 'LineWidth', 2.5);

% стандартные методы MATLAB
plot(x45, y45, 'c-', 'LineWidth', 1.5);
plot(x23, y23, 'y-', 'LineWidth', 1.5);
plot(x113, y113, 'Color', [0.5 0.2 0.8], 'LineWidth', 1.5);
plot(x15s, y15s, 'Color', [0.2 0.6 0.2], 'LineWidth', 1.5);
plot(x23s, y23s, 'Color', [0.8 0.4 0.1], 'LineWidth', 1.5);
plot(x23t, y23t, 'Color', [0.1 0.7 0.7], 'LineWidth', 1.5);
plot(x23tb, y23tb, 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);

grid on;
xlabel('x', 'FontSize', 12);
ylabel('y', 'FontSize', 12);
title('Сравнение решений задачи Коши y'' = 1 + x·sin(y), y(?) = 2?', 'FontSize', 14);
legend('Эйлер h=0.2', 'Эйлер h=0.05', 'Рунге-Кутта 4 h=0.2', ...
       'Рунге-Кутта 4 h=0.05', 'Эталонное решение (точное)', ...
       'ode45', 'ode23', 'ode113', 'ode15s', 'ode23s', 'ode23t', 'ode23tb', ...
       'Location', 'best');
hold off;

%% График 2: Абсолютная погрешность
figure('Position', [100, 100, 1000, 600]);
hold on;

semilogy(x_euler_02, err_euler_02, 'r-o', 'LineWidth', 1.5, 'MarkerSize', 6);
semilogy(x_euler_005, err_euler_005, 'b--o', 'LineWidth', 1.5, 'MarkerSize', 4);
semilogy(x_rk4_02, err_rk4_02, 'k-*', 'LineWidth', 1.5, 'MarkerSize', 8);
semilogy(x_rk4_005, err_rk4_005, 'm-.', 'LineWidth', 1.5);

grid on;
xlabel('x', 'FontSize', 12);
ylabel('Абсолютная погрешность', 'FontSize', 12);
title('Поведение абсолютной погрешности (логарифмическая шкала)', 'FontSize', 14);
legend('Эйлер h=0.2', 'Эйлер h=0.05', 'Рунге-Кутта 4 h=0.2', ...
       'Рунге-Кутта 4 h=0.05', 'Location', 'best');
hold off;

%% График 3: Относительная погрешность
figure('Position', [100, 100, 1000, 600]);
hold on;

semilogy(x_euler_02, rel_err_euler_02, 'r-o', 'LineWidth', 1.5, 'MarkerSize', 6);
semilogy(x_euler_005, rel_err_euler_005, 'b--o', 'LineWidth', 1.5, 'MarkerSize', 4);
semilogy(x_rk4_02, rel_err_rk4_02, 'k-*', 'LineWidth', 1.5, 'MarkerSize', 8);
semilogy(x_rk4_005, rel_err_rk4_005, 'm-.', 'LineWidth', 1.5);

grid on;
xlabel('x', 'FontSize', 12);
ylabel('Относительная погрешность', 'FontSize', 12);
title('Поведение относительной погрешности (логарифмическая шкала)', 'FontSize', 14);
legend('Эйлер h=0.2', 'Эйлер h=0.05', 'Рунге-Кутта 4 h=0.2', ...
       'Рунге-Кутта 4 h=0.05', 'Location', 'best');
hold off;

%% График 4: Сравнение только методов Эйлера и Рунге-Кутта с эталоном
figure('Position', [100, 100, 800, 600]);
hold on;

plot(x_euler_02, y_euler_02, 'ro-', 'LineWidth', 1.5, 'MarkerSize', 8);
plot(x_euler_005, y_euler_005, 'bs--', 'LineWidth', 1.5, 'MarkerSize', 6);
plot(x_rk4_02, y_rk4_02, 'kd-', 'LineWidth', 1.5, 'MarkerSize', 8);
plot(x_rk4_005, y_rk4_005, 'm^-', 'LineWidth', 1.5, 'MarkerSize', 6);
plot(x_exact, y_exact, 'g-', 'LineWidth', 2.5);

grid on;
xlabel('x', 'FontSize', 12);
ylabel('y', 'FontSize', 12);
title('Сравнение методов Эйлера и Рунге-Кутта 4 порядка', 'FontSize', 14);
legend('Эйлер h=0.2', 'Эйлер h=0.05', 'РК4 h=0.2', 'РК4 h=0.05', ...
       'Эталонное решение', 'Location', 'best');
hold off;

%% Вывод итоговой информации
fprintf('\n========== ВЫВОДЫ ==========\n');
fprintf('1. Функция y = 8e^x + e^{2x} является решением ДУ y'' - y = e^{2x}\n');
fprintf('2. Для задачи Коши y'' = 1 + x·sin(y), y(?) = 2?:\n');
fprintf('   - Метод Рунге-Кутта 4 порядка значительно точнее метода Эйлера\n');
fprintf('   - Уменьшение шага в 4 раза (0.2 ? 0.05) существенно повышает точность\n');
fprintf('   - Погрешность метода Эйлера ~O(h), Рунге-Кутта ~O(h^4) - подтверждается правилом Рунге\n');
fprintf('   - Стандартные решатели MATLAB (ode45, ode23 и др.) дают высокую точность\n');
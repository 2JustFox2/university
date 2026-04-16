clear; clc; close all;

f = @(x) 9*exp(-4*x) - 5*x + 1;

%% 2. Локализация корня методом перебора
fprintf('Локализация корня\n');
x_range = 0:0.1:1;
f_vals = f(x_range);

% Поиск смены знака
roots_coarse = [];
for i = 1:length(x_range)-1
    if f_vals(i)*f_vals(i+1) < 0
        root_approx = (x_range(i) + x_range(i+1))/2;
        roots_coarse = [roots_coarse; root_approx];
        fprintf('Корень локализован в [%.1f, %.1f], приближение: %.4f\n', ...
            x_range(i), x_range(i+1), root_approx);
    end
end

if isempty(roots_coarse)
    error('Корень не найден! Измените диапазон поиска.');
end

% Выбираем первый найденный корень (должен быть один)
x0 = roots_coarse(1); 
fprintf('\nНачальное приближение: x0 = %.6f\n', x0);

%% 3. График функции
figure('Position', [100 100 1200 800]);
x_plot = linspace(0, 1, 1000);
y_plot = f(x_plot);
plot(x_plot, y_plot, 'b-', 'LineWidth', 2);
hold on;
plot(x_plot, zeros(size(x_plot)), 'k--', 'LineWidth', 1);
grid on;
xlabel('x');
ylabel('f(x)');
title('Решение уравнения 9e^{-4x} = 5x - 1');
legend('f(x) = 9e^{-4x} - 5x + 1', 'y = 0', 'Location', 'best');

%% 4. Точное решение через fzero
tol = 1e-10;
options_fzero = optimset('TolX', tol, 'Display', 'off');
x_exact = fzero(f, x0, options_fzero);
fprintf('\nЭталонное решение (fzero)\n');
fprintf('x* = %.10f, f(x*) = %.2e\n', x_exact, f(x_exact));

% Отмечаем точный корень на графике
plot(x_exact, 0, 'mp', 'MarkerSize', 15, 'MarkerFaceColor', 'm', ...
    'DisplayName', 'Точный корень (fzero)');

%% 5. Уточнение корня методами
max_iter = 100;
eps = 1e-8; % заданная точность

% Вторая производная для проверки сходимости
f2 = @(x) 144*exp(-4*x); % f''(x) = 144*exp(-4*x)

% 5.1 Метод простых итераций
% Приводим к виду x = phi(x): x = (9*exp(-4x) + 1)/5
phi = @(x) (9*exp(-4*x) + 1)/5;
phi_prime = @(x) -36*exp(-4*x)/5; % производная для проверки сходимости

% Проверка условия сходимости |phi'(x)| < 1 в окрестности корня
fprintf('\nМетод простых итераций\n');
phi_prime_x0 = abs(phi_prime(x0));
if phi_prime_x0 < 1
    fprintf('Условие сходимости выполнено |phi''(x0)| = %.3f < 1\n', phi_prime_x0);
    x_iter = x0;
    iter = 0;
    x_history = x_iter;
    while iter < max_iter
        x_new = phi(x_iter);
        x_history = [x_history, x_new];
        iter = iter + 1;
        if abs(x_new - x_iter) < eps
            break;
        end
        x_iter = x_new;
    end
    x_simple = x_new;
    iter_simple = iter;
    fprintf('Корень: %.10f, итераций: %d, f(x)=%.2e\n', x_simple, iter_simple, f(x_simple));
else
    fprintf('Метод простых итераций: условие сходимости не выполнено |phi''(x0)| = %.3f\n', phi_prime_x0);
    x_simple = NaN; iter_simple = NaN;
end

% 5.2 Метод хорд
fprintf('\nМетод хорд\n');
a = 0; b = 1;
fa = f(a); fb = f(b);
x_chord = a;
iter = 0;
x_history_chord = [];

% Проверка сходимости метода хорд по второй производной
if f2(a) * f2(b) > 0
    fprintf('Вторая производная не меняет знак на [%d, %d] - сходимость монотонная\n', a, b);
    if fa * f2(a) > 0
        fprintf('Неподвижным будет левый конец интервала (a = %d)\n', a);
    else
        fprintf('Неподвижным будет правый конец интервала (b = %d)\n', b);
    end
else
    fprintf('Вторая производная меняет знак на интервале - возможны осцилляции\n');
end

while iter < max_iter
    x_new = a - fa*(b-a)/(fb-fa);
    x_history_chord = [x_history_chord, x_new];
    iter = iter + 1;
    if abs(x_new - x_chord) < eps && iter > 1
        break;
    end
    f_new = f(x_new);
    if f_new*fa < 0
        b = x_new;
        fb = f_new;
    else
        a = x_new;
        fa = f_new;
    end
    x_chord = x_new;
end
x_chord_final = x_new;
iter_chord = iter;
fprintf('Корень: %.10f, итераций: %d, f(x)=%.2e\n', x_chord_final, iter_chord, f(x_chord_final));

% 5.3 Метод касательных (Ньютона)
df = @(x) -36*exp(-4*x) - 5;

fprintf('\nМетод касательных\n');
if abs(df(x0)) > eps
    % Проверка сходимости метода Ньютона по второй производной
    if f(x0) * f2(x0) > 0
        fprintf('Условие сходимости выполнено: f(x0)*f''''(x0) = %.3e > 0\n', f(x0)*f2(x0));
        fprintf('Метод Ньютона будет сходиться монотонно\n');
    else
        fprintf('Условие сходимости не выполнено: f(x0)*f''''(x0) = %.3e < 0\n', f(x0)*f2(x0));
        fprintf('Возможны осцилляции или расходимость\n');
    end
    
    x_newton = x0;
    iter = 0;
    x_history_newton = x_newton;
    while iter < max_iter
        x_next = x_newton - f(x_newton)/df(x_newton);
        x_history_newton = [x_history_newton, x_next];
        iter = iter + 1;
        if abs(x_next - x_newton) < eps
            break;
        end
        x_newton = x_next;
    end
    x_newton_final = x_next;
    iter_newton = iter;
    fprintf('Корень: %.10f, итераций: %d, f(x)=%.2e\n', x_newton_final, iter_newton, f(x_newton_final));
else
    fprintf('Метод Ньютона: производная близка к нулю.\n');
    x_newton_final = NaN; iter_newton = NaN;
end

% 5.4 Метод секущих
fprintf('\nМетод секущих\n');
x_sec0 = 0;
x_sec1 = 1;
iter = 0;
x_history_sec = [x_sec0, x_sec1];

% Проверка сходимости метода секущих через знак второй производной
if f2(x_sec0) * f2(x_sec1) > 0
    fprintf('Вторая производная не меняет знак между начальными точками - благоприятно для сходимости\n');
else
    fprintf('Вторая производная меняет знак - возможно замедление сходимости\n');
end

while iter < max_iter
    x_next = x_sec1 - f(x_sec1)*(x_sec1 - x_sec0)/(f(x_sec1) - f(x_sec0));
    x_history_sec = [x_history_sec, x_next];
    iter = iter + 1;
    if abs(x_next - x_sec1) < eps
        break;
    end
    x_sec0 = x_sec1;
    x_sec1 = x_next;
end
x_sec_final = x_next;
iter_sec = iter;
fprintf('Корень: %.10f, итераций: %d, f(x)=%.2e\n', x_sec_final, iter_sec, f(x_sec_final));

%% 6. Визуализация начальных точек и промежуточных шагов
% Начальная точка (общая для всех методов, кроме секущих)
plot(x0, f(x0), 'ro', 'MarkerSize', 12, 'LineWidth', 2, ...
    'DisplayName', 'Начальная точка (x0)');

% Промежуточные шаги и конечные корни
if ~isnan(x_simple)
    plot(x_history, zeros(size(x_history)), 'r*', 'MarkerSize', 8, ...
        'DisplayName', 'Шаги: простые итерации');
    plot(x_simple, 0, 'r*', 'MarkerSize', 14, 'MarkerFaceColor', 'r', ...
        'DisplayName', 'Корень: простые итерации');
end

plot(x_history_chord, zeros(size(x_history_chord)), 'g*', 'MarkerSize', 8, ...
    'DisplayName', 'Шаги: метод хорд');
plot(x_chord_final, 0, 'g*', 'MarkerSize', 14, 'MarkerFaceColor', 'g', ...
    'DisplayName', 'Корень: метод хорд');

if ~isnan(x_newton_final)
    plot(x_history_newton, zeros(size(x_history_newton)), 'b*', 'MarkerSize', 8, ...
        'DisplayName', 'Шаги: метод касательных');
    plot(x_newton_final, 0, 'b*', 'MarkerSize', 14, 'MarkerFaceColor', 'b', ...
        'DisplayName', 'Корень: метод касательных');
end

plot(x_history_sec, zeros(size(x_history_sec)), 'm*', 'MarkerSize', 8, ...
    'DisplayName', 'Шаги: метод секущих');
plot(x_sec_final, 0, 'm*', 'MarkerSize', 14, 'MarkerFaceColor', [0.5 0 0.5], ...
    'DisplayName', 'Корень: метод секущих');

legend('Location', 'best');
hold off;
%% 1 Задание

x0 = [0.74; 0.67];
options = optimoptions('fsolve', 'Display', 'iter');
[x, fval] = fsolve(@system, x0, options);

%% 2 Задание

f = @(x, y) x^3 * sin(y) + 1;
xspan = [0, 1];
y0 = 0.0;
[X, Y] = ode45(f, xspan, y0);

disp('    x         y');
disp([X, Y]);

plot(X, Y, '-o', 'LineWidth', 2);
grid on;
xlabel('x'); ylabel('y(x)');
title('Решение задачи Коши методом Рунге-Кутты (ode45)');

%% 3 Задание

I_simpson = trapz(X, Y);

p = polyfit(X, Y, 3);
fprintf('Коэффициенты полинома МНК')
disp(p)

crit_points = roots(polyder(p)); 

% Отфильтруем только вещественные экстремумы
real_extrema = crit_points(isreal(crit_points));
y_extrema = polyval(p, real_extrema);

%% Вывод результатов в консоль
fprintf('a) Интеграл: %.6f\n', I_simpson);
fprintf('b) Коэффициенты полинома: %s\n', mat2str(p, 4));
fprintf('c) Точки экстремумов X: %s\n   Значения в них Y: %s\n', mat2str(real_extrema, 4), mat2str(y_extrema, 4));
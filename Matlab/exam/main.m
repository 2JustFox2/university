
%% 1 Задание
fprintf('1 Задание\n');

% Система уравнений
F = @(x) [tan(x(1)-x(2)) - 4*x(1); x(1)^2 + 3*x(2)^3 - 4];

% Поиск одного корня на отрезке [0, 3]
options = optimoptions('lsqnonlin');
[x, ~, fval] = lsqnonlin(F, [1.5; 0.5], [0, 0], [3, 3], options); % Начальное приближение внутри [0,3]
fprintf('методы локальной оптимизации, основанные на линеаризации и вычислении матрицы Якоби\nМетод Левенберга-Марквардта - гибрид Гаусса-Ньютона и метода наискорейшего спуска (градиентный метод)\n');
fprintf('Найден корень: x1 = %.6f, x2 = %.6f\n', x(1), x(2));
fprintf('Невязка: |f1| = %.2e, |f2| = %.2e\n', abs(fval(1)), abs(fval(2)));

% Графическая иллюстрация
figure(1);
hold on; grid on;
x1_range = linspace(0, 3, 100);
x2_range = linspace(0, 3, 100);
[X1, X2] = meshgrid(x1_range, x2_range);

F1 = tan(X1 - X2) - 4*X1;
F2 = X1.^2 + 3*X2.^3 - 4;

contour(X1, X2, F1, [0 0], 'b', 'LineWidth', 2);
contour(X1, X2, F2, [0 0], 'r', 'LineWidth', 2);
plot(x(1), x(2), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');

xlabel('x_1'); ylabel('x_2');
title('Решение системы нелинейных уравнений');
legend('tg(x_1 - x_2) - 4x_1 = 0', 'x_1^2 + 3x_2^3 - 4 = 0', 'Корень', 'Location', 'best');
xlim([0, 3]); ylim([0, 3]);
hold off;

%% 2 Задание
fprintf('\n2 Задание\n');
% Решение задачи Коши методом Рунге-Кутта 4 порядка
f = @(x, y) 1 + x * exp(y^2);

[X, Y] = ode45(f, [0, 0.6], 0.4);

fprintf('Решение успешно найдено. Количество точек: %d\n', length(X));
fprintf('    x         y\n');
for i = 1:length(X)
    fprintf('%.4f    %.6f\n', X(i), Y(i));
end

% Графическая иллюстрация
figure(2);
plot(X, Y, '-o', 'LineWidth', 2, 'MarkerSize', 6);
grid on; 
xlabel('x'); 
ylabel('y(x)');
title('Решение задачи Коши методом Рунге-Кутта 4 порядка (ode45)');

%% 3 Задание
fprintf('\n3 Задание\n');

% а) Вычисление интеграла через встроенный pchip-сплайн
% кусочно-кубической эрмитовой интерполяции, сохраняющей форму
f_interp = @(x) interp1(X, Y, x, 'pchip');
I_simpson = integral(f_interp, min(X), max(X));
fprintf('a) Интеграл (метод Симпсона): %.8f\n', I_simpson);

% b) Аппроксимирующий полином МНК 3-й степени
p = polyfit(X, Y, 3);
fprintf('b) Коэффициенты аппроксимирующего полинома:\n');
fprintf('    p(x) = %.6f·x^2 + %.6f·x + %.6f\n', p(1), p(2), p(3));

% c) Поиск экстремумов полинома (для 2-й степени экстремум всегда один)
x_ext = -p(2) / (2*p(1));  % Аналитический корень производной 2ax + b = 0
y_ext = polyval(p, x_ext);
fprintf('Метод схему Горнера (также известную как метод вложенных умножений)\n')
if p(1) > 0, type = 'минимум'; else, type = 'максимум'; end
fprintf('c) Экстремум полинома: x = %.8f, y = %.8f (%s)\n', x_ext, y_ext, type);

% Графическая иллюстрация
figure(3);
xx = linspace(min(X)-0.2, max(X)+0.2, 200);

plot(X, Y, 'bo', 'MarkerSize', 6, 'DisplayName', 'Исходные данные (ode45)'); hold on;
plot(xx, polyval(p, xx), 'r-', 'LineWidth', 2, 'DisplayName', 'Аппроксимирующий полином');
plot(x_ext, y_ext, 'gs', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'DisplayName', 'Экстремум');

grid on; xlabel('x'); ylabel('y');
title('Аппроксимация МНК полиномом и его экстремумы');
legend('Location', 'best'); hold off;

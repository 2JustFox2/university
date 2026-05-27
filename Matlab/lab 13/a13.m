function lab13

clc;
clear;
close all;


h = 0.1; % шаг расчета
y0_task1 = [1; 1]; % начальный вектор для Задания 1

fprintf('Тема: решение систем ОДУ\n\n');

fprintf('ИСХОДНЫЕ ДАННЫЕ ЗАДАНИЯ 1\n'); % заголовок данных
fprintf('h = %.1f\n', h); % вывод шага
fprintf('y1(0) = %.1f\n', y0_task1(1)); % вывод y1
fprintf('y2(0) = %.1f\n\n', y0_task1(2)); % вывод y2


% ЗАДАНИЕ 1

fprintf('ЗАДАНИЕ 1\n'); % вывод задания
fprintf('y1'' = y1*exp(-x^2) + x*y2\n'); % первое уравнение
fprintf('y2'' = 3*x - y1 + 2*y2\n'); % второе уравнение
fprintf('Интервал: [0; 1]\n\n'); % интервал решения

[x1, e1, k1e] = euler_method(@f1, @j1, 0, 1, h, y0_task1); % метод Эйлера

[x1, m1, k1m] = mod_euler_method(@f1, @j1, 0, 1, h, y0_task1); % модиф Эйлер

[x1, r1, k1r] = rk4_method(@f1, @j1, 0, 1, h, y0_task1); % метод РК4

[xo1, o1] = ode45(@f1, x1, y0_task1); % стандарт ode45

print_task1(x1, e1, m1, r1, o1); % вывод таблицы
print_stiff1(x1, k1e, k1m, k1r); % вывод жесткости

plot_task1(x1, e1, m1, r1, xo1, o1); % график задания


% задание 2
% ___________________________
y0_task2 = [2; 0]; % ВАЖНО: начальный вектор для жесткой системы Задания 2

fprintf('\nЗАДАНИЕ 2\n'); % вывод задания
fprintf('y1'' = -20*y1 + 5*y2\n'); % первое уравнение
fprintf('y2'' = 19*y1 - 5*y2\n'); % второе уравнение
fprintf('Начальные условия: y1(0) = %.1f, y2(0) = %.1f\n', y0_task2(1), y0_task2(2));
fprintf('Интервал: [0; 3]\n\n'); % интервал решения

[x2, e2, k2e] = euler_method(@f2, @j2, 0, 3, h, y0_task2); % явный Эйлер

[x2, i2, k2i] = implicit_euler_task2(0, 3, h, y0_task2); % неявный Эйлер

oldWarn = warning('off','all'); % убрать warning
[xo2, o2] = ode15s(@f2, [0 3], y0_task2); % стандарт ode15s
warning(oldWarn); % вернуть warning

print_task2(x2, e2, i2); % вывод таблицы
print_stiff2(x2, k2e, k2i); % вывод жесткости

fprintf('\nСТАНДАРТНЫЙ ОПЕРАТОР MATLAB ДЛЯ ЗАДАНИЯ 2\n'); % заголовок ode
fprintf('ode15s успешно дошёл до конца интервала (x = 3).\n'); % пояснение

plot_task2(x2, e2, i2, xo2, o2); % график задания



end


% явный Эйлер
function [x, y, stiff] = euler_method(fun, jac, a, b, h, y0)

x = a:h:b; % сетка x
n = length(x); % число узлов
y = zeros(n,2); % массив решения
stiff = zeros(n,1); % массив жесткости
y(1,:) = y0'; % первое значение

for i = 1:n % цикл жесткости
    stiff(i) = stiff_number(jac(x(i), y(i,:)')); % число жесткости
end % конец цикла

for i = 1:n-1 % цикл Эйлера
    y(i+1,:) = y(i,:) + h * fun(x(i), y(i,:)')'; % новый слой
end % конец цикла

end % конец функции


% мод Эйлер
function [x, y, stiff] = mod_euler_method(fun, jac, a, b, h, y0)


x = a:h:b; % сетка x
n = length(x); % число узлов
y = zeros(n,2); % массив решения
stiff = zeros(n,1); % массив жесткости
y(1,:) = y0'; % первое значение

for i = 1:n % цикл жесткости
    stiff(i) = stiff_number(jac(x(i), y(i,:)')); % число жесткости
end % конец цикла

for i = 1:n-1 % цикл метода
    fLeft = fun(x(i), y(i,:)'); % левый наклон
    yPred = y(i,:)' + h * fLeft; % прогноз Эйлера
    fRight = fun(x(i+1), yPred); % правый наклон
    y(i+1,:) = y(i,:) + h * (fLeft' + fRight') / 2; % уточнение шага
end % конец цикла

end % конец функции


% РК4
function [x, y, stiff] = rk4_method(fun, jac, a, b, h, y0)

x = a:h:b; % сетка x
n = length(x); % число узлов
y = zeros(n,2); % массив решения
stiff = zeros(n,1); % массив жесткости
y(1,:) = y0'; % первое значение

for i = 1:n % цикл жесткости
    stiff(i) = stiff_number(jac(x(i), y(i,:)')); % число жесткости
end % конец цикла

for i = 1:n-1 % цикл РК4
    yi = y(i,:)'; % текущий вектор
    k1 = fun(x(i), yi); % первый наклон
    k2 = fun(x(i)+h/2, yi+h*k1/2); % второй наклон
    k3 = fun(x(i)+h/2, yi+h*k2/2); % третий наклон
    k4 = fun(x(i+1), yi+h*k3); % четвертый наклон
    y(i+1,:) = (yi + h*(k1+2*k2+2*k3+k4)/6)'; % новый слой
end % конец цикла

end % конец функции


% Неявный Эйлер Аналитик
function [x, y, stiff] = implicit_euler_task2(a, b, h, y0)

x = a:h:b; % сетка x
n = length(x); % число узлов
y = zeros(n,2); % массив решения
stiff = zeros(n,1); % массив жесткости
y(1,:) = y0'; % первое значение

for i = 1:n % цикл жесткости
    stiff(i) = stiff_number(j2(x(i), y(i,:)')); % число жесткости
end % конец цикла

for i = 1:n-1 % цикл неявн
    y1_old = y(i, 1);
    y2_old = y(i, 2);
    
    % Знаменатель для системы: -20*y1 + 5*y2 / 19*y1 - 5*y2
    denom = (1 + 20 * h) * (1 + 5 * h) - (-5 * h) * (-19 * h);
     
    % Аналитическое решение методом подстановки/Крамера
    y1_new = (y1_old * (1 + 5 * h) + y2_old * 5 * h) / denom;
    y2_new = (y2_old * (1 + 20 * h) - y1_old * 19 * h) / denom;
    
    y(i+1,:) = [y1_new, y2_new]; % запись решения
end % конец цикла

end % конец функции


% ПРАВАЯ ЧАСТЬ ЗАДАНИЯ 1
function dy = f1(x, y)

dy = zeros(2,1); % вектор функции
dy(1) = y(1)*exp(-x^2) + x*y(2); % первое уравнение
dy(2) = 3*x - y(1) + 2*y(2); % второе уравнение

end % конец функции


% якобиан задания 1
function J = j1(x, y)

J = [exp(-x^2), x; -1, 2]; % матрица Якоби

end % конец функции


% ПРАВАЯ ЧАСТЬ ЗАДАНИЯ 2 (жесткая система)
function dy = f2(x, y)

dy = zeros(2,1); % вектор функции
dy(1) = -20*y(1) + 5*y(2); % первое уравнение
dy(2) = 19*y(1) - 5*y(2); % второе уравнение

end % конец функции


% якобиан 2 (Учебная жесткая система)
function J = j2(x, y)

J = [-20, 5; 19, -5]; % матрица Якоби

end


% считает число жёсткости
function k = stiff_number(J)

lambda = eig(J); % собственные числа
a = abs(lambda); % модули чисел
k = max(a) / min(a); % число жесткости

end


% таблица 1
function print_task1(x, e, m, r, o)

fprintf('ТАБЛИЦА 1. ЗАДАНИЕ 1, КОМПОНЕНТА y1\n'); % заголовок таблицы
fprintf('x        Euler_y1      Mod_y1        RK4_y1        ode45_y1\n'); % шапка таблицы

for q = 1:length(x) % цикл строк
    fprintf('%4.1f  %12.5e  %12.5e  %12.5e  %12.5e\n', x(q), e(q,1), m(q,1), r(q,1), o(q,1)); % строка y1
end % конец цикла

fprintf('\nТАБЛИЦА 2. ЗАДАНИЕ 1, КОМПОНЕНТА y2\n'); % заголовок таблицы
fprintf('x        Euler_y2      Mod_y2        RK4_y2        ode45_y2\n'); % шапка таблицы

for q = 1:length(x) % цикл строк
    fprintf('%4.1f  %12.5e  %12.5e  %12.5e  %12.5e\n', x(q), e(q,2), m(q,2), r(q,2), o(q,2)); % строка y2
end % конец цикла

end % конец функции


% жесткость 1
function print_stiff1(x, a, b, c)

fprintf('\nЖЕСТКОСТЬ ЗАДАНИЯ 1\n'); % заголовок таблицы
fprintf('x        Euler         Mod           RK4\n'); % шапка таблицы

for q = 1:length(x) % цикл строк
    fprintf('%4.1f  %12.5e  %12.5e  %12.5e\n', x(q), a(q), b(q), c(q)); % строка таблицы
end % конец цикла

end % конец функции



% таблица 2
function print_task2(x, e, i)

fprintf('\nТАБЛИЦА 3. ЗАДАНИЕ 2, КОМПОНЕНТА y1\n'); % заголовок таблицы
fprintf('x        Euler_y1      Imp_y1\n'); % шапка таблицы

for q = 1:length(x) % цикл строк
    fprintf('%4.1f  %12.5e  %12.5e\n', x(q), e(q,1), i(q,1)); % строка y1
end % конец цикла

fprintf('\nТАБЛИЦА 4. ЗАДАНИЕ 2, КОМПОНЕНТА y2\n'); % заголовок таблицы
fprintf('x        Euler_y2      Imp_y2\n'); % шапка таблицы

for q = 1:length(x) % цикл строк
    fprintf('%4.1f  %12.5e  %12.5e\n', x(q), e(q,2), i(q,2)); % строка y2
end % конец цикла

end % конец функции


% ВЫВОДИТ ЖЕСТКОСТЬ 2
function print_stiff2(x, a, b)

fprintf('\nЖЕСТКОСТЬ ЗАДАНИЯ 2\n'); % заголовок таблицы
fprintf('x        Euler         Implicit\n'); % шапка таблицы

for q = 1:length(x) % цикл строк
    fprintf('%4.1f  %12.5e  %12.5e\n', x(q), a(q), b(q)); % строка таблицы
end % конец цикла

end % конец функции


% грфики 1
function plot_task1(x, e, m, r, xo, o)
screen = get(0, 'ScreenSize');
width = 800;  % ширина окна
height = 400; % высота окна

% Вычисляем позицию для центра экрана
posX = (screen(3) - width) / 2;   % центр по горизонтали
posY = (screen(4) - height) / 2;  % центр по вертикали
% Первый график - y1
figure('Name', 'Сравнение y1', 'Position', [posX, posY, width, height]);
plot(x, e(:,1), '-', 'Color', [0.85 0.33 0.10], 'LineWidth', 2.0); % Эйлер y1
hold on; % удержание графика
plot(x, m(:,1), '--', 'Color', [0.00 0.45 0.74], 'LineWidth', 2.0); % мод Эйлер y1
plot(x, r(:,1), '-.', 'Color', [0.49 0.18 0.56], 'LineWidth', 2.0); % РК4 y1
plot(xo, o(:,1), ':', 'Color', [0.20 0.20 0.20], 'LineWidth', 2.4); % ode45 y1
grid on; % включить сетку
xlabel('x'); % подпись x
ylabel('y1'); % подпись y
title('Задание 1: сравнение y1'); % заголовок графика
legend('Euler y1','Mod Euler y1','RK4 y1','ode45 y1','Location','NorthWest'); % легенда графика

% Второй график - y2
figure('Name', 'Сравнение y2', 'Position', [posX, posY, width, height]);
plot(x, e(:,2), '-', 'Color', [0.47 0.67 0.19], 'LineWidth', 2.0); % Эйлер y2
hold on; % удержание графика
plot(x, m(:,2), '--', 'Color', [0.00 0.60 0.60], 'LineWidth', 2.0); % мод Эйлер y2
plot(x, r(:,2), '-.', 'Color', [0.64 0.08 0.18], 'LineWidth', 2.0); % РК4 y2
plot(xo, o(:,2), ':', 'Color', [0.35 0.35 0.35], 'LineWidth', 2.4); % ode45 y2
grid on; % включить сетку
xlabel('x'); % подпись x
ylabel('y2'); % подпись y
title('Задание 1: сравнение y2'); % заголовок графика
legend('Euler y2','Mod Euler y2','RK4 y2','ode45 y2','Location','NorthWest'); % легенда графика

end


%  графики 2
function plot_task2(x, e, i, xo, o)
% Получаем размер экрана
screen = get(0, 'ScreenSize');
width = 800;  % ширина окна
height = 400; % высота окна

% Вычисляем позицию для центра экрана
posX = (screen(3) - width) / 2;   % центр по горизонтали
posY = (screen(4) - height) / 2;  % центр по вертикали
% Первый график - y1
figure('Name', 'Задание 2: y1', 'Position', [posX, posY, width, height]);
% Сначала строим эталон толстой линией
plot(xo, o(:,1), '-', 'Color', [0.10 0.10 0.50], 'LineWidth', 3.0); hold on;
% Затем явный и неявный методы с нужными маркерами
plot(x, e(:,1), '--', 'Color', [0.80 0.15 0.15], 'LineWidth', 1.8, 'MarkerSize', 6);
plot(x, i(:,1), '-o', 'Color', [0.00 0.45 0.74], 'LineWidth', 2.0, 'MarkerSize', 6);
grid on; % сетка
xlabel('x'); 
ylabel('y_1(x)'); 
title('Задание 2. Решение жесткой системы для y_1'); 
legend('ode15s (эталон)', 'Явный Эйлер (неустойчив)', 'Неявный Эйлер (устойчив)', 'Location', 'northeast'); 
xlim([0 3]); 

ylim([-2e5 4.5e5]); 

% Второй график - y2
figure('Name', 'Задание 2: y2', 'Position', [posX, posY, width, height]);
plot(xo, o(:,2), '-', 'Color', [0.10 0.10 0.10], 'LineWidth', 3.0); hold on;
plot(x, e(:,2), '--', 'Color', [0.80 0.15 0.15], 'LineWidth', 1.8, 'MarkerSize', 6);
plot(x, i(:,2), '-o', 'Color', [0.00 0.45 0.74], 'LineWidth', 2.0, 'MarkerSize', 6);
grid on; % сетка
xlabel('x'); 
ylabel('y_2(x)'); 
title('Задание 2. Решение жесткой системы для y_2'); 
legend('ode15s (эталон)', 'Явный Эйлер (неустойчив)', 'Неявный Эйлер (устойчив)', 'Location', 'northeast'); 
xlim([0 3]); 
ylim([-2e5 2e5]); 

end
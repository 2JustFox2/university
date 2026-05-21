%очищаем рабочую область
clear
clc
close all

%задаем формат вывода
format long g

%задаем данные из седьмой лабораторной работы
x_tab = [0, 2, 5, 9, 11, 16, 18, 21, 24];
y_tab = [10.00, 918.4, 2222.5, 3448.9, 3550.9, 1736.4, 984.174, 436.146, 807.6];

%находим степень интерполяционного полинома
n_tab = length(x_tab) - 1;

%центрирование и масштабирование для устойчивости
x_mean = mean(x_tab);
x_std = std(x_tab);
x_norm = (x_tab - x_mean) / x_std;

%создаем матрицу вандермонда на нормированных данных
A = zeros(length(x_norm));
for i = 1:length(x_norm)
    for j = 1:length(x_norm)
        A(i,j) = x_norm(i)^(j - 1);
    end
end

%проверяем число обусловленности
cond_A = cond(A);
disp(['число обусловленности матрицы Вандермонда = ' num2str(cond_A)])
if cond_A > 1e10
    disp('внимание: матрица плохо обусловлена, возможны погрешности')
end

%проверяем определитель матрицы
det_A = det(A);
if abs(det_A) < 1e-12
    error('определитель матрицы близок к нулю')
end

%находим коэффициенты интерполяционного полинома
coef_tab_norm = A \ y_tab(:);

%коэффициенты от старшей степени к младшей для polyval/polyder
coef_poly = flipud(coef_tab_norm)';

%находим коэффициенты первой производной полинома через polyder
coef_d1_poly = polyder(coef_poly);

%находим коэффициенты второй производной полинома через polyder
coef_d2_poly = polyder(coef_d1_poly);

%задаем точки между узлами один два и восемь девять
x_mid = [(x_tab(1) + x_tab(2)) / 2; (x_tab(8) + x_tab(9)) / 2];
%нормируем межузловые точки
x_mid_norm = (x_mid - x_mean) / x_std;

%вычисляем значения полинома в межузловых точках (напрямую через polyval)
y_mid = polyval(coef_poly, x_mid_norm);

%вычисляем первую производную в межузловых точках (с учетом нормировки)
d1_mid = polyval(coef_d1_poly, x_mid_norm) / x_std;

%вычисляем вторую производную в межузловых точках (с учетом нормировки)
d2_mid = polyval(coef_d2_poly, x_mid_norm) / (x_std^2);

%ищем самый большой промежуток между узлами
[~, gap_index] = max(diff(x_tab));

%добавляем точку внутри самого большого промежутка
x_add = (x_tab(gap_index) + x_tab(gap_index + 1)) / 2;
x_add_norm = (x_add - x_mean) / x_std;

%вычисляем значение добавленной точки через полином
y_add = polyval(coef_poly, x_add_norm);

%формируем расширенный набор узлов
x_aug = [x_tab(:); x_add];
y_aug = [y_tab(:); y_add];

%сортируем расширенный набор узлов
[x_aug, ind_aug] = sort(x_aug);
y_aug = y_aug(ind_aug);

%находим разделенную разность максимального порядка
c_aug = y_aug(:);
m_aug = length(x_aug);
for j = 2:m_aug
    for i = m_aug:-1:j
        c_aug(i) = (c_aug(i) - c_aug(i - 1)) / (x_aug(i) - x_aug(i - j + 1));
    end
end
dd_n1 = c_aug(m_aug);

%вычисляем средний шаг для неравномерной сетки
h_avg = (x_tab(end) - x_tab(1)) / n_tab;

%вычисляем f^(n+1) через разделенную разность
f_n1 = abs(dd_n1) * factorial(n_tab + 1);

%оцениваем погрешность первой производной по формуле
err_d1_mid = zeros(size(x_mid));
for idx = 1:length(x_mid)
    %текущая точка для оценки погрешности
    x_eval = x_mid(idx);
    
    %находим индекс i ближайшего левого узла (нумерация с 0)
    i_node = find(x_tab <= x_eval, 1, 'last') - 1;
    
    %вычисляем произведение pi(x_eval - x_k) для всех k кроме i_node
    prod_term = 1;
    for k = 1:length(x_tab)
        if k ~= (i_node + 1)
            prod_term = prod_term * (x_eval - x_tab(k));
        end
    end
    
    %вычисляем факториальный коэффициент i!*(n-i)!/(n+1)!
    fact_term = factorial(i_node) * factorial(n_tab - i_node) / factorial(n_tab + 1);
    
    %вычисляем знак (-1)^(n-i)
    sign_term = (-1)^(n_tab - i_node);
    
    %погрешность по формуле (13.25)
    err_d1_mid(idx) = abs(sign_term * fact_term * h_avg^n_tab * f_n1 * prod_term);
end

%собираем таблицу результатов для табличной функции
table_tab = table(x_mid, y_mid, d1_mid, d2_mid, err_d1_mid, ...
    'VariableNames', {'x', 'y_interp', 'd1_interp', 'd2_interp', 'err_d1_est'});

%выводим результаты для табличной функции
disp('результаты для табличной функции')
disp(table_tab)

%выводим параметры для оценки погрешности
disp('параметры оценки погрешности первой производной')
disp(['степень полинома n = ' num2str(n_tab)])
disp(['самый большой промежуток между узлами: от x(' num2str(gap_index) ') до x(' num2str(gap_index+1) ')'])
disp(['координата добавленной точки x_add = ' num2str(x_add)])
disp(['значение полинома в добавленной точке y_add = ' num2str(y_add)])
disp(['средний шаг сетки h_avg = ' num2str(h_avg)])

%строим сетку для графика интерполяции
x_plot = linspace(min(x_tab), max(x_tab), 1000)';
x_plot_norm = (x_plot - x_mean) / x_std;
%вычисляем значения полинома на сетке
y_plot = polyval(coef_poly, x_plot_norm);

%строим график интерполяционного полинома
figure
plot(x_plot, y_plot, 'LineWidth', 1.5)
hold on
plot(x_tab, y_tab, 'o', 'MarkerFaceColor', 'k', 'MarkerSize', 6)
plot(x_mid, y_mid, 's', 'MarkerFaceColor', 'y', 'MarkerSize', 8)
plot(x_add, y_add, 'p', 'MarkerFaceColor', 'c', 'MarkerSize', 10)
grid on
xlabel('x')
ylabel('y')
title('интерполяционный полином для табличной функции')
legend('полином', 'узлы', 'точки производных', 'добавленная точка', 'Location', 'best')

%задаем функцию из задания
f = @(x) x.^2 + tan(x);

% Задаем точную первую производную
df = @(x) 2*x + tan(x).^2 + 1;

% Задаем точную вторую производную
d2f = @(x) 2*tan(x) .*(tan(x).^2 + 1) + 2;

%задаем точку вычисления
x0 = -3.2;

%задаем основной шаг
h0 = 0.1;

%вычисляем значение функции в точке
y0 = f(x0);

%вычисляем точную первую производную в точке
d1_exact = df(x0);

%вычисляем точную вторую производную в точке
d2_exact = d2f(x0);

%вычисляем правую разность первой производной
d1_right = (f(x0 + h0) - f(x0)) / h0;

%вычисляем левую разность первой производной
d1_left = (f(x0) - f(x0 - h0)) / h0;

%вычисляем центральную разность первой производной
d1_center = (f(x0 + h0) - f(x0 - h0)) / (2*h0);

%вычисляем пятиточечную формулу первой производной
d1_five = (f(x0 - 2*h0) - 8*f(x0 - h0) + 8*f(x0 + h0) - f(x0 + 2*h0)) / (12*h0);

%вычисляем метод рунге первой производной
h_half = h0 / 2;
d1_right_h = (f(x0 + h0) - f(x0)) / h0;
d1_right_h2 = (f(x0 + h_half) - f(x0)) / h_half;
d1_runge = 2*d1_right_h2 - d1_right_h;

%вычисляем трехточечную формулу второй производной
d2_simple = (f(x0 + h0) - 2*f(x0) + f(x0 - h0)) / h0^2;

%вычисляем пятиточечную формулу второй производной
d2_five = (-f(x0 + 2*h0) + 16*f(x0 + h0) - 30*f(x0) + 16*f(x0 - h0) - f(x0 - 2*h0)) / (12*h0^2);

%вычисляем метод рунге второй производной
d2_simple_h = (f(x0 + h0) - 2*f(x0) + f(x0 - h0)) / h0^2;
d2_simple_h2 = (f(x0 + h_half) - 2*f(x0) + f(x0 - h_half)) / (h_half^2);
d2_runge = (4*d2_simple_h2 - d2_simple_h) / 3;

%собираем таблицу первой производной
method_d1 = {'right_simple'; 'left_simple'; 'center_simple'; 'five_point'; 'runge_right'};
value_d1 = [d1_right; d1_left; d1_center; d1_five; d1_runge];
error_d1 = abs(value_d1 - d1_exact);
table_d1 = table(method_d1, value_d1, error_d1, 'VariableNames', {'method', 'value', 'error'});

%собираем таблицу второй производной
method_d2 = {'simple_three_point'; 'five_point'; 'runge'};
value_d2 = [d2_simple; d2_five; d2_runge];
error_d2 = abs(value_d2 - d2_exact);
table_d2 = table(method_d2, value_d2, error_d2, 'VariableNames', {'method', 'value', 'error'});

%выводим точные значения функции и её производных в исследуемой точке
disp('точные значения функции и производных в исследуемой точке')
disp(['x0 = ' num2str(x0)])
disp(['f(x0) = ' num2str(y0)])
disp(['точная первая производная f''(x0) = ' num2str(d1_exact)])
disp(['точная вторая производная f''''(x0) = ' num2str(d2_exact)])

%выводим результаты первой производной
disp('первая производная в точке x0')
disp(table_d1)

%выводим результаты второй производной
disp('вторая производная в точке x0')
disp(table_d2)

%задаем сетку для графиков погрешностей
x_grid = (x0-1:h0:x0+4)';

%создаем массивы ошибок первой производной
er_d1_right = NaN(size(x_grid));
er_d1_left = NaN(size(x_grid));
er_d1_center = NaN(size(x_grid));
er_d1_five = NaN(size(x_grid));
er_d1_runge = NaN(size(x_grid));

%вычисляем ошибки правой разности на сетке
for i = 1:length(x_grid) - 1
    val = (f(x_grid(i) + h0) - f(x_grid(i))) / h0;
    er_d1_right(i) = abs(df(x_grid(i)) - val);
end

%вычисляем ошибки левой разности на сетке
for i = 2:length(x_grid)
    val = (f(x_grid(i)) - f(x_grid(i) - h0)) / h0;
    er_d1_left(i) = abs(df(x_grid(i)) - val);
end

%вычисляем ошибки центральной разности на сетке
for i = 2:length(x_grid) - 1
    val = (f(x_grid(i) + h0) - f(x_grid(i) - h0)) / (2*h0);
    er_d1_center(i) = abs(df(x_grid(i)) - val);
end

%вычисляем ошибки пятиточечной формулы на сетке
for i = 3:length(x_grid) - 2
    val = (f(x_grid(i) - 2*h0) - 8*f(x_grid(i) - h0) + 8*f(x_grid(i) + h0) - f(x_grid(i) + 2*h0)) / (12*h0);
    er_d1_five(i) = abs(df(x_grid(i)) - val);
end

%вычисляем ошибки метода рунге для первой производной на сетке
for i = 1:length(x_grid) - 1
    val_h = (f(x_grid(i) + h0) - f(x_grid(i))) / h0;
    val_h2 = (f(x_grid(i) + h0/2) - f(x_grid(i))) / (h0/2);
    val = 2*val_h2 - val_h;
    er_d1_runge(i) = abs(df(x_grid(i)) - val);
end

%строим графики ошибок первой производной
figure
plot(x_grid, er_d1_right, '-o')
hold on
plot(x_grid, er_d1_left, '-s')
plot(x_grid, er_d1_center, '-d')
plot(x_grid, er_d1_five, '-^')
plot(x_grid, er_d1_runge, '-p')
grid on
xlabel('x')
ylabel('абсолютная погрешность')
title('погрешность первой производной')
legend('правая', 'левая', 'центральная', 'пятиточечная', 'рунге', 'Location', 'best')

%создаем массивы ошибок второй производной
er_d2_simple = NaN(size(x_grid));
er_d2_five = NaN(size(x_grid));
er_d2_runge = NaN(size(x_grid));

%вычисляем ошибки трехточечной формулы второй производной
for i = 2:length(x_grid) - 1
    val = (f(x_grid(i) + h0) - 2*f(x_grid(i)) + f(x_grid(i) - h0)) / h0^2;
    er_d2_simple(i) = abs(d2f(x_grid(i)) - val);
end

%вычисляем ошибки пятиточечной формулы второй производной
for i = 3:length(x_grid) - 2
    val = (-f(x_grid(i) + 2*h0) + 16*f(x_grid(i) + h0) - 30*f(x_grid(i)) + 16*f(x_grid(i) - h0) - f(x_grid(i) - 2*h0)) / (12*h0^2);
    er_d2_five(i) = abs(d2f(x_grid(i)) - val);
end

%вычисляем ошибки метода рунге для второй производной на сетке
for i = 2:length(x_grid) - 1
    val_h = (f(x_grid(i) + h0) - 2*f(x_grid(i)) + f(x_grid(i) - h0)) / h0^2;
    val_h2 = (f(x_grid(i) + h0/2) - 2*f(x_grid(i)) + f(x_grid(i) - h0/2)) / ((h0/2)^2);
    val = (4*val_h2 - val_h) / 3;
    er_d2_runge(i) = abs(d2f(x_grid(i)) - val);
end

%строим графики ошибок второй производной
figure
plot(x_grid, er_d2_simple, '-o')
hold on
plot(x_grid, er_d2_five, '-s')
plot(x_grid, er_d2_runge, '-d')
grid on
xlabel('x')
ylabel('абсолютная погрешность')
title('погрешность второй производной')
legend('трехточечная', 'пятиточечная', 'рунге', 'Location', 'best')

%задаем количество шагов для анализа
n_h = 30;

%создаем массив шагов
h_vec = zeros(1, n_h);
h_vec(1) = 1.0;
for i = 2:n_h
    h_vec(i) = h_vec(i - 1) / 2;
end

%создаем массивы ошибок по шагу
er_step_d1_right = zeros(size(h_vec));
er_step_d1_center = zeros(size(h_vec));
er_step_d1_five = zeros(size(h_vec));
er_step_d1_runge = zeros(size(h_vec));
er_step_d2_simple = zeros(size(h_vec));
er_step_d2_five = zeros(size(h_vec));
er_step_d2_runge = zeros(size(h_vec));

%считаем ошибки при разных шагах
for i = 1:length(h_vec)
    h = h_vec(i);
    
    val_d1_right = (f(x0 + h) - f(x0)) / h;
    er_step_d1_right(i) = abs(d1_exact - val_d1_right);
    
    val_d1_center = (f(x0 + h) - f(x0 - h)) / (2*h);
    er_step_d1_center(i) = abs(d1_exact - val_d1_center);
    
    val_d1_five = (f(x0 - 2*h) - 8*f(x0 - h) + 8*f(x0 + h) - f(x0 + 2*h)) / (12*h);
    er_step_d1_five(i) = abs(d1_exact - val_d1_five);
    
    val_d1_right_h2 = (f(x0 + h/2) - f(x0)) / (h/2);
    val_d1_runge = 2*val_d1_right_h2 - val_d1_right;
    er_step_d1_runge(i) = abs(d1_exact - val_d1_runge);
    
    val_d2_simple = (f(x0 + h) - 2*f(x0) + f(x0 - h)) / h^2;
    er_step_d2_simple(i) = abs(d2_exact - val_d2_simple);
    
    val_d2_five = (-f(x0 + 2*h) + 16*f(x0 + h) - 30*f(x0) + 16*f(x0 - h) - f(x0 - 2*h)) / (12*h^2);
    er_step_d2_five(i) = abs(d2_exact - val_d2_five);
    
    val_d2_simple_h = (f(x0 + h) - 2*f(x0) + f(x0 - h)) / h^2;
    val_d2_simple_h2 = (f(x0 + h/2) - 2*f(x0) + f(x0 - h/2)) / ((h/2)^2);
    val_d2_runge = (4*val_d2_simple_h2 - val_d2_simple_h) / 3;
    er_step_d2_runge(i) = abs(d2_exact - val_d2_runge);
end

%строим влияние шага на первую производную
figure
loglog(h_vec, er_step_d1_right, '-o')
hold on
loglog(h_vec, er_step_d1_center, '-s')
loglog(h_vec, er_step_d1_five, '-d')
loglog(h_vec, er_step_d1_runge, '-^')
grid on
xlabel('h')
ylabel('абсолютная погрешность')
title('влияние шага на первую производную')
legend('правая', 'центральная', 'пятиточечная', 'рунге', 'Location', 'best')

%строим влияние шага на вторую производную
figure
loglog(h_vec, er_step_d2_simple, '-o')
hold on
loglog(h_vec, er_step_d2_five, '-s')
loglog(h_vec, er_step_d2_runge, '-d')
grid on
xlabel('h')
ylabel('абсолютная погрешность')
title('влияние шага на вторую производную')
legend('трехточечная', 'пятиточечная', 'рунге', 'Location', 'best')

%собираем таблицу влияния шага на первую производную
table_step_d1 = table(h_vec', er_step_d1_right', er_step_d1_center', er_step_d1_five', er_step_d1_runge', ...
    'VariableNames', {'h', 'right', 'center', 'five_point', 'runge'});

%собираем таблицу влияния шага на вторую производную
table_step_d2 = table(h_vec', er_step_d2_simple', er_step_d2_five', er_step_d2_runge', ...
    'VariableNames', {'h', 'simple', 'five_point', 'runge'});

%выводим таблицу влияния шага на первую производную
disp('влияние шага на первую производную')
disp(table_step_d1)

%выводим таблицу влияния шага на вторую производную
disp('влияние шага на вторую производную')
disp(table_step_d2)

%строим график функции и двух производных
%задаем расширенную сетку вокруг точки x0
x_range = 10; %диапазон в обе стороны от x0
x_plot_func = linspace(x0 - x_range, x0 + x_range, 500)';

%вычисляем значения функции и производных на сетке
y_plot_func = f(x_plot_func);
dy_plot_func = df(x_plot_func);
d2y_plot_func = d2f(x_plot_func);

%создаем график
figure
plot(x_plot_func, y_plot_func, 'b-', 'LineWidth', 1.5)
hold on
plot(x_plot_func, dy_plot_func, 'g-', 'LineWidth', 1.5)
plot(x_plot_func, d2y_plot_func, 'r-', 'LineWidth', 1.5)

%отмечаем точку x0 на всех кривых
plot(x0, y0, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8)
plot(x0, d1_exact, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 8)
plot(x0, d2_exact, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8)

%добавляем вертикальную линию в точке x0
yl = ylim;
plot([x0 x0], yl, 'k--', 'LineWidth', 0.5)

grid on
xlabel('x')
ylabel('значения')
title(['Функция f(x) = x^3 + e^x и её производные, x_0 = ' num2str(x0)])
legend('f(x)', 'f''(x)', 'f''''(x)', ['f(x_0) = ' num2str(y0, '%.4f')], ...
    ['f''(x_0) = ' num2str(d1_exact, '%.4f')], ...
    ['f''''(x_0) = ' num2str(d2_exact, '%.4f')], ...
    'x_0', 'Location', 'best')

%подписываем значения в точке x0
text(x0 + 0.2, y0, ['f(x_0) = ' num2str(y0, '%.4f')], 'FontSize', 9)
text(x0 + 0.2, d1_exact, ['f''(x_0) = ' num2str(d1_exact, '%.4f')], 'FontSize', 9)
text(x0 + 0.2, d2_exact, ['f''''(x_0) = ' num2str(d2_exact, '%.4f')], 'FontSize', 9)
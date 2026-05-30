clear
clc
close all

%% Параметры
a = -1;
b = 1.5;

%% Исходная функция
syms x
f = tan(x) + x^2;

%% 1. Интеграл аналитически
disp('Интеграл:')
F = int(f, x);

I = int(f, x, a, b); % интеграл по границам
fprintf('Значение интеграла от %d до %d: %.8f\n\n', a, b, double(I));

%% 2. Вторая производная и её максимум
f2 = diff(f, x, 2);
disp('Вторая производная:')
pretty(f2)

f2_num = matlabFunction(f2); % делаем обычную F
x_vals = linspace(a, b, 1000);
y2 = f2_num(x_vals); % считаем значение производной и берем максимум
[max2, idx2] = max(y2);
fprintf('Максимум второй производной на [%d, %d]: %.4f в точке x = %.4f\n\n', a, b, max2, x_vals(idx2));

%% 3. Четвёртая производная и её максимум
f4 = diff(f, x, 4);
disp('Четвёртая производная:')
pretty(f4)

f4_num = matlabFunction(f4);
y4 = f4_num(x_vals);
[max4, idx4] = max(y4);
fprintf('Максимум четвёртой производной на [%d, %d]: %.4f в точке x = %.4f\n\n', a, b, max4, x_vals(idx4));

%% График функции
figure;
fun_handle = matlabFunction(f, 'Vars', x);
x_plot = linspace(a, b, 1000);
y_plot = fun_handle(x_plot);
plot(x_plot, y_plot, 'b', 'LineWidth', 2);
xlabel('x');
ylabel('f(x)');
title(sprintf('График f = tan(x) + x^2 на [%d, %d]', a, b));
grid on;


%% метод трапеций
% Задаём требуемую точность для метода трапеций
eps_trap = 1e-2;

% Берём максимум второй производной, вычисленный ранее
M2 = max2;

% Вычисляем максимально допустимый шаг по формуле (5)
h_trap_max = sqrt(12 * eps_trap / ((b - a) * M2));

% Определяем число разбиений
n_trap = ceil((b - a) / h_trap_max);

% Фактический шаг интегрирования
h_trap = (b - a) / n_trap;
fprintf(' шаг от %d\n\n', h_trap);
fprintf(' кол разбиений от %d\n\n', n_trap);


% Переводим символьную функцию в числовую для быстрых вычислений
f_num = matlabFunction(f);

% Формируем сетку узлов с шагом h
x_trap = a:h_trap:b;

% Вычисляем значения функции в узлах сетки
y_trap = f_num(x_trap);

% Вычисляем интеграл по формуле трапеций (3) на всём отрезке [a, b]
I_trap_h = h_trap/2 * (y_trap(1) + y_trap(end) + 2*sum(y_trap(2:end-1)));

% Уменьшаем шаг вдвое для процедуры Рунге
h_half = h_trap / 2;

% Число разбиений с половинным шагом
n_half = 2 * n_trap;

% Формируем сетку узлов с шагом h/2
x_half = a:h_half:b;

% Значения функции на удвоенной сетке
y_half = f_num(x_half);

% Вычисляем интеграл с шагом h/2
I_trap_half = h_half/2 * (y_half(1) + y_half(end) + 2*sum(y_half(2:end-1)));

% Порядок метода трапеций
p = 2;

% оценка погрешности по Рунге (формула 12)
R_runge = (I_trap_half - I_trap_h) / (2^p - 1);

% Уточнённое значение интеграла по Рунге – повышение порядка до p+1 (формула 13)
I_trap_runge = I_trap_half + R_runge;

% Теоретическая оценка погрешности метода трапеций (формула 4)
R_trap_theor = -(b - a) * h_trap^2 / 12 * M2;

fprintf('\nМетод трапеций (шаг h):     %.8f\n', I_trap_h);
fprintf('Метод трапеций (шаг h/2):   %.8f\n', I_trap_half);
fprintf('Уточнённое по Рунге:        %.8f\n', I_trap_runge);
fprintf('Точное значение:            %.8f\n', double(I));
fprintf('Погрешность трапеций:       %.6f%%\n', abs(I_trap_h - double(I)) / abs(double(I)) * 100);
fprintf('Погрешность после Рунге:    %.6f%%\n', abs(I_trap_runge - double(I)) / abs(double(I)) * 100);

% Метод Симпсона
eps_simp = 1e-4;

% Аналитически находим четвёртую производную
M4 = max4;  % максимум модуля четвёртой производной на [a, b]

% Вычисляем максимально допустимый шаг по формуле (9) из лекции
h_simp_max = (180 * eps_simp / ((b - a) * M4))^(1/4);

% Число разбиений должно быть чётным (n = 2m)
n_simp = ceil((b - a) / h_simp_max);
if mod(n_simp, 2) ~= 0
    n_simp = n_simp + 1;
end
h_simp = (b - a) / n_simp;
m = n_simp / 2;  % число пар отрезков

% Формируем сеточную функцию
x_simp = a:h_simp:b;
y_simp = f_num(x_simp);

% Суммы для формулы Симпсона (7):
% 4 * сумма нечётных y (индексы 2,4,...,2m в MATLAB, т.е. i=1..m для y_{2i-1})
sum_odd = sum(y_simp(2:2:end-1));
% 2 * сумма чётных y (индексы 3,5,...,2m-1 в MATLAB, т.е. i=1..m-1 для y_{2i})
sum_even = sum(y_simp(3:2:end-2));

% Формула Симпсона (7)
I_simp = h_simp/3 * (y_simp(1) + y_simp(end) + 4*sum_odd + 2*sum_even);

% Теоретическая погрешность по формуле (8)
R_simp_theor = -(b - a) * h_simp^4 / 180 * M4;

fprintf('\nМетод Симпсона:            %.8f\n', I_simp);
fprintf('Точное значение:           %.8f\n', double(I));
fprintf('Погрешность Симпсона:      %.6f%%\n', abs(I_simp - double(I)) / abs(double(I)) * 100);



%% Сравнение со стандартными функциями MATLAB
f_num = matlabFunction(f);

I_trapz = trapz(x_trap, y_trap);
I_quad = integral(f_num, a, b);
I_integral = integral(f_num, a, b);

fprintf('\nРезультаты:\n');
fprintf('Аналитически:               %.6f\n', double(I));
fprintf('Трапеции:                   %.6f  (%.10e%%)\n', I_trap_h, abs(I_trap_h - double(I)) / abs(double(I)) * 100);
fprintf('Трапеции + Рунге:           %.6f  (%.10e%%)\n', I_trap_runge, abs(I_trap_runge - double(I)) / abs(double(I)) * 100);
fprintf('Симпсон:                    %.6f  (%.10e%%)\n', I_simp, abs(I_simp - double(I)) / abs(double(I)) * 100);
fprintf('MATLAB trapz:               %.6f  (%.10e%%)\n', I_trapz, abs(I_trapz - double(I)) / abs(double(I)) * 100);
fprintf('MATLAB quad (Симпсон):      %.6f  (%.10e%%)\n', I_quad, abs(I_quad - double(I)) / abs(double(I)) * 100);
fprintf('MATLAB integral:            %.6f  (%.10e%%)\n', I_integral, abs(I_integral - double(I)) / abs(double(I)) * 100);

% Create summary table of integration results
methods = {'Analytic'; 'Trap_h'; 'Trap_Runge'; 'Simpson'; 'trapz'; 'quad'; 'integral'};
values = [double(I); I_trap_h; I_trap_runge; I_simp; I_trapz; I_quad; I_integral];
relErrPerc = abs(values - double(I)) ./ abs(double(I)) * 100;
T_summary = table(methods, values, relErrPerc, 'VariableNames', {'Method','Value','RelErrorPercent'});
disp(T_summary)
% writetable(T_summary, 'summary_results.csv');

%% Задание 2: Неопределённый интеграл (аналитически)
syms x a_sym
f2 = a_sym^x * exp(-x);
F2 = int(f2, x);
disp('Задание 2. Неопределённый интеграл:')
disp(F2)

%% Задание 3: Несобственный интеграл (аналитически)
syms x a_sym p_sym 
assume(a_sym > 0)
assume(p_sym > 1)
f3 = (1 + x) / (x + a_sym)^(p_sym + 1);
I3_sym = int(f3, x, 0, Inf);
disp('Задание 3. Несобственный интеграл (аналитически):')

%% приближённое вычисление по формуле 14

disp('Приближённое вычисление по формуле (14)');

% Выберем конкретные числовые параметры для демонстрации
a_val = 2;
p_val = 2;

% Подынтегральная функция (числовая)
f_num = @(x) (1 + x) ./ (x + a_val).^(p_val + 1);

% Точное значение (для сравнения)
I_exact = double(subs(I3_sym, [a_sym, p_sym], [a_val, p_val]));
fprintf('Точное значение (аналитически): %.8f\n', I_exact);

% Итерационный подбор пределов [A, B] по методичке
% Внимание: интеграл от 0 до Inf, поэтому нижний предел фиксирован = 0,
% а верхний B расширяем.
% Формула (14) здесь используется как идея: отрезаем хвост от B до Inf.

tol = 1e-4;
B = 5;
step = 10;
I_prev = 0;
fprintf('\nИтерации подбора верхнего предела B (интеграл от 0 до B):\n');

for iter = 1:10000
    % Численно интегрируем от 0 до B
    I_curr = integral(f_num, 0, B);
    %fprintf('B = %5.1f, I = %.8f\n', B, I_curr);
    
    if abs(I_curr - I_prev) < tol
        fprintf('\nСходимость достигнута.\n');
        break;
    end
    I_prev = I_curr;
    B = B + step;
end
disp(iter);
fprintf('\nПриближённое значение по (14): %.8f\n', I_curr);
fprintf('Абсолютная погрешность: %.2e\n', abs(I_curr - I_exact));
fprintf('Относительная погрешность: %.6f%%\n', abs(I_curr - I_exact) / abs(I_exact) * 100);
%% Шаг 1: Подбор пределов [a, b], где хвосты пренебрежимо малы
f_improper = @(x) (1 + x) ./ (x + a_val).^(p_val + 1);

% Метод последовательного расширения пределов (формула 14)
tol = 1e-8;
B = 10;
step = 10;
I_prev = 0;
fprintf('\nИтерации подбора верхнего предела B:\n');

for iter = 1:100
    I_curr = integral(f_improper, 0, B);
    fprintf('B = %6.1f, I = %.10f, изменение = %.2e\n', B, I_curr, abs(I_curr - I_prev));
    
    if abs(I_curr - I_prev) < tol
        fprintf('\nСходимость достигнута за %d итераций\n', iter);
        break;
    end
    I_prev = I_curr;
    B = B + step;
end

fprintf('\nПриближённое значение по формуле (14): %.10f\n', I_curr);
fprintf('Абсолютная погрешность: %.2e\n', abs(I_curr - I_exact));
fprintf('Относительная погрешность: %.6f%%\n', abs(I_curr - I_exact) / abs(I_exact) * 100);

%% Шаг 2: Вычисление интеграла методом Симпсона
fprintf('\nШАГ 2: Вычисление интеграла методом Симпсона (формула 9)\n');

f4 = diff(f, x, 4);

f4_num = matlabFunction(f4); % в числовую функцию
x_test = linspace(-10, 10, 10000);
M4 = double(vpa(max(abs(f4_num(x_test))))); % максимум модуля

M4 = 24;  % max|f?(x)| для 1/(1+x?)
eps_target = 1e-8;  % требуемая точность

% Формула (9) из методички
h_max = (180 * eps_target / ((b - a) * M4))^(1/4);
n = ceil((b - a) / h_max);
if mod(n, 2) ~= 0
    n = n + 1;  % n должно быть чётным для Симпсона
end
h = (b - a) / n;

fprintf('M? = max|f?(x)| = %.1f\n', M4);
fprintf('Требуемая точность ? = %.2e\n', eps_target);
fprintf('Длина отрезка: %.2e\n', b - a);
fprintf('Максимальный шаг h_max = %.4f\n', double(h_max));
fprintf('Фактический шаг h = %.4f\n', h);
fprintf('Число разбиений n = %d\n', n);

% Вычисляем суммы без создания полного массива
sum_odd = 0;   % сум y_нечёт
sum_even = 0;  % сум y_чёт

for i = 1:n-1
    x_i = a + i * h;
    y_i = f_num(x_i);
    if mod(i, 2) == 1
        sum_odd = sum_odd + y_i;
    else
        sum_even = sum_even + y_i;
    end
end

y0 = f_num(a);
yn = f_num(b);

% Формула Симпсона (7)
I_simpson = h/3 * (y0 + yn + 4 * sum_odd + 2 * sum_even);

% Теоретическая погрешность по формуле (8)
R_theor = (b - a) * h^4 / 180 * M4;

fprintf('\nрезльтаты\n');
fprintf('Метод Симпсона (численно)          : %.15f\n', I_simpson);
fprintf('Точное значение (аналитически)     : %.15f\n', I_exact);
fprintf('Фактическая погрешность            : %.2e\n', abs(I_simpson - I_exact));
fprintf('Теоретическая оценка погрешности   : %.2e\n', R_theor);
fprintf('Относительная погрешность          : %.6f%%\n', abs(I_simpson - I_exact) / abs(I_exact) * 100);


%% Исследование влияния шага h на точность для основной функции
disp('=== ИССЛЕДОВАНИЕ ВЛИЯНИЯ ШАГА h НА ТОЧНОСТЬ ===')
disp('Для функции f(x) = tan(x) + x^2 на интервале [-0.9, 0.9]')

a_int = a;
b_int = b;
syms x
f_sym = tan(x) + x^2;
I_exact = double(int(f_sym, x, a_int, b_int));
fprintf('Точное значение интеграла: %.10f\n\n', I_exact);

% Вычисляем максимумы производных для основной функции
f2_sym = diff(f_sym, x, 2);
f4_sym = diff(f_sym, x, 4);
f2_num = matlabFunction(f2_sym);
f4_num = matlabFunction(f4_sym);

x_check = linspace(a_int, b_int, 10000);
M2 = max(abs(f2_num(x_check)));
M4 = max(abs(f4_num(x_check)));
fprintf('M2 = %.6f, M4 = %.6f\n', M2, M4);
fprintf('Длина отрезка: %.4f\n\n', b_int - a_int);

% Перебираем разные точности (как в методичке)
eps_vec = logspace(-2, -7, 10);

err_trap = zeros(size(eps_vec));
err_runge = zeros(size(eps_vec));
err_simp = zeros(size(eps_vec));
h_vec = zeros(size(eps_vec));
h_simp_vec = zeros(size(eps_vec));
n_vec = zeros(size(eps_vec));
n_simp_vec = zeros(size(eps_vec));

f_num_main = matlabFunction(f_sym);

for i = 1:length(eps_vec)
    eps_target = eps_vec(i);
    
    % Вычисляем шаг по формуле (5) для трапеций
    h_trap = sqrt(12 * eps_target / ((b_int - a_int) * M2));
    n = ceil((b_int - a_int) / h_trap);
    h = (b_int - a_int) / n;
    h_vec(i) = h;
    n_vec(i) = n;
    
    x_trap = linspace(a_int, b_int, n+1);
    y_trap = f_num_main(x_trap);
    
    % Трапеции
    I_tr = h/2 * (y_trap(1) + y_trap(end) + 2*sum(y_trap(2:end-1)));
    err_trap(i) = abs(I_tr - I_exact);
    
    % Рунге (шаг h/2)
    n_half = 2*n;
    h_half = h/2;
    x_half = linspace(a_int, b_int, n_half+1);
    y_half = f_num_main(x_half);
    I_tr2 = h_half/2 * (y_half(1) + y_half(end) + 2*sum(y_half(2:end-1)));
    I_r = I_tr2 + (I_tr2 - I_tr)/3;
    err_runge(i) = abs(I_r - I_exact);
    
    % Симпсон (шаг по формуле (9))
    h_simp = (180 * eps_target / ((b_int - a_int) * M4))^(1/4);
    n_s = ceil((b_int - a_int) / h_simp);
    if mod(n_s, 2) ~= 0
        n_s = n_s + 1;
    end
    h_s = (b_int - a_int) / n_s;
    h_simp_vec(i) = h_s;
    n_simp_vec(i) = n_s;
    
    x_simp = linspace(a_int, b_int, n_s+1);
    y_simp = f_num_main(x_simp);
    I_s = h_s/3 * (y_simp(1) + y_simp(end) + ...
                   4*sum(y_simp(2:2:end-1)) + ...
                   2*sum(y_simp(3:2:end-2)));
    err_simp(i) = abs(I_s - I_exact);
end

% Таблица результатов
T_eps = table(eps_vec(:), h_vec(:), h_simp_vec(:), n_vec(:), n_simp_vec(:), ...
              err_trap(:), err_runge(:), err_simp(:), ...
              'VariableNames', {'Eps','h_trap','h_simp','n_trap','n_simp',...
                                'err_trap','err_runge','err_simp'});
disp(T_eps)



%% Прямой перебор шагов h для основной функции
disp(' ')
disp('Исследование влияния шага h на точность (h — независимая переменная)')
fprintf('Для функции f(x) = tan(x) + x^2 на интервале [%.2f, %.2f]\n', a, b);

f_num_main = matlabFunction(tan(x) + x^2);
a_int = a;
b_int = b;
I_exact = double(int(tan(x) + x^2, x, a_int, b_int));

n_direct = [10, 20, 40, 60, 100, 200, 400, 600, 1000, 2000];

err_trap_direct = zeros(size(n_direct));
err_runge_direct = zeros(size(n_direct));
err_simp_direct = zeros(size(n_direct));
err_simp_runge_direct = zeros(size(n_direct));
h_direct = zeros(size(n_direct));

for i = 1:length(n_direct)
    n = n_direct(i);
    
    % для Симпсона нужно чётное n
    n_s = n;
    if mod(n_s, 2) ~= 0
        n_s = n_s + 1;
    end
    
    h = (b_int - a_int) / n;
    h_direct(i) = h;
    
    % Трапеции
    x_trap = linspace(a_int, b_int, n+1);
    y_trap = f_num_main(x_trap);
    I_tr = h/2 * (y_trap(1) + y_trap(end) + 2*sum(y_trap(2:end-1)));
    err_trap_direct(i) = abs(I_tr - I_exact);
    
    % Рунге
    x_half = linspace(a_int, b_int, 2*n+1);
    y_half = f_num_main(x_half);
    I_tr2 = (h/2)/2 * (y_half(1) + y_half(end) + 2*sum(y_half(2:end-1)));
    I_r = I_tr2 + (I_tr2 - I_tr)/3;
    err_runge_direct(i) = abs(I_r - I_exact);
    
%  Симпсон с шагом h
    n_h = n*2;
    if mod(n_h, 2) ~= 0, n_h = n_h + 1; end % делаем чётным
    h_s = (b_int - a_int) / n_h;
    
    x_simp_h = linspace(a_int, b_int, n_h+1);
    y_simp_h = f_num_main(x_simp_h);
    I_simp_h = (h_s/3) * (y_simp_h(1) + y_simp_h(end) + ...
                          4*sum(y_simp_h(2:2:end-1)) + ...
                          2*sum(y_simp_h(3:2:end-2)));

    % Симпсон с шагом h/2 (удваиваем число интервалов) 
    n_half = n_h * 2; 
    h_half = h_s / 2;
    
    x_simp_half = linspace(a_int, b_int, n_half+1);
    y_simp_half = f_num_main(x_simp_half);
    I_simp_half = (h_half/3) * (y_simp_half(1) + y_simp_half(end) + ...
                                4*sum(y_simp_half(2:2:end-1)) + ...
                                2*sum(y_simp_half(3:2:end-2)));

    % --- 3. Уточнение по Рунге (для Симпсона делим на 15) ---
    I_simp_runge = I_simp_half + (I_simp_half - I_simp_h) / 15;

    % Сохраняем ошибки
    err_simp_direct(i) = abs(I_simp_h - I_exact);           % Обычный Симпсон
    err_simp_runge_direct(i) = abs(I_simp_runge - I_exact);
end 

%% График зависимости ошибки от шага (прямой перебор h)
figure;
% Основные методы
loglog(h_direct, err_trap_direct, 'o-', 'LineWidth', 1.5, 'MarkerSize', 6); hold on;
loglog(h_direct, err_runge_direct, 's-', 'LineWidth', 1.5, 'MarkerSize', 6);
loglog(h_direct, err_simp_direct, 'd-', 'LineWidth', 1.5, 'MarkerSize',     6);
loglog(h_direct, err_simp_runge_direct, 'p-', 'LineWidth', 1.5, 'MarkerSize', 6); % Симпсон+Рунге

% Теоретические наклоны для визуального сравнения порядка
h_ref = h_direct;
loglog(h_ref, 0.1*h_ref.^2, 'k:', 'LineWidth', 1);   % Ожидаемый наклон h^2
loglog(h_ref, 0.01*h_ref.^4, 'k-.', 'LineWidth', 1); % Ожидаемый наклон h^4
% Примечание: Симпсон+Рунге должен иметь наклон h^6

grid on;
xlabel('Шаг h');
ylabel('Абсолютная ошибка');
title('Зависимость ошибки от шага h (сравнение всех методов)');
legend('Трапеции (O(h^2))', ...
       'Симпсон (O(h^4))', 'Симпсон+Рунге (O(h^6))', ...
       '~h^2', '~h^4', 'Location', 'southeast');
set(gca, 'FontSize', 12);

%% Вывод таблицы
% Create table for direct-h sweep results
T_h_direct = table(n_direct(:), h_direct(:), err_trap_direct(:), err_runge_direct(:), err_simp_direct(:), err_simp_runge_direct(:), ...
    'VariableNames', {'n','h','err_trap','err_runge','err_simp','err_simp_runge'});
disp(T_h_direct)
% writetable(T_h_direct, 'errors_vs_h.csv');
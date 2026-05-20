clear
clc
close all

%% Параметры
a = -5;  % левая граница
b = 5;   % правая граница

%% Исходная функция
syms x;
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
f_plot = @(t) tan(t) + t.^2;
try
    h = fplot(f_plot, [a, b]);
    if ~isgraphics(h)
        error('NoGraphicsHandle');
    end
    set(h, 'Color', 'b', 'LineWidth', 2);
catch
    % fplot can fail for functions with singularities (tan). Fall back to sampled plot
    xs = linspace(a, b, 2000);
    ys = f_plot(xs);
    bad = ~isfinite(ys) | abs(ys) > 1e6;
    xs(bad) = [];
    ys(bad) = [];
    h = plot(xs, ys, 'b-', 'LineWidth', 2);
end
xlabel('x');
ylabel('f(x)');
title(sprintf('График f(x) = x^3 + e^x на [%d, %d]', a, b));
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
% Numerical integration avoiding singularities of tan(x)
eps_pole = 1e-3; % exclude a small neighborhood around each pole
min_seg_len = 1e-6; % skip segments shorter than this
kmin = ceil((a - pi/2)/pi);
kmax = floor((b - pi/2)/pi);
if kmin <= kmax
    poles = (pi/2) + (kmin:kmax)*pi;
else
    poles = [];
end
cuts = [a];
for p = poles
    % only add cuts that lie inside [a,b]
    left = p - eps_pole;
    right = p + eps_pole;
    if left > a && left < b
        cuts = [cuts, left];
    end
    if right > a && right < b
        cuts = [cuts, right];
    end
end
cuts = [cuts, b];
cuts = sort(cuts);

I_quad = 0;
I_integral = 0;
for i = 1:length(cuts)-1
    s = cuts(i);
    e = cuts(i+1);
    seg_len = e - s;
    if seg_len < min_seg_len
        continue; % skip tiny segments
    end
    % prefer quadgk for difficult integrands
    Iq = NaN;
    try
        Iq = quadgk(f_num, s, e, 'AbsTol', 1e-9, 'RelTol', 1e-6, 'MaxIntervalCount', 2000);
    catch
        Iq = NaN;
    end
    if ~isnan(Iq)
        I_quad = I_quad + Iq;
    else
        % fallback to integral with relaxed tolerances
        try
            Iseg = integral(f_num, s, e, 'RelTol', 1e-6, 'AbsTol', 1e-9);
        catch
            Iseg = NaN;
        end
        if ~isnan(Iseg)
            I_integral = I_integral + Iseg;
        end
    end
end

fprintf('\nРезультаты:\n');
fprintf('Аналитически:               %.6f\n', double(I));
fprintf('Трапеции:                   %.6f  (%.10e%%)\n', I_trap_h, abs(I_trap_h - double(I)) / abs(double(I)) * 100);
fprintf('Трапеции + Рунге:           %.6f  (%.10e%%)\n', I_trap_runge, abs(I_trap_runge - double(I)) / abs(double(I)) * 100);
fprintf('Симпсон:                    %.6f  (%.10e%%)\n', I_simp, abs(I_simp - double(I)) / abs(double(I)) * 100);
fprintf('MATLAB trapz:               %.6f  (%.10e%%)\n', I_trapz, abs(I_trapz - double(I)) / abs(double(I)) * 100);
fprintf('MATLAB quad (Симпсон):      %.6f  (%.10e%%)\n', I_quad, abs(I_quad - double(I)) / abs(double(I)) * 100);
fprintf('MATLAB integral:            %.6f  (%.10e%%)\n', I_integral, abs(I_integral - double(I)) / abs(double(I)) * 100);

%% Задание 2: Неопределённый интеграл (аналитически)
syms x a
f2 = a^x * exp(-x);
F2 = int(f2, x);
disp('Задание 2. Неопределённый интеграл:')
pretty(F2)

syms x
f = x^3 + exp(x);
I = int(f, x, -Inf, Inf);
disp('Значение интеграла из задачи 9 от -беск до + беск');
disp(I); %почему эта функция не подходит.

%% Задание 3: Несобственный интеграл (аналитически)
syms x a p 
assume(a > 0)
assume(p > 1)
f3 = (1 + x) / (x + a)^(p + 1);
I3_sym = int(f3, x, 0, Inf);
disp('Задание 3. Несобственный интеграл (аналитически):')
pretty(I3_sym)

%% приближённое вычисление по формуле 14

disp('---------------------------------------------');
disp('Приближённое вычисление по формуле (14)');

% Выберем конкретные числовые параметры для демонстрации
a_val = 2;
p_val = 2;

% Подынтегральная функция (числовая)
f_num = @(x) (1 + x) ./ (x + a_val).^(p_val + 1);

% Точное значение (для сравнения)
I_exact = double(subs(I3_sym, [a, p], [a_val, p_val]));
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
disp('__________________');
%% Шаг 1: Подбор пределов [a, b], где хвосты пренебрежимо малы
f_num = @(x) 1 ./ (1 + x.^2);
syms x; f = 1/(1+x^2);
I_numeric = double(int(f, x, -Inf, Inf));

tol_tail = 1e-4;  % ослабляем до разумного
a = -1;
b = 1;

fprintf('шаг 1: Поиск пределов, где хвосты малы\n');

for iter = 1:50
    % Вычисляем хвосты
    left_tail = integral(f_num, -Inf, a);
    right_tail = integral(f_num, b, Inf);
    
    fprintf('a = %10.1f, b = %10.1f, левый хвост = %.2e, правый хвост = %.2e\n', ...
            a, b, left_tail, right_tail);
    
    % Проверяем: оба хвоста меньше tol_tail?
    if abs(left_tail) < tol_tail && abs(right_tail) < tol_tail
        fprintf('\nНайдены пределы: a = %.1f, b = %.1f\n', a, b);
        fprintf('Левый хвост = %.2e, правый хвост = %.2e (оба < %.0e)\n', ...
                left_tail, right_tail, tol_tail);
        break;
    end
    
    % Расширяем пределы
    a = a * 2;
    b = b * 2;
end

%% Шаг 2: Вычисление интеграла методом Симпсона
fprintf('\nШАГ 2: Вычисление интеграла методом Симпсона (формула 9)\n');

f4 = diff(f, x, 4);         % четвёртая производная
pretty(f4)                   % вывод формулы

f4_num = matlabFunction(f4); % в числовую функцию
x_test = linspace(-10, 10, 10000);
M4 = max(abs(f4_num(x_test))); % максимум модуля

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
fprintf('Максимальный шаг h_max = %.4f\n', h_max);
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

fprintf('\n=== РЕЗУЛЬТАТЫ ===\n');
fprintf('Метод Симпсона (численно)          : %.15f\n', I_simpson);
fprintf('Точное значение (аналитически)     : %.15f\n', I_numeric);
fprintf('Фактическая погрешность            : %.2e\n', abs(I_simpson - I_numeric));
fprintf('Теоретическая оценка погрешности   : %.2e\n', R_theor);
fprintf('Относительная погрешность          : %.6f%%\n', abs(I_simpson - I_numeric) / I_numeric * 100);



%% шаг точность
disp('анализ влияния шага на точность интегрирования')
disp('шаг вычисляется по формулам из методички для разных точностей')

f_num = @(x) x.^2 + exp(x + 3);
a_int = -5;
b_int = 5;

syms x
f_sym = x^2 + exp(x + 3);
I_exact = double(int(f_sym, x, a_int, b_int));
fprintf('Точное значение интеграла: %.8f\n', I_exact);

% Вычисляем максимумы производных
f2_sym = diff(f_sym, x, 2);
f4_sym = diff(f_sym, x, 4);
f2_num = matlabFunction(f2_sym);
f4_num = matlabFunction(f4_sym);

x_check = linspace(a_int, b_int, 10000);
M2 = max(abs(f2_num(x_check)));
M4 = max(abs(f4_num(x_check)));
fprintf('M2 = %.4f, M4 = %.4f\n', M4);
fprintf('Длина отрезка: %.4f\n', b_int - a_int);

% Перебираем разные точности (как в методичке)
eps_vec = logspace(-2, -7, 20);  % меньше точек для читаемой таблицы

err_trap = zeros(size(eps_vec));
err_runge = zeros(size(eps_vec));
err_simp = zeros(size(eps_vec));
h_vec = zeros(size(eps_vec));
h_simp_vec = zeros(size(eps_vec));
n_vec = zeros(size(eps_vec));
n_simp_vec = zeros(size(eps_vec));

for i = 1:length(eps_vec)
    eps_target = eps_vec(i);
    
    % Вычисляем шаг по формуле (5) для трапеций
    h_trap = sqrt(12 * eps_target / ((b_int - a_int) * M2));
    n = ceil((b_int - a_int) / h_trap);
    h = (b_int - a_int) / n;
    h_vec(i) = h;
    n_vec(i) = n;
    
    x_trap = linspace(a_int, b_int, n+1);
    y_trap = f_num(x_trap);
    
    % Трапеции
    I_tr = h/2 * (y_trap(1) + y_trap(end) + 2*sum(y_trap(2:end-1)));
    err_trap(i) = abs(I_tr - I_exact);
    
    % Рунге (шаг h/2)
    n_half = 2*n;
    h_half = h/2;
    x_half = linspace(a_int, b_int, n_half+1);
    y_half = f_num(x_half);
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
    y_simp = f_num(x_simp);
    I_s = h_s/3 * (y_simp(1) + y_simp(end) + ...
                   4*sum(y_simp(2:2:end-1)) + ...
                   2*sum(y_simp(3:2:end-2)));
    err_simp(i) = abs(I_s - I_exact);
end




%%  перебор шагов h
disp(' ')
disp('=Исследование влияния шага h на точность (h — независимая переменная)')

n_direct = [4, 6, 10, 20, 40, 60, 100, 200, 400, 600, 1000, 2000, 4000, 6000, 10000,20000,35000,70000,100000];

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
    y_trap = f_num(x_trap);
    I_tr = h/2 * (y_trap(1) + y_trap(end) + 2*sum(y_trap(2:end-1)));
    err_trap_direct(i) = abs(I_tr - I_exact);
    
    % Рунге
    x_half = linspace(a_int, b_int, 2*n+1);
    y_half = f_num(x_half);
    I_tr2 = (h/2)/2 * (y_half(1) + y_half(end) + 2*sum(y_half(2:end-1)));
    I_r = I_tr2 + (I_tr2 - I_tr)/3;
    err_runge_direct(i) = abs(I_r - I_exact);
    
%  Симпсон с шагом h
    n_h = n*2;
    if mod(n_h, 2) ~= 0, n_h = n_h + 1; end % делаем чётным
    h_s = (b_int - a_int) / n_h;
    
    x_simp_h = linspace(a_int, b_int, n_h+1);
    y_simp_h = f_num(x_simp_h);
    I_simp_h = (h_s/3) * (y_simp_h(1) + y_simp_h(end) + ...
                          4*sum(y_simp_h(2:2:end-1)) + ...
                          2*sum(y_simp_h(3:2:end-2))); % <-- обрати внимание на end-2

    % Симпсон с шагом h/2 (удваиваем число интервалов) 
    n_half = n_h * 2; 
    h_half = h_s / 2;
    
    x_simp_half = linspace(a_int, b_int, n_half+1);
    y_simp_half = f_num(x_simp_half);
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
loglog(h_direct, err_simp_direct, 'd-', 'LineWidth', 1.5, 'MarkerSize', 6);
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
legend('Трапеции (O(h^2))', 'Трапеции+Рунге (O(h^4))', ...
       'Симпсон (O(h^4))', 'Симпсон+Рунге (O(h^6))', ...
       '~h^2', '~h^4', 'Location', 'southeast');
set(gca, 'FontSize', 12);

%% Вывод таблицы
fprintf('\n%-8s %-12s %-14s %-14s %-14s %-14s\n', ...
        'n', 'h', 'err_trap', 'err_runge', 'err_simp', 'err_simp_R');
fprintf('%s\n', repmat('-', 1, 80));

for i = 1:length(n_direct)
    fprintf('%-8d %-12.6f %-14.4e %-14.4e %-14.4e %-14.4e\n', ...
        n_direct(i), h_direct(i), ...
        err_trap_direct(i), ...
        err_runge_direct(i), ...
        err_simp_direct(i), ...
        err_simp_runge_direct(i));
end
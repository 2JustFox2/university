clear; clc;

A = [3, 2, 1, 5;
     1, 2, 3, 4;
     8, 9, 5, 4;
     8, 4, 2, 3];
b = [42; 47; 142; 89];

fprintf('Исходная матрица A:\n');
disp(A);
fprintf('Вектор b:\n');
disp(b);

%% Анализ матрицы
fprintf('\nАнализ матрицы\n');

det_A = det(A);
fprintf('Определитель (det(A)): %.4f\n', det_A);

if abs(det_A) < 1e-10
    fprintf('Матрица вырожденная!\n');
else
    fprintf('Матрица невырожденная, система имеет единственное решение.\n');
end

% Ранг матрицы
rank_A = rank(A);
fprintf('Ранг матрицы (rank(A)): %d\n', rank_A);

% Число обусловленности
cond_A = cond(A, inf);
fprintf('Число обусловленности (cond(A)): %.4f\n', cond_A);
if cond_A > 1000
    fprintf('Система плохо обусловлена.\n');
else
    fprintf('Система обусловлена хорошо.\n');
end

%% Точное решение
fprintf('\nТочное решение\n');
x_exact = linsolve(A, b);
fprintf('Решение:\n');
for i = 1:length(x_exact)
    fprintf('x%d = %.6f\n', i, x_exact(i));
end

%% Преобразование системы для обеспечения сходимости итерационных методов
fprintf('\nПреобразование системы\n');

% Метод 1: Приведение к диагональному преобладанию перестановкой строк
fprintf('\n1. Пытаемся достичь диагонального преобладания перестановкой строк...\n');

% Проверяем исходное диагональное преобладание
has_diag_dominance = true;
n = size(A, 1);
for i = 1:n
    sum_row = sum(abs(A(i, :))) - abs(A(i, i));
    if abs(A(i, i)) <= sum_row
        has_diag_dominance = false;
        fprintf('Строка %d: |%d| <= %.2f - диагональное преобладание нарушено\n', i, A(i,i), sum_row);
    end
end

if ~has_diag_dominance
    fprintf('\nПробуем переставить строки для достижения диагонального преобладания...\n');
    
    % Создаем перестановку строк, чтобы максимизировать диагональные элементы
    A_perm = A;
    b_perm = b;
    perm = 1:n;
    
    % Жадный алгоритм перестановки строк
    for i = 1:n
        % Ищем строку с максимальным диагональным элементом
        max_val = abs(A_perm(i, i));
        max_row = i;
        for j = i+1:n
            if abs(A_perm(j, i)) > max_val
                max_val = abs(A_perm(j, i));
                max_row = j;
            end
        end
        % Меняем строки местами
        if max_row ~= i
            A_perm([i, max_row], :) = A_perm([max_row, i], :);
            b_perm([i, max_row]) = b_perm([max_row, i]);
            perm([i, max_row]) = perm([max_row, i]);
            fprintf('Поменяли строки %d и %d\n', i, max_row);
        end
    end
    
    fprintf('\nМатрица после перестановки строк:\n');
    disp(A_perm);
    
    % Проверяем диагональное преобладание после перестановки
    has_diag_dominance_after = true;
    for i = 1:n
        sum_row = sum(abs(A_perm(i, :))) - abs(A_perm(i, i));
        if abs(A_perm(i, i)) <= sum_row
            has_diag_dominance_after = false;
            fprintf('Строка %d все еще не имеет диагонального преобладания\n', i);
        end
    end
    
    if has_diag_dominance_after
        fprintf('\nУспешно достигнуто диагональное преобладание!\n');
        A = A_perm;
        b = b_perm;
    else
        fprintf('\nПерестановка строк не дала полного диагонального преобладания.\n');
        fprintf('Используем метод релаксации для улучшения сходимости.\n');
    end
end

%% Метод 2: Использование метода верхней релаксации (SOR) для гарантированной сходимости
fprintf('\nРешение методом верхней релаксации\n');

epsilon = 1e-6;
max_iter = 5000;
x0 = zeros(n, 1);

% Оптимальный параметр релаксации для SOR
% Для плохо обусловленных систем используем w = 1.2 - 1.5
w_optimal = 1.3;
fprintf('Параметр релаксации SOR: w = %.2f\n', w_optimal);

x_sor = x0;
iter_sor = 0;
converged_sor = false;

for iter = 1:max_iter
    x_old = x_sor;
    
    % Метод SOR
    for i = 1:n
        sum1 = 0;
        sum2 = 0;
        for j = 1:i-1
            sum1 = sum1 + A(i, j) * x_sor(j);
        end
        for j = i+1:n
            sum2 = sum2 + A(i, j) * x_old(j);
        end
        x_sor(i) = (1 - w_optimal) * x_old(i) + w_optimal * (b(i) - sum1 - sum2) / A(i, i);
    end
    
    if norm(x_sor - x_old, inf) < epsilon
        iter_sor = iter;
        converged_sor = true;
        break;
    end
    iter_sor = iter;
end

if converged_sor
    fprintf('\nРешение методом SOR (итераций: %d):\n', iter_sor);
    for i = 1:length(x_sor)
        fprintf('x%d = %.8f\n', i, x_sor(i));
    end
    fprintf('Погрешность относительно точного решения: %.2e\n', norm(x_sor - x_exact, inf));
else
    fprintf('Метод SOR не сошелся за %d итераций.\n', max_iter);
end

%% Метод 3: Метод сопряженных градиентов (для симметричных систем)
fprintf('\nМетод сопряженных градиентов\n');

% Используем CGNR для несимметричных систем
x_cgnr = x0;
r = b - A * x_cgnr;
p = A' * r;
iter_cgnr = 0;
converged_cgnr = false;

for iter = 1:max_iter
    Ap = A * p;
    alpha = (r' * r) / (p' * Ap);
    x_cgnr = x_cgnr + alpha * p;
    r_new = r - alpha * Ap;
    
    if norm(r_new, inf) < epsilon * norm(b, inf)
        iter_cgnr = iter;
        converged_cgnr = true;
        break;
    end
    
    beta = (r_new' * r_new) / (r' * r);
    p = A' * r_new + beta * p;
    r = r_new;
    iter_cgnr = iter;
end

if converged_cgnr
    fprintf('\nРешение методом CGNR (итераций: %d):\n', iter_cgnr);
    for i = 1:length(x_cgnr)
        fprintf('x%d = %.8f\n', i, x_cgnr(i));
    end
    fprintf('Погрешность относительно точного решения: %.2e\n', norm(x_cgnr - x_exact, inf));
else
    fprintf('Метод CGNR не сошелся за %d итераций.\n', max_iter);
end

%% Метод 4: Модифицированный метод простой итерации с оптимальным параметром
fprintf('\nМодифицированный метод простой итерации\n');

% Находим оптимальный параметр tau
% Для сходимости необходимо: 0 < tau < 2 / ?_max
% Оцениваем спектральный радиус
eig_vals = eig(A);
lambda_max = max(abs(eig_vals));
lambda_min = min(abs(eig_vals));

% Оптимальный параметр для симметричных положительно определенных матриц
tau_optimal = 2 / (lambda_max + lambda_min);
fprintf('Оценка спектра: ?_min ? %.4f, ?_max ? %.4f\n', lambda_min, lambda_max);
fprintf('Оптимальный параметр tau = %.6f\n', tau_optimal);

% Используем безопасный параметр
norm_A = norm(A, inf);
tau = min(tau_optimal, 1 / norm_A);
fprintf('Используемый параметр tau = %.6f\n', tau);

x_simple = x0;
iter_simple = 0;
converged_simple = false;

for iter = 1:max_iter
    x_new = x_simple + tau * (b - A * x_simple);
    
    if norm(x_new - x_simple, inf) < epsilon
        x_simple = x_new;
        iter_simple = iter;
        converged_simple = true;
        break;
    end
    x_simple = x_new;
    iter_simple = iter;
end

if converged_simple
    fprintf('\nРешение модифицированным методом простой итерации (итераций: %d):\n', iter_simple);
    for i = 1:length(x_simple)
        fprintf('x%d = %.8f\n', i, x_simple(i));
    end
    fprintf('Погрешность относительно точного решения: %.2e\n', norm(x_simple - x_exact, inf));
else
    fprintf('Метод простой итерации не сошелся за %d итераций.\n', max_iter);
end

%% Метод 5: Прямое решение с помощью левой и правой прекондиции
fprintf('\nРешение с предобуславливанием\n');

% Используем диагональное предобуславливание
D = diag(diag(A));
M = diag(1 ./ sqrt(diag(A))); % Матрица предобуславливания

A_precond = M * A * M;
b_precond = M * b;

x_precond = zeros(n, 1);
iter_precond = 0;
converged_precond = false;

% Метод Зейделя с предобуславливанием
for iter = 1:max_iter
    x_old = x_precond;
    
    for i = 1:n
        sum1 = 0;
        sum2 = 0;
        for j = 1:i-1
            sum1 = sum1 + A_precond(i, j) * x_precond(j);
        end
        for j = i+1:n
            sum2 = sum2 + A_precond(i, j) * x_old(j);
        end
        x_precond(i) = (b_precond(i) - sum1 - sum2) / A_precond(i, i);
    end
    
    if norm(x_precond - x_old, inf) < epsilon
        iter_precond = iter;
        converged_precond = true;
        break;
    end
    iter_precond = iter;
end

% Возвращаем к исходным переменным
x_precond = M \ x_precond;

if converged_precond
    fprintf('\nРешение методом Зейделя с предобуславливанием (итераций: %d):\n', iter_precond);
    for i = 1:length(x_precond)
        fprintf('x%d = %.8f\n', i, x_precond(i));
    end
    fprintf('Погрешность относительно точного решения: %.2e\n', norm(x_precond - x_exact, inf));
else
    fprintf('Метод с предобуславливанием не сошелся за %d итераций.\n', max_iter);
end

%% Итоговое сравнение
fprintf('Сравнение методов\n');
fprintf('Точное решение:\n');
fprintf('  x1 = %.8f, x2 = %.8f, x3 = %.8f, x4 = %.8f\n', x_exact(1), x_exact(2), x_exact(3), x_exact(4));

if converged_sor
    fprintf('\nSOR метод (w=%.2f):\n', w_optimal);
    fprintf('  x1 = %.8f, x2 = %.8f, x3 = %.8f, x4 = %.8f\n', x_sor(1), x_sor(2), x_sor(3), x_sor(4));
    fprintf('  Итераций: %d, Погрешность: %.2e\n', iter_sor, norm(x_sor - x_exact, inf));
end

if converged_cgnr
    fprintf('\nМетод CGNR:\n');
    fprintf('  x1 = %.8f, x2 = %.8f, x3 = %.8f, x4 = %.8f\n', x_cgnr(1), x_cgnr(2), x_cgnr(3), x_cgnr(4));
    fprintf('  Итераций: %d, Погрешность: %.2e\n', iter_cgnr, norm(x_cgnr - x_exact, inf));
end

if converged_simple
    fprintf('\nМетод простой итерации:\n');
    fprintf('  x1 = %.8f, x2 = %.8f, x3 = %.8f, x4 = %.8f\n', x_simple(1), x_simple(2), x_simple(3), x_simple(4));
    fprintf('  Итераций: %d, Погрешность: %.2e\n', iter_simple, norm(x_simple - x_exact, inf));
end

if converged_precond
    fprintf('\nМетод Зейделя с предобуславливанием:\n');
    fprintf('  x1 = %.8f, x2 = %.8f, x3 = %.8f, x4 = %.8f\n', x_precond(1), x_precond(2), x_precond(3), x_precond(4));
    fprintf('  Итераций: %d, Погрешность: %.2e\n', iter_precond, norm(x_precond - x_exact, inf));
end

fprintf('\nИтоговый код доступа: %d %d %d %d\n', round(x_exact(1)), round(x_exact(2)), round(x_exact(3)), round(x_exact(4)));
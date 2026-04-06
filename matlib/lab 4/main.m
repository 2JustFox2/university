%% Решение СЛАУ - полная версия с сохранением данных

clear; clc;

% Исходные данные
A = [3 2 1 5; 1 2 3 4; 8 9 5 4; 8 4 2 3];
b = [42; 47; 142; 89];
n = size(A,1);

%% 1. Анализ матрицы
fprintf('1. АНАЛИЗ МАТРИЦЫ СИСТЕМЫ\n');
fprintf('Детерминант:                 det(A) = %.0f\n', det(A));
fprintf('Ранг:                       rank(A) = %d\n', rank(A));
fprintf('1-норма:                     ||A||  = %.2f\n', norm(A,1));
fprintf('1-норма:                     ||b||  = %.2f\n', norm(b,1));
fprintf('Число обусловленности:      cond(A) = %.2f\n', cond(A,1));
fprintf('\n');

%% 2. Точное решение
fprintf('2. ТОЧНОЕ РЕШЕНИЕ (linsolve)\n');
x_exact = linsolve(A,b);
fprintf('x1 = %.0f, x2 = %.0f, x3 = %.0f, x4 = %.0f\n', x_exact);
fprintf('Проверка: A*x = [%.0f, %.0f, %.0f, %.0f]^T\n', A*x_exact);
fprintf('\n');

%% 3. Подбор перенумерации неизвестных
fprintf('3. ПЕРЕНУМЕРАЦИЯ НЕИЗВЕСТНЫХ ДЛЯ УСИЛЕНИЯ ДИАГОНАЛИ\n');

best_min_ratio = -Inf;
best_sum_ratio = -Inf;
best_perm = 1:n;
perms_all = perms(1:n);

for p = 1:size(perms_all,1)
    perm = perms_all(p,:);
    A_try = A(:,perm);
    d = abs(diag(A_try));
    s = sum(abs(A_try),2) - d;
    ratio = d ./ s;
    min_ratio = min(ratio);
    sum_ratio = sum(ratio);

    if (min_ratio > best_min_ratio) || (abs(min_ratio - best_min_ratio) < 1e-12 && sum_ratio > best_sum_ratio)
        best_min_ratio = min_ratio;
        best_sum_ratio = sum_ratio;
        best_perm = perm;
    end
end

A_iter = A(:,best_perm);
b_iter = b;

orig_ratio = abs(diag(A)) ./ (sum(abs(A),2) - abs(diag(A)));
iter_ratio = abs(diag(A_iter)) ./ (sum(abs(A_iter),2) - abs(diag(A_iter)));

fprintf('Перестановка неизвестных (новый порядок столбцов): [%d %d %d %d]\n', best_perm);
% fprintf('min(|aii|/sum|aij|, j!=i): до = %.4f, после = %.4f\n', min(orig_ratio), min(iter_ratio));
% fprintf('sum(|aii|/sum|aij|, j!=i): до = %.4f, после = %.4f\n', sum(orig_ratio), sum(iter_ratio));
fprintf('\n');

%% 4. Автоподбор tau и метод простой итерации
fprintf('4. АВТОПОДБОР TAU И МЕТОД ПРОСТОЙ ИТЕРАЦИИ\n');
epsilon = 1e-6;

tau_candidates = linspace(1e-4, 2 / norm(A_iter,inf), 2000);
tau_best = tau_candidates(1);
rho_tau_best = Inf;
normB_best = Inf;

for tau_candidate = tau_candidates
    B_candidate = eye(n) - tau_candidate*A_iter;
    rho_candidate = max(abs(eig(B_candidate)));
    if rho_candidate < rho_tau_best - 1e-12
        tau_best = tau_candidate;
        rho_tau_best = rho_candidate;
        normB_best = norm(B_candidate, inf);
        B = B_candidate;
    end
end

fprintf('Лучшее tau по min rho(I - tau*A): %.6f\n', tau_best);
fprintf('Минимальный спектральный радиус: %.6f\n', rho_tau_best);
fprintf('Норма итерационной матрицы: ||B|| = %.6f\n', normB_best);

if rho_tau_best < 1
    fprintf('условие сходимости выполнено\n');
    
    y = zeros(n,1);
    F = tau_best*b_iter;
    iter = 0;
    
    for k = 1:1000
        y_new = B*y + F;
        if norm(y_new - y, inf) < epsilon
            y = y_new;
            iter = k;
            break;
        end
        y = y_new;
    end

    x = zeros(n,1);
    x(best_perm) = y;
    
    fprintf('Решение: [%.6f, %.6f, %.6f, %.6f]\n', x);
    fprintf('Число итераций: %d\n', iter);
    fprintf('Невязка: ||Ax-b|| = %.2e\n', norm(A*x - b, inf));
    x_simple = x;
    iter_simple = iter;
else
    fprintf('на выбранном диапазоне tau сходимость не достигнута\n');
    x_simple = NaN(4,1);
    iter_simple = Inf;
end
fprintf('\n');

%% 5. Метод Якоби
fprintf('5. МЕТОД ЯКОБИ\n');

A = A' * A;
b = A' * b;

D = diag(diag(A));
L = tril(A) - D;
U = triu(A) - D;

Bj = -inv(D) \ (L + U);          
rho_J = D \ b;
fprintf('Спектральный радиус матрицы Якоби: (B_J) = %.6f', rho_J);
b_norma = norm(Bj)

if rho_J < 1
    fprintf('условие выполнено\n');
    
    y = zeros(n,1);
    D_inv = diag(1./diag(D));
    iter = 0;
    
    for k = 1:5000
        y_new = -D_inv*(L+U)*y + D_inv*b_iter;
        if norm(y_new - y, inf) < epsilon
            y = y_new;
            iter = k;
            break;
        end
        y = y_new;
    end

    x = zeros(n,1);
    x(best_perm) = y;
    
    fprintf('Решение: [%.6f, %.6f, %.6f, %.6f]\n', x);
    fprintf('Число итераций: %d\n', iter);
    x_jacobi = x;
    iter_jacobi = iter;
else
    fprintf('условие не выполнено метод расходится\n');
    x_jacobi = NaN(4,1);
    iter_jacobi = Inf;
end
fprintf('\n');

%% 6. Метод Зейделя
fprintf('6. МЕТОД ЗЕЙДЕЛЯ\n');

D = diag(diag(A_iter));
L = tril(A_iter,-1);
U = triu(A_iter,1);
B_S = -inv(L+D)*U;
rho_S = max(abs(eig(B_S)));
fprintf('Спектральный радиус матрицы Зейделя:(B_S) = %.6f ', rho_S);

if rho_S < 1
    fprintf('условие выполнено\n');
    
    y = zeros(n,1);
    iter = 0;
    
    for k = 1:1000
        y_new = y;
        for i = 1:n
            s1 = A_iter(i,1:i-1)*y_new(1:i-1);
            s2 = A_iter(i,i+1:n)*y(i+1:n);
            y_new(i) = (b_iter(i) - s1 - s2)/A_iter(i,i);
        end
        if norm(y_new - y, inf) < epsilon
            y = y_new;
            iter = k;
            break;
        end
        y = y_new;
    end

    x = zeros(n,1);
    x(best_perm) = y;
    
    fprintf('Решение: [%.6f, %.6f, %.6f, %.6f]\n', x);
    fprintf('Число итераций: %d\n', iter);
    fprintf('Невязка: ||Ax-b|| = %.2e\n', norm(A*x - b, inf));
    x_seidel = x;
    iter_seidel = iter;
else
    fprintf('условие не выполнено\n');
    x_seidel = NaN(4,1);
    iter_seidel = Inf;
end
fprintf('\n');

%% 7. Метод SOR с автоподбором omega
fprintf('7. МЕТОД SOR С АВТОПОДБОРОМ OMEGA\n');

omega_candidates = linspace(0.05, 1.95, 400);
omega_best = omega_candidates(1);
rho_omega_best = Inf;

for omega_candidate = omega_candidates
    B_candidate = (D + omega_candidate*L) \ ((1 - omega_candidate)*D - omega_candidate*U);
    rho_candidate = max(abs(eig(B_candidate)));
    if rho_candidate < rho_omega_best - 1e-12
        omega_best = omega_candidate;
        rho_omega_best = rho_candidate;
    end
end

fprintf('Лучшее omega по min rho(B_omega): %.6f\n', omega_best);
fprintf('Минимальный спектральный радиус: %.6f\n', rho_omega_best);

if rho_omega_best < 1
    fprintf('условие сходимости выполнено\n');

    y = zeros(n,1);
    iter = 0;

    for k = 1:1000
        y_new = y;
        for i = 1:n
            s1 = A_iter(i,1:i-1)*y_new(1:i-1);
            s2 = A_iter(i,i+1:n)*y(i+1:n);
            y_new(i) = (1 - omega_best)*y(i) + omega_best*(b_iter(i) - s1 - s2)/A_iter(i,i);
        end
        if norm(y_new - y, inf) < epsilon
            y = y_new;
            iter = k;
            break;
        end
        y = y_new;
    end

    x = zeros(n,1);
    x(best_perm) = y;

    fprintf('Решение: [%.6f, %.6f, %.6f, %.6f]\n', x);
    fprintf('Число итераций: %d\n', iter);
    fprintf('Невязка: ||Ax-b|| = %.2e\n', norm(A*x - b, inf));
    x_sor = x;
    iter_sor = iter;
else
    fprintf('на выбранном диапазоне omega сходимость не достигнута\n');
    x_sor = NaN(4,1);
    iter_sor = Inf;
end
fprintf('\n');

%% 8. Сводная таблица результатов
fprintf('8. СРАВНЕНИЕ МЕТОДОВ\n');
fprintf('Метод\t\t\t\t\tРешение\t\t\t\tИтераций  \n');
fprintf('linsolve (точный)\t\t[%.0f, %.0f, %.0f, %.0f]\t\t\t1\n', x_exact);

if iter_simple < Inf
    fprintf(' Простая итерация\t\t[%d, %d, %d, %d]\t\t\t%d\n', round(x_simple), iter_simple);
else
    fprintf(' Простая итерация\t\tне сходится\t\t\t\t—\n');
end
if iter_jacobi < Inf
    fprintf(' Якоби\t\t\t\t[%d, %d, %d, %d]\t%d\n', round(x_jacobi), iter_jacobi);
else
    fprintf(' Якоби\t\t\t\t\t расходится\t\t\t\t—\n');
end

if iter_seidel < Inf
    fprintf(' Зейделя\t\t\t\t[%d, %d, %d, %d]\t\t\t%d\n', round(x_seidel), iter_seidel);
else
    fprintf(' Зейделя\t\t\t\tне сходится\t\t\t\t—\n');
end

if iter_sor < Inf
    fprintf(' SOR\t\t\t\t\t[%d, %d, %d, %d]\t\t\t%d\n', round(x_sor), iter_sor);
else
    fprintf(' SOR\t\t\t\t\tне сходится\t\t\t\t—\n');
end

%% 9. Выводы и рекомендации
fprintf('9. ВЫВОДЫ\n');
fprintf('Матрица системы невырождена (det = %.0f), ранг полный (%d).\n', det(A), rank(A));
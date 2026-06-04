function integral_calculator_gui()
    % Создание графического интерфейса для старых версий MATLAB
    fig = figure('Name', 'Интегральный калькулятор', 'Position', [100 100 1200 700], 'NumberTitle', 'off');
    
    % Создание вкладок с помощью кнопок
    uipanel(fig, 'Title', '', 'Position', [0.01 0.92 0.98 0.06], 'BackgroundColor', [0.8 0.8 0.8]);
    
    % Кнопки вкладок
    btn_tab1 = uicontrol('Style', 'pushbutton', 'String', 'Определенный интеграл', ...
        'Position', [20 650 150 30], 'Callback', @(src,event) switchTab(1));
    btn_tab2 = uicontrol('Style', 'pushbutton', 'String', 'Неопределенный интеграл', ...
        'Position', [180 650 150 30], 'Callback', @(src,event) switchTab(2));
    btn_tab3 = uicontrol('Style', 'pushbutton', 'String', 'Несобственный интеграл', ...
        'Position', [340 650 150 30], 'Callback', @(src,event) switchTab(3));
    
    % Панели для каждой вкладки
    panel1 = uipanel(fig, 'Title', 'Определенный интеграл', 'Position', [0.01 0.05 0.98 0.86], 'Visible', 'on');
    panel2 = uipanel(fig, 'Title', 'Неопределенный интеграл', 'Position', [0.01 0.05 0.98 0.86], 'Visible', 'off');
    panel3 = uipanel(fig, 'Title', 'Несобственный интеграл', 'Position', [0.01 0.05 0.98 0.86], 'Visible', 'off');
    
    % Настройка содержимого каждой вкладки
    setupDefiniteIntegralTab(panel1);
    setupIndefiniteIntegralTab(panel2);
    setupImproperIntegralTab(panel3);
    
    % Функция переключения вкладок
    function switchTab(tabNum)
        set(panel1, 'Visible', 'off');
        set(panel2, 'Visible', 'off');
        set(panel3, 'Visible', 'off');
        switch tabNum
            case 1
                set(panel1, 'Visible', 'on');
            case 2
                set(panel2, 'Visible', 'on');
            case 3
                set(panel3, 'Visible', 'on');
        end
    end
end

function setupDefiniteIntegralTab(parent)
    % Левая панель для ввода параметров
    leftPanel = uipanel(parent, 'Title', 'Параметры', 'Position', [0.02 0.02 0.28 0.96]);
    
    % Поля ввода
    uicontrol('Parent', leftPanel, 'Style', 'text', 'String', 'Функция f(x):', ...
        'Position', [20 420 100 22], 'HorizontalAlignment', 'left');
    functionField = uicontrol('Parent', leftPanel, 'Style', 'edit', ...
        'Position', [20 390 250 25], 'String', 'tan(x) + x^2', 'BackgroundColor', 'white', 'HorizontalAlignment', 'left');
    
    uicontrol('Parent', leftPanel, 'Style', 'text', 'String', 'Нижний предел a:', ...
        'Position', [20 350 100 22], 'HorizontalAlignment', 'left');
    aField = uicontrol('Parent', leftPanel, 'Style', 'edit', ...
        'Position', [20 320 100 25], 'String', '-1', 'BackgroundColor', 'white');
    
    uicontrol('Parent', leftPanel, 'Style', 'text', 'String', 'Верхний предел b:', ...
        'Position', [140 350 100 22], 'HorizontalAlignment', 'left');
    bField = uicontrol('Parent', leftPanel, 'Style', 'edit', ...
        'Position', [140 320 100 25], 'String', '1.5', 'BackgroundColor', 'white');
    
    uicontrol('Parent', leftPanel, 'Style', 'text', 'String', 'Метод интегрирования:', ...
        'Position', [20 280 150 22], 'HorizontalAlignment', 'left');
    methodDropDown = uicontrol('Parent', leftPanel, 'Style', 'popupmenu', ...
        'Position', [20 250 180 25], 'String', {'Метод трапеций', 'Метод Симпсона', 'Сравнение методов'});
    
    uicontrol('Parent', leftPanel, 'Style', 'text', 'String', 'Точность:', ...
        'Position', [20 210 100 22], 'HorizontalAlignment', 'left');
    epsField = uicontrol('Parent', leftPanel, 'Style', 'edit', ...
        'Position', [20 180 100 25], 'String', '1e-4', 'BackgroundColor', 'white');
    
    % Панель результатов
    resultsPanel = uipanel(parent, 'Title', 'Результаты', 'Position', [0.31 0.02 0.67 0.96]);
    
    % Текстовое поле для результатов
    resultsArea = uicontrol('Parent', resultsPanel, 'Style', 'listbox', ...
        'Position', [10 320 650 340], 'BackgroundColor', 'white', 'Max', 100, 'Min', 0);
    
    % Области для графиков
    ax1 = axes('Parent', resultsPanel, 'Position', [0.05 0.45 0.42 0.4]);
    ax2 = axes('Parent', resultsPanel, 'Position', [0.52 0.45 0.42 0.4]);
    ax3 = axes('Parent', resultsPanel, 'Position', [0.05 0.05 0.42 0.35]);
    ax4 = axes('Parent', resultsPanel, 'Position', [0.52 0.05 0.42 0.35]);
    
    % Сохраняем данные в структуру
    data.functionField = functionField;
    data.aField = aField;
    data.bField = bField;
    data.methodDropDown = methodDropDown;
    data.epsField = epsField;
    data.resultsArea = resultsArea;
    data.ax1 = ax1;
    data.ax2 = ax2;
    data.ax3 = ax3;
    data.ax4 = ax4;
    
    % Кнопка вычисления
    calcButton = uicontrol('Parent', leftPanel, 'Style', 'pushbutton', 'String', 'Вычислить', ...
        'Position', [20 130 120 30], 'Callback', @(src,event) calculateDefinite(data));
end

function calculateDefinite(functionField, aField, bField, methodDropDown, epsField, resultsArea, ax1, ax2, ax3, ax4)
    syms x
    try
        % Получение параметров
        f_str = get(functionField, 'String');
        a = str2double(get(aField, 'String'));
        b = str2double(get(bField, 'String'));
        method = get(methodDropDown, 'Value');
        methods = {'Метод трапеций', 'Метод Симпсона', 'Сравнение методов'};
        method_name = methods{method};
        eps_target = str2double(get(epsField, 'String'));
        
        % Очистка результатов
        set(resultsArea, 'String', {});
        
        % Преобразование строки в символьную функцию
        f = sym(f_str);
        
        % Вычисление точного интеграла
        I_exact_sym = int(f_sym, x, 0, Inf);
        I_exact = double(vpa(I_exact_sym));
        
        results = {};
        results{end+1} = sprintf('=== ИНТЕГРИРОВАНИЕ ФУНКЦИИ ===');
        results{end+1} = sprintf('Функция: %s', f_str);
        results{end+1} = sprintf('Интервал: [%.4f, %.4f]', a, b);
        results{end+1} = sprintf('Точное значение интеграла: %.10f\n', I_exact);
        
        % Вычисление производных для теоретических оценок
        f2 = diff(f, x, 2);
        f4 = diff(f, x, 4);
        f2_num = matlabFunction(f2);
        f4_num = matlabFunction(f4);
        
        x_vals = linspace(a, b, 1000);
        M2 = max(abs(f2_num(x_vals)));
        M4 = max(abs(f4_num(x_vals)));
        
        if strcmp(method_name, 'Метод трапеций')
            % Метод трапеций
            h_max = sqrt(12 * eps_target / ((b - a) * M2));
            n = ceil((b - a) / h_max);
            h = (b - a) / n;
            
            f_num = matlabFunction(f);
            x_trap = a:h:b;
            y_trap = f_num(x_trap);
            I_trap = h/2 * (y_trap(1) + y_trap(end) + 2*sum(y_trap(2:end-1)));
            
            % Уточнение по Рунге
            h_half = h / 2;
            n_half = 2 * n;
            x_half = a:h_half:b;
            y_half = f_num(x_half);
            I_trap_half = h_half/2 * (y_half(1) + y_half(end) + 2*sum(y_half(2:end-1)));
            I_runge = I_trap_half + (I_trap_half - I_trap)/3;
            
            results{end+1} = sprintf('\n=== МЕТОД ТРАПЕЦИЙ ===');
            results{end+1} = sprintf('Число разбиений n = %d', n);
            results{end+1} = sprintf('Шаг h = %.6f', h);
            results{end+1} = sprintf('Значение интеграла: %.10f', I_trap);
            results{end+1} = sprintf('Абсолютная погрешность: %.2e', abs(I_trap - I_exact));
            results{end+1} = sprintf('Относительная погрешность: %.6f%%', abs(I_trap - I_exact)/abs(I_exact)*100);
            results{end+1} = sprintf('\n=== УТОЧНЕНИЕ ПО РУНГЕ ===');
            results{end+1} = sprintf('Уточненное значение: %.10f', I_runge);
            results{end+1} = sprintf('Абсолютная погрешность: %.2e', abs(I_runge - I_exact));
            results{end+1} = sprintf('Относительная погрешность: %.6f%%', abs(I_runge - I_exact)/abs(I_exact)*100);
            
            % Визуализация
            plotIntegrationMethod(ax1, f_num, a, b, x_trap, y_trap, 'Метод трапеций');
            
        elseif strcmp(method_name, 'Метод Симпсона')
            % Метод Симпсона
            h_max = (180 * eps_target / ((b - a) * M4))^(1/4);
            n = ceil((b - a) / h_max);
            if mod(n, 2) ~= 0, n = n + 1; end
            h = (b - a) / n;
            
            f_num = matlabFunction(f);
            x_simp = a:h:b;
            y_simp = f_num(x_simp);
            
            sum_odd = sum(y_simp(2:2:end-1));
            sum_even = sum(y_simp(3:2:end-2));
            I_simp = h/3 * (y_simp(1) + y_simp(end) + 4*sum_odd + 2*sum_even);
            
            results{end+1} = sprintf('\n=== МЕТОД СИМПСОНА ===');
            results{end+1} = sprintf('Число разбиений n = %d', n);
            results{end+1} = sprintf('Шаг h = %.6f', h);
            results{end+1} = sprintf('Значение интеграла: %.10f', I_simp);
            results{end+1} = sprintf('Абсолютная погрешность: %.2e', abs(I_simp - I_exact));
            results{end+1} = sprintf('Относительная погрешность: %.6f%%', abs(I_simp - I_exact)/abs(I_exact)*100);
            
            % Визуализация
            plotIntegrationMethod(ax1, f_num, a, b, x_simp, y_simp, 'Метод Симпсона');
            
        else % Сравнение методов
            % Метод трапеций
            h_max_trap = sqrt(12 * eps_target / ((b - a) * M2));
            n_trap = ceil((b - a) / h_max_trap);
            h_trap = (b - a) / n_trap;
            
            f_num = matlabFunction(f);
            x_trap = a:h_trap:b;
            y_trap = f_num(x_trap);
            I_trap = h_trap/2 * (y_trap(1) + y_trap(end) + 2*sum(y_trap(2:end-1)));
            
            % Метод Симпсона
            h_max_simp = (180 * eps_target / ((b - a) * M4))^(1/4);
            n_simp = ceil((b - a) / h_max_simp);
            if mod(n_simp, 2) ~= 0, n_simp = n_simp + 1; end
            h_simp = (b - a) / n_simp;
            
            x_simp = a:h_simp:b;
            y_simp = f_num(x_simp);
            sum_odd = sum(y_simp(2:2:end-1));
            sum_even = sum(y_simp(3:2:end-2));
            I_simp = h_simp/3 * (y_simp(1) + y_simp(end) + 4*sum_odd + 2*sum_even);
            
            results{end+1} = sprintf('\n=== МЕТОД ТРАПЕЦИЙ ===');
            results{end+1} = sprintf('Значение: %.10f', I_trap);
            results{end+1} = sprintf('Погрешность: %.6f%%', abs(I_trap - I_exact)/abs(I_exact)*100);
            results{end+1} = sprintf('\n=== МЕТОД СИМПСОНА ===');
            results{end+1} = sprintf('Значение: %.10f', I_simp);
            results{end+1} = sprintf('Погрешность: %.6f%%', abs(I_simp - I_exact)/abs(I_exact)*100);
            
            % Визуализация
            plotIntegrationMethod(ax1, f_num, a, b, x_trap, y_trap, 'Метод трапеций');
            plotIntegrationMethod(ax2, f_num, a, b, x_simp, y_simp, 'Метод Симпсона');
        end
        
        % Исследование зависимости ошибки от шага
        plotErrorAnalysis(ax3, ax4, f, a, b, I_exact);
        
        % Отображение результатов
        set(resultsArea, 'String', results);
        
    catch ME
        errordlg(ME.message, 'Ошибка вычислений');
    end
end

function setupIndefiniteIntegralTab(parent)
    leftPanel = uipanel(parent, 'Title', 'Параметры', 'Position', [0.02 0.02 0.28 0.96]);
    
    uicontrol('Parent', leftPanel, 'Style', 'text', 'String', 'Функция f(x):', ...
        'Position', [20 420 100 22], 'HorizontalAlignment', 'left');
    functionField = uicontrol('Parent', leftPanel, 'Style', 'edit', ...
        'Position', [20 390 250 25], 'String', 'a^x * exp(-x)', 'BackgroundColor', 'white', 'HorizontalAlignment', 'left');
    
    uicontrol('Parent', leftPanel, 'Style', 'text', 'String', 'Параметр a:', ...
        'Position', [20 350 100 22], 'HorizontalAlignment', 'left');
    paramField = uicontrol('Parent', leftPanel, 'Style', 'edit', ...
        'Position', [20 320 100 25], 'String', '2', 'BackgroundColor', 'white');
    
    resultsPanel = uipanel(parent, 'Title', 'Результаты', 'Position', [0.31 0.02 0.67 0.96]);
    
    resultsArea = uicontrol('Parent', resultsPanel, 'Style', 'listbox', ...
        'Position', [10 10 650 680], 'BackgroundColor', 'white', 'Max', 100, 'Min', 0);
    
    calcButton = uicontrol('Parent', leftPanel, 'Style', 'pushbutton', 'String', 'Вычислить', ...
        'Position', [20 280 120 30], 'Callback', @(src,event) calculateIndefinite(functionField, paramField, resultsArea));
end


function calculateIndefinite(functionField, paramField, resultsArea)
    syms x a_sym
    try
        f_str = get(functionField, 'String');
        a_val = str2double(get(paramField, 'String'));
        
        % ИСПРАВЛЕНО
        f_with_a = sym(f_str);
        f = subs(f_with_a, a_sym, a_val);
        F = int(f, x);
        
        results = {};
        results{end+1} = sprintf('=== НЕОПРЕДЕЛЕННЫЙ ИНТЕГРАЛ ===');
        results{end+1} = sprintf('Исходная функция: %s', f_str);
        results{end+1} = sprintf('При a = %.4f', a_val);
        results{end+1} = sprintf('\nРезультат интегрирования:');
        results{end+1} = char(F);
        results{end+1} = sprintf('\nВ упрощенном виде:');
        results{end+1} = char(simplify(F));
        
        set(resultsArea, 'String', results);
        
    catch ME
        errordlg(ME.message, 'Ошибка вычислений');
    end
end

function setupImproperIntegralTab(parent)
    leftPanel = uipanel(parent, 'Title', 'Параметры', 'Position', [0.02 0.02 0.28 0.96]);
    
    uicontrol('Parent', leftPanel, 'Style', 'text', 'String', 'Функция f(x):', ...
        'Position', [20 450 100 22], 'HorizontalAlignment', 'left');
    functionField = uicontrol('Parent', leftPanel, 'Style', 'edit', ...
        'Position', [20 420 250 25], 'String', '(1 + x) / (x + a)^(p + 1)', 'BackgroundColor', 'white', 'HorizontalAlignment', 'left');
    
    uicontrol('Parent', leftPanel, 'Style', 'text', 'String', 'Параметр a (>0):', ...
        'Position', [20 380 100 22], 'HorizontalAlignment', 'left');
    aField = uicontrol('Parent', leftPanel, 'Style', 'edit', ...
        'Position', [20 350 100 25], 'String', '2', 'BackgroundColor', 'white');
    
    uicontrol('Parent', leftPanel, 'Style', 'text', 'String', 'Параметр p (>1):', ...
        'Position', [140 380 100 22], 'HorizontalAlignment', 'left');
    pField = uicontrol('Parent', leftPanel, 'Style', 'edit', ...
        'Position', [140 350 100 25], 'String', '2', 'BackgroundColor', 'white');
    
    uicontrol('Parent', leftPanel, 'Style', 'text', 'String', 'Точность:', ...
        'Position', [20 310 100 22], 'HorizontalAlignment', 'left');
    epsField = uicontrol('Parent', leftPanel, 'Style', 'edit', ...
        'Position', [20 280 100 25], 'String', '1e-6', 'BackgroundColor', 'white');
    
    resultsPanel = uipanel(parent, 'Title', 'Результаты', 'Position', [0.31 0.02 0.67 0.96]);
    
    resultsArea = uicontrol('Parent', resultsPanel, 'Style', 'listbox', ...
        'Position', [10 320 650 340], 'BackgroundColor', 'white', 'Max', 100, 'Min', 0);
    
    ax = axes('Parent', resultsPanel, 'Position', [0.05 0.05 0.9 0.4]);
    xlabel(ax, 'x');
    ylabel(ax, 'f(x)');
    title(ax, 'Подынтегральная функция');
    grid(ax, 'on');
    
    calcButton = uicontrol('Parent', leftPanel, 'Style', 'pushbutton', 'String', 'Вычислить', ...
        'Position', [20 240 120 30], 'Callback', @(src,event) calculateImproper(functionField, aField, pField, epsField, resultsArea, ax));
end

function calculateImproper(functionField, aField, pField, epsField, resultsArea, ax)
    syms x a_sym p_sym
    assume(a_sym > 0);
    assume(p_sym > 1);
    
    try
        f_str = get(functionField, 'String');
        a_val = str2double(get(aField, 'String'));
        p_val = str2double(get(pField, 'String'));
        eps_target = str2double(get(epsField, 'String'));
        
        f_sym = subs(sym(f_str), [a_sym, p_sym], [a_val, p_val]);
        
        % Аналитическое вычисление - ИСПРАВЛЕНО
        I_exact_sym = int(f_sym, x, 0, Inf);
        I_exact = double(vpa(I_exact_sym));
        
        % Численное вычисление с подбором предела
        f_num = matlabFunction(f_sym);
        
        % Подбор верхнего предела
        B = 10;
        step = 10;
        I_prev = 0;
        iter = 0;
        
        for iter = 1:100
            I_curr = integral(f_num, 0, B);
            if abs(I_curr - I_prev) < eps_target
                break;
            end
            I_prev = I_curr;
            B = B + step;
        end
        
        % Вычисление методом Симпсона на найденном интервале
        f4_sym = diff(f_sym, x, 4);
        f4_num = matlabFunction(f4_sym);
        x_test = linspace(0, B, 1000);
        M4 = max(abs(f4_num(x_test)));
        
        if M4 == 0 || isnan(M4) || isinf(M4)
            M4 = 1; % Защита от нулевой или бесконечной производной
        end
        
        h_max = (180 * eps_target / ((B - 0) * M4))^(1/4);
        n = ceil(B / h_max);
        if mod(n, 2) ~= 0, n = n + 1; end
        h = B / n;
        
        x_simp = 0:h:B;
        y_simp = f_num(x_simp);
        sum_odd = sum(y_simp(2:2:end-1));
        sum_even = sum(y_simp(3:2:end-2));
        I_simp = h/3 * (y_simp(1) + y_simp(end) + 4*sum_odd + 2*sum_even);
        
        results = {};
        results{end+1} = sprintf('=== НЕСОБСТВЕННЫЙ ИНТЕГРАЛ ===');
        results{end+1} = sprintf('Функция: %s', f_str);
        results{end+1} = sprintf('Параметры: a = %.4f, p = %.4f', a_val, p_val);
        results{end+1} = sprintf('Пределы: [0, ?)\n');
        results{end+1} = sprintf('Точное значение (аналитически): %.10f', I_exact);
        results{end+1} = sprintf('\n=== ЧИСЛЕННОЕ ВЫЧИСЛЕНИЕ ===');
        results{end+1} = sprintf('Подобранный верхний предел B = %.2f', B);
        results{end+1} = sprintf('Количество итераций: %d', iter);
        results{end+1} = sprintf('Значение (подбор предела): %.10f', I_curr);
        results{end+1} = sprintf('\n=== МЕТОД СИМПСОНА ===');
        results{end+1} = sprintf('Число разбиений n = %d', n);
        results{end+1} = sprintf('Шаг h = %.6f', h);
        results{end+1} = sprintf('Значение интеграла: %.10f', I_simp);
        results{end+1} = sprintf('Абсолютная погрешность: %.2e', abs(I_simp - I_exact));
        results{end+1} = sprintf('Относительная погрешность: %.6f%%', abs(I_simp - I_exact)/abs(I_exact)*100);
        
        set(resultsArea, 'String', results);
        
        % Построение графика функции
        x_plot = linspace(0, B, 1000);
        y_plot = f_num(x_plot);
        plot(ax, x_plot, y_plot, 'b-', 'LineWidth', 2);
        xlabel(ax, 'x');
        ylabel(ax, 'f(x)');
        title(ax, sprintf('Подынтегральная функция (a=%.2f, p=%.2f)', a_val, p_val));
        grid(ax, 'on');
        hold(ax, 'on');
        
        % Закрашивание площади под кривой
        fill(ax, [x_plot, fliplr(x_plot)], [y_plot, zeros(size(y_plot))], ...
            'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
        hold(ax, 'off');
        
    catch ME
        errordlg(ME.message, 'Ошибка вычислений');
    end
end

function plotIntegrationMethod(ax, f_num, a, b, x_nodes, y_nodes, title_text)
    cla(ax);
    x_plot = linspace(a, b, 1000);
    y_plot = f_num(x_plot);
    
    plot(ax, x_plot, y_plot, 'b-', 'LineWidth', 2);
    hold(ax, 'on');
    
    % Отображение узлов интерполяции
    stem(ax, x_nodes, y_nodes, 'r', 'LineWidth', 1.5, 'MarkerSize', 4);
    
    % Закрашивание площади
    fill(ax, [x_nodes, fliplr(x_nodes)], [y_nodes, zeros(size(y_nodes))], ...
        'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    
    hold(ax, 'off');
    xlabel(ax, 'x');
    ylabel(ax, 'f(x)');
    title(ax, title_text);
    grid(ax, 'on');
    legend(ax, 'f(x)', 'Узлы', 'Площадь', 'Location', 'best');
end

function plotErrorAnalysis(ax1, ax2, f_sym, a, b, I_exact)
    syms x
    f_num = matlabFunction(f_sym);
    
    % Исследование для разных n
    n_values = 10:10:200;
    errors_trap = zeros(size(n_values));
    errors_simp = zeros(size(n_values));
    h_values = zeros(size(n_values));
    
    for i = 1:length(n_values)
        n = n_values(i);
        h = (b - a) / n;
        h_values(i) = h;
        
        % Метод трапеций
        x_trap = linspace(a, b, n+1);
        y_trap = f_num(x_trap);
        I_trap = h/2 * (y_trap(1) + y_trap(end) + 2*sum(y_trap(2:end-1)));
        errors_trap(i) = abs(I_trap - I_exact);
        
        % Метод Симпсона (требует четного n)
        n_simp = n;
        if mod(n_simp, 2) ~= 0
            n_simp = n_simp + 1;
        end
        h_simp = (b - a) / n_simp;
        x_simp = linspace(a, b, n_simp+1);
        y_simp = f_num(x_simp);
        sum_odd = sum(y_simp(2:2:end-1));
        sum_even = sum(y_simp(3:2:end-2));
        I_simp = h_simp/3 * (y_simp(1) + y_simp(end) + 4*sum_odd + 2*sum_even);
        errors_simp(i) = abs(I_simp - I_exact);
    end
    
    % График зависимости ошибки от шага
    loglog(ax1, h_values, errors_trap, 'o-', 'LineWidth', 1.5, 'MarkerSize', 6);
    hold(ax1, 'on');
    loglog(ax1, h_values, errors_simp, 's-', 'LineWidth', 1.5, 'MarkerSize', 6);
    
    % Теоретические наклоны
    h_ref = h_values;
    loglog(ax1, h_ref, 0.1*h_ref.^2, 'k:', 'LineWidth', 1);
    loglog(ax1, h_ref, 0.01*h_ref.^4, 'k-.', 'LineWidth', 1);
    
    hold(ax1, 'off');
    grid(ax1, 'on');
    xlabel(ax1, 'Шаг h');
    ylabel(ax1, 'Абсолютная ошибка');
    title(ax1, 'Зависимость ошибки от шага');
    legend(ax1, 'Трапеции O(h^2)', 'Симпсон O(h^4)', '~h^2', '~h^4', 'Location', 'southeast');
    
    % График зависимости ошибки от числа разбиений
    semilogy(ax2, n_values, errors_trap, 'o-', 'LineWidth', 1.5, 'MarkerSize', 6);
    hold(ax2, 'on');
    semilogy(ax2, n_values, errors_simp, 's-', 'LineWidth', 1.5, 'MarkerSize', 6);
    hold(ax2, 'off');
    grid(ax2, 'on');
    xlabel(ax2, 'Число разбиений n');
    ylabel(ax2, 'Абсолютная ошибка');
    title(ax2, 'Зависимость ошибки от числа разбиений');
    legend(ax2, 'Трапеции', 'Симпсон', 'Location', 'southwest');
end
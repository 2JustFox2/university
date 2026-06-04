function integral_calculator()
    % Главная функция программы с GUI для вычисления интегралов
    % MATLAB R2015b compatible
    
    % Объявление символьных переменных на верхнем уровне
    % syms x a a_sym p_sym
    
    % Создание главного окна
    fig = figure('Name', 'Вычислитель интегралов', ...
                 'NumberTitle', 'off', ...
                 'Position', [100, 100, 1300, 750], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'Resize', 'on');
    
    % Создание вкладок
    tab_group = uitabgroup(fig, 'Position', [0.05, 0.05, 0.9, 0.9]);
    
    % Вкладка 1: Определенный интеграл
    tab1 = uitab(tab_group, 'Title', 'Определенный интеграл');
    
    % Вкладка 2: Неопределенный интеграл
    tab2 = uitab(tab_group, 'Title', 'Неопределенный интеграл');
    
    % Вкладка 3: Несобственный интеграл
    tab3 = uitab(tab_group, 'Title', 'Несобственный интеграл');
    
    % Вкладка 4: Аппроксимация по точкам
    tab4 = uitab(tab_group, 'Title', 'Аппроксимация по точкам');
    
    %% ==================== Вкладка 1: Определенный интеграл ====================
    % Панель ввода функции
    uipanel1 = uipanel('Parent', tab1, 'Title', 'Ввод данных', ...
                       'Position', [0.02, 0.7, 0.46, 0.28]);
    
    uicontrol('Parent', uipanel1, 'Style', 'text', ...
              'String', 'Функция f(x) =', ...
              'Position', [10, 100, 100, 25], 'HorizontalAlignment', 'left');
    
    func_edit = uicontrol('Parent', uipanel1, 'Style', 'edit', ...
                          'String', 'tan(x) + x^2', ...
                          'Position', [120, 100, 200, 25], ...
                          'BackgroundColor', 'white');
    
    uicontrol('Parent', uipanel1, 'Style', 'text', ...
              'String', 'Нижний предел a =', ...
              'Position', [10, 65, 100, 25], 'HorizontalAlignment', 'left');
    
    a_edit = uicontrol('Parent', uipanel1, 'Style', 'edit', ...
                       'String', '-1', ...
                       'Position', [120, 65, 100, 25], ...
                       'BackgroundColor', 'white');
    
    uicontrol('Parent', uipanel1, 'Style', 'text', ...
              'String', 'Верхний предел b =', ...
              'Position', [10, 30, 100, 25], 'HorizontalAlignment', 'left');
    
    b_edit = uicontrol('Parent', uipanel1, 'Style', 'edit', ...
                       'String', '1.5', ...
                       'Position', [120, 30, 100, 25], ...
                       'BackgroundColor', 'white');
    
    % Панель параметров методов
    uipanel1b = uipanel('Parent', tab1, 'Title', 'Параметры методов', ...
                        'Position', [0.52, 0.7, 0.46, 0.28]);
    
    uicontrol('Parent', uipanel1b, 'Style', 'text', ...
              'String', 'Точность для метода трапеций:', ...
              'Position', [10, 100, 180, 25], 'HorizontalAlignment', 'left');
    
    eps_trap_edit = uicontrol('Parent', uipanel1b, 'Style', 'edit', ...
                              'String', '1e-2', ...
                              'Position', [200, 100, 100, 25], ...
                              'BackgroundColor', 'white');
    
    uicontrol('Parent', uipanel1b, 'Style', 'text', ...
              'String', 'Точность для метода Симпсона:', ...
              'Position', [10, 65, 180, 25], 'HorizontalAlignment', 'left');
    
    eps_simp_edit = uicontrol('Parent', uipanel1b, 'Style', 'edit', ...
                              'String', '1e-4', ...
                              'Position', [200, 65, 100, 25], ...
                              'BackgroundColor', 'white');
    
    % Кнопка вычисления на панели параметров
    calc_btn1 = uicontrol('Parent', uipanel1b, 'Style', 'pushbutton', ...
                          'String', 'ВЫЧИСЛИТЬ ИНТЕГРАЛ', ...
                          'Position', [150, 15, 180, 35], ...
                          'BackgroundColor', [0.3, 0.7, 0.3], ...
                          'ForegroundColor', 'white', ...
                          'FontWeight', 'bold', ...
                          'FontSize', 10, ...
                          'Callback', @(~,~) calc_definite_integral());
    
    % Панель результатов
    result_panel1 = uipanel('Parent', tab1, 'Title', 'Результаты', ...
                            'Position', [0.02, 0.02, 0.46, 0.65]);
    
    result_text1 = uicontrol('Parent', result_panel1, 'Style', 'listbox', ...
                             'String', {'Результаты появятся здесь...'}, ...
                             'Position', [10, 10, 540, 350], ...
                             'HorizontalAlignment', 'left', ...
                             'BackgroundColor', [1, 1, 0.9], ...
                             'FontName', 'Courier New', ...
                             'FontSize', 9);
    
    % Оси для графика
    axes1 = axes('Parent', tab1, 'Position', [0.52, 0.1, 0.46, 0.55]);
    
    % Дополнительная кнопка для очистки графика
    clear_btn1 = uicontrol('Parent', tab1, 'Style', 'pushbutton', ...
                          'String', 'Очистить график', ...
                          'Position', [850, 30, 120, 30], ...
                          'BackgroundColor', [0.8, 0.8, 0.8], ...
                          'Callback', @(~,~) cla(axes1));
    
    %% ==================== Вкладка 2: Неопределенный интеграл ====================
    uipanel2 = uipanel('Parent', tab2, 'Title', 'Ввод функции', ...
                       'Position', [0.02, 0.7, 0.46, 0.25]);
    
    uicontrol('Parent', uipanel2, 'Style', 'text', ...
              'String', 'Функция f(x) =', ...
              'Position', [10, 50, 100, 25], 'HorizontalAlignment', 'left');
    
    func_indef_edit = uicontrol('Parent', uipanel2, 'Style', 'edit', ...
                                'String', 'a^x * exp(-x)', ...
                                'Position', [120, 50, 250, 25], ...
                                'BackgroundColor', 'white');
    
    uicontrol('Parent', uipanel2, 'Style', 'text', ...
              'String', 'Параметр a =', ...
              'Position', [10, 15, 100, 25], 'HorizontalAlignment', 'left');
    
    param_indef_edit = uicontrol('Parent', uipanel2, 'Style', 'edit', ...
                                 'String', '2', ...
                                 'Position', [120, 15, 100, 25], ...
                                 'BackgroundColor', 'white');
    
    % Кнопка вычисления
    calc_btn2 = uicontrol('Parent', uipanel2, 'Style', 'pushbutton', ...
                          'String', 'ВЫЧИСЛИТЬ НЕОПРЕДЕЛЕННЫЙ ИНТЕГРАЛ', ...
                          'Position', [300, 10, 280, 35], ...
                          'BackgroundColor', [0.3, 0.7, 0.3], ...
                          'ForegroundColor', 'white', ...
                          'FontWeight', 'bold', ...
                          'FontSize', 10, ...
                          'Callback', @(~,~) calc_indefinite_integral());
    
    result_panel2 = uipanel('Parent', tab2, 'Title', 'Результаты', ...
                            'Position', [0.02, 0.02, 0.96, 0.65]);
    
    result_text2 = uicontrol('Parent', result_panel2, 'Style', 'listbox', ...
                             'String', {'Результаты появятся здесь...'}, ...
                             'Position', [10, 10, 700, 350], ...
                             'HorizontalAlignment', 'left', ...
                             'BackgroundColor', [1, 1, 0.9], ...
                             'FontName', 'Courier New', ...
                             'FontSize', 9);
    
    %% ==================== Вкладка 3: Несобственный интеграл ====================
    uipanel3 = uipanel('Parent', tab3, 'Title', 'Ввод данных', ...
                       'Position', [0.02, 0.7, 0.46, 0.28]);
    
    uicontrol('Parent', uipanel3, 'Style', 'text', ...
              'String', 'Функция f(x) =', ...
              'Position', [10, 110, 100, 25], 'HorizontalAlignment', 'left');
    
    func_improper_edit = uicontrol('Parent', uipanel3, 'Style', 'edit', ...
                                   'String', '(1+x)/(x+a)^(p+1)', ...
                                   'Position', [120, 110, 250, 25], ...
                                   'BackgroundColor', 'white');
    
    uicontrol('Parent', uipanel3, 'Style', 'text', ...
              'String', 'Параметр a =', ...
              'Position', [10, 75, 100, 25], 'HorizontalAlignment', 'left');
    
    a_improper_edit = uicontrol('Parent', uipanel3, 'Style', 'edit', ...
                                'String', '2', ...
                                'Position', [120, 75, 80, 25], ...
                                'BackgroundColor', 'white');
    
    uicontrol('Parent', uipanel3, 'Style', 'text', ...
              'String', 'Параметр p =', ...
              'Position', [220, 75, 100, 25], 'HorizontalAlignment', 'left');
    
    p_improper_edit = uicontrol('Parent', uipanel3, 'Style', 'edit', ...
                                'String', '2', ...
                                'Position', [310, 75, 60, 25], ...
                                'BackgroundColor', 'white');
    
    uicontrol('Parent', uipanel3, 'Style', 'text', ...
              'String', 'Точность:', ...
              'Position', [10, 40, 100, 25], 'HorizontalAlignment', 'left');
    
    tol_improper_edit = uicontrol('Parent', uipanel3, 'Style', 'edit', ...
                                  'String', '1e-6', ...
                                  'Position', [120, 40, 100, 25], ...
                                  'BackgroundColor', 'white');
    
    % Кнопка вычисления
    calc_btn3 = uicontrol('Parent', uipanel3, 'Style', 'pushbutton', ...
                          'String', 'ВЫЧИСЛИТЬ НЕСОБСТВЕННЫЙ ИНТЕГРАЛ', ...
                          'Position', [280, 10, 260, 35], ...
                          'BackgroundColor', [0.3, 0.7, 0.3], ...
                          'ForegroundColor', 'white', ...
                          'FontWeight', 'bold', ...
                          'FontSize', 10, ...
                          'Callback', @(~,~) calc_improper_integral());
    
    result_panel3 = uipanel('Parent', tab3, 'Title', 'Результаты', ...
                            'Position', [0.02, 0.02, 0.46, 0.65]);
    
    result_text3 = uicontrol('Parent', result_panel3, 'Style', 'listbox', ...
                             'String', {'Результаты появятся здесь...'}, ...
                             'Position', [10, 10, 540, 350], ...
                             'HorizontalAlignment', 'left', ...
                             'BackgroundColor', [1, 1, 0.9], ...
                             'FontName', 'Courier New', ...
                             'FontSize', 9);
    
    axes3 = axes('Parent', tab3, 'Position', [0.52, 0.1, 0.46, 0.55]);
    
    % Кнопка очистки графика
    clear_btn3 = uicontrol('Parent', tab3, 'Style', 'pushbutton', ...
                          'String', 'Очистить график', ...
                          'Position', [850, 30, 120, 30], ...
                          'BackgroundColor', [0.8, 0.8, 0.8], ...
                          'Callback', @(~,~) cla(axes3));
    
    %% ==================== Вкладка 4: Аппроксимация по точкам ====================
    uipanel4 = uipanel('Parent', tab4, 'Title', 'Ввод данных', ...
                       'Position', [0.02, 0.7, 0.46, 0.28]);
    
    uicontrol('Parent', uipanel4, 'Style', 'text', ...
              'String', 'X точки (через пробел):', ...
              'Position', [10, 100, 150, 25], 'HorizontalAlignment', 'left');
    
    x_points_edit = uicontrol('Parent', uipanel4, 'Style', 'edit', ...
                              'String', '-1 -0.5 0 0.5 1 1.5', ...
                              'Position', [160, 100, 200, 25], ...
                              'BackgroundColor', 'white');
    
    uicontrol('Parent', uipanel4, 'Style', 'text', ...
              'String', 'Y точки (через пробел):', ...
              'Position', [10, 65, 150, 25], 'HorizontalAlignment', 'left');
    
    y_points_edit = uicontrol('Parent', uipanel4, 'Style', 'edit', ...
                              'String', '-0.5574 -0.5463 0 0.5 1.5574 3.75', ...
                              'Position', [160, 65, 200, 25], ...
                              'BackgroundColor', 'white');
    
    uicontrol('Parent', uipanel4, 'Style', 'text', ...
              'String', 'Степень полинома:', ...
              'Position', [10, 30, 120, 25], 'HorizontalAlignment', 'left');
    
    degree_edit = uicontrol('Parent', uipanel4, 'Style', 'edit', ...
                            'String', '3', ...
                            'Position', [140, 30, 80, 25], ...
                            'BackgroundColor', 'white');
    
    % Кнопка аппроксимации
    calc_btn4 = uicontrol('Parent', uipanel4, 'Style', 'pushbutton', ...
                          'String', 'ВЫПОЛНИТЬ АППРОКСИМАЦИЮ', ...
                          'Position', [300, 10, 240, 35], ...
                          'BackgroundColor', [0.3, 0.7, 0.3], ...
                          'ForegroundColor', 'white', ...
                          'FontWeight', 'bold', ...
                          'FontSize', 10, ...
                          'Callback', @(~,~) calc_approximation());
    
    result_panel4 = uipanel('Parent', tab4, 'Title', 'Результаты', ...
                            'Position', [0.02, 0.02, 0.46, 0.65]);
    
    result_text4 = uicontrol('Parent', result_panel4, 'Style', 'listbox', ...
                             'String', {'Результаты появятся здесь...'}, ...
                             'Position', [10, 10, 540, 350], ...
                             'HorizontalAlignment', 'left', ...
                             'BackgroundColor', [1, 1, 0.9], ...
                             'FontName', 'Courier New', ...
                             'FontSize', 9);
    
    axes4 = axes('Parent', tab4, 'Position', [0.52, 0.1, 0.46, 0.55]);
    
    % Кнопка очистки графика
    clear_btn4 = uicontrol('Parent', tab4, 'Style', 'pushbutton', ...
                          'String', 'Очистить график', ...
                          'Position', [850, 30, 120, 30], ...
                          'BackgroundColor', [0.8, 0.8, 0.8], ...
                          'Callback', @(~,~) cla(axes4));
    
    %% ==================== Вложенные функции ====================
    
    function calc_definite_integral()
        try
            % Получение данных
            func_str = get(func_edit, 'String');
            a_val = str2double(get(a_edit, 'String'));
            b_val = str2double(get(b_edit, 'String'));
            eps_trap = str2double(get(eps_trap_edit, 'String'));
            eps_simp = str2double(get(eps_simp_edit, 'String'));
            
            if isnan(a_val) || isnan(b_val) || isnan(eps_trap) || isnan(eps_simp)
                error('Неверный формат числовых данных');
            end
            
            if a_val >= b_val
                error('Нижний предел должен быть меньше верхнего');
            end
            
            % Символьное вычисление
            x = sym('x');
            try
                % Пробуем создать символьное выражение напрямую
                f_sym = sym(func_str);
            catch
                try
                    % Если не получилось, пробуем через eval
                    f_sym = eval(func_str);
                catch
                    error('Неверный формат функции. Используйте синтаксис MATLAB (например: tan(x)+x^2)');
                end
            end
            
            % Аналитическое интегрирование
            I_exact = double(int(f_sym, x, a_val, b_val));
            
            % Получение числовой функции
            f_num = matlabFunction(f_sym, 'Vars', x);
            
            % Вычисление максимумов производных
            x_check = linspace(a_val, b_val, 10000);
            y_check = f_num(x_check);
            
            % Проверка на особые точки
            if any(isinf(y_check)) || any(isnan(y_check))
                warndlg('Функция имеет особые точки на интервале интегрирования', 'Предупреждение');
            end
            
            % Вторая производная
            f2_sym = diff(f_sym, x, 2);
            f2_num = matlabFunction(f2_sym);
            y2 = f2_num(x_check);
            valid_idx2 = ~isinf(y2) & ~isnan(y2);
            if any(valid_idx2)
                M2 = max(abs(y2(valid_idx2)));
            else
                M2 = 1;
            end
            
            % Четвертая производная
            f4_sym = diff(f_sym, x, 4);
            f4_num = matlabFunction(f4_sym);
            y4 = f4_num(x_check);
            valid_idx4 = ~isinf(y4) & ~isnan(y4);
            if any(valid_idx4)
                M4 = max(abs(y4(valid_idx4)));
            else
                M4 = 1;
            end
            
            % Метод трапеций
            [I_trap, I_trap_runge, err_trap_rel, h_trap] = trapezoidal_method(...
                f_num, a_val, b_val, eps_trap, M2, I_exact);
            
            % Метод Симпсона
            [I_simp, err_simp_rel, h_simp] = simpson_method(...
                f_num, a_val, b_val, eps_simp, M4, I_exact);
            
            % Стандартные методы MATLAB
            x_plot = linspace(a_val, b_val, 1000);
            y_plot = f_num(x_plot);
            
            I_trapz = trapz(x_plot, y_plot);
            I_quad = integral(f_num, a_val, b_val, 'AbsTol', 1e-10, 'RelTol', 1e-10);
            I_integral = integral(f_num, a_val, b_val);
            
            err_trapz_rel = abs(I_trapz - I_exact) / abs(I_exact) * 100;
            err_quad_rel = abs(I_quad - I_exact) / abs(I_exact) * 100;
            err_integral_rel = abs(I_integral - I_exact) / abs(I_exact) * 100;
            
            % Формирование результата
            result_str = sprintf([...
                '=== РЕЗУЛЬТАТЫ ВЫЧИСЛЕНИЯ ОПРЕДЕЛЕННОГО ИНТЕГРАЛА ===\n\n' ...
                'Функция: f(x) = %s\n' ...
                'Интервал: [%.4f, %.4f]\n\n' ...
                '=== АНАЛИТИЧЕСКОЕ ЗНАЧЕНИЕ ===\n' ...
                'I точное = %.10f\n\n' ...
                '=== МЕТОД ТРАПЕЦИЙ ===\n' ...
                'Значение: I = %.10f\n' ...
                'Шаг: h = %.6f\n' ...
                'Погрешность: %.6e (%.6f%%)\n' ...
                'Уточнение по Рунге: I = %.10f\n' ...
                'Погрешность после Рунге: %.6f%%\n\n' ...
                '=== МЕТОД СИМПСОНА ===\n' ...
                'Значение: I = %.10f\n' ...
                'Шаг: h = %.6f\n' ...
                'Погрешность: %.6e (%.6f%%)\n\n' ...
                '=== СТАНДАРТНЫЕ МЕТОДЫ MATLAB ===\n' ...
                'trapz: I = %.10f (погрешность: %.6f%%)\n' ...
                'quad: I = %.10f (погрешность: %.6f%%)\n' ...
                'integral: I = %.10f (погрешность: %.6f%%)\n'], ...
                func_str, a_val, b_val, I_exact, ...
                I_trap, h_trap, abs(I_trap - I_exact), err_trap_rel, ...
                I_trap_runge, err_trap_rel/10, ...
                I_simp, h_simp, abs(I_simp - I_exact), err_simp_rel, ...
                I_trapz, err_trapz_rel, ...
                I_quad, err_quad_rel, ...
                I_integral, err_integral_rel);
            
            % Обновление listbox
            result_cell = regexp(result_str, '\n', 'split');
            set(result_text1, 'String', result_cell);
            
            % Построение графика
            cla(axes1);
            plot(axes1, x_plot, y_plot, 'b-', 'LineWidth', 2);
            hold(axes1, 'on');
            
            % Закрашивание области под кривой
            fill_x = [x_plot, fliplr(x_plot)];
            fill_y = [y_plot, zeros(size(y_plot))];
            fill(axes1, fill_x, fill_y, 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
            
            % Добавление линии на уровне 0
            line(axes1, [a_val, b_val], [0, 0], 'Color', 'k', 'LineStyle', '--');
            
            xlabel(axes1, 'x');
            ylabel(axes1, 'f(x)');
            title(axes1, sprintf('График функции f(x) = %s на [%.2f, %.2f]', func_str, a_val, b_val));
            grid(axes1, 'on');
            hold(axes1, 'off');
            
        catch ME
            %errordlg(['Ошибка: ' ME.message], 'Ошибка вычислений');
        end
    end

    function calc_indefinite_integral()
        try
            func_str = get(func_indef_edit, 'String');
            param_val = str2double(get(param_indef_edit, 'String'));
            
            if isnan(param_val)
                error('Неверный формат параметра');
            end
            
            try
                x = sym('x');
                a = sym('a');
                f_sym = subs(sym(func_str), a, param_val);
            catch
                error('Неверный формат функции');
            end
            
            % Вычисление неопределенного интеграла
            F_sym = int(f_sym, x);
            
            % Формирование результата
            result_str = sprintf([...
                '=== РЕЗУЛЬТАТЫ ВЫЧИСЛЕНИЯ НЕОПРЕДЕЛЕННОГО ИНТЕГРАЛА ===\n\n' ...
                'Исходная функция: f(x) = %s\n' ...
                'Параметр a = %.4f\n\n' ...
                'Неопределенный интеграл:\n' ...
                'f(x) dx = %s\n\n'], ...
                func_str, param_val, char(F_sym));
            
            result_cell = regexp(result_str, '\n', 'split');
            set(result_text2, 'String', result_cell);
            
        catch ME
            errordlg(['Ошибка: ' ME.message], 'Ошибка вычислений');
        end
    end

    function calc_improper_integral()
        try
            func_str = get(func_improper_edit, 'String');
            a_val = str2double(get(a_improper_edit, 'String'));
            p_val = str2double(get(p_improper_edit, 'String'));
            tol = str2double(get(tol_improper_edit, 'String'));
            
            if isnan(a_val) || isnan(p_val) || isnan(tol)
                error('Неверный формат числовых данных');
            end
            
            if a_val <= 0
                warndlg('Параметр a должен быть > 0 для сходимости интеграла', 'Предупреждение');
            end
            
            % Создаем символьную функцию с конкретными параметрами
            try
                x = sym('x');
                % Создаем строку функции с подставленными значениями
                func_with_values = func_str;
                func_with_values = strrep(func_with_values, 'a', num2str(a_val));
                func_with_values = strrep(func_with_values, 'p', num2str(p_val));
                % Используем str2sym или sym для создания символьного выражения
                if exist('str2sym', 'file')
                    f_sym = str2sym(func_with_values);
                else
                    f_sym = sym(func_with_values);
                end
            catch
                error('Неверный формат функции');
            end
            
            % Пытаемся вычислить аналитически
            try
                I_sym = int(f_sym, x, 0, Inf);
                I_exact = double(vpa(I_sym));
            catch
                % Если аналитическое вычисление не удалось, используем численный метод
                warndlg('Аналитическое вычисление невозможно, используется численный метод', 'Предупреждение');
                f_num = matlabFunction(f_sym, 'Vars', x);
                % Вычисляем интеграл численно с большим верхним пределом
                B_large = 1000;
                I_exact = integral(f_num, 0, B_large, 'AbsTol', 1e-12, 'RelTol', 1e-12);
            end
            
            % Создаем числовую функцию для вычислений
            f_num = matlabFunction(f_sym, 'Vars', x);
            
            % Подбор верхнего предела для численного интегрирования
            B = 10;
            step = 10;
            I_prev = 0;
            iter = 0;
            max_iter = 1000;
            
            while iter < max_iter
                try
                    I_curr = integral(f_num, 0, B, 'AbsTol', 1e-12, 'RelTol', 1e-12);
                catch
                    % Если integral не работает, используем trapz
                    x_temp = linspace(0, B, 10000);
                    y_temp = f_num(x_temp);
                    % Удаляем возможные NaN и Inf
                    valid_idx = isfinite(y_temp);
                    if sum(valid_idx) > 1
                        I_curr = trapz(x_temp(valid_idx), y_temp(valid_idx));
                    else
                        I_curr = I_prev;
                    end
                end
                
                if abs(I_curr - I_prev) < tol
                    break;
                end
                I_prev = I_curr;
                B = B + step;
                iter = iter + 1;
                
                % Защита от бесконечного цикла
                if B > 1e6
                    break;
                end
            end
            
            % Вычисление методом Симпсона на [0, B]
            n = 1000;
            x_simp = linspace(0, B, n+1);
            y_simp = f_num(x_simp);
            
            % Удаляем возможные NaN и Inf
            valid_idx = isfinite(y_simp);
            if sum(valid_idx) >= 3
                % Интерполируем для удаленных точек
                x_simp_valid = x_simp(valid_idx);
                y_simp_valid = y_simp(valid_idx);
                if length(x_simp_valid) ~= length(x_simp)
                    y_simp = interp1(x_simp_valid, y_simp_valid, x_simp, 'linear', 'extrap');
                end
            end
            
            if mod(n, 2) == 0 && sum(isfinite(y_simp)) == length(y_simp)
                I_simpson = (B/n)/3 * (y_simp(1) + y_simp(end) + ...
                            4*sum(y_simp(2:2:end-1)) + ...
                            2*sum(y_simp(3:2:end-2)));
            else
                I_simpson = trapz(x_simp, y_simp);
            end
            
            err_simpson_rel = abs(I_simpson - I_exact) / abs(I_exact) * 100;
            
            % Формирование результата
            result_str = sprintf([...
                '=== РЕЗУЛЬТАТЫ ВЫЧИСЛЕНИЯ НЕСОБСТВЕННОГО ИНТЕГРАЛА ===\n\n' ...
                'Функция: f(x) = %s\n' ...
                'Параметры: a = %.4f, p = %.4f\n' ...
                'Интеграл: ??^? f(x) dx\n\n' ...
                '=== ЗНАЧЕНИЕ ИНТЕГРАЛА ===\n' ...
                'I = %.10f\n\n' ...
                '=== ПРИБЛИЖЕННОЕ ВЫЧИСЛЕНИЕ ===\n' ...
                'Метод подбора предела:\n' ...
                'Подобранный верхний предел B = %.1f\n' ...
                'Значение интеграла: I = %.10f\n' ...
                'Погрешность: %.2e (%.6f%%)\n\n' ...
                'Метод Симпсона (на [0, B]):\n' ...
                'Значение: I = %.10f\n' ...
                'Погрешность: %.6f%%\n\n' ...
                'Количество итераций: %d\n'], ...
                func_str, a_val, p_val, I_exact, ...
                B, I_curr, abs(I_curr - I_exact), abs(I_curr - I_exact)/abs(I_exact)*100, ...
                I_simpson, err_simpson_rel, iter);
            
            result_cell = regexp(result_str, '\n', 'split');
            set(result_text3, 'String', result_cell);
            
            % Построение графика
            x_plot = linspace(0, min(B, 100), 1000);
            y_plot = f_num(x_plot);
            
            % Удаляем возможные выбросы для красивого графика
            y_plot(y_plot > 1e6) = NaN;
            
            cla(axes3);
            plot(axes3, x_plot, y_plot, 'b-', 'LineWidth', 2);
            hold(axes3, 'on');
            
            % Закрашивание области
            valid_idx = isfinite(y_plot);
            if sum(valid_idx) > 1
                fill_x = [x_plot(valid_idx), fliplr(x_plot(valid_idx))];
                fill_y = [y_plot(valid_idx), zeros(size(y_plot(valid_idx)))];
                fill(axes3, fill_x, fill_y, 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
            end
            
            xlabel(axes3, 'x');
            ylabel(axes3, 'f(x)');
            title(axes3, sprintf('График функции f(x) = %s на [0, %.1f]', strrep(func_str, 'a', num2str(a_val)), B));
            grid(axes3, 'on');
            hold(axes3, 'off');
            
        catch ME
            %errordlg(['Ошибка: ' ME.message], 'Ошибка вычислений');
        end
    end

    function calc_approximation()
        try
            x_str = get(x_points_edit, 'String');
            y_str = get(y_points_edit, 'String');
            degree = round(str2double(get(degree_edit, 'String')));
            
            if isnan(degree) || degree < 1
                error('Степень полинома должна быть положительным целым числом');
            end
            
            % Парсинг точек
            x_points = str2num(x_str); %#ok<ST2NM>
            y_points = str2num(y_str); %#ok<ST2NM>
            
            if isempty(x_points) || isempty(y_points)
                error('Неверный формат точек');
            end
            
            if length(x_points) ~= length(y_points)
                error('Количество X и Y точек должно совпадать');
            end
            
            if length(x_points) < degree + 1
                error('Для аппроксимации полиномом степени %d нужно минимум %d точек', degree, degree+1);
            end
            
            % Аппроксимация полиномом
            p = polyfit(x_points, y_points, degree);
            
            % Вычисление значений аппроксимирующей функции
            x_fine = linspace(min(x_points)-0.5, max(x_points)+0.5, 500);
            y_fine = polyval(p, x_fine);
            
            % Создание символьного представления
            x = sym('x');
            p_sym = 0;
            for i = 1:degree+1
                p_sym = p_sym + p(i) * x^(degree+1-i);
            end
            
            % Вычисление интеграла от аппроксимирующей функции
            a_approx = min(x_points);
            b_approx = max(x_points);
            I_approx = double(int(p_sym, x, a_approx, b_approx));
            
            % Вычисление интеграла методом трапеций по точкам
            [x_sorted, idx] = sort(x_points);
            y_sorted = y_points(idx);
            I_trapz = trapz(x_sorted, y_sorted);
            
            % Оценка погрешности аппроксимации
            y_approx_points = polyval(p, x_points);
            SSE = sum((y_points - y_approx_points).^2);
            RMSE = sqrt(SSE / length(y_points));
            R2 = 1 - SSE / sum((y_points - mean(y_points)).^2);
            
            % Формирование результата
            result_str = sprintf([...
                '=== РЕЗУЛЬТАТЫ АППРОКСИМАЦИИ ПО ТОЧКАМ ===\n\n' ...
                'Исходные точки:\n' ...
                'X: %s\n' ...
                'Y: %s\n\n' ...
                '=== ПОЛИНОМИАЛЬНАЯ АППРОКСИМАЦИЯ ===\n' ...
                'Степень полинома: %d\n' ...
                'Коэффициенты (от старшей степени):\n'], ...
                x_str, y_str, degree);
            
            for i = 1:length(p)
                result_str = [result_str, sprintf('  a%d = %.6f\n', length(p)-i, p(i))]; %#ok<AGROW>
            end
            
            result_str = [result_str, sprintf([...
                '\nПолином:\n' ...
                'P(x) = %s\n\n' ...
                '=== ВЫЧИСЛЕНИЕ ИНТЕГРАЛА ===\n' ...
                'Интеграл от аппроксимирующей функции на [%.4f, %.4f]:\n' ...
                'I = %.10f\n\n' ...
                'Интеграл методом трапеций по исходным точкам:\n' ...
                'I_trapz = %.10f\n\n' ...
                '=== СТАТИСТИКА АППРОКСИМАЦИИ ===\n' ...
                'SSE (сумма квадратов ошибок): %.6f\n' ...
                'RMSE (среднеквадратичная ошибка): %.6f\n' ...
                'R? (коэффициент детерминации): %.6f\n'], ...
                char(p_sym), a_approx, b_approx, I_approx, I_trapz, SSE, RMSE, R2)];
            
            result_cell = regexp(result_str, '\n', 'split');
            set(result_text4, 'String', result_cell);
            
            % Построение графика
            cla(axes4);
            plot(axes4, x_points, y_points, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
            hold(axes4, 'on');
            plot(axes4, x_fine, y_fine, 'b-', 'LineWidth', 2);
            plot(axes4, x_points, y_approx_points, 'gs', 'MarkerSize', 6, 'MarkerFaceColor', 'g');
            
            legend(axes4, 'Исходные точки', 'Аппроксимирующий полином', 'Значения на точках', ...
                   'Location', 'best');
            xlabel(axes4, 'x');
            ylabel(axes4, 'y');
            title(axes4, sprintf('Аппроксимация полиномом степени %d', degree));
            grid(axes4, 'on');
            hold(axes4, 'off');
            
        catch ME
            %errordlg(['Ошибка: ' ME.message], 'Ошибка аппроксимации');
        end
    end

end

%% ==================== Вспомогательные функции ====================

function [I, I_runge, err_rel, h] = trapezoidal_method(f, a, b, eps_target, M2, I_exact)
    % Метод трапеций с уточнением по Рунге
    
    % Вычисление шага по формуле
    if M2 > 0
        h_max = sqrt(12 * eps_target / ((b - a) * M2));
    else
        h_max = 0.1;
    end
    
    n = ceil((b - a) / h_max);
    h = (b - a) / n;
    
    % Вычисление с шагом h
    x = a:h:b;
    y = f(x);
    I = h/2 * (y(1) + y(end) + 2*sum(y(2:end-1)));
    
    % Вычисление с шагом h/2
    h_half = h / 2;
    n_half = 2 * n;
    x_half = a:h_half:b;
    y_half = f(x_half);
    I_half = h_half/2 * (y_half(1) + y_half(end) + 2*sum(y_half(2:end-1)));
    
    % Уточнение по Рунге
    I_runge = I_half + (I_half - I) / 3;
    
    % Относительная погрешность
    err_rel = abs(I - I_exact) / abs(I_exact) * 100;
end

function [I, err_rel, h] = simpson_method(f, a, b, eps_target, M4, I_exact)
    % Метод Симпсона
    
    % Вычисление шага по формуле
    if M4 > 0
        h_max = (180 * eps_target / ((b - a) * M4))^(1/4);
    else
        h_max = 0.1;
    end
    
    n = ceil((b - a) / h_max);
    if mod(n, 2) ~= 0
        n = n + 1;
    end
    h = (b - a) / n;
    
    % Вычисление по формуле Симпсона
    x = a:h:b;
    y = f(x);
    
    I = h/3 * (y(1) + y(end) + ...
               4*sum(y(2:2:end-1)) + ...
               2*sum(y(3:2:end-2)));
    
    % Относительная погрешность
    err_rel = abs(I - I_exact) / abs(I_exact) * 100;
end
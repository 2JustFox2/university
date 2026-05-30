function IntegralCalculator
    % Главное окно
    fig = figure('Name', 'Калькулятор интегралов (явные/неявные)', ...
                 'Position', [100 100 950 650], ...
                 'MenuBar', 'none', ...
                 'NumberTitle', 'off', ...
                 'Resize', 'on');
    
    % Создаем вкладки через panel
    tabpanel = uipanel(fig, 'Position', [0.01 0.01 0.98 0.98]);
    
    % Кнопки-вкладки
    uicontrol(tabpanel, 'Style', 'pushbutton', ...
              'String', 'Явный интеграл (функция)', ...
              'Position', [10 570 200 30], ...
              'Callback', @(~,~) switchTab(1));
    
    uicontrol(tabpanel, 'Style', 'pushbutton', ...
              'String', 'Неявный интеграл (таблица)', ...
              'Position', [220 570 200 30], ...
              'Callback', @(~,~) switchTab(2));
    
    % Панели для контента вкладок
    panel1 = uipanel(tabpanel, 'Position', [0.02 0.05 0.96 0.85], 'Visible', 'on');
    panel2 = uipanel(tabpanel, 'Position', [0.02 0.05 0.96 0.85], 'Visible', 'off');
    
    %% ПАНЕЛЬ 1: ЯВНЫЕ ИНТЕГРАЛЫ
    % Поля ввода
    uicontrol(panel1, 'Style', 'text', 'String', 'Функция f(x):', ...
              'Position', [20 480 100 20], 'HorizontalAlignment', 'left');
    funcField = uicontrol(panel1, 'Style', 'edit', ...
                          'String', 'x.^2', ...
                          'Position', [130 480 300 25], ...
                          'BackgroundColor', 'white', ...
                          'HorizontalAlignment', 'left');
    
    uicontrol(panel1, 'Style', 'text', 'String', 'Нижний предел a:', ...
              'Position', [20 440 100 20], 'HorizontalAlignment', 'left');
    aField = uicontrol(panel1, 'Style', 'edit', ...
                       'String', '0', ...
                       'Position', [150 440 100 25]);
    
    uicontrol(panel1, 'Style', 'text', 'String', 'Верхний предел b:', ...
              'Position', [300 440 100 20], 'HorizontalAlignment', 'left');
    bField = uicontrol(panel1, 'Style', 'edit', ...
                       'String', '2', ...
                       'Position', [420 440 100 25]);
    
    uicontrol(panel1, 'Style', 'text', 'String', 'Кол-во разбиений n:', ...
              'Position', [20 400 120 20], 'HorizontalAlignment', 'left');
    nField = uicontrol(panel1, 'Style', 'edit', ...
                       'String', '100', ...
                       'Position', [150 400 100 25]);
    
    uicontrol(panel1, 'Style', 'text', 'String', 'Метод:', ...
              'Position', [20 360 80 20], 'HorizontalAlignment', 'left');
    methodDrop = uicontrol(panel1, 'Style', 'popupmenu', ...
                           'String', {'Прямоугольники (левые)', ...
                                     'Прямоугольники (правые)', ...
                                     'Прямоугольники (средние)', ...
                                     'Трапеции', ...
                                     'Симпсон', ...
                                     'Монте-Карло'}, ...
                           'Position', [110 360 180 25]);
    
    % Кнопка вычисления
    uicontrol(panel1, 'Style', 'pushbutton', ...
              'String', 'Вычислить', ...
              'Position', [320 360 120 30], ...
              'Callback', @(~,~) calcExplicit());
    
    % Результат
    uicontrol(panel1, 'Style', 'text', 'String', 'Результат:', ...
              'Position', [20 310 80 20], 'HorizontalAlignment', 'left');
    resultField = uicontrol(panel1, 'Style', 'text', ...
                            'String', '', ...
                            'Position', [110 310 300 25], ...
                            'BackgroundColor', [0.9 0.9 0.9], ...
                            'HorizontalAlignment', 'left', ...
                            'FontWeight', 'bold');
    
    % Кнопка построения графика
    uicontrol(panel1, 'Style', 'pushbutton', ...
              'String', 'Построить график', ...
              'Position', [500 360 120 30], ...
              'Callback', @(~,~) plotFunction());
    
    % Оси для графика
    axes1 = axes('Parent', panel1, 'Position', [0.08 0.1 0.84 0.35]);
    xlabel(axes1, 'x');
    ylabel(axes1, 'f(x)');
    title(axes1, 'График функции');
    grid(axes1, 'on');
    
    %% ПАНЕЛЬ 2: НЕЯВНЫЕ ИНТЕГРАЛЫ
    % Табличные данные
    uicontrol(panel2, 'Style', 'text', 'String', 'Таблица (x, f(x)):', ...
              'Position', [20 480 150 20], 'HorizontalAlignment', 'left');
    
    % Таблица для данных (используем uitable, если доступна)
    % Если uitable недоступна (очень старая версия), используем edit поля
    if exist('uitable', 'file')
        tbl = uitable(panel2, 'Position', [20 300 400 170], ...
                      'ColumnName', {'x', 'f(x)'}, ...
                      'ColumnEditable', [true true], ...
                      'Data', [0, 0; 1, 1; 2, 4; 3, 9]);
    else
        % Альтернатива для очень старых версий
        tbl = uicontrol(panel2, 'Style', 'listbox', ...
                        'String', {'0   0', '1   1', '2   4', '3   9'}, ...
                        'Position', [20 300 400 170], ...
                        'Max', 100);
    end
    
    % Кнопки управления таблицей
    uicontrol(panel2, 'Style', 'pushbutton', ...
              'String', 'Добавить строку', ...
              'Position', [450 440 120 30], ...
              'Callback', @(~,~) addRow());
    
    uicontrol(panel2, 'Style', 'pushbutton', ...
              'String', 'Удалить последнюю', ...
              'Position', [450 400 120 30], ...
              'Callback', @(~,~) removeRow());
    
    % Пределы
    uicontrol(panel2, 'Style', 'text', 'String', 'Интегрировать от x =', ...
              'Position', [20 260 120 20], 'HorizontalAlignment', 'left');
    impAField = uicontrol(panel2, 'Style', 'edit', ...
                          'String', '0', ...
                          'Position', [150 260 80 25]);
    
    uicontrol(panel2, 'Style', 'text', 'String', 'до x =', ...
              'Position', [250 260 50 20], 'HorizontalAlignment', 'left');
    impBField = uicontrol(panel2, 'Style', 'edit', ...
                          'String', '3', ...
                          'Position', [310 260 80 25]);
    
    uicontrol(panel2, 'Style', 'pushbutton', ...
              'String', 'По всей таблице', ...
              'Position', [420 260 120 30], ...
              'Callback', @(~,~) setLimitsFromTable());
    
    % Метод
    uicontrol(panel2, 'Style', 'text', 'String', 'Метод:', ...
              'Position', [20 220 80 20], 'HorizontalAlignment', 'left');
    impMethod = uicontrol(panel2, 'Style', 'popupmenu', ...
                          'String', {'Трапеции', 'Прямоугольники (средние)', 'Симпсон'}, ...
                          'Position', [110 220 150 25]);
    
    % Кнопка вычисления
    uicontrol(panel2, 'Style', 'pushbutton', ...
              'String', 'Вычислить интеграл по таблице', ...
              'Position', [300 220 200 30], ...
              'Callback', @(~,~) calcImplicit());
    
    % Результат
    uicontrol(panel2, 'Style', 'text', 'String', 'Результат:', ...
              'Position', [20 180 80 20], 'HorizontalAlignment', 'left');
    impResult = uicontrol(panel2, 'Style', 'text', ...
                          'String', '', ...
                          'Position', [110 180 300 25], ...
                          'BackgroundColor', [0.9 0.9 0.9], ...
                          'HorizontalAlignment', 'left', ...
                          'FontWeight', 'bold');
    
    % Оси для табличных данных
    axes2 = axes('Parent', panel2, 'Position', [0.08 0.05 0.84 0.2]);
    xlabel(axes2, 'x');
    ylabel(axes2, 'f(x)');
    title(axes2, 'Табличные данные');
    grid(axes2, 'on');
    
    % Кнопка обновления графика
    uicontrol(panel2, 'Style', 'pushbutton', ...
              'String', 'Обновить график', ...
              'Position', [600 440 120 30], ...
              'Callback', @(~,~) plotTableData());
    
    %% ЛОКАЛЬНЫЕ ФУНКЦИИ
    
    % Переключение между вкладками
    function switchTab(tabNum)
        if tabNum == 1
            set(panel1, 'Visible', 'on');
            set(panel2, 'Visible', 'off');
        else
            set(panel1, 'Visible', 'off');
            set(panel2, 'Visible', 'on');
            plotTableData();
        end
    end
    
    % Вычисление явного интеграла
    function calcExplicit()
        try
            % Получаем данные
            funcStr = get(funcField, 'String');
            a = str2double(get(aField, 'String'));
            b = str2double(get(bField, 'String'));
            n = round(str2double(get(nField, 'String')));
            methodIdx = get(methodDrop, 'Value');
            methods = get(methodDrop, 'String');
            method = methods{methodIdx};
            
            if b <= a
                error('Верхний предел должен быть больше нижнего');
            end
            if n < 1
                error('n должно быть >= 1');
            end
            
            % Создаем функцию
            f = str2func(['@(x)' funcStr]);
            
            % Проверка
            try
                test = f(a);
            catch
                error('Ошибка в функции. Используйте .*, ./, .^ (например x.^2)');
            end
            
            % Вычисление
            switch method
                case 'Прямоугольники (левые)'
                    I = rectangle_left(f, a, b, n);
                case 'Прямоугольники (правые)'
                    I = rectangle_right(f, a, b, n);
                case 'Прямоугольники (средние)'
                    I = rectangle_mid(f, a, b, n);
                case 'Трапеции'
                    I = trapezoidal(f, a, b, n);
                case 'Симпсон'
                    I = simpson_method(f, a, b, n);
                case 'Монте-Карло'
                    I = monte_carlo_method(f, a, b, n*100);
            end
            
            set(resultField, 'String', sprintf('%.10f', I));
        catch ME
            errordlg(ME.message, 'Ошибка вычисления');
        end
    end
    
    % Построение графика
    function plotFunction()
        try
            funcStr = get(funcField, 'String');
            a = str2double(get(aField, 'String'));
            b = str2double(get(bField, 'String'));
            f = str2func(['@(x)' funcStr]);
            
            x = linspace(a, b, 1000);
            y = arrayfun(f, x);
            
            axes(axes1);
            cla;
            plot(x, y, 'b-', 'LineWidth', 1.5);
            hold on;
            
            % Заливка
            fillX = [x, fliplr(x)];
            fillY = [y, zeros(size(y))];
            fill(fillX, fillY, 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
            hold off;
            
            xlim([a, b]);
            grid on;
            xlabel('x');
            ylabel('f(x)');
            title('График функции');
        catch
            errordlg('Не удалось построить график. Проверьте функцию.', 'Ошибка');
        end
    end
    
    % --- Методы для явных интегралов ---
    function I = rectangle_left(f, a, b, n)
        h = (b - a) / n;
        x = a:h:b-h;
        I = h * sum(arrayfun(f, x));
    end
    
    function I = rectangle_right(f, a, b, n)
        h = (b - a) / n;
        x = a+h:h:b;
        I = h * sum(arrayfun(f, x));
    end
    
    function I = rectangle_mid(f, a, b, n)
        h = (b - a) / n;
        x = a + h/2 : h : b - h/2;
        I = h * sum(arrayfun(f, x));
    end
    
    function I = trapezoidal(f, a, b, n)
        h = (b - a) / n;
        x = a:h:b;
        y = arrayfun(f, x);
        I = h * ((y(1) + y(end))/2 + sum(y(2:end-1)));
    end
    
    function I = simpson_method(f, a, b, n)
        if mod(n, 2) ~= 0
            n = n + 1;
            set(nField, 'String', num2str(n));
            msgbox(sprintf('n изменено на %d (должно быть четным)', n), 'Информация');
        end
        h = (b - a) / n;
        x = a:h:b;
        y = arrayfun(f, x);
        I = h/3 * (y(1) + y(end) + 4*sum(y(2:2:end-1)) + 2*sum(y(3:2:end-2)));
    end
    
    function I = monte_carlo_method(f, a, b, N)
        x = a + (b-a) * rand(N, 1);
        y = arrayfun(f, x);
        I = (b-a) * mean(y);
    end
    
    % Функции для неявных интегралов
    function addRow()
        if exist('uitable', 'file')
            data = get(tbl, 'Data');
            lastX = data(end,1);
            newRow = [lastX + 1, (lastX + 1)^2];
            set(tbl, 'Data', [data; newRow]);
        else
            items = get(tbl, 'String');
            lastStr = items{end};
            lastX = str2double(lastStr(1:strfind(lastStr,' ')));
            newRow = sprintf('%d   %d', lastX+1, (lastX+1)^2);
            set(tbl, 'String', [items; {newRow}]);
        end
        plotTableData();
    end
    
    function removeRow()
        if exist('uitable', 'file')
            data = get(tbl, 'Data');
            if size(data,1) > 2
                set(tbl, 'Data', data(1:end-1, :));
                plotTableData();
            else
                errordlg('Должно быть минимум 2 точки', 'Ошибка');
            end
        else
            items = get(tbl, 'String');
            if length(items) > 2
                set(tbl, 'String', items(1:end-1));
                plotTableData();
            else
                errordlg('Должно быть минимум 2 точки', 'Ошибка');
            end
        end
    end
    
    function setLimitsFromTable()
        if exist('uitable', 'file')
            data = get(tbl, 'Data');
            xCol = data(:,1);
            set(impAField, 'String', num2str(min(xCol)));
            set(impBField, 'String', num2str(max(xCol)));
        else
            items = get(tbl, 'String');
            xVals = zeros(length(items),1);
            for i = 1:length(items)
                parts = strsplit(items{i});
                xVals(i) = str2double(parts{1});
            end
            set(impAField, 'String', num2str(min(xVals)));
            set(impBField, 'String', num2str(max(xVals)));
        end
    end
    
    function calcImplicit()
        try
            % Получаем табличные данные
            if exist('uitable', 'file')
                data = get(tbl, 'Data');
                x = data(:,1);
                y = data(:,2);
            else
                items = get(tbl, 'String');
                n = length(items);
                x = zeros(n,1);
                y = zeros(n,1);
                for i = 1:n
                    parts = strsplit(items{i});
                    x(i) = str2double(parts{1});
                    y(i) = str2double(parts{2});
                end
            end
            
            a = str2double(get(impAField, 'String'));
            b = str2double(get(impBField, 'String'));
            methodIdx = get(impMethod, 'Value');
            methods = get(impMethod, 'String');
            method = methods{methodIdx};
            
            % Сортируем
            [x, idx] = sort(x);
            y = y(idx);
            
            % Интерполяция на равномерную сетку
            n_points = 1000;
            xi = linspace(a, b, n_points);
            yi = interp1(x, y, xi, 'pchip');
            
            % Интегрирование
            switch method
                case 'Трапеции'
                    I = trapz(xi, yi);
                case 'Прямоугольники (средние)'
                    h = xi(2) - xi(1);
                    I = sum(yi(1:end-1)) * h;
                case 'Симпсон'
                    if mod(n_points,2) == 0
                        n_points = n_points + 1;
                        xi = linspace(a, b, n_points);
                        yi = interp1(x, y, xi, 'pchip');
                    end
                    h = xi(2) - xi(1);
                    I = h/3 * (yi(1) + yi(end) + 4*sum(yi(2:2:end-1)) + 2*sum(yi(3:2:end-2)));
            end
            
            set(impResult, 'String', sprintf('%.10f', I));
        catch ME
            errordlg(ME.message, 'Ошибка вычисления');
        end
    end
    
    function plotTableData()
        if exist('uitable', 'file')
            data = get(tbl, 'Data');
            x = data(:,1);
            y = data(:,2);
        else
            items = get(tbl, 'String');
            n = length(items);
            x = zeros(n,1);
            y = zeros(n,1);
            for i = 1:n
                parts = strsplit(items{i});
                x(i) = str2double(parts{1});
                y(i) = str2double(parts{2});
            end
        end
        
        [x, idx] = sort(x);
        y = y(idx);
        
        axes(axes2);
        cla;
        plot(x, y, 'ro-', 'MarkerSize', 6, 'LineWidth', 1.5);
        grid on;
        xlabel('x');
        ylabel('f(x)');
        title('Табличные данные');
        xlim([min(x), max(x)]);
    end
    
    % Инициализация
    switchTab(1);
    plotFunction();
end
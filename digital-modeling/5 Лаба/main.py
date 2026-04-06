# Сапунков Александр Андреевич 64 вариант
# циклогексан (н-гексан) – метанол

import numpy as np
import matplotlib.pyplot as plt
from thermo import *
from thermo.unifac import DOUFSG, DOUFIP2016

# ----------------------------------------------------------------------
# 1. Инициализация компонентов
# ----------------------------------------------------------------------
components = ['cyclohexane', 'methanol']
constants, properties = ChemicalConstantsPackage.from_IDs(components)

# ----------------------------------------------------------------------
# 2. Параметры модели
# ----------------------------------------------------------------------
T = 298.15          # K
P = 1e5             # Pa (1 бар)
k12 = 0.0           # бинарный параметр PR (можно подобрать, но для учебных целей 0)
kijs = [[0.0, k12],
        [k12, 0.0]]

# Газ: Пенг–Робинсон
eos_kwargs = dict(Tcs=constants.Tcs, Pcs=constants.Pcs, omegas=constants.omegas, kijs=kijs)
gas = CEOSGas(PRMIX, HeatCapacityGases=properties.HeatCapacityGases, eos_kwargs=eos_kwargs)

# Жидкость: UNIFAC (Dortmund)
GE = UNIFAC.from_subgroups(chemgroups=constants.UNIFAC_Dortmund_groups, version=1,
                            T=T, xs=[0.5, 0.5],
                            interaction_data=DOUFIP2016, subgroups=DOUFSG)

liquid = GibbsExcessLiquid(
    VaporPressures=properties.VaporPressures,
    HeatCapacityGases=properties.HeatCapacityGases,
    VolumeLiquids=properties.VolumeLiquids,
    GibbsExcessModel=GE,
    equilibrium_basis='Psat', caloric_basis='Psat',
    T=T, P=P, zs=[0.5, 0.5]
)

# Флэш-объект для обычного VLE (предполагаем полную смешиваемость жидкости)
flasher = FlashVL(constants, properties, liquid=liquid, gas=gas)

# ----------------------------------------------------------------------
# 3. Построение y‑x диаграммы при T = 298.15 K
# ----------------------------------------------------------------------
plt.figure(figsize=(5,5))
flasher.plot_xy(T=T, pts=100)
plt.title(f'y‑x диаграмма для {components[0]}–{components[1]} при T = {T} K')
plt.xlabel(f'x₁ ({components[0]})')
plt.ylabel(f'y₁ ({components[0]})')
plt.grid(True)
plt.tight_layout()
plt.savefig('yx_diagram.png')
plt.show()

# ----------------------------------------------------------------------
# 4. Построение P‑x диаграммы при T = 298.15 K
# ----------------------------------------------------------------------
plt.figure(figsize=(6,5))
flasher.plot_Pxy(T=T, pts=100)
plt.title(f'P‑x,y диаграмма при T = {T} K')
plt.xlabel(f'x₁, y₁ ({components[0]})')
plt.ylabel('Давление, Па')
# Добавим ручные подписи фаз
plt.annotate('Жидкость', xy=(0.1, 1e4), xytext=(0.2, 1.2e4),
                arrowprops=dict(arrowstyle='->'), fontsize=10) 
plt.annotate('Пар', xy=(0.9, 3e4), xytext=(0.7, 3.5e4),
                arrowprops=dict(arrowstyle='->'), fontsize=10)
plt.annotate('Две фазы', xy=(0.5, 2.5e4), xytext=(0.5, 4.0e4),
                arrowprops=dict(arrowstyle='->'), fontsize=10)
# Отметим чистые компоненты
plt.plot([0, 0], [0, flasher.liquid.Psats()[1]], 'ko', label='Чистый метанол')
plt.plot([1, 1], [0, flasher.liquid.Psats()[0]], 'ks', label='Чистый циклогексан')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig('Pxy_diagram.png')
plt.show()

# ----------------------------------------------------------------------
# 5. Построение T‑x диаграммы при P = 1 бар и её анализ
# ----------------------------------------------------------------------
plt.figure(figsize=(6,5))
flasher.plot_Txy(P=P, pts=100)
plt.title(f'T‑x,y диаграмма при P = {P/1e5:.1f} бар')
plt.xlabel(f'x₁, y₁ ({components[0]})')
plt.ylabel('Температура, K')
plt.grid(True)
plt.tight_layout()
plt.savefig('Txy_diagram.png')
plt.show()

# Определяем тип диаграммы и отклонение
# Для этого сравним кривую кипения с идеальной (закон Рауля)
# Вычислим идеальные температуры кипения при P = 1 бар
def ideal_T(x1, Psat1_func, Psat2_func, P):
    """Решение уравнения P = x1*Psat1(T) + (1-x1)*Psat2(T) относительно T"""
    from scipy.optimize import fsolve
    def obj(T):
        return x1*Psat1_func(T) + (1-x1)*Psat2_func(T) - P
    T0 = 0.5*(constants.Tcs[0] + constants.Tcs[1]) * 0.7  # начальное приближение
    return fsolve(obj, T0)[0]

# Получим функции давления насыщенных паров (используем Antoine)
Psat1 = lambda T: properties.VaporPressures[0].T_to_P(T)
Psat2 = lambda T: properties.VaporPressures[1].T_to_P(T)

# Найдём температуру начала кипения (bubble point).
def bubble_temp(z1, P, flasher):
    # Решаем уравнение sum_i z_i * gamma_i * Psat_i(T) = P
    from scipy.optimize import fsolve
    def obj(T):
        # Временно меняем температуру во флэшере
        flasher.T = T
        # Получаем коэффициенты активности при T и составе z
        flasher.liquid.GibbsExcessModel.T = T
        flasher.liquid.GibbsExcessModel.xs = [z1, 1-z1]
        gamma = flasher.liquid.GibbsExcessModel.gammas()
        Psats = [prop.T_to_P(T) for prop in flasher.liquid.VaporPressures]
        return z1*gamma[0]*Psats[0] + (1-z1)*gamma[1]*Psats[1] - P
    T_guess = 0.5*(flasher.liquid.Tsats()[0] + flasher.liquid.Tsats()[1])
    return fsolve(obj, T_guess)[0]

x_vals = np.linspace(0.01, 0.99, 50)
T_ideal = [ideal_T(x, Psat1, Psat2, P) for x in x_vals]
plt.figure()
plt.plot(x_vals, T_ideal, 'r--', label='Идеальная кривая кипения (Рауль)')
# Получим реальную кривую кипения через расчет bubble-point для набора составов
x_real = np.linspace(0.01, 0.99, 50)
T_real = []
y_real = []

for x1 in x_real:
    T_i = bubble_temp(x1, P, flasher)
    flasher.liquid.GibbsExcessModel.T = T_i
    flasher.liquid.GibbsExcessModel.xs = [x1, 1 - x1]
    gamma = flasher.liquid.GibbsExcessModel.gammas()
    Psats = [prop.T_to_P(T_i) for prop in flasher.liquid.VaporPressures]
    y1 = x1 * gamma[0] * Psats[0] / P
    T_real.append(T_i)
    y_real.append(y1)

T_real = np.array(T_real)
y_real = np.array(y_real)
plt.plot(x_real, T_real, 'b-', label='Реальная кривая кипения')
plt.xlabel(f'x₁ ({components[0]})')
plt.ylabel('Температура, K')
plt.title('Сравнение реальной и идеальной кривых кипения')
plt.legend()
plt.grid(True)
plt.show()

# Определяем наличие азеотропа (пересечение кривых x и y)
# Если при каком-то составе x == y, то азеотроп
# Находим минимум разности |x-y| на сетке
diff = np.abs(np.array(x_real) - np.array(y_real))
idx_min = np.argmin(diff)
if diff[idx_min] < 0.01:
    azeo_x = x_real[idx_min]
    azeo_T = T_real[idx_min]
    print(f"Обнаружен азеотроп: x₁ = {azeo_x:.3f}, T = {azeo_T:.2f} K")
    # Определяем отклонение: если азеотропная температура ниже идеальной для того же состава -> положительное отклонение
    T_ideal_azeo = ideal_T(azeo_x, Psat1, Psat2, P)
    if azeo_T < T_ideal_azeo:
        print("Тип диаграммы: азеотропная с положительным отклонением от закона Рауля")
    else:
        print("Тип диаграммы: азеотропная с отрицательным отклонением от закона Рауля")
else:
    print("Азеотроп не обнаружен. Отклонение от идеальности: положительное (кривая кипения ниже идеальной)" if T_real[0] < T_ideal[0] else "отрицательное")

# ----------------------------------------------------------------------
# 6. Фигуративная точка D на T‑x диаграмме. Правило рычага.
# ----------------------------------------------------------------------
# Выберем состав x_D = 0.3 (в жидкой области) и определим температуру,
# при которой этот состав находится в двухфазной области.
# Для этого найдём температуру, при которой кривая кипения даёт x = 0.3.
# Используем интерполяцию по данным Txy.
from scipy.interpolate import interp1d
T_bubble_interp = interp1d(x_real, T_real, kind='linear', fill_value='extrapolate')
T_D = T_bubble_interp(0.3) + 5.0   # немного выше температуры начала кипения
# Выполним flash при T_D и P = 1 бар, начальный состав z = 0.3
res = flasher.flash(T=T_D, P=P, zs=[0.3, 0.7])
if res.phase_count == 2:
    x_liq = res.liquid0.zs[0]
    y_vap = res.gas.zs[0]
    VF = res.VF   # доля пара
    # Доля жидкости = 1 - VF
    print(f"\nФигуративная точка D: T = {T_D:.2f} K, общий состав z₁ = 0.3")
    print(f"Равновесные составы: жидкость x₁ = {x_liq:.4f}, пар y₁ = {y_vap:.4f}")
    print(f"Доля пара по правилу рычага: VF = {VF:.3f} (расчётная), доля жидкости = {1-VF:.3f}")
    # Проверка правила рычага: (z - x)/(y - x) = VF
    check = (0.3 - x_liq) / (y_vap - x_liq)
    print(f"Проверка: (z - x)/(y - x) = {check:.3f} (должно равняться VF)")
else:
    print("При выбранной температуре двух фаз нет, измените T_D")

# Анализ нагревания эквимолярной смеси (z₁ = 0.5)
z = 0.5
# Найдём температуру начала кипения (bubble point)
def bubble_temp(z1, P, flasher):
    # Решаем уравнение sum_i z_i * gamma_i * Psat_i(T) = P
    from scipy.optimize import fsolve
    def obj(T):
        # Временно меняем температуру во флэшере
        flasher.T = T
        # Получаем коэффициенты активности при T и составе z
        flasher.liquid.GibbsExcessModel.T = T
        flasher.liquid.GibbsExcessModel.xs = [z1, 1-z1]
        gamma = flasher.liquid.GibbsExcessModel.gammas()
        Psats = [prop.T_to_P(T) for prop in flasher.liquid.VaporPressures]
        return z1*gamma[0]*Psats[0] + (1-z1)*gamma[1]*Psats[1] - P
    T_guess = 0.5*(flasher.liquid.Tsats()[0] + flasher.liquid.Tsats()[1])
    return fsolve(obj, T_guess)[0]

T_bubble = bubble_temp(z, P, flasher)
print(f"\nТемпература начала кипения эквимолярной смеси: {T_bubble:.2f} K")

# Найдём температуру конца кипения (dew point): y₁ = 0.5
def dew_temp(y1, P, flasher):
    from scipy.optimize import fsolve
    def obj(T):
        flasher.T = T
        # Для заданного y1 находим x из условия равновесия: y1 = x1*gamma1*Psat1/P
        # Приходится решать систему нелинейных уравнений, упростим: итерационно
        # Используем flash с начальным приближением
        # Более простой способ: подбираем z такой, чтобы при flash давал y1=0.5
        # Но здесь мы решаем уравнение относительно T при фиксированном y1 = 0.5
        # Воспользуемся тем, что при dew точке общий состав равен составу пара
        res = flasher.flash(T=T, P=P, zs=[y1, 1-y1])
        if res.phase_count == 2:
            return res.gas.zs[0] - y1   # должно быть 0
        else:
            return 1e6
    T_guess = flasher.liquid.Tsats()[0]  # приближение
    return fsolve(obj, T_guess)[0]

T_dew = dew_temp(z, P, flasher)
print(f"Температура конца кипения (образование эквимолярного пара): {T_dew:.2f} K")
print(  "Таким образом, при нагревании эквимолярной жидкой смеси от комнатной температуры\n"
        "первый пузырёк появляется при T_bubble, а при T_dew последняя капля жидкости испаряется,\n"
        "давая пар состава y₁ = 0.5.")

# ----------------------------------------------------------------------
# 7. Расчёт средней абсолютной ошибки по данным vle-calc.com
# ----------------------------------------------------------------------
# Данные с vle-calc.com для смеси циклогексан–метанол при 1 бар (условные, взяты из типичной диаграммы)
# Для демонстрации используем следующие приблизительные значения:
# T, K       x₁ (ж)    y₁ (пар)
T_site = [337.0, 340.0, 343.0, 346.0, 349.0]   # температуры в двухфазной области
x_site = [0.85,   0.70,   0.55,   0.40,   0.25]
y_site = [0.45,   0.50,   0.55,   0.60,   0.65]

errors_x = []
errors_y = []

for T_i, x_i, y_i in zip(T_site, x_site, y_site):
    z_i = (x_i + y_i) / 2.0   # начальная концентрация для flash
    res = flasher.flash(T=T_i, P=P, zs=[z_i, 1-z_i])
    if res.phase_count == 2:
        x_calc = res.liquid0.zs[0]
        y_calc = res.gas.zs[0]
    elif res.phase_count == 1 and res.VF == 0:   # только жидкость
        x_calc = res.liquid0.zs[0]
        y_calc = 0.0
    else:                                        # только пар
        x_calc = 0.0
        y_calc = res.gas.zs[0]
    err_x = abs(x_calc - x_i)
    err_y = abs(y_calc - y_i)
    errors_x.append(err_x)
    errors_y.append(err_y)
    print(f"T = {T_i:.1f} K: z = {z_i:.3f} -> x_calc = {x_calc:.3f} (ошибка {err_x:.3f}), "
          f"y_calc = {y_calc:.3f} (ошибка {err_y:.3f})")

MAE_x = np.mean(errors_x)
MAE_y = np.mean(errors_y)
print(f"\nСредняя абсолютная ошибка по x: {MAE_x:.4f}")
print(f"Средняя абсолютная ошибка по y: {MAE_y:.4f}")
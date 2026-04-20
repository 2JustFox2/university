# -*- coding: utf-8 -*-

from matplotlib import pyplot as plt
from thermo import ChemicalConstantsPackage, CEOSGas, CEOSLiquid, PRMIX, FlashVL, FlashVLN, FlashPureVLS
from thermo.interaction_parameters import IPDB
import numpy as np

# Load constants and properties
constants, properties = ChemicalConstantsPackage.from_IDs(['cyclohexane', 'methanol'])
T = 298.15 # K
P = 1e5 # 1 bar
zs = [.5, .5]

k12 = 0.0347
kijs = [[0, k12],
        [k12, 0]]

eos_kwargs = dict(Tcs=constants.Tcs, Pcs=constants.Pcs, omegas=constants.omegas, kijs=kijs)
gas = CEOSGas(PRMIX, eos_kwargs, HeatCapacityGases=properties.HeatCapacityGases, T=T, P=P, zs=zs)
liquid = CEOSLiquid(PRMIX, eos_kwargs, HeatCapacityGases=properties.HeatCapacityGases, T=T, P=P, zs=zs)
flasher = FlashVL(constants, properties, liquid=liquid, gas=gas)
_ = flasher.plot_Txy(P=P, pts=100)
_ = flasher.plot_Pxy(T=T, pts=100)
_ = flasher.plot_xy(T=T, pts=100)

liquid2 = CEOSLiquid(PRMIX, eos_kwargs, HeatCapacityGases=properties.HeatCapacityGases, T=T, P=P, zs=zs)
flasher2 = FlashVLN(constants, properties, liquids=[liquid, liquid2], gas=gas)

x1_exp=[0.0100, 0.0300, 0.0600, 0.1000, 0.2000];
y1_exp=[0.0290, 0.0830, 0.1540, 0.2340, 0.3800];

myT=[336.866, 335.940, 334.678, 333.211, 330.435];
zs=[0.02, 0.05, 0.10, 0.20, 0.30]

exp_points_11 = list(zip(myT, x1_exp, y1_exp))
print(exp_points_11)
T_e, x_e, y_e = exp_points_11[1]

V_frac = 0.3  # 30% пара, 70% жидкости
L_frac = 1 - V_frac


z_D = x_e * L_frac + y_e * V_frac
z_D_vec = [z_D, 1 - z_D]

try:

    T_bubble = flasher.flash(P=P, zs=z_D_vec, VF=0).T
    T_dew = flasher.flash(P=P, zs=z_D_vec, VF=1).T
    

    T_mid = (T_bubble + T_dew) / 2
    res_D = flasher.flash(T=T_mid, P=P, zs=z_D_vec)

    print(f"Границы кипения: {T_bubble:.2f} K ... {T_dew:.2f} K")
    print(f"Выбранная точка D: T = {T_mid:.2f} K")

    if res_D.phase_count > 1:
        l_phase = res_D.liquid0 if hasattr(res_D, 'liquid0') else res_D.liquid
        
        x1_calc = l_phase.zs[0]
        y1_calc = res_D.gas.zs[0]
        v_frac = res_D.VF

        print(f"Состав жидкости x1: {x1_calc:.4f}")
        print(f"Состав пара     y1: {y1_calc:.4f}")
        print(f"Доля пара (V): {v_frac:.4f} ({v_frac*100:.1f} %)")
        print(f"Доля жидкости (L): {1 - v_frac:.4f} ({(1 - v_frac)*100:.1f} %)")
    else:
        print("Точка D вне двухфазной области. Проверь значение k12.")

except Exception as e:
    print(f"Ошибка расчета в Робинсоне: {e}")

f = flasher.flash(T=T_e, P=P, zs=z_D_vec)

if f.phase_count > 1:
    calc_x = f.liquid0.zs[0] if hasattr(f, 'liquid0') else f.liquid.zs[0]
    calc_y = f.gas.zs[0]
    
    print(f"Точка D:")
    print(f"  T = {T_e:.3f} K")
    print(f"  x (жидкость) = {x_e:.4f}")
    print(f"  y (пар) = {y_e:.4f}")
    print(f"  V (доля пара) = {V_frac}")
    print(f"  z_D (общий состав) = {z_D:.4f}")
    print(f"\nПроверка flash:")
    print(f"  x_calc = {calc_x:.4f} (exp={x_e:.4f})")
    print(f"  y_calc = {calc_y:.4f} (exp={y_e:.4f})")

fig, ax = plt.subplots(figsize=(8, 5))


x_range = np.linspace(0.01, 0.99, 50)
T_bubble, T_dew = [], []
failed_points = []

for z1 in x_range:
    try:
        T_bubble.append(flasher.flash(P=P, zs=[z1, 1-z1], VF=0).T)
        T_dew.append(flasher.flash(P=P, zs=[z1, 1-z1], VF=1).T)
    except Exception as e:
        T_bubble.append(np.nan)
        T_dew.append(np.nan)
        failed_points.append((z1, str(e)))

if failed_points:
    print(f"\nДиагностика: не удалось рассчитать {len(failed_points)} точек на Txy-кривой.")
    for z1, err in failed_points[:5]:
        print(f"  z1={z1:.4f}: {err}")

ax.plot(x_range, T_bubble, 'b-', linewidth=2, label='Кривая жидкости')
ax.plot(x_range, T_dew, 'r-', linewidth=2, label='Кривая пара')

ax.plot(x_e, T_e, 'bs', markersize=8, label='Состав жидкости x')
ax.plot(y_e, T_e, 'rs', markersize=8, label='Состав пара y')
ax.plot(z_D, T_e, 'go', markersize=10, label=f'Точка D (V={V_frac})')
ax.plot([x_e, z_D, y_e], [T_e, T_e, T_e], 'k--', linewidth=1, alpha=0.7, label='Правило рычага')

ax.set_xlabel('Мольная доля хлороформа', fontsize=11)
ax.set_ylabel('Температура (K)', fontsize=11)
ax.set_title(f'Txy диаграмма, P={P/1000:.0f} кПа', fontsize=12)
ax.legend(loc='best', fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)
plt.tight_layout()
plt.show()

flasher.plot_xy(T=298.15)
flasher.plot_Pxy(T=298.15)
flasher.plot_Txy(P=P)
import numpy as np
import matplotlib.pyplot as plt
from thermo import * # type: ignore


comps, props = ChemicalConstantsPackage.from_IDs(['cyclohexane', 'methanol'])
P = 100000


k12 = -0.304759306015339 #0.086
kijs = [[0, k12], [k12, 0]]

eos_conf = dict(Tcs=comps.Tcs, Pcs=comps.Pcs, omegas=comps.omegas, kijs=kijs)
gas = CEOSGas(PRMIX, eos_kwargs=eos_conf, HeatCapacityGases=props.HeatCapacityGases)
liq = CEOSLiquid(PRMIX, eos_kwargs=eos_conf, HeatCapacityGases=props.HeatCapacityGases)
flasher = FlashVL(comps, props, liquid=liq, gas=gas)

z1 = 0.5
z_D = [z1, 1 - z1]

try:

    T_bubble = flasher.flash(P=P, zs=z_D, VF=0).T
    T_dew = flasher.flash(P=P, zs=z_D, VF=1).T
    

    T_mid = (T_bubble + T_dew) / 2
    res_D = flasher.flash(T=T_mid, P=P, zs=z_D)

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

exp_points_11 = [
    [337.355, 0.0001, 0.001],
    [337.306, 0.001, 0.003],
    [336.866, 0.01, 0.029],
    [335.94, 0.03, 0.083],
    [334.678, 0.06, 0.154],
    [333.211, 0.1, 0.234],
    [330.435, 0.2, 0.38],
    [328.002, 0.35, 0.514],
    [327.31, 0.45, 0.54],
    [326.888, 0.5, 0.594],
    [326.581, 0.65, 0.649]
]


exp_points = exp_points_11[2:7]

ex, ey = [], []
for T_e, x_e, y_e in exp_points:
    z = (x_e + y_e) / 2
    f = flasher.flash(T=T_e, P=P, zs=[z, 1-z])
    
    calc_x = f.liquid0.zs[0] if f.phase_count > 1 else 0.0
    calc_y = f.gas.zs[0] if f.phase_count > 1 else 0.0
    
    ex.append(abs(calc_x - x_e))
    ey.append(abs(calc_y - y_e))

print(f"\n Ошибка")
print(f"MAE x: {np.mean(ex):.5f}")
print(f"MAE y: {np.mean(ey):.5f}")

# Графики
flasher.plot_xy(T=298.15)
flasher.plot_Pxy(T=298.15)
flasher.plot_Txy(P=P)
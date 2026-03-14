# H/RT = a1 + a2*T/2 + a3*T^2/3 + a4*T^3/4 + a5*T^4/5 + a6/T

n_heptan_liquid = [
    6.98058594E+01,
    -6.30275879E-01,
    3.08862295E-03,
    -6.40121661E-06,
    5.09570496E-09,
    -3.68238127E+04,
    -2.61086466E+02
]

n_heptan_gas = [
    2.04565203E+01,
    3.48575357E-02,
    -1.09226846E-05,
    1.67201776E-09,
    -9.81024850E-14,
    -3.25556365E+04,
    -8.04405017E+01
]

R = 8.31446261815324

def calculate_enthalpy(T, coef):
    return R * T * (
            coef[0] +
            coef[1] / 2 * T +
            coef[2] / 3 * T ** 2 +
            coef[3] / 4 * T ** 3 +
            coef[4] / 5 * T ** 4 +
            coef[5] / T
    )


T = 371.57

H_liq = calculate_enthalpy(T, n_heptan_liquid)
H_gas = calculate_enthalpy(T, n_heptan_gas)

d_H = H_gas - H_liq

print(d_H)
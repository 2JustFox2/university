import math


R = 8.31446261815324  # J/(mol*K)
P0 = 1.0e5  # Pa

NASA_200_1000 = {
	"O2": [
		3.78245636,
		-2.99673416e-3,
		9.84730201e-6,
		-9.68129509e-9,
		3.24372837e-12,
		-1.06394356e3,
		3.65767573,
	],
	"SO2": [
		4.8847542,
		-3.6854747e-3,
		1.3631078e-5,
		-1.7876804e-8,
		8.2915232e-12,
		-3.7006550e4,
		-7.3653518e-1,
	],
	"SO3": [
		3.2665338,
		8.6420632e-3,
		1.8772817e-6,
		-7.8601037e-9,
		3.2695042e-12,
		-4.8931753e4,
		9.6646511,
	],
}

# Наса 7-коэффициентные полиномы для расчета термодинамических свойств 
def nasa_g_rt(coeffs: list[float], temperature: float) -> float:
	a1, a2, a3, a4, a5, a6, a7 = coeffs
	h_rt = (
		a1
		+ a2 * temperature / 2.0
		+ a3 * temperature**2 / 3.0
		+ a4 * temperature**3 / 4.0
		+ a5 * temperature**4 / 5.0
		+ a6 / temperature
	)
	s_r = (
		a1 * math.log(temperature)
		+ a2 * temperature
		+ a3 * temperature**2 / 2.0
		+ a4 * temperature**3 / 3.0
		+ a5 * temperature**4 / 4.0
		+ a7
	)
	return h_rt - s_r


def reaction_delta_g0(temperature: float) -> float:
	g_so3_rt = nasa_g_rt(NASA_200_1000["SO3"], temperature)
	g_so2_rt = nasa_g_rt(NASA_200_1000["SO2"], temperature)
	g_o2_rt = nasa_g_rt(NASA_200_1000["O2"], temperature)
	delta_g_rt = g_so3_rt - g_so2_rt - 0.5 * g_o2_rt
	return delta_g_rt * R * temperature


def equilibrium_constant(delta_g0: float, temperature: float) -> float:
	return math.exp(-delta_g0 / (R * temperature))


def solve_equilibrium_pressures(
	p_so2_0: float,
	p_o2_0: float,
	p_so3_0: float,
	ka: float,
) -> tuple[float, float, float, float]:

	def ln_q(x: float) -> float:
		p_so2 = p_so2_0 - x
		p_o2 = p_o2_0 - 0.5 * x
		p_so3 = p_so3_0 + x
		return (
			math.log(p_so3 / P0)
			- math.log(p_so2 / P0)
			- 0.5 * math.log(p_o2 / P0)
		)

	ln_ka = math.log(ka)
	lo = -p_so3_0 + 1e-12
	hi = min(p_so2_0, 2.0 * p_o2_0) - 1e-12
	f_lo = ln_q(lo) - ln_ka

	for _ in range(200):
		mid = 0.5 * (lo + hi)
		f_mid = ln_q(mid) - ln_ka
		if f_lo * f_mid <= 0.0:
			hi = mid
		else:
			lo = mid
			f_lo = f_mid

	x_eq = 0.5 * (lo + hi)
	p_so2_eq = p_so2_0 - x_eq
	p_o2_eq = p_o2_0 - 0.5 * x_eq
	p_so3_eq = p_so3_0 + x_eq
	return x_eq, p_so2_eq, p_o2_eq, p_so3_eq


def main() -> None:
	temperature = 900.0  # K
	p_so2_0 = 3.0e-4  # Pa
	p_o2_0 = 1.0e-4  # Pa
	p_so3_0 = 1.5e-4  # Pa

	p_total_0 = p_so2_0 + p_o2_0 + p_so3_0
	y_so2_0 = p_so2_0 / p_total_0
	y_o2_0 = p_o2_0 / p_total_0
	y_so3_0 = p_so3_0 / p_total_0

	delta_g0 = reaction_delta_g0(temperature)
	ka = equilibrium_constant(delta_g0, temperature)

	x_eq, p_so2_eq, p_o2_eq, p_so3_eq = solve_equilibrium_pressures(
		p_so2_0, p_o2_0, p_so3_0, ka
	)

	c_so2_eq = p_so2_eq / (R * temperature)
	c_o2_eq = p_o2_eq / (R * temperature)
	c_so3_eq = p_so3_eq / (R * temperature)
	alpha_a_eq = x_eq / p_so2_0

	print("Реакция: SO2 + 1/2 O2 = SO3")
	print(f"T = {temperature:.1f} K")
	print(f"Delta G0(T) = {delta_g0:.3f} J/mol ({delta_g0/1000.0:.3f} kJ/mol)")
	print(f"Ka = {ka:.6g}")

	print("\nНачальные мольные доли:")
	print(f"y_SO2,0 = {y_so2_0:.6f}")
	print(f"y_O2,0  = {y_o2_0:.6f}")
	print(f"y_SO3,0 = {y_so3_0:.6f}")

	print("\nРавновесные парциальные давления (Па):")
	print(f"p_SO2,eq = {p_so2_eq:.9e}")
	print(f"p_O2,eq  = {p_o2_eq:.9e}")
	print(f"p_SO3,eq = {p_so3_eq:.9e}")

	print("\nРавновесные концентрации (моль/м^3):")
	print(f"c_SO2,eq = {c_so2_eq:.9e}")
	print(f"c_O2,eq  = {c_o2_eq:.9e}")
	print(f"c_SO3,eq = {c_so3_eq:.9e}")

	print("\nСтепень равновесного превращения A (SO2):")
	print(f"alpha_A,eq = {alpha_a_eq:.6f}")


if __name__ == "__main__":
	main()

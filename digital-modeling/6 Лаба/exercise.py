import math


R = 8.31446261815324  # J/(mol*K)
T = 700.0  # K
P = 300000.0  # Pa
P0 = 100000.0  # Pa

# Standard Gibbs energies of reactions, J/mol
DG0_R1 = -30000.0
DG0_R2 = 60000.0

# Basis: 1 mol initial mixture
N0 = {
	"N2": 0.30,
	"H2": 0.50,
	"CH4": 0.10,
	"H2O": 0.10,
	"NH3": 0.00,
	"CO": 0.00,
}


def ka_from_dg0(delta_g0: float, temperature: float) -> float:
	"""Dimensionless activity equilibrium constant Ka = exp(-dG0/RT)."""
	return math.exp(-delta_g0 / (R * temperature))


def composition_from_extents(xi1: float, xi2: float) -> dict[str, float]:
	"""Return moles from extents xi1 (reaction 1), xi2 (reaction 2)."""
	n = {
		"N2": N0["N2"] - xi1,
		"H2": N0["H2"] - 3.0 * xi1 + 3.0 * xi2,
		"NH3": 2.0 * xi1,
		"CH4": N0["CH4"] - xi2,
		"H2O": N0["H2O"] - xi2,
		"CO": xi2,
	}
	n["NT"] = sum(n.values())
	return n


def ln_equations(xi1: float, xi2: float, ka1: float, ka2: float) -> tuple[float, float] | None:
	"""Log-form equations F1=0, F2=0 for robust Newton solving."""
	n = composition_from_extents(xi1, xi2)
	if min(n.values()) <= 0.0:
		return None

	y = {name: n[name] / n["NT"] for name in ("N2", "H2", "NH3", "CH4", "H2O", "CO")}
	p_ratio = P / P0

	f1 = (
		2.0 * math.log(y["NH3"])
		- math.log(y["N2"])
		- 3.0 * math.log(y["H2"])
		- 2.0 * math.log(p_ratio)
		- math.log(ka1)
	)
	f2 = (
		math.log(y["CO"])
		+ 3.0 * math.log(y["H2"])
		- math.log(y["CH4"])
		- math.log(y["H2O"])
		+ 2.0 * math.log(p_ratio)
		- math.log(ka2)
	)
	return f1, f2


def solve_extents(ka1: float, ka2: float) -> tuple[float, float]:
	"""Solve for equilibrium extents using damped Newton method."""
	xi1 = 0.10
	xi2 = 1e-4

	for _ in range(60):
		current = ln_equations(xi1, xi2, ka1, ka2)
		if current is None:
			raise ValueError("Invalid initial guess for solver")
		f1, f2 = current
		norm = abs(f1) + abs(f2)
		if norm < 1e-13:
			return xi1, xi2

		h = 1e-8
		p1 = ln_equations(xi1 + h, xi2, ka1, ka2)
		m1 = ln_equations(xi1 - h, xi2, ka1, ka2)
		p2 = ln_equations(xi1, xi2 + h, ka1, ka2)
		m2 = ln_equations(xi1, xi2 - h, ka1, ka2)
		if p1 is None or m1 is None or p2 is None or m2 is None:
			h = 1e-10
			p1 = ln_equations(xi1 + h, xi2, ka1, ka2)
			m1 = ln_equations(xi1 - h, xi2, ka1, ka2)
			p2 = ln_equations(xi1, xi2 + h, ka1, ka2)
			m2 = ln_equations(xi1, xi2 - h, ka1, ka2)
			if p1 is None or m1 is None or p2 is None or m2 is None:
				raise ValueError("Cannot estimate Jacobian near current point")

		df1_dxi1 = (p1[0] - m1[0]) / (2.0 * h)
		df2_dxi1 = (p1[1] - m1[1]) / (2.0 * h)
		df1_dxi2 = (p2[0] - m2[0]) / (2.0 * h)
		df2_dxi2 = (p2[1] - m2[1]) / (2.0 * h)

		det = df1_dxi1 * df2_dxi2 - df1_dxi2 * df2_dxi1
		if abs(det) < 1e-18:
			raise ValueError("Jacobian is singular")

		dxi1 = (-f1 * df2_dxi2 + f2 * df1_dxi2) / det
		dxi2 = (-df1_dxi1 * f2 + df2_dxi1 * f1) / det

		# Damping keeps the update inside physical bounds and improves stability.
		lam = 1.0
		improved = False
		for _ in range(30):
			cand_xi1 = xi1 + lam * dxi1
			cand_xi2 = xi2 + lam * dxi2
			cand = ln_equations(cand_xi1, cand_xi2, ka1, ka2)
			if cand is not None and abs(cand[0]) + abs(cand[1]) < norm:
				xi1, xi2 = cand_xi1, cand_xi2
				improved = True
				break
			lam *= 0.5
		if not improved:
			raise ValueError("Newton step failed to improve residual")

	raise ValueError("Solver did not converge")


def main() -> None:
	ka1 = ka_from_dg0(DG0_R1, T)
	ka2 = ka_from_dg0(DG0_R2, T)

	xi1, xi2 = solve_extents(ka1, ka2)
	n = composition_from_extents(xi1, xi2)
	y = {name: n[name] / n["NT"] for name in ("N2", "H2", "NH3", "CH4", "H2O", "CO")}
	p = {name: y[name] * P for name in y}
	c = {name: p[name] / (R * T) for name in p}

	alpha_n2 = xi1 / N0["N2"]

	print("T = 700 K, P = 300000 Pa")
	print(f"Ka1 (N2 + 3H2 <-> 2NH3) = {ka1:.6g}")
	print(f"Ka2 (CH4 + H2O <-> CO + 3H2) = {ka2:.6g}")

	print("\nEquilibrium mole numbers (basis 1 mol initial):")
	for name in ("N2", "H2", "NH3", "CH4", "H2O", "CO"):
		print(f"n_{name} = {n[name]:.9e} mol")

	print("\nEquilibrium concentrations:")
	for name in ("N2", "H2", "NH3", "CH4", "H2O", "CO"):
		print(f"c_{name} = {c[name]:.9e} mol/m^3")

	print("\nEquilibrium conversion degree of first reactant in reaction 1 (N2):")
	print(f"alpha_N2 = {alpha_n2:.6f}")


if __name__ == "__main__":
	main()

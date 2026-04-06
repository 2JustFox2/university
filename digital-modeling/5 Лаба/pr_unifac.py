#############
# UNIFAC + PR
#############

from thermo import * # type: ignore
from thermo.unifac import DOUFSG, DOUFIP2016
# Load constants and properties
constants, properties = ChemicalConstantsPackage.from_IDs(['acetone', 'water'])
# Objects are initialized at a particular condition
T = 333.15
P = 1e5
zs = [.5, .5]

#print(constants)

# Use Peng-Robinson for the vapor phase
k12 = -0.2477
kijs = [[0, k12],
        [k12, 0]]
print(k12)
eos_kwargs = dict(Tcs=constants.Tcs, Pcs=constants.Pcs, omegas=constants.omegas) #, kijs=kijs
gas = CEOSGas(PRMIX, HeatCapacityGases=properties.HeatCapacityGases, eos_kwargs=eos_kwargs)

# Configure the activity model
GE = UNIFAC.from_subgroups(chemgroups=constants.UNIFAC_Dortmund_groups, version=1, T=T, xs=zs, interaction_data=DOUFIP2016, subgroups=DOUFSG)
# Configure the liquid model with activity coefficients
liquid = GibbsExcessLiquid(
	VaporPressures=properties.VaporPressures,
	HeatCapacityGases=properties.HeatCapacityGases,
	VolumeLiquids=properties.VolumeLiquids,
	GibbsExcessModel=GE,
	equilibrium_basis='Psat', caloric_basis='Psat',
	T=T, P=P, zs=zs)

# Create a flasher instance, assuming only vapor-liquid behavior
flasher = FlashVL(constants, properties, liquid=liquid, gas=gas)

# Create a T-xy plot at P bar
_ = flasher.plot_Txy(P=P, pts=100)

# Create a P-xy plot at T Kelvin
_ = flasher.plot_Pxy(T=T, pts=100)

# Create a xy diagram at T Kelvin
_ = flasher.plot_xy(T=T, pts=100)

# VLLE flash
liquid2 = GibbsExcessLiquid(
	VaporPressures=properties.VaporPressures,
	HeatCapacityGases=properties.HeatCapacityGases,
	VolumeLiquids=properties.VolumeLiquids,
	GibbsExcessModel=GE,
	equilibrium_basis='Psat', caloric_basis='Psat',
	T=T, P=P, zs=zs)

flasher2 = FlashVLN(constants, properties, liquids=[liquid, liquid2], gas=gas)

x1_exp=[0.01, 0.03, 0.1, 0.5, 0.85];
y1_exp=[0.250369, 0.494505, 0.725424, 0.839958, 0.908808];

myT=[365.699, 355.741, 342.005, 332.748, 330.14];

#initial mole fractions of component 1 to start flash from
#take this between x and y at plot. At first glance, between x1_exp and y1_exp
zs=[0.1, 0.2, 0.7, 0.8, 0.87]

for i in range(5):
	res = flasher2.flash(T=myT[i], P=P, zs=[zs[i], 1-zs[i]])
	print('There are %s phases present at %f K and %f bar' %(res.phase_count,myT[i],P/1e5))
	if res.VF == 0:
		print("Only liquid")
	if res.VF > 0:
		print("x: ")
		print(res.gas.zs)
	if res.VF == 1:  # Есть только пар
		print("Only vapour")
	else:
		print("Liquid0: ")
		print(res.liquid0.zs)
		if res.liquid_count>1:
			print("LIQUID PHASE SEPARATION")
			print("Liquid1: ")
			print(res.liquid1.zs)


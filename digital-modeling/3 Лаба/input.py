import pandas as pd
import re

data_text = """
State	Temperature	Pressure	Thermal conductivity
	[K]	[°C]	[°F]	[bara]	[psia]	[mW/m K]	[kcal(IT)/(h m K)]	[Btu(IT)/(h ft °F)]
Liquid at equilibrium	134.9	-138.25	-216.85	6.7E-06	9.7E-05	176.6	0.1518	0.1020
	150	-123	-190	8.6E-05	1.2E-03	171.2	0.1472	0.09892
	200	-73	-100	0.0194	0.281	149.4	0.1285	0.08632
	220	-53	-64	0.0781	1.13	139.9	0.1203	0.08083
	240	-33.2	-28	0.241	3.49	130.4	0.1121	0.07534
	260	-13.2	8.3	0.610	8.84	121.2	0.1042	0.07003
	280	6.9	44.3	1.33	19.3	112.3	0.09656	0.06489
	300	26.9	80.3	2.58	37.4	103.9	0.08934	0.06003
	320	46.9	116	4.56	66.2	96.10	0.08263	0.05553
	340	66.9	152	7.52	109	88.88	0.07642	0.05135
	360	86.9	188	11.7	170	82.27	0.07074	0.04753
	380	106.9	224	17.4	252	76.22	0.06554	0.04404
	400	126.9	260	25.0	362	70.60	0.06071	0.04079
	420	146.9	296	34.9	506	67.19	0.05777	0.03882
	134.9	-138.25	-216.85	6.7E-06	9.7E-05	4.855	0.00417	0.00281
Gas at equilibrium	150	-123	-190	8.6E-05	1.2E-03	5.579	0.00480	0.00322
	200	-73	-100	0.0194	0.281	8.497	0.00731	0.00491
	220	-53	-64	0.0781	1.13	9.884	0.00850	0.00571
	240	-33.2	-28	0.241	3.49	11.39	0.00979	0.00658
	260	-13.2	8.3	0.610	8.84	13.03	0.01120	0.00753
	280	6.9	44.3	1.33	19.3	14.82	0.01274	0.00856
	300	26.9	80.3	2.58	37.4	16.78	0.01443	0.00970
	320	46.9	116	4.56	66.2	19.00	0.01634	0.01098
	340	66.9	152	7.52	109	21.58	0.01856	0.01247
	360	86.9	188	11.7	170	24.72	0.02126	0.01428
	380	107	224	17.4	252	28.81	0.02477	0.01665
	400	127	260	25.0	362	35.03	0.03012	0.02024
	420	147	296	34.9	506	53.10	0.04566	0.03068
Liquid	150	-123	-190	1	14.5	171.2	0.1472	0.09893
	200	-73.2	-100	1	14.5	149.4	0.1285	0.08632
	250	-23.2	-9.7	1	14.5	125.8	0.1082	0.07269
	272.31	-0.84	30.49	1	14.5	115.7	0.09947	0.06684
Gas	272.31	-0.84	30.49	1	14.5	14.11	0.01213	0.00815
	300	26.9	80.3	1	14.5	16.75	0.01440	0.00968
	350	76.9	170	1	14.5	22.12	0.01902	0.01278
	400	127	260	1	14.5	28.28	0.02431	0.01634
	450	177	350	1	14.5	35.23	0.03029	0.02036
	500	227	440	1	14.5	42.98	0.03696	0.02483
	550	277	530	1	14.5	51.53	0.04431	0.02978
Liquid	150	-123	-190	10	145	171.5	0.1474	0.09908
	200	-73.2	-100	10	145	149.8	0.1288	0.08655
	250	-23.2	-9.7	10	145	126.3	0.1086	0.07300
	300	26.9	80.3	10	145	104.5	0.08986	0.06038
	350	76.9	170	10	145	85.56	0.07357	0.04944
	352.62	79.47	175.05	10	145	84.64	0.07277	0.04890
Gas	352.62	79.47	175.05	10	145	23.47	0.02018	0.01356
	400	127	260	10	145	29.23	0.02513	0.01689
	450	177	350	10	145	36.24	0.03116	0.02094
	500	227	440	10	145	44.07	0.03789	0.02546
	550	277	530	10	145	52.70	0.04532	0.03045
"""

lines = data_text.strip().split('\n')

data = []
current_state = None

for line in lines:
    if 'State' in line or '[K]' in line or '[°C]' in line:
        continue
    
    parts = line.split('\t')
    
    parts = [p.strip() for p in parts if p.strip()]
    
    if len(parts) < 6:
        continue
    
    if parts[0] in ['Liquid at equilibrium', 'Gas at equilibrium', 'Liquid', 'Gas', 'Supercritical phase']:
        current_state = parts[0]
        if len(parts) > 6:
            temp_k = float(parts[1])
            pressure_bara = float(parts[4])
            thermal_cond = float(parts[6])
            
            # Берем только газовую фазу
            if current_state in ['Gas', 'Gas at equilibrium']:
                data.append({
                    'Temperature': temp_k,
                    'Pressure': pressure_bara,
                    'Cp': thermal_cond
                })
    else:
        if current_state in ['Gas', 'Gas at equilibrium'] and len(parts) >= 3:
            temp_k = float(parts[0])
            pressure_bara = float(parts[3])
            thermal_cond = float(parts[5])
            
            data.append({
                'Temperature': temp_k,
                'Pressure': pressure_bara,
                'Cp': thermal_cond
            })

df_gas = pd.DataFrame(data)
df_gas = df_gas.drop_duplicates()
df_gas = df_gas.sort_values(['Pressure', 'Temperature'])

print("Извлеченные данные для газовой фазы:")
print(df_gas)
print(f"\nВсего точек: {len(df_gas)}")

df_gas.to_csv('data_butane_gas_thermal_conductivity.csv', index=False)
print("\nФайл сохранен как 'data_butane_gas_thermal_conductivity.csv'")

print("\nСтатистика по давлениям:")
print(df_gas['Pressure'].value_counts().sort_index())
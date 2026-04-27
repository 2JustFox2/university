import random


arr = [['Tr\\Pr']]

for i in range(7, 12):
    arr[0].append(str(i/10))

for i in range(5, 10):
    arr.append([str(i/10)])
    for j in range(len(arr[0]) - 1):
        arr[-1].append(str(random.randint(7, 12) / 10))
    
with open('data.csv', 'w') as f:
    template = ' '.join(['{:<5}'] * len(arr[0])) + '\n'
    for row in arr:
        f.write(template.format(*row))
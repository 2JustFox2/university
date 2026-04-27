import re
from window import AppWindow

def parse_data(file_path):
    with open(file_path, 'r') as file:
        data = file.readlines()
        return [re.sub(r'\s+', ' ', line).strip().split(' ') for line in data]

def main():
    print("Программа запущена")
    data = parse_data('data.csv')
    AppWindow(data)
    print(data)

if __name__ == "__main__":
    main()
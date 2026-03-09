import os
import pathlib

# Сапунков Александр Андреевич 15

class Path:
    def __init__(self, path):
        self.path = pathlib.Path(path)

    def __str__(self):
        return self.path.__str__()

    def __repr__(self):
        return f"Path('{self.path.__str__()}')"

    def get_directory_with_number(self):
        res = []
        if self.path.is_dir():
            if any(char.isdigit() for char in self.path.name):
                res.append(self.path)

        for parent in self.path.parents:
            dirk = parent.name
            if any(char.isdigit() for char in dirk):
                res.append(parent)
        return res

    def replace_directory_number(self):
        directories = self.get_directory_with_number()
        for directory in directories:
            new_name = ''.join([chr(65 + int(i)) if i.isdigit() else i for i in directory.name])
            new_file_path = directory.with_name(new_name)
            directory.rename(new_file_path)
        return self.path

    def swap_folders(self):
        if self.path.is_dir():
            first_directory = self.path.name
        else:
            first_directory = self.path.parent.name

        final_directory = self.path.parents[-1].drive[:-1]
        
        print(first_directory, final_directory)
        print(str(self.path).replace(first_directory, '1temp', 1).replace(final_directory, first_directory, 1).replace('1temp', final_directory, 1))

    def get_directory_with_underscore(self):
        res = []
        if self.path.is_dir():
            if any(char == '_' for char in self.path.name):
                res.append(self.path)

        for parent in self.path.parents:
            dirk = parent.name
            if any(char == '_' for char in dirk):
                res.append(parent)
        return res

def main():
    # path = Path(os.path.abspath(__file__))
    path = Path("C:\\Users\\alexv\\OneDrive\\Pictures\\Camera Roll\\test_1")
    print(path)
    print(f"Папок, содержащих в своих именах цифры: {len(path.get_directory_with_number())}")
    print(f"Папок, содержащих в своих именах подчеркивания: {len(path.get_directory_with_underscore())}")
    # print(f"Папки изменившее свои цифры на буквы: {path.replace_directory_number()}")
    print(f"Поменять местами первую и последнюю папки: {path.swap_folders()}")
    
    print(path)

if __name__ == "__main__":
    main()
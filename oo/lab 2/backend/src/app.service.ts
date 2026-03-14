import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as fse from 'fs-extra';

@Injectable()
export class AppService {
  getHello(): string {
    return 'Hello World!';
  }

  async getFiles(FilePath: string): Promise<
    {
      name: string;
      weight: string;
      extension: string;
    }[]
  > {
    try {
      function formatBits(bits) {
        if (bits === 0) return '0 Бит';
        const bytes = bits / 8;
        const sizes = ['Байт', 'КБ', 'МБ', 'ГБ', 'ТБ'];
        const i = Math.floor(Math.log(bytes) / Math.log(1024));
        return (
          parseFloat((bytes / Math.pow(1024, i)).toFixed(2)) + ' ' + sizes[i]
        );
      }
      const files = await fs.promises.readdir(FilePath);
      const processedFiles = await Promise.all(
        files.map(async (file) => {
          const stats = await fs.promises.stat(`${FilePath}\\${file}`);
          if (stats.isDirectory()) {
            return {
              name: `${file}`,
              weight: '-',
              extension: 'directory',
            };
          }
          return {
            name: file,
            weight: formatBits(stats.size),
            extension: file.split('.').pop() || '',
          };
        }),
      );
      return processedFiles;
    } catch (err) {
      console.error('Error reading directory:', err);
      return [];
    }
  }

  async rename(filePath: string, newFilePath: string): Promise<void> {
    try {
      // const newFilePath =
      //   filePath.substring(0, filePath.lastIndexOf('\\') + 1) + newName;
      await fs.promises.rename(filePath, newFilePath);
    } catch (err) {
      console.error(`Error renaming file ${filePath}:`, err);
    }
  }

  async copy(filePath: string, newFilePath: string): Promise<void> {
    try {
      await fse.copy(filePath, newFilePath);
    } catch (err) {
      console.error(`Error copying file ${filePath}:`, err);
    }
  }

  async move(filePath: string, newFilePath: string): Promise<void> {
    try {
      await fse.move(filePath, newFilePath);
    } catch (err) {
      console.error(`Error moving file ${filePath}:`, err);
    }
  }

  async remove(filePath: string): Promise<void> {
    try {
      await fse.remove(filePath);
    } catch (err) {
      console.error(`Error removing file ${filePath}:`, err);
    }
  }
}

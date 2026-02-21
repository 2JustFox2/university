import { Injectable } from '@nestjs/common';
import * as fs from 'fs';

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
            weight: `${stats.size} bytes`,
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

  async getFileStat(filePath: string): Promise<fs.Stats | null> {
    try {
      const stats = await fs.promises.stat(filePath);
      return stats;
    } catch (err) {
      console.error(`Error getting stats for file ${filePath}:`, err);
      return null;
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
}

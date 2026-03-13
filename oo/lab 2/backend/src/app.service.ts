/* eslint-disable @typescript-eslint/no-unsafe-call */
import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as koffi from 'koffi';
import * as fse from 'fs-extra';

class DiskInfoService {
  private kernel32: any;
  private getLogicalDrives: any;

  constructor() {
    // 1. Загружаем библиотеку kernel32.dll
    this.kernel32 = koffi.load('kernel32.dll');

    // 2. Объявляем функцию GetLogicalDrives.
    // Она возвращает битовую маску, где каждый бит соответствует букве диска
    // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access
    this.getLogicalDrives = this.kernel32.func('uint32_t GetLogicalDrives()');
  }

  /**
   * Получает список всех логических дисков в системе
   */
  getAvailableDrives(): string[] {
    const drives: string[] = [];
    // Вызываем системную функцию
    // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
    const mask: number = this.getLogicalDrives();

    if (mask === 0) {
      return [];
    }

    // Проходим по 26 возможным буквам дисков (от A до Z)
    for (let i = 0; i < 26; i++) {
      // Если i-й бит установлен, значит диск с этой буквой существует
      if (mask & (1 << i)) {
        const letter = String.fromCharCode(65 + i); // 65 — это код буквы 'A'
        drives.push(`${letter}:\\`);
      }
    }

    return drives;
  }
}

const kernel32 = koffi.load('kernel32.dll');
const GetDiskFreeSpaceExW = kernel32.func(
  '__stdcall',
  'GetDiskFreeSpaceExW',
  'bool',
  ['str16', 'uint64*', 'uint64*', 'uint64*'],
);

function formatBytes(value: number | bigint): string {
  const bytes = Number(value);

  if (bytes === 0) {
    return '0 Байт';
  }

  const sizes = ['Байт', 'КБ', 'МБ', 'ГБ', 'ТБ'];
  const index = Math.min(
    Math.floor(Math.log(bytes) / Math.log(1024)),
    sizes.length - 1,
  );

  return `${parseFloat((bytes / 1024 ** index).toFixed(2))} ${sizes[index]}`;
}

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
          try {
            const stats = await fs.promises.stat(`${FilePath}\\${file}`);
            if (stats.isDirectory()) {
              return {
                name: `${file}`,
                weight: formatBytes(stats.size),
                extension: 'directory',
              };
            }
            return {
              name: file,
              weight: formatBytes(stats.size),
              extension: file.split('.').pop() || '',
            };
          } catch (err) {
            console.error(`Error reading file ${file}:`, err);
            return null;
          }
        }),
      );
      return processedFiles.filter((v): v is NonNullable<typeof v> => !!v);
    } catch (err) {
      console.error('Error reading directory:', err);
      return [];
    }
  }

  async rename(filePath: string, newFilePath: string): Promise<void> {
    try {
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

  getFreeSpace(disk: string): string[] {
    try {
      const freeAvailable = Buffer.alloc(8);
      const total = Buffer.alloc(8);
      const totalFree = Buffer.alloc(8);

      const normalizedDisk = disk.endsWith('\\') ? disk.slice(0, -1) : disk;
      const diskRoot = `${normalizedDisk}\\`;

      const ok =
        GetDiskFreeSpaceExW(diskRoot, freeAvailable, total, totalFree) === true;

      if (!ok) {
        throw new Error('GetDiskFreeSpaceExW failed');
      }
      const totalBytes = total.readBigUInt64LE(0);
      const totalFreeBytes = totalFree.readBigUInt64LE(0);
      const used = totalBytes - totalFreeBytes;

      return [
        formatBytes(totalBytes),
        formatBytes(totalFreeBytes),
        formatBytes(used),
      ];
    } catch (err) {
      console.error(`Error getting free space for disk ${disk}:`, err);
      return ['0 Байт', '0 Байт', '0 Байт'];
    }
  }

  getDisk(): {
    total: string;
    free: string;
    used: string;
    name: string;
  }[] {
    try {
      const data: {
        name: string;
        total: string;
        free: string;
        used: string;
      }[] = [];
      const allDiskInfoService = new DiskInfoService().getAvailableDrives();
      for (const disk of allDiskInfoService) {
        const [total, free, used] = this.getFreeSpace(disk);
        data.push({
          name: disk,
          total,
          free,
          used,
        });
      }

      return data;
    } catch (err) {
      console.error('Error getting disk usage:', err);
      return [
        { name: 'Unknown', total: '0 Байт', free: '0 Байт', used: '0 Байт' },
      ];
    }
  }
}

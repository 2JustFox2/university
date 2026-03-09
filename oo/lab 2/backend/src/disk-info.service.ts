// simple-disk-info.service.ts
import { Injectable, Logger } from '@nestjs/common';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

export interface DiskSpaceInfo {
  path: string;
  total: number;
  used: number;
  free: number;
  filesystem?: string;
  mountPoint?: string;
}

export interface FormattedDiskSpaceInfo extends DiskSpaceInfo {
  totalFormatted: string;
  usedFormatted: string;
  freeFormatted: string;
  usagePercent: string;
}

@Injectable()
export class SimpleDiskInfoService {
  private readonly logger = new Logger(SimpleDiskInfoService.name);

  /**
   * Получает информацию о свободном месте на диске
   * @param path - путь к диску или директории
   */
  async getDiskSpace(path: string): Promise<DiskSpaceInfo> {
    try {
      this.logger.log(`Getting disk space for path: ${path}`);

      return await this.getWindowsDiskSpace(path);
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : String(error);
      this.logger.error(
        `Failed to get disk space for ${path}: ${errorMessage}`,
      );
      throw new Error(`Failed to get disk space: ${errorMessage}`);
    }
  }

  /**
   * Получает информацию о всех доступных дисках
   */
  async getAllDrives(): Promise<DiskSpaceInfo[]> {
    try {
      if (process.platform === 'win32') {
        return await this.getAllWindowsDrives();
      } else {
        return await this.getAllUnixMounts();
      }
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : String(error);
      this.logger.error(`Failed to get Windows drives: ${errorMessage}`);
      throw error;
    }
  }

  /**
   * Получает отформатированную информацию о диске
   * @param path - путь к диску
   */
  async getFormattedDiskSpace(path: string): Promise<FormattedDiskSpaceInfo> {
    const info = await this.getDiskSpace(path);

    return {
      ...info,
      totalFormatted: this.formatBytes(info.total),
      usedFormatted: this.formatBytes(info.used),
      freeFormatted: this.formatBytes(info.free),
      usagePercent: ((info.used / info.total) * 100).toFixed(2) + '%',
    };
  }

  /**
   * Получает информацию о диске в Windows
   * @param path - путь к диску (например, "C:\")
   */
  private async getWindowsDiskSpace(path: string): Promise<DiskSpaceInfo> {
    // Нормализуем путь
    const normalizedPath = path.replace(/\\$/, '');

    try {
      // Используем WMIC для получения информации о диске
      const { stdout, stderr } = await execAsync(
        `wmic logicaldisk where "DeviceID='${normalizedPath}'" get Size,FreeSpace /format:csv`,
      );

      if (stderr) {
        throw new Error(`WMIC error: ${stderr}`);
      }

      // Парсим вывод WMIC
      const lines = stdout
        .trim()
        .split('\n')
        .filter((line) => line.trim());

      if (lines.length < 2) {
        throw new Error(`No data returned for drive ${normalizedPath}`);
      }

      // CSV формат: Node,DeviceID,FreeSpace,Size
      const [, , freeSpaceStr, sizeStr] = lines[1].split(',');

      const total = parseInt(sizeStr, 10);
      const free = parseInt(freeSpaceStr, 10);

      if (isNaN(total) || isNaN(free)) {
        throw new Error('Invalid disk space data received');
      }

      return {
        path: normalizedPath,
        total,
        free,
        used: total - free,
      };
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : String(error);
      this.logger.error(`Windows disk space error: ${errorMessage}`);
      throw error;
    }
  }

  /**
   * Получает информацию о всех дисках в Windows
   */
  private async getAllWindowsDrives(): Promise<DiskSpaceInfo[]> {
    try {
      const { stdout, stderr } = await execAsync(
        'wmic logicaldisk get DeviceID,Size,FreeSpace /format:csv',
      );

      if (stderr) {
        throw new Error(`WMIC error: ${stderr}`);
      }

      const lines = stdout
        .trim()
        .split('\n')
        .filter((line) => line.trim());
      const drives: DiskSpaceInfo[] = [];

      // Пропускаем заголовок (первая строка)
      for (let i = 1; i < lines.length; i++) {
        const [, deviceId, freeSpaceStr, sizeStr] = lines[i].split(',');

        const total = parseInt(sizeStr, 10);
        const free = parseInt(freeSpaceStr, 10);

        // Пропускаем диски без информации о размере
        if (!isNaN(total) && !isNaN(free)) {
          drives.push({
            path: deviceId,
            total,
            free,
            used: total - free,
          });
        }
      }

      return drives;
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : String(error);
      this.logger.error(`Failed to get Windows drives: ${errorMessage}`);
      throw error;
    }
  }

  /**
   * Получает информацию о всех точках монтирования в Unix
   */
  private async getAllUnixMounts(): Promise<DiskSpaceInfo[]> {
    try {
      const { stdout, stderr } = await execAsync('df -k -P | tail -n +2');

      if (stderr) {
        throw new Error(`df error: ${stderr}`);
      }

      const lines = stdout.trim().split('\n');
      const mounts: DiskSpaceInfo[] = [];

      for (const line of lines) {
        if (!line.trim()) continue;

        const parts = line.trim().split(/\s+/);
        if (parts.length >= 6) {
          const filesystem = parts[0];
          const totalKb = parseInt(parts[1], 10);
          const usedKb = parseInt(parts[2], 10);
          const freeKb = parseInt(parts[3], 10);
          const mountPoint = parts[5];

          mounts.push({
            path: mountPoint,
            total: totalKb * 1024,
            used: usedKb * 1024,
            free: freeKb * 1024,
            filesystem,
            mountPoint,
          });
        }
      }

      return mounts;
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : String(error);
      this.logger.error(`Failed to get Unix mounts: ${errorMessage}`);
      throw error;
    }
  }

  /**
   * Форматирует байты в читаемый вид
   * @param bytes - количество байт
   */
  private formatBytes(bytes: number): string {
    if (bytes === 0) return '0 B';

    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));

    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }

  /**
   * Проверяет доступность диска
   * @param path - путь к диску
   */
  async isDiskAvailable(path: string): Promise<boolean> {
    try {
      await this.getDiskSpace(path);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Получает информацию о диске в процентах
   * @param path - путь к диску
   */
  async getDiskUsagePercent(path: string): Promise<number> {
    const info = await this.getDiskSpace(path);
    return (info.used / info.total) * 100;
  }
}

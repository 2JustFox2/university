import { Controller, Get, Post, Query } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Get('Directory')
  async getFiles(@Query('fullPath') fullPath: string) {
    process.chdir(fullPath);
    const files = await this.appService.getFiles(fullPath);
    return { files };
  }

  @Post('file/rename')
  async renameFile(
    @Query('fullPath') fullPath: string,
    @Query('newFilePath') newFilePath: string,
  ) {
    await this.appService.rename(fullPath, newFilePath);
    return { message: 'File renamed successfully' };
  }

  @Post('file/copy')
  async copyFile(
    @Query('fullPath') fullPath: string,
    @Query('newFilePath') newFilePath: string,
  ) {
    await this.appService.copy(fullPath, newFilePath);
    return { message: 'File copied successfully' };
  }

  @Post('file/move')
  async moveFile(
    @Query('fullPath') fullPath: string,
    @Query('newFilePath') newFilePath: string,
  ) {
    await this.appService.move(fullPath, newFilePath);
    return { message: 'File moved successfully' };
  }

  @Post('file/remove')
  async removeFile(@Query('fullPath') fullPath: string) {
    await this.appService.remove(fullPath);
    return { message: 'File removed successfully' };
  }
}

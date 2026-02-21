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
    // process.chdir(fullPath);
    await this.appService.rename(fullPath, newFilePath);
    return { message: 'File renamed successfully' };
  }
}

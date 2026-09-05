import { AppService } from "./app.service.js";

function Controller(_path: string): ClassDecorator {
  return () => undefined;
}

function Get(): MethodDecorator {
  return () => undefined;
}

@Controller("app")
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getGreeting(): string {
    return this.appService.getGreeting();
  }
}

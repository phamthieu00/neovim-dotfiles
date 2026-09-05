function Injectable(): ClassDecorator {
  return () => undefined;
}

@Injectable()
export class AppService {
  getGreeting(): string {
    return "Hello from the fixture";
  }
}

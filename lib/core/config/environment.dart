enum Environment { dev, staging, prod }

class EnvironmentConfig {
  static Environment get current {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    switch (env.toLowerCase()) {
      case 'staging':
        return Environment.staging;
      case 'prod':
      case 'production':
        return Environment.prod;
      case 'dev':
      case 'development':
      default:
        return Environment.dev;
    }
  }

  static String get baseUrl {
    switch (current) {
      case Environment.dev:
        return const String.fromEnvironment(
          'DEV_API_URL',
          defaultValue: 'https://d0ffd7861caa.ngrok-free.app',
        );
      case Environment.staging:
        return const String.fromEnvironment(
          'STAGING_API_URL',
          defaultValue: 'https://staging-api.example.com',
        );
      case Environment.prod:
        return const String.fromEnvironment(
          'PROD_API_URL',
          defaultValue: 'https://api.example.com',
        );
    }
  }

  static bool get isDevelopment => current == Environment.dev;

  static bool get isStaging => current == Environment.staging;

  static bool get isProduction => current == Environment.prod;

  static String get name {
    switch (current) {
      case Environment.dev:
        return 'development';
      case Environment.staging:
        return 'staging';
      case Environment.prod:
        return 'production';
    }
  }
}


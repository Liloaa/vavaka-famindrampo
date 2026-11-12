class Env {
  static const apiUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.90.30:3000/api',
  );
}
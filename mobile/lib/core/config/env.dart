class Env {
  static const apiUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://vavaka-famindrapo-api.onrender.com/api',
  );
}
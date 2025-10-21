import 'package:app_todo/services/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';
import '../models/token_pair.dart';
import 'token_storage.dart';

/// Базовый класс для взаимодействия с API.
/// Использует Fresh (интерсептор) для автоматической аутентификации и обновления токенов.
class ApiClient {
  static const String _baseUrl =
      'http://5.129.206.58/'; // Используйте ваш актуальный IP

  late final Dio _dio;
  late final Fresh<TokenPair> _fresh;

  // ИСПРАВЛЕНИЕ 1: Создаем прямой экземпляр хранилища для прямого доступа к read()/write()
  final SecureTokenStorage _tokenStorage = SecureTokenStorage();

  // Предоставляем доступ к Fresh, чтобы main.dart мог слушать события токена
  Fresh<TokenPair> get fresh => _fresh;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );

    // 1. Настройка Fresh (логика обновления токенов)
    _fresh = Fresh.oAuth2<TokenPair>(
      // ИСПРАВЛЕНИЕ 2: Передаем в Fresh наш прямой экземпляр хранилища
      tokenStorage: _tokenStorage,

      tokenHeader: (token) => {'Authorization': "Bearer ${token.accessToken}"},
      // 2. Логика обновления токена (вызывается при ошибке 401)
      refreshToken: (token, client) async {
        if (token == null || token.refreshToken == null) {
          throw RevokeTokenException();
        }

        try {
          final response = await client.post(
            '/api/token/refresh/', // Эндпоинт для обновления токена
            data: {'refresh': token.refreshToken},
          );

          return TokenPair.fromJson(response.data);
        } on DioException {
          // Если обновление токена не удалось, вызываем исключение
          throw RevokeTokenException();
        }
      },
      // 3. Обработка ошибки 401
      shouldRefresh: (response) => response?.statusCode == 401,
    );

    // Добавляем Fresh как интерсептор к Dio
    _dio.interceptors.add(_fresh);
  }

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  // =========================================================================
  // МЕТОДЫ АУТЕНТИФИКАЦИИ
  // =========================================================================

  /// Вход в систему
  Future<void> login(String username, String password) async {
    final response = await _dio.post(
      '/api/token/', // Эндпоинт для получения токенов
      data: {'username': username, 'password': password},
    );

    final token = TokenPair.fromJson(response.data);
    await _fresh.setToken(token);
  }

  /// Выход из системы
  Future<void> logout() async {
    await _fresh.setToken(null);
  }

  /// Проверяет, есть ли сохраненный токен при старте приложения.
  Future<bool> isAuthenticated() async {
    // ИСПРАВЛЕНИЕ 3: Вызываем read() напрямую из нашего экземпляра хранилища
    final TokenPair? token = await _tokenStorage.read();
    return token != null;
  }

  // =========================================================================
  // МЕТОДЫ РАБОТЫ С ЗАДАЧАМИ (Todo)
  // =========================================================================

  /// Получает список всех задач
  Future<List<dynamic>> getTodos() async {
    final response = await _dio.get('/api/todos/');
    return response.data['results']; // Список Map<String, dynamic>
  }

  /// Создает новую задачу
  Future<void> createTodo(String todoText, String description) async {
    await _dio.post(
      '/api/todos/',
      data: {'title': todoText, 'completed': false, 'description': description},
    );
  }

  Future<void> updateTodoStatus(int id, bool newStatus) async {
    await _dio.patch('/api/todos/$id/', data: {'completed': newStatus});
  }

  /// Обновляет статус задачи
  Future<void> updateTodoContent(
    int id,
    String newTitle,
    String newDescription,
  ) async {
    await _dio.patch(
      '/api/todos/$id/',
      data: {'title': newTitle, 'description': newDescription},
    );
  }

  /// Удаляет задачу
  Future<void> deleteTodo(int id) async {
    await _dio.delete('/api/todos/$id/');
  }
}

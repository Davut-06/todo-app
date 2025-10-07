import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async'; // Для TimeoutException и Future.delayed
import 'dart:developer' as developer; // Для логирования
import '../models/user.dart';
import '../models/todo.dart';

class AuthService {
  static const String baseUrl = 'https://dummyjson.com';

  // Метод 1: Вход в систему (login)
  Future<User> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10)); // Таймаут 10 секунд

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return User.fromJson(jsonBody);
      } else {
        // --- БЛОК ОТЛАДКИ ОШИБОК СЕРВЕРА ---
        print('--- DUMMYJSON LOGIN ERROR DEBUG ---');
        print('Status Code: ${response.statusCode}');
        String responseBody = response.body;
        print('Response Body: $responseBody');
        print('-----------------------------------');

        // Попытка извлечь сообщение об ошибке из JSON
        try {
          final errorJson = jsonDecode(responseBody);
          if (errorJson['message'] != null) {
            // Выбрасываем точное сообщение от сервера
            throw Exception(
              'Status ${response.statusCode}: ${errorJson['message']}',
            );
          }
        } catch (_) {
          // Если тело ответа не JSON, выбрасываем общую ошибку
        }

        throw Exception('Login failed. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      // Ошибка, если запрос занял больше 10 секунд
      throw Exception(
        'Timeout: Server did not respond. Check your internet connection.',
      );
    } catch (e) {
      // Если это не Timeout, перебрасываем ошибку дальше (например, ошибка сокета)
      rethrow;
    }
  }

  // Метод 2: Получение списка To-Do задач для пользователя (fetchUserTodos)
  Future<List<Todo>> fetchUserTodos(int userId, String token) async {
    final url = Uri.parse('$baseUrl/todos/user/$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final List todosList = jsonBody['todos'] as List;

      return todosList.map((json) => Todo.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load user todos. Status: ${response.statusCode}',
      );
    }
  }

  // ------------------------------------------------------------------
  // *** ИСПРАВЛЕНИЕ: МЕТОД 3 ДОБАВЛЕН ВНУТРЬ КЛАССА AuthService ***
  // ------------------------------------------------------------------
  Future<Todo> addTodo(Todo newTodo, int userId, String token) async {
    // 1. Имитация задержки сети
    await Future.delayed(const Duration(milliseconds: 700));

    // 2. Имитация успешного ответа
    const int mockStatusCode = 200;

    // 3. Вывод в консоль для подтверждения (ваш запрос)
    developer.log(
      'MOCK API: УСПЕШНАЯ ОТПРАВКА (Status $mockStatusCode)',
      name: 'AuthService/addTodo',
      error: 'Запрос: POST /todos. UserID: $userId. Задача: ${newTodo.todo}',
    );

    // 4. Имитация ответа сервера: возвращаем объект с присвоенным ID
    //    используем время для создания уникального мок-ID
    return newTodo.copyWith(
      id: DateTime.now().millisecondsSinceEpoch,
      completed: false,
      userId: userId,
    );
  }
}

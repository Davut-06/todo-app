import 'package:flutter/material.dart';
import 'package:app_todo/services/auth_service.dart';
import 'package:app_todo/models/user.dart';
import 'todo_list_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 2. Переменные для логина
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // 3. Метод обработки входа (ОБНОВЛЕННЫЙ с отладкой)
  Future<void> _handleLogin() async {
    // --- ПЕЧАТЬ ДЛЯ ПРОВЕРКИ ---
    print('--- КНОПКА НАЖАТА, МЕТОД ВЫЗВАН ---');
    // ----------------------------

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User user = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      // Проверка, что виджет все еще в дереве (ВАЖНО для async)
      if (!mounted) return;

      // УСПЕХ: Перенаправляем на новый экран задач
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TodoListScreen(user: user)),
      );
    } catch (e) {
      // ОШИБКА: Теперь показываем более детальную информацию
      print('--- ОШИБКА АУТЕНТИФИКАЦИИ В UI ---');
      print(e); // Вывод полного исключения из AuthService

      // Показываем ошибку, которую нам передал AuthService (включая статус и сообщение)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Убираем AppBar для чистого экрана
      body: Stack(
        // Используем Stack для размещения изображения под UI
        children: [
          // 1. Фоновое изображение (ПЕРВЫЙ ЭЛЕМЕНТ В STACK)
          Positioned.fill(
            child: Image.asset(
              'assets/images/1b.jpg',
              fit: BoxFit.cover, // Растянуть изображение на весь экран
            ),
          ),

          // 2. Весь остальной UI (поверх изображения)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Заголовок
                  const Text(
                    'WELCOME',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign in to access your tasks',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  // 2. Блок входа (Карточка)
                  Container(
                    padding: const EdgeInsets.all(25.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Поле Username
                        TextField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'emilys',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Поле Password
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'emilyspass',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Кнопка LOGIN
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.cyanAccent,
                            )
                            : ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 60),
                                backgroundColor: Colors.cyan,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                elevation: 10,
                              ),
                              child: const Text(
                                'SIGN IN',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const SelectableText(
                    'Help: emilys | emilyspass',
                    style: TextStyle(fontSize: 14, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

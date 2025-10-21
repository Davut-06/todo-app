import 'package:app_todo/services/api_client.dart';
import 'package:flutter/material.dart';
// УДАЛЯЕМ: import 'package:app_todo/models/user.dart'; // User больше не нужен здесь
import 'todo_list_screen.dart';

// Если вы используете GoRouter, возможно, вам понадобится:
// import 'package:go_router/go_router.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 2. Переменные для логина
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiClient _authService = ApiClient();
  bool _isLoading = false;

  // 3. Метод обработки входа
  Future<void> _handleLogin() async {
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
      // ИСПРАВЛЕНО: Вызываем login. Результат (токен) автоматически сохраняется.
      await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      // ИСПРАВЛЕНО: Перенаправляем на экран задач БЕЗ передачи User.
      // Если вы используете GoRouter (как видно из main.dart):
      // GoRouter.of(context).go('/');

      // Если вы используете Navigator.pushReplacement:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TodoListScreen()),
      );
    } catch (e) {
      // В случае ошибки Dio, e будет содержать полезную информацию
      print('--- ОШИБКА АУТЕНТИФИКАЦИИ В UI ---');
      print(e);

      String errorMessage = 'Login failed. Check credentials.';
      // Вы можете добавить обработку DioException для лучшего сообщения
      // if (e is DioException && e.response?.statusCode == 401) {
      //   errorMessage = 'Invalid username or password.';
      // }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (весь код build остается без изменений)
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/1b.jpg', fit: BoxFit.cover),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                        TextField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'ahmet',
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

                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'ahmet',
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
                    'Help: ahmet | ahmet',
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

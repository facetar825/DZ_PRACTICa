import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  String loginError = '';
  String passwordError = '';
  String successMessage = '';


  String? validateLogin(String login) {
    if (login.length < 4 || login.length > 12) {
      return 'Логин должен быть от 4 до 12 символов';
    }

    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(login)) {
      return 'Только буквы и цифры (без символов)';
    }

    return null;
  }


  String? validatePassword(String password) {
    if (password.length < 6) {
      return 'Минимум 6 символов';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Добавьте заглавную букву';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Добавьте цифру';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Добавьте спец. символ';
    }

    return null;
  }


  void register() {
    setState(() {
      loginError = '';
      passwordError = '';
      successMessage = '';

      final login = _loginController.text;
      final password = _passwordController.text;

      final loginValidation = validateLogin(login);
      final passwordValidation = validatePassword(password);

      if (loginValidation != null) {
        loginError = loginValidation;
      }

      if (passwordValidation != null) {
        passwordError = passwordValidation;
      }

      if (loginValidation == null && passwordValidation == null) {
        successMessage = 'Регистрация успешна';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: GFCard(
          elevation: 8,
          margin: const EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Регистрация',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),


              TextField(
                controller: _loginController,
                decoration: InputDecoration(
                  labelText: 'Логин',
                  border: const OutlineInputBorder(),
                  errorText: loginError.isEmpty ? null : loginError,
                ),
              ),

              const SizedBox(height: 15),


              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  border: const OutlineInputBorder(),
                  errorText: passwordError.isEmpty ? null : passwordError,
                ),
              ),

              const SizedBox(height: 20),


              GFButton(
                text: 'Зарегистрироваться',
                fullWidthButton: true,
                onPressed: register,
              ),

              const SizedBox(height: 10),


              if (successMessage.isNotEmpty)
                Text(
                  successMessage,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
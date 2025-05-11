import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin = true;
  String errorMessage = '';

  Future<void> handleAuth() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Please enter username and password.');
      return;
    }

    ParseResponse response;
    if (isLogin) {
      final user = ParseUser(username, password, null);
      response = await user.login();
    } else {
      final user = ParseUser(username, password, username);
      response = await user.signUp();
    }

    if (response.success) {
      Navigator.of(context).pushReplacementNamed('/crud');
    } else {
      setState(() => errorMessage = response.error?.message ?? 'Error occurred.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 10),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: handleAuth, child: Text(isLogin ? 'Login' : 'Sign Up')),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? 'Create an account' : 'Already have an account?'),
            ),
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}

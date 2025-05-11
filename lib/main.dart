import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'login_page.dart';
import 'crud_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const keyApplicationId = 'ZwL1PIe5xY3GSeFTlRCFi1oo6lQ3yDeiPmsj4gjI';
  const keyClientKey = 'BiLzyFGJtZdXI8T3FRIQD55ZkUbs0FewAAGIgmO3';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  final currentUser = await ParseUser.currentUser() as ParseUser?;

  runApp(MyApp(isLoggedIn: currentUser != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Back4App CRUD',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: isLoggedIn ? '/crud' : '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/crud': (context) => const CrudPage(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ViewModels/auth_viewmodel.dart';
import 'Views/welcome_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthViewModel())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trao Đổi Sách',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          primary: Colors.black,
        ),
        useMaterial3: true,
      ),
      // Cứ gọi thẳng tên màn hình
      home: WelcomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/registro_page.dart';
import '../pages/home_page.dart';

Map<String, WidgetBuilder> getAppRoutes() {
  return <String, WidgetBuilder>{
    '/': (context) => const LoginPage(),
    '/login': (context) => const LoginPage(),
    '/registro': (context) => const RegistroPage(),
    '/home': (context) => const HomePage(),
  };
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/Login/login.dart';
import 'screens/Login/register.dart';
import 'screens/homePage/home.dart';

// // Cấu hình router
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);

// final GoRouter router = GoRouter(
//   initialLocation: '/', // Mặc định là màn hình đăng nhập
//   routes: [
//     GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
//     GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
//   ],
//   redirect: (context, state) async {
//     final token = await SharedPrefs.getToken();
//     final isAuthenticated = token != null;
//     if (!isAuthenticated && state.fullPath != '/') {
//       return '/';
//     }
//     return null;
//   },
// );

import 'package:beacon/presentation/pages/chat.dart';
import 'package:beacon/presentation/pages/dashboard.dart';
import 'package:beacon/presentation/pages/resources.dart';
import 'package:flutter/material.dart';

import 'presentation/pages/profile.dart';
import 'presentation/pages/landing_page.dart';

import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
      return const LandingPage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'dashboard',
          builder: (BuildContext context, GoRouterState state) {
            return const NetworkDashboardPage();
          },
        ),
        GoRoute(
          path: 'profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfilePage();
          },
        ),
        GoRoute(
          path: 'resources',
          builder: (BuildContext context, GoRouterState state) {
            return const ResourcesPage();
          },
        ),
        GoRoute(
          path: 'chat',
          builder: (BuildContext context, GoRouterState state) {
            return const ChattingPage();
          },
        ),
      ],
    ),
  ],
);


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'BEACON',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.red,
        colorScheme: ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.redAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }
}

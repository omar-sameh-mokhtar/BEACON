import 'package:beacon/presentation/pages/chat.dart';
import 'package:beacon/presentation/pages/dashboard.dart';
import 'package:beacon/presentation/pages/resources.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/pages/profile.dart';
import 'presentation/pages/landing_page.dart';

import 'package:go_router/go_router.dart';

import 'viewmodels/voice_viewmodel.dart';
import 'viewmodels/p2p_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VoiceViewModel()),
        ChangeNotifierProvider(create: (context) => MyAppState()),
        ChangeNotifierProvider(create: (context) => P2PViewModel()),
      ],
      child: const MyApp(),
    ),
  );
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
          name: 'dashboard',
          path: 'dashboard/:isHost',
          builder: (BuildContext context, GoRouterState state) {
            final isHost = state.pathParameters['isHost'] == 'true';

            return NetworkDashboardPage(isHost: isHost);
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
        /*GoRoute(
          name: 'chat',
          path: 'chat/:target/:isHost',
          builder: (BuildContext context, GoRouterState state) {
            final target = state.pathParameters['target'];
            final isHost = state.pathParameters['isHost'] == 'true';
            return ChattingPage(target: target, isHost: isHost);
          },
        ),*/
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

class MyAppState extends ChangeNotifier {
  
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  MyAppState() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); 
    //print(isDark);
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = _themeMode == ThemeMode.dark;
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners(); 
  }
}


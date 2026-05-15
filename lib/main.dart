import 'package:beacon/presentation/pages/dashboard.dart';
import 'package:beacon/presentation/pages/resources.dart';
import 'package:beacon/viewmodels/ProfileViewModel.dart';
import 'package:beacon/viewmodels/add_edit_resource_viewmodel.dart';
import 'package:beacon/viewmodels/resources_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/pages/profile.dart';
import 'presentation/pages/landing_page.dart';

import 'package:go_router/go_router.dart';

import 'viewmodels/voice_viewmodel.dart';
import 'viewmodels/p2p_viewmodel.dart';
import 'viewmodels/fall_detection_viewmodel.dart';

import 'package:flutter/services.dart';

final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VoiceViewModel()),
        ChangeNotifierProvider(create: (_) => MyAppState()),
        ChangeNotifierProvider(create: (_) => P2PViewModel()),
        ChangeNotifierProvider(create: (_) => ResourcesViewModel()),
        ChangeNotifierProvider(create: (_) => AddEditResourceViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => FallDetectionViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  navigatorKey: navigatorKey,
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
            final isHost =
                state.pathParameters['isHost'] == 'true';

            return NetworkDashboardPage(
              isHost: isHost,
            );
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
        colorScheme: const ColorScheme.dark(
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

  List<String> _predefinedMessages = [
    "HELP",
    "LOCATION",
    "MEDICAL"
  ];

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  List<String> get predefinedMessages => _predefinedMessages;

  MyAppState() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();

    final isDark = prefs.getBool('isDarkMode') ?? true;

    _themeMode =
    isDark ? ThemeMode.dark : ThemeMode.light;

    _predefinedMessages =
        prefs.getStringList('predefinedMessages') ??
            ["HELP", "LOCATION", "MEDICAL"];

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    _themeMode =
    (_themeMode == ThemeMode.dark)
        ? ThemeMode.light
        : ThemeMode.dark;

    await prefs.setBool('isDarkMode', isDarkMode);

    notifyListeners();
  }

  Future<void> addPredefinedMessage(String message) async {
    if (message.isEmpty ||
        _predefinedMessages.contains(message)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    _predefinedMessages.add(message);

    await prefs.setStringList(
        'predefinedMessages', _predefinedMessages);

    notifyListeners();
  }

  Future<void> deletePredefinedMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();

    _predefinedMessages.remove(message);

    await prefs.setStringList(
        'predefinedMessages', _predefinedMessages);

    notifyListeners();
  }
}
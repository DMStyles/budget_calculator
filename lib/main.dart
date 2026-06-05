import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/budget_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);

    // Pixel UI Theme configuration (Material 3)
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121318), // Soft Charcoal
      primaryColor: const Color(0xFFA8C7FA), // Pixel Pastel Blue
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFA8C7FA),
        secondary: Color(0xFFF2B8B5), // Soft Coral/Red
        tertiary: Color(0xFFC4EED0), // Soft Mint Green
        surface: Color(0xFF1E2025), // Dark surface
        background: Color(0xFF121318),
      ),
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        color: const Color(0xFF1E2025),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F9FC), // Soft Off-white
      primaryColor: const Color(0xFF0B57D0), // Classic Pixel Blue
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0B57D0),
        secondary: Color(0xFFB3261E), // Red
        tertiary: Color(0xFF146C2E), // Green
        surface: Color(0xFFEEF0F6), // Soft grey surface
        background: Color(0xFFF8F9FC),
      ),
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        color: const Color(0xFFEEF0F6),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );

    return MaterialApp(
      title: 'Glass Budget',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: provider.themeMode,
      home: const MainNavigationHub(),
    );
  }
}

class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: isDark ? const Color(0xFF1E2025) : const Color(0xFFEEF0F6),
        indicatorColor: isDark ? const Color(0xFF004A77).withOpacity(0.4) : const Color(0xFFC2E7FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'providers/budget_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'package:flutter/services.dart';

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

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightScheme = lightDynamic.copyWith(
            surface: const Color(0xFFEEF0F6),
          );
          darkScheme = darkDynamic.copyWith(
            surface: const Color(0xFF1E2025),
          );
        } else {
          lightScheme = const ColorScheme.light(
            primary: Color(0xFF0B57D0),
            secondary: Color(0xFFB3261E), // Red
            tertiary: Color(0xFF146C2E), // Green
            surface: Color(0xFFEEF0F6), // Soft grey surface
          );
          darkScheme = const ColorScheme.dark(
            primary: Color(0xFFA8C7FA),
            secondary: Color(0xFFF2B8B5), // Soft Coral/Red
            tertiary: Color(0xFFC4EED0), // Soft Mint Green
            surface: Color(0xFF1E2025), // Dark surface
          );
        }

        final darkTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121318), // Soft Charcoal
          primaryColor: darkScheme.primary,
          colorScheme: darkScheme,
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
          primaryColor: lightScheme.primary,
          colorScheme: lightScheme,
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
      },
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
    final provider = Provider.of<BudgetProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Required for glassmorphism nav bar
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: _currentIndex == 0 ? Padding(
        padding: const EdgeInsets.only(bottom: 40.0), // Push FAB above the glass nav bar
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddTransactionScreen(),
              ),
            );
          },
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ) : null,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: isDark 
                ? const Color(0xFF1E2025).withValues(alpha: 0.8) 
                : const Color(0xFFEEF0F6).withValues(alpha: 0.8),
            indicatorColor: isDark 
                ? theme.colorScheme.primary.withValues(alpha: 0.2) 
                : theme.colorScheme.primary.withValues(alpha: 0.2),
            elevation: 0,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics_rounded),
                label: 'Reports',
              ),
              NavigationDestination(
                icon: provider.hasUpdate
                    ? Badge(
                        backgroundColor: theme.colorScheme.error,
                        child: const Icon(Icons.settings_outlined),
                      )
                    : const Icon(Icons.settings_outlined),
                selectedIcon: provider.hasUpdate
                    ? Badge(
                        backgroundColor: theme.colorScheme.error,
                        child: const Icon(Icons.settings_rounded),
                      )
                    : const Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

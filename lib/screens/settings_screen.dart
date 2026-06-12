import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../providers/budget_provider.dart';
import 'manage_categories_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '1.0.0';
  bool _isCheckingForUpdates = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      debugPrint('Error loading app version: $e');
    }
  }

  Future<void> _checkForUpdates(bool showUpToDateDialog) async {
    setState(() {
      _isCheckingForUpdates = true;
    });

    try {
      // Call GitHub API for latest release (with 30s timeout)
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/DMStyles/budget_calculator/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestTag = data['tag_name'] as String; // e.g. "v1.1.1"
        final releaseNotes = data['body'] as String? ?? 'No release notes provided.';
        final releaseUrl = data['html_url'] as String;

        // Compare versions (stripping 'v' prefix and non-numeric chars)
        final remoteVersion = latestTag.replaceAll(RegExp(r'[^\d.]'), '');
        final localVersion = _appVersion.replaceAll(RegExp(r'[^\d.]'), '');

        final isNewer = _isVersionNewer(localVersion, remoteVersion);

        if (!mounted) return;

        if (isNewer) {
          _showUpdateDialog(latestTag, releaseNotes, releaseUrl);
        } else if (showUpToDateDialog) {
          _showUpToDateDialog(latestTag);
        }
      } else if (response.statusCode == 404) {
        throw Exception('No releases found yet. Check back later.');
      } else {
        throw Exception('Server returned HTTP ${response.statusCode}. Try again later.');
      }
    } catch (e) {
      debugPrint('Error checking updates: $e');
      if (!mounted) return;
      // Show a friendly message instead of raw Dart exception text
      final String friendlyMsg;
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('timeout') || errStr.contains('timedout')) {
        friendlyMsg = 'Connection timed out. Please check your internet and try again.';
      } else if (errStr.contains('socketexception') || errStr.contains('failed host lookup') || errStr.contains('network')) {
        friendlyMsg = 'No internet connection. Please check your network and try again.';
      } else if (e is Exception) {
        friendlyMsg = e.toString().replaceFirst('Exception: ', '');
      } else {
        friendlyMsg = 'Something went wrong. Please try again later.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyMsg),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingForUpdates = false;
        });
      }
    }
  }

  bool _isVersionNewer(String current, String latest) {
    List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < latestParts.length; i++) {
      int currentVal = i < currentParts.length ? currentParts[i] : 0;
      int latestVal = latestParts[i];
      if (latestVal > currentVal) return true;
      if (latestVal < currentVal) return false;
    }
    return false;
  }

  void _showUpdateDialog(String version, String notes, String url) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Icon(Icons.system_update_rounded, color: Colors.tealAccent.shade400),
            const SizedBox(width: 12),
            const Text('Update Available!'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Version $version is now available.', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('What\'s New:', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(notes, style: const TextStyle(fontSize: 13, height: 1.4)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Later', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent.shade400,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  void _showUpToDateDialog(String version) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent.shade400),
            const SizedBox(width: 12),
            const Text('Up to Date'),
          ],
        ),
        content: Text('You are using the latest version of GlassBudget (v$version).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = isDark ? const Color(0xFF1E2025) : const Color(0xFFF0F4F9);
    final outlineColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings Group: Appearance
            _buildSectionHeader('Appearance'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: outlineColor),
              ),
              child: Column(
                children: [
                  _buildThemeOptionTile(
                    context,
                    title: 'System Default',
                    subtitle: 'Follow device settings',
                    icon: Icons.brightness_auto_rounded,
                    mode: ThemeMode.system,
                    currentMode: provider.themeMode,
                    onTap: () => provider.setThemeMode(ThemeMode.system),
                  ),
                  _buildDivider(isDark),
                  _buildThemeOptionTile(
                    context,
                    title: 'Light Theme',
                    subtitle: 'Clean white color space',
                    icon: Icons.light_mode_rounded,
                    mode: ThemeMode.light,
                    currentMode: provider.themeMode,
                    onTap: () => provider.setThemeMode(ThemeMode.light),
                  ),
                  _buildDivider(isDark),
                  _buildThemeOptionTile(
                    context,
                    title: 'Dark Theme',
                    subtitle: 'Slate/Charcoal dark mode',
                    icon: Icons.dark_mode_rounded,
                    mode: ThemeMode.dark,
                    currentMode: provider.themeMode,
                    onTap: () => provider.setThemeMode(ThemeMode.dark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Group: Categories
            _buildSectionHeader('Categories'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: outlineColor),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.category_rounded, color: Colors.purpleAccent.shade100),
                ),
                title: const Text('Manage Categories', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Add, rename, or delete categories'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ManageCategoriesScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Settings Group: Updates & Maintenance
            _buildSectionHeader('App Updates'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: outlineColor),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.shade100.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.cloud_download_rounded, color: Colors.blueAccent.shade100),
                ),
                title: const Text('Check for Updates', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(provider.hasUpdate
                    ? 'New update available: ${provider.latestVersion}'
                    : 'Current version: v$_appVersion'),
                trailing: _isCheckingForUpdates
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.tealAccent),
                      )
                    : (provider.hasUpdate
                        ? Icon(Icons.info_outline, color: theme.colorScheme.error)
                        : const Icon(Icons.chevron_right_rounded)),
                onTap: _isCheckingForUpdates
                    ? null
                    : () {
                        if (provider.hasUpdate) {
                          _showUpdateDialog(
                            provider.latestVersion,
                            provider.updateNotes,
                            provider.updateUrl,
                          );
                        } else {
                          _checkForUpdates(true);
                        }
                      },
              ),
            ),
            const SizedBox(height: 24),

            // Settings Group: About
            _buildSectionHeader('About Glass Budget'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: outlineColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.tealAccent.shade400,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.pie_chart_rounded, color: Colors.black, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Glass Budget',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            'v$_appVersion - Offline First',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'A premium offline budget tracker built with Flutter, designed with a Google Pixel-inspired Material You interface. Easily monitor earnings, manage expenses, allocate monthly savings, and browse visual analytics sheets.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse('https://github.com/DMStyles/budget_calculator');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.code_rounded),
                      label: const Text('View Project on GitHub'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black,
                        side: BorderSide(color: outlineColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildThemeOptionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? colorScheme.primary : Colors.grey,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      endIndent: 20,
      color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
    );
  }
}

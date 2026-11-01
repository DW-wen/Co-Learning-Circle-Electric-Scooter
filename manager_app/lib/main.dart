import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/strings.dart';
import 'screens/dashboard_shell.dart';
import 'wireframe/wire.dart';

void main() => runApp(const ManagerApp());

/// Campus Security Team (駐警隊) monitoring dashboard (desktop),
/// Traditional Chinese (Taiwan).
class ManagerApp extends StatelessWidget {
  const ManagerApp({super.key});

  /// zh-Hant-TW. Script + region also make Flutter pick Traditional-Chinese
  /// glyph variants from the system fonts.
  static const Locale zhTW =
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW');

  @override
  Widget build(BuildContext context) {
    return ThemeHost(
      builder: (context, theme) => MaterialApp(
        title: S.appTitle,
        debugShowCheckedModeBanner: false,
        locale: zhTW,
        supportedLocales: const [zhTW],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: theme,
        // Tokens switch instantly, so skip the theme cross-fade.
        themeAnimationDuration: Duration.zero,
        home: const DashboardShell(),
      ),
    );
  }
}

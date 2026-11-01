import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/strings.dart';
import 'screens/home_shell.dart';
import 'wireframe/wire.dart';

void main() => runApp(const UserApp());

/// Student app (mobile), Traditional Chinese (Taiwan).
/// On a wide window (desktop / Chrome) the UI is constrained to phone width
/// so the layout can be reviewed as on a phone.
class UserApp extends StatelessWidget {
  const UserApp({super.key});

  static const double phoneMaxWidth = 430;

  /// zh-Hant-TW. Setting the script + region (not just "zh") also makes
  /// Flutter pick Traditional-Chinese glyph variants from the system fonts.
  static const Locale zhTW =
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: S.appTitle,
      debugShowCheckedModeBanner: false,
      locale: zhTW,
      supportedLocales: const [zhTW],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
        scaffoldBackgroundColor: Wf.bg,
      ),
      builder: (context, child) => ColoredBox(
        color: Wf.fill,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: phoneMaxWidth),
            child: child,
          ),
        ),
      ),
      home: const HomeShell(),
    );
  }
}

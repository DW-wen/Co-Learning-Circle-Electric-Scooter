// Visual theme: two palettes + Material ThemeData + light/dark switch.
//
//   Light — warm paper & copper (neo-skeuomorphic style-guide reference)
//   Dark  — deep navy, sand, slate & grey-blue ("twinkle" reference)
//
// Colour tokens (Wf.*) and text styles (Tx.*) are read at build time from the
// active palette, so every widget follows the current mode. This file is
// identical in user_app and manager_app.

import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../l10n/strings.dart';

/// One complete colour set.
class Palette {
  const Palette({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.fill,
    required this.border,
    required this.text,
    required this.muted,
    required this.primary,
    required this.onPrimary,
    required this.ok,
    required this.warn,
    required this.bad,
    required this.info,
    required this.shadow,
  });

  final Brightness brightness;

  /// Page background.
  final Color bg;

  /// Cards, sheets, bars.
  final Color surface;

  /// Inset areas: placeholders, table headers, input fill.
  final Color fill;
  final Color border;
  final Color text;
  final Color muted;

  /// Accent: copper (light) / sand (dark).
  final Color primary;
  final Color onPrimary;
  final Color ok;
  final Color warn;
  final Color bad;
  final Color info;

  /// Card shadow (transparent in dark mode — borders carry the edges there).
  final Color shadow;

  /// Warm paper + copper.
  static const Palette light = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFEFE9E1),
    surface: Color(0xFFFAF7F2),
    fill: Color(0xFFE9E2D8),
    border: Color(0xFFDDD3C6),
    text: Color(0xFF3A332F),
    muted: Color(0xFF7A6F66),
    primary: Color(0xFFAD6442),
    onPrimary: Color(0xFFFFFFFF),
    ok: Color(0xFF5B8A67),
    warn: Color(0xFFB7832A),
    bad: Color(0xFFB4473A),
    info: Color(0xFF4E6C8A),
    shadow: Color(0x1F6B5440),
  );

  /// Navy + sand + slate + grey-blue.
  static const Palette dark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF1C1F2B),
    surface: Color(0xFF262A39),
    fill: Color(0xFF30364A),
    border: Color(0xFF3B4257),
    text: Color(0xFFE9E3DA),
    muted: Color(0xFF8E9BA5),
    primary: Color(0xFFC49B76),
    onPrimary: Color(0xFF1C1F2B),
    ok: Color(0xFF8DBB98),
    warn: Color(0xFFDDB46B),
    bad: Color(0xFFE38277),
    info: Color(0xFF93AECB),
    shadow: Color(0x00000000),
  );
}

/// Colour tokens of the active palette.
class Wf {
  Wf._();

  static Palette _p = Palette.light;
  static Palette get palette => _p;
  static void use(Palette p) => _p = p;
  static bool get isDark => _p.brightness == Brightness.dark;

  static Color get bg => _p.bg;
  static Color get surface => _p.surface;
  static Color get fill => _p.fill;
  static Color get border => _p.border;
  static Color get text => _p.text;
  static Color get muted => _p.muted;
  static Color get primary => _p.primary;
  static Color get onPrimary => _p.onPrimary;
  static Color get ok => _p.ok;
  static Color get warn => _p.warn;
  static Color get bad => _p.bad;
  static Color get info => _p.info;
  static Color get shadow => _p.shadow;

  /// Soft tinted background for a semantic colour (badges, banners, chips).
  static Color tint(Color c) => c.withAlpha(isDark ? 44 : 30);
}

/// Text styles of the active palette.
class Tx {
  Tx._();

  static TextStyle get label => TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Wf.muted,
      letterSpacing: 0.6);
  static TextStyle get muted => TextStyle(fontSize: 13, color: Wf.muted);
  static TextStyle get small =>
      TextStyle(fontSize: 12, color: Wf.muted, height: 1.4);
  static TextStyle get body =>
      TextStyle(fontSize: 14, color: Wf.text, height: 1.4);
  static TextStyle get bold =>
      TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Wf.text);
  static TextStyle get title =>
      TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Wf.text);

  /// Big numbers (timers, KPIs): tabular digits so they don't jitter.
  static TextStyle number(double size, Color color) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

/// Material theme derived from a [Palette].
ThemeData buildTheme(Palette p) {
  final dark = p.brightness == Brightness.dark;
  final tint = Color.alphaBlend(p.primary.withAlpha(dark ? 56 : 40), p.surface);
  final radius12 = BorderRadius.circular(12);
  bool sel(Set<WidgetState> s) => s.contains(WidgetState.selected);

  final scheme = ColorScheme(
    brightness: p.brightness,
    primary: p.primary,
    onPrimary: p.onPrimary,
    primaryContainer: tint,
    onPrimaryContainer: p.text,
    secondary: p.primary,
    onSecondary: p.onPrimary,
    secondaryContainer: tint,
    onSecondaryContainer: p.text,
    tertiary: p.info,
    onTertiary: p.onPrimary,
    error: p.bad,
    onError: dark ? p.onPrimary : Colors.white,
    surface: p.surface,
    onSurface: p.text,
    onSurfaceVariant: p.muted,
    surfaceContainerLowest: p.surface,
    surfaceContainerLow: p.surface,
    surfaceContainer: p.surface,
    surfaceContainerHigh: p.surface,
    surfaceContainerHighest: p.fill,
    outline: p.border,
    outlineVariant: p.border,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: p.text,
    onInverseSurface: p.surface,
    inversePrimary: p.primary,
    surfaceTint: Colors.transparent,
  );

  final outline = OutlineInputBorder(
    borderRadius: radius12,
    borderSide: BorderSide(color: p.border),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: p.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.bg,
    canvasColor: p.surface,
    dividerColor: p.border,
    // System CJK fonts per platform (macOS/iOS, Android/Linux, Windows).
    fontFamilyFallback: const ['PingFang TC', 'Noto Sans TC', 'Microsoft JhengHei'],
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, color: p.text),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 68,
      indicatorColor: tint,
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontSize: 12,
            fontWeight: sel(s) ? FontWeight.w700 : FontWeight.w500,
            color: sel(s) ? p.text : p.muted,
          )),
      iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: sel(s) ? p.primary : p.muted)),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: p.surface,
      indicatorColor: tint,
      selectedIconTheme: IconThemeData(color: p.primary),
      unselectedIconTheme: IconThemeData(color: p.muted),
      selectedLabelTextStyle: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700, color: p.text),
      unselectedLabelTextStyle: TextStyle(fontSize: 14, color: p.muted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: radius12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.text,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(borderRadius: radius12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStatePropertyAll(BorderSide(color: p.border)),
        shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: radius12)),
        backgroundColor: WidgetStateProperty.resolveWith(
            (s) => sel(s) ? p.primary : p.surface),
        foregroundColor: WidgetStateProperty.resolveWith(
            (s) => sel(s) ? p.onPrimary : p.text),
        textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surface,
      selectedColor: tint,
      showCheckmark: false,
      shape: const StadiumBorder(),
      side: WidgetStateBorderSide.resolveWith((s) =>
          BorderSide(color: sel(s) ? p.primary : p.border)),
      labelStyle: TextStyle(fontSize: 13, color: p.text),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color.alphaBlend(p.fill.withAlpha(110), p.surface),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: outline,
      enabledBorder: outline,
      disabledBorder: outline,
      focusedBorder: OutlineInputBorder(
        borderRadius: radius12,
        borderSide: BorderSide(color: p.primary, width: 1.6),
      ),
      labelStyle: TextStyle(color: p.muted),
      floatingLabelStyle: TextStyle(color: p.primary),
      hintStyle: TextStyle(color: p.muted),
      prefixIconColor: p.muted,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700, color: p.text),
      contentTextStyle: TextStyle(fontSize: 14, color: p.text, height: 1.5),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      dragHandleColor: p.border,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: radius12),
      textStyle: TextStyle(fontSize: 14, color: p.text),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.text,
      contentTextStyle: TextStyle(fontSize: 14, color: p.surface),
      actionTextColor: p.primary,
      shape: RoundedRectangleBorder(borderRadius: radius12),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
          color: p.text, borderRadius: BorderRadius.circular(8)),
      textStyle: TextStyle(fontSize: 12, color: p.surface),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => sel(s) ? p.onPrimary : p.muted),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => sel(s) ? p.primary : p.fill),
      trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => sel(s) ? Colors.transparent : p.border),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.primary,
      linearTrackColor: p.fill,
    ),
    dividerTheme: DividerThemeData(color: p.border, thickness: 1),
    listTileTheme: ListTileThemeData(
      iconColor: p.muted,
      textColor: p.text,
      selectedColor: p.primary,
      selectedTileColor: tint,
    ),
    dataTableTheme: DataTableThemeData(
      headingTextStyle: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700, color: p.muted),
      dataTextStyle: TextStyle(fontSize: 13, color: p.text),
      dividerThickness: 1,
    ),
    badgeTheme: BadgeThemeData(
      backgroundColor: p.bad,
      textColor: dark ? p.onPrimary : Colors.white,
    ),
  );
}

// ------------------------------------------------------------- mode switch

/// Holds light/dark mode at the app root. Starts from the system setting.
/// [builder] receives the ThemeData for the active palette.
class ThemeHost extends StatefulWidget {
  const ThemeHost({super.key, required this.builder});

  final Widget Function(BuildContext context, ThemeData theme) builder;

  @override
  State<ThemeHost> createState() => _ThemeHostState();
}

class _ThemeHostState extends State<ThemeHost> {
  late bool _dark;

  @override
  void initState() {
    super.initState();
    _dark = WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
    Wf.use(_dark ? Palette.dark : Palette.light);
  }

  void _toggle() {
    setState(() {
      _dark = !_dark;
      Wf.use(_dark ? Palette.dark : Palette.light);
    });
    // Tokens are read at build time, so rebuild the whole tree (including
    // const widgets) once; app state lives in State objects and is kept.
    void mark(Element e) {
      e.markNeedsBuild();
      e.visitChildren(mark);
    }

    (context as Element).visitChildren(mark);
  }

  @override
  Widget build(BuildContext context) => _ThemeScope(
        dark: _dark,
        toggle: _toggle,
        child: widget.builder(context, buildTheme(Wf.palette)),
      );
}

class _ThemeScope extends InheritedWidget {
  const _ThemeScope({
    required this.dark,
    required this.toggle,
    required super.child,
  });

  final bool dark;
  final VoidCallback toggle;

  @override
  bool updateShouldNotify(_ThemeScope old) => dark != old.dark;
}

/// Sun / moon button that flips light <-> dark.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ThemeScope>();
    if (scope == null) return const SizedBox.shrink();
    return IconButton(
      tooltip: scope.dark ? S.themeToLight : S.themeToDark,
      icon: Icon(
        scope.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        color: Wf.muted,
      ),
      onPressed: scope.toggle,
    );
  }
}

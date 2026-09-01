import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme.dart';
import 'providers/preferences_providers.dart';
import 'router/app_router.dart';

/// 应用根 Widget。
class ZhiHengApp extends ConsumerWidget {
  const ZhiHengApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final palette =
        ref.watch(accentPaletteProvider).value ?? AccentPalettes.ocean;

    return MaterialApp.router(
      title: '知衡',
      debugShowCheckedModeBanner: false,
      locale: const Locale('zh', 'CN'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN')],
      theme: AppTheme.light(palette),
      darkTheme: AppTheme.dark(palette),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

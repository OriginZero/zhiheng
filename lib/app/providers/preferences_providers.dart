import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import 'core_providers.dart';

/// 偏好键：主题模式。
const String _themeModeKey = 'theme_mode';

/// 偏好键：强调色主题（iOS 26 tint 风格）。
const String _accentPaletteKey = 'accent_palette';

/// 主题模式（跟随系统 / 亮色 / 暗色），持久化到本地偏好。
class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final repo = ref.watch(repositoryProvider);
    final stored = await repo.readPreference(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  /// 切换主题模式并持久化。
  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncData(mode);
    final repo = ref.read(repositoryProvider);
    await repo.writePreference(_themeModeKey, mode.name);
  }
}

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// 强调色主题（5 套 iOS 26 风格 tint），持久化到本地偏好。
class AccentPaletteNotifier extends AsyncNotifier<AccentPalette> {
  @override
  Future<AccentPalette> build() async {
    final repo = ref.watch(repositoryProvider);
    final stored = await repo.readPreference(_accentPaletteKey);
    return AccentPalettes.byId(stored);
  }

  /// 切换强调色并持久化。
  Future<void> setPalette(AccentPalette palette) async {
    state = AsyncData(palette);
    final repo = ref.read(repositoryProvider);
    await repo.writePreference(_accentPaletteKey, palette.id);
  }
}

final accentPaletteProvider =
    AsyncNotifierProvider<AccentPaletteNotifier, AccentPalette>(
  AccentPaletteNotifier.new,
);

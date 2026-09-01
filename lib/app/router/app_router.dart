import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/timeline/timeline_page.dart';
import '../../shared/widgets/glass/glass.dart';

/// 路由路径常量（禁止散落的魔法字符串）。
abstract final class AppRoutes {
  static const String home = '/';
  static const String timeline = '/timeline';
  static const String settings = '/settings';
}

/// 全局路由（开发文档 §17）。
///
/// 三个主页面共享玻璃导航壳。
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: AppRoutes.timeline,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TimelinePage()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsPage()),
          ),
        ],
      ),
    ],
  );
});

/// 玻璃导航壳：Level 1 背景 + 内容 + 悬浮导航。
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _navItems = [
    GlassNavItem(
      icon: Icons.today_outlined,
      activeIcon: Icons.today,
      label: '今日',
    ),
    GlassNavItem(
      icon: Icons.timeline_outlined,
      activeIcon: Icons.timeline,
      label: '时间线',
    ),
    GlassNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: '我的',
    ),
  ];

  int _indexFor(String location) {
    if (location.startsWith(AppRoutes.timeline)) return 1;
    if (location.startsWith(AppRoutes.settings)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _indexFor(location);

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: child),
        bottomNavigationBar: GlassNavigation(
          items: _navItems,
          selectedIndex: selectedIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go(AppRoutes.home);
              case 1:
                context.go(AppRoutes.timeline);
              case 2:
                context.go(AppRoutes.settings);
            }
          },
        ),
      ),
    );
  }
}

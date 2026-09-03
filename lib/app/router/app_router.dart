import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/disease/disease_detail_page.dart';
import '../../features/disease/diseases_page.dart';
import '../../features/home/home_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/timeline/timeline_page.dart';
import '../../features/diabetes/diabetes_page.dart';

import '../../shared/widgets/glass/glass.dart';

/// 路由路径常量（禁止散落的魔法字符串）。
abstract final class AppRoutes {
  static const String home = '/';
  static const String timeline = '/timeline';
  static const String settings = '/settings';
  static const String diseases = '/diseases';
  static const String diabetes = '/disease/:id/diabetes';

  static const String diseaseDetail = '/disease/:id';
}

/// 全局路由（开发文档 §17）。
///
/// 三个主页面共享玻璃导航壳；疾病页为独立路由。
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
      GoRoute(
        path: AppRoutes.diseases,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: GlassBackground(child: DiseasesPage()),
        ),
      ),
      GoRoute(
        path: AppRoutes.diseaseDetail,
        pageBuilder: (context, state) => NoTransitionPage(
          child: GlassBackground(
            child: DiseaseDetailPage(
              diseaseId: state.pathParameters['id']!,
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.diabetes,
        pageBuilder: (context, state) => NoTransitionPage(
          child: GlassBackground(
            child: DiabetesPage(
              diseaseId: state.pathParameters['id']!,
            ),
          ),
        ),
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

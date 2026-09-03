import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/disease/disease_detail_page.dart';
import '../../features/disease/diseases_page.dart';
import '../../features/home/home_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/timeline/timeline_page.dart';
import '../../features/diabetes/diabetes_page.dart';

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
/// 三个主页面共享 M3 NavigationBar 导航壳；疾病页为独立路由，
/// 页面自带 Scaffold。
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
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: DiseasesPage()),
      ),
      GoRoute(
        path: AppRoutes.diseaseDetail,
        pageBuilder: (context, state) => NoTransitionPage(
          child: DiseaseDetailPage(diseaseId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.diabetes,
        pageBuilder: (context, state) => NoTransitionPage(
          child: DiabetesPage(diseaseId: state.pathParameters['id']!),
        ),
      ),
    ],
  );
});

/// M3 导航壳：Scaffold + 官方 NavigationBar。
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.today_outlined),
      selectedIcon: Icon(Icons.today),
      label: '今日',
    ),
    NavigationDestination(
      icon: Icon(Icons.timeline_outlined),
      selectedIcon: Icon(Icons.timeline),
      label: '时间线',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
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

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
            case 1:
              context.go(AppRoutes.timeline);
            case 2:
              context.go(AppRoutes.settings);
          }
        },
        destinations: _destinations,
      ),
    );
  }
}

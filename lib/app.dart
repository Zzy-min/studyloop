import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/corgi_chat_screen.dart';
import 'presentation/screens/entry_screen.dart';
import 'presentation/screens/welcome_screen.dart';
import 'presentation/screens/focus_screen.dart';
import 'presentation/screens/history_detail_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/insights_screen.dart';
import 'presentation/screens/paywall_screen.dart';
import 'presentation/screens/reflection_screen.dart';
import 'presentation/screens/rest_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/start_card_screen.dart';
import 'presentation/screens/summary_screen.dart';
import 'presentation/screens/task_screen.dart';
import 'presentation/widgets/main_shell.dart';
import 'presentation/theme/app_theme.dart';
import 'providers.dart';

export 'presentation/screens/entry_screen.dart';
export 'presentation/screens/welcome_screen.dart';
export 'presentation/screens/focus_screen.dart';
export 'presentation/screens/history_detail_screen.dart';
export 'presentation/screens/history_screen.dart';
export 'presentation/screens/insights_screen.dart';
export 'presentation/screens/paywall_screen.dart';
export 'presentation/screens/reflection_screen.dart';
export 'presentation/screens/rest_screen.dart';
export 'presentation/screens/settings_screen.dart';
export 'presentation/screens/start_card_screen.dart';
export 'presentation/screens/summary_screen.dart';
export 'presentation/screens/task_screen.dart';
export 'presentation/theme/app_theme.dart';
export 'presentation/widgets/companion_card.dart';
export 'presentation/widgets/page_frame.dart';

class StudyLoopApp extends ConsumerStatefulWidget {
  const StudyLoopApp({super.key});

  @override
  ConsumerState<StudyLoopApp> createState() => _StudyLoopAppState();
}

class _StudyLoopAppState extends ConsumerState<StudyLoopApp>
    with WidgetsBindingObserver {
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final rootKey = GlobalKey<NavigatorState>();
    router = GoRouter(
      navigatorKey: rootKey,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const EntryScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/history',
                  builder: (context, state) => const HistoryScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/insights',
                  builder: (context, state) => const InsightsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          parentNavigatorKey: rootKey,
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootKey,
          path: '/chat',
          builder: (context, state) => const CorgiChatScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootKey,
          path: '/task',
          builder: (context, state) => const TaskScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootKey,
          path: '/card',
          builder: (context, state) => const StartCardScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootKey,
          path: '/focus',
          builder: (context, state) => const FocusScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootKey,
          path: '/reflection',
          builder: (context, state) => const ReflectionScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootKey,
          path: '/summary',
          builder: (context, state) => const SummaryScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootKey,
          path: '/history/:id',
          builder: (context, state) =>
              HistoryDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          parentNavigatorKey: rootKey,
          path: '/paywall',
          builder: (context, state) => const PaywallScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootKey,
          path: '/rest',
          builder: (context, state) => const RestScreen(),
        ),
      ],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await ref.read(timerProvider.notifier).restore() && mounted) {
        _showRecovery();
      }
    });
  }

  Future<void> _showRecovery() async {
    final strings = ref.read(stringsProvider);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(strings.recoveryTitle),
        content: Text(strings.recoveryContent),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(timerProvider.notifier).finishEarly();
              if (context.mounted) {
                Navigator.pop(context);
                router.go('/reflection');
              }
            },
            child: Text(strings.saveFocusedTime),
          ),
          FilledButton(
            onPressed: () {
              ref.read(timerProvider.notifier).continueSession();
              Navigator.pop(context);
              router.go('/focus');
            },
            child: Text(strings.recoveryContinue),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final timer = ref.read(timerProvider.notifier);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      timer.pauseForLifecycle();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      final current = ref.read(timerProvider);
      if (current.snapshot != null &&
          current.outcome == null &&
          !current.running &&
          !current.pausedByUser &&
          !current.needsRecovery) {
        timer.continueSession();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final strings = ref.watch(stringsProvider);

    return MaterialApp.router(
      title: strings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: Locale(currentLocale.startsWith('zh') ? 'zh' : 'en'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      routerConfig: router,
    );
  }
}

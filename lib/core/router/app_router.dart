import 'package:go_router/go_router.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/analysis_screen.dart';
import '../../presentation/screens/rewrite_screen.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/entities/rewrite_result.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/analysis',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! AnalysisResult) {
            return const HomeScreen(); // Fallback for direct URL access
          }
          return AnalysisScreen(result: extra);
        },
      ),
      GoRoute(
        path: '/rewrite',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! RewriteResult) {
            return const HomeScreen(); // Fallback
          }
          return RewriteScreen(
            analysisResult: extra.originalResult,
            rewrittenText: extra.rewrittenText,
          );
        },
      ),
    ],
  );
}

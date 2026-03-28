import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/repositories/analysis_repository_impl.dart';
import 'data/services/mock_analysis_service.dart';
import 'domain/usecases/analyze_text_use_case.dart';
import 'domain/usecases/rewrite_text_use_case.dart';
import 'presentation/bloc/analysis_cubit.dart';

void main() {
  final service = MockAnalysisService();
  final repository = AnalysisRepositoryImpl(service);
  final analyzeUseCase = AnalyzeTextUseCase(repository);
  final rewriteUseCase = RewriteTextUseCase(repository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AnalysisCubit(
            analyzeUseCase: analyzeUseCase,
            rewriteUseCase: rewriteUseCase,
          ),
        ),
      ],
      child: const DeHumaniseApp(),
    ),
  );
}

class DeHumaniseApp extends StatelessWidget {
  const DeHumaniseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Humanise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}

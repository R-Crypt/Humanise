import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/entities/rewrite_result.dart';
import '../bloc/analysis_cubit.dart';
import '../../core/theme/app_theme.dart';

class AnalysisScreen extends StatelessWidget {
  final AnalysisResult result;

  const AnalysisScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final aiPercent = result.aiPercentage;
    final plagiarismPercent = result.plagiarismPercentage;

    Color getStatusColor(double percent) {
      if (percent < 0.3) return AppTheme.secondary;
      if (percent < 0.7) return Colors.amber;
      return Colors.redAccent;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<AnalysisCubit>().reset();
            context.go('/');
          },
        ),
        title: const Text('Analysis Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                // Score Cards Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ScoreCard(
                      label: 'AI Content',
                      percent: aiPercent,
                      color: getStatusColor(aiPercent),
                      isCircular: true,
                    ),
                    _ScoreCard(
                      label: 'Plagiarism',
                      percent: plagiarismPercent,
                      color: getStatusColor(plagiarismPercent),
                      isCircular: true,
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),

                const SizedBox(height: 60),

                // Flagged Sentences
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Potentially Flagged Sections',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: result.flaggedSentences.isEmpty
                        ? [const Text('No major flags found. Your content looks clean.')]
                        : result.flaggedSentences.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              border: Border(left: BorderSide(color: Colors.redAccent, width: 4)),
                            ),
                            child: Text(s, style: const TextStyle(height: 1.5)),
                          ),
                        )).toList(),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                const SizedBox(height: 60),

                // Actions
                BlocConsumer<AnalysisCubit, AnalysisState>(
                  listener: (context, state) {
                    if (state is RewriteSuccess) {
                      context.go('/rewrite', extra: RewriteResult(
                        originalResult: state.originalResult,
                        rewrittenText: state.rewrittenText,
                      ));
                    }
                  },
                  builder: (context, state) {
                    final isRewriting = state is RewriteLoading;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            context.read<AnalysisCubit>().reset();
                            context.go('/');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primary),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: const Text('Start Over'),
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton(
                          onPressed: isRewriting
                              ? null
                              : () => context.read<AnalysisCubit>().rewrite(result),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: Row(
                            children: [
                              if (isRewriting)
                                const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  ),
                                ),
                              const Text('Humanise & De-Plagiarise'),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  final bool isCircular;

  const _ScoreCard({
    required this.label,
    required this.percent,
    required this.color,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 80.0,
            lineWidth: 12.0,
            animation: true,
            percent: percent,
            center: Text(
              '${(percent * 100).toInt()}%',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
            footer: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: color,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
          ),
        ],
      ),
    );
  }
}

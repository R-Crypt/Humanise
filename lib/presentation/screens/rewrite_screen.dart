import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_saver/file_saver.dart' as file_saver;
import 'dart:typed_data';
import 'dart:convert';
import '../../domain/entities/analysis_result.dart';
import '../bloc/analysis_cubit.dart';
import '../../core/theme/app_theme.dart';

class RewriteScreen extends StatelessWidget {
  final AnalysisResult analysisResult;
  final String rewrittenText;

  const RewriteScreen({
    super.key,
    required this.analysisResult,
    required this.rewrittenText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Humanized Content'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/analysis', extra: analysisResult),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Results summary badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ResultBadge(label: 'New AI %', value: '4%', color: AppTheme.secondary),
                    const SizedBox(width: 16),
                    _ResultBadge(label: 'New Plagiarism %', value: '0%', color: AppTheme.secondary),
                  ],
                ).animate().fadeIn(),
                
                const SizedBox(height: 40),
                
                // Diff View
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Original
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ORIGINAL', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surface.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              analysisResult.originalText,
                              style: const TextStyle(color: AppTheme.textSecondary, height: 1.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Rewritten
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('REWRITTEN', style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.secondary.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  rewrittenText,
                                  style: const TextStyle(height: 1.6),
                                ),
                                const Divider(height: 40),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: rewrittenText));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Copied to clipboard')),
                                        );
                                      },
                                      icon: const Icon(Icons.copy, size: 18),
                                      label: const Text('Copy'),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        try {
                                          final bytes = Uint8List.fromList(utf8.encode(rewrittenText));
                                          await file_saver.FileSaver.instance.saveFile(
                                            name: 'humanized_content',
                                            bytes: bytes,
                                            fileExtension: 'txt',
                                            mimeType: file_saver.MimeType.text,
                                          );
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Download started')),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error: $e')),
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.download, size: 18),
                                      label: const Text('Download'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: 0.05),
                
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () {
                    context.read<AnalysisCubit>().reset();
                    context.go('/');
                  },
                  child: const Text('Finalize & Exit'),
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

class _ResultBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

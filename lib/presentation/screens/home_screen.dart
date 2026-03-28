import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:typed_data';
import '../../core/utils/document_parser.dart';
import '../bloc/analysis_cubit.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Humanise',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 64,
                    letterSpacing: -2,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1),
                const SizedBox(height: 12),
                Text(
                  'Bypass AI detection and ensure originality with precision.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 20,
                    color: AppTheme.textSecondary,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
                const SizedBox(height: 60),
                
                // Input Area
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _controller,
                        maxLines: 12,
                        decoration: const InputDecoration(
                          hintText: 'Paste your text here or upload a document...',
                          contentPadding: EdgeInsets.all(24),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primary.withValues(alpha: 0.5),
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    final result = await file_picker.FilePicker.platform.pickFiles(
                                      type: file_picker.FileType.custom,
                                      allowedExtensions: ['txt', 'docx'],
                                    );
                                    if (result != null && result.files.isNotEmpty) {
                                      final file = result.files.first;
                                      if (file.bytes != null) {
                                        final content = DocumentParser.extractText(
                                          Uint8List.fromList(file.bytes!),
                                          file.extension ?? 'txt',
                                        );
                                        setState(() {
                                          _controller.text = content;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Could not read file content.')),
                                        );
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: const Column(
                                      children: [
                                        Icon(Icons.upload_file, color: AppTheme.primary),
                                        SizedBox(height: 8),
                                        Text('Upload DOCX, PDF, or TXT'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms).scale(begin: const Offset(0.98, 0.98)),

                const SizedBox(height: 40),
                
                // CTA
                BlocConsumer<AnalysisCubit, AnalysisState>(
                  listener: (context, state) {
                    if (state is AnalysisSuccess) {
                      context.go('/analysis', extra: state.result);
                    } else if (state is AnalysisFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is AnalysisLoading;
                    return ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) {
                        return ElevatedButton(
                          onPressed: isLoading || _controller.text.isEmpty
                              ? null
                              : () => context.read<AnalysisCubit>().analyze(_controller.text),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLoading)
                                const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  ),
                                ),
                              Text(isLoading ? 'Analyzing...' : 'Analyze Text'),
                            ],
                          ),
                        );
                      },
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

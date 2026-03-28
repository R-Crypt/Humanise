import 'package:equatable/equatable.dart';

class AnalysisResult extends Equatable {
  final String originalText;
  final double aiPercentage;
  final double plagiarismPercentage;
  final List<String> flaggedSentences;

  const AnalysisResult({
    required this.originalText,
    required this.aiPercentage,
    required this.plagiarismPercentage,
    required this.flaggedSentences,
  });

  @override
  List<Object?> get props => [
        originalText,
        aiPercentage,
        plagiarismPercentage,
        flaggedSentences,
      ];
}

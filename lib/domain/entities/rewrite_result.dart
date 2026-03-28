import 'analysis_result.dart';

class RewriteResult {
  final AnalysisResult originalResult;
  final String rewrittenText;

  RewriteResult({
    required this.originalResult,
    required this.rewrittenText,
  });
}
